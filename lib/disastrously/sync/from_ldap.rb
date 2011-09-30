# Copyright 2011 Redpill-Linpro AS.
#
# This file is part of Disastrously.
#
# Disastrously is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# Disastrously is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Disastrously. If not, see <http://www.gnu.org/licenses/>.

#
# Code for syncing LDAP information into PostgreSQL, used to sync information
# about customers, customer groups and users into Disastrously.
#
# This code is executed via disastrously:sync:from_ldap rake task.
#
require 'yaml'
require 'net-ldap'

module FromLDAPHelpers
  private

  # Use LDAP search base & filter config corresponding to given model symbol
  # and yield each entry to given block.
  def ldap_search(model)
    config = @config[:search][model]
    filter = Net::LDAP::Filter.construct(config[:filter])

    @ldap.search(:base => config[:base], :filter => filter) do |entry|
      yield(entry) if block_given?
    end
  end

  # Map attributes in given ldap_entry to correct model attribute names.
  def sql_attrs_for(model, ldap_entry)
    @config[:sync][model.to_sym].inject({}) do |hash, (sql_col, ldap_col)|
      if @singles[model.to_sym].key? sql_col
        hash[sql_col] = [ldap_entry[ldap_col]].flatten.first
      else
        hash[sql_col] = ldap_entry[ldap_col]
      end

    hash
    end
  end

  # Callbacks activated before each record of the given type is saved. The
  # information fetched from ldap is given as trailing argument:

  def before_user_save(record, ldap_entry)
  end

  def before_group_save(record, ldap_entry)
  end

  def before_customer_save(record, ldap_entry)
    extra =
      if (sla_mail = ldap_entry[:linproslamail]).to_s.chars.any?
        "(Messages go to %s)" % sla_mail
      else
        "(linproSLAmail not set)"
      end

    record.description = [record.description, extra].compact.join(" ")
  end

  def before_membership_save(record, customer_entry, group_entry)
  end
end

module FromLDAPActions
  private

  # We need to store the created_at field for each group membership
  # to make sure new customers do not inherit old incidents from the
  # already existing groups.
  def store_group_memberships
    puts %(Storing group_memberships in in-memory-cache: id, parent_id and created_at ...)

    @group_memberships = {}
    GroupMembership.find_each do |gm|
      symbols_as_keys = gm.attributes.inject({}) {|hash, (k, v)| hash[k.to_sym] = v; hash}
      @group_memberships[[gm.group_id, gm.parent_id]] = symbols_as_keys
    end
  end

  def delete_group_memberships
    puts %(Deleting group_memberships rows ...)
    incr :group_membership, :delete, GroupMembership.count
    GroupMembership.delete_all
  end

  def delete_groups
    puts %(Deleting groups rows ...)
    incr :group, :delete, Group.count
    Group.delete_all
  end

  def update_users
    puts %(Updating users from LDAP ...)

    ldap_search(:user) do |entry|
      puts %(>> Trying user '%s' ...) % entry.dn if verbose
      next unless sql_id = [entry[:uidnumber]].flatten.first and username = [entry[:uid]].flatten.first

      if user = User.find_by_id_and_username(sql_id, username)

        # Force update of all possible attributes.
        user.send(:attributes=, sql_attrs_for(:user, entry), :guard_protected_attributes => false)
        before_user_save(user, entry)
        puts %(   => User exists, updating ... %s) % user.inspect if verbose

        if user.save
          incr :user, :update
        else
          incr :user, :error
          $stderr.puts "WARN: Failed to update user:", user.attributes.inspect, user.errors.full_messages, entry.inspect, ""
        end

      elsif user = User.find_by_id(sql_id)
        $stderr.puts "WARN: The sql_id/uidNumber '#{sql_id}' is not available. Is the uidNumber re-used with a new username?"

      else
        attrs = @config[:default][:user].clone
        attrs.merge! sql_attrs_for(:user, entry)

        user = User.new
        user.send(:attributes=, attrs, :guard_protected_attributes => false)

        # The ID is special and always needs to be set explicitly:
        user.id = attrs[:id]

        before_user_save(user, entry)
        puts %(   => User is new, creating ... %s) % user.inspect if verbose

        if user.save
          incr :user, :create
        else
          incr :user, :error
          $stderr.puts "WARN: Failed to create user:", user.attributes.inspect, user.errors.full_messages, entry.inspect, ""
        end
      end
    end
  end

  def add_ldap_customers
    puts %(Adding all customers from LDAP into groups table ...)

    ldap_search(:customer) do |entry|
      attrs = @config[:default][:customer].clone
      attrs.merge! sql_attrs_for(:customer, entry)

      group = Group.new(attrs)
      before_customer_save(group, entry)
      puts %(>> Creating customer '%s' ... %s) % [attrs[:name], inspect(entry)] if verbose

      if group.save
        incr :group, :create
      else
        incr :group, :error
        raise "ERROR: Failed to create group:", group.attributes.inspect, group.errors.full_messages, entry.inspect, ""
      end
    end
  end

  def add_ldap_groups
    puts %(Adding all customers groups from LDAP into groups table ...)

    ldap_search(:group) do |entry|
      attrs = @config[:default][:group].clone
      attrs.merge! sql_attrs_for(:group, entry)

      group = Group.new(attrs)
      before_group_save(group, entry)
      puts %(>> Creating group '%s' ... %s) % [attrs[:name], inspect(entry)] if verbose

      if group.save
        incr :group, :create
      else
        incr :group, :error
        raise "ERROR: Failed to create group:", group.attributes.inspect, group.errors.full_messages, entry.inspect, ""
      end
    end
  end

  def create_group_memberships
    puts %(Creating group_memberships rows based on LDAP information ...)

    # Don't set created_at/updated_at.
    GroupMembership.record_timestamps = false

    config     = @config[:group_membership]

    ldap_field = config[:base_from_ldap]
    filter     = Net::LDAP::Filter.construct(config[:filter])

    ldap_search(:customer) do |entry|
      attrs = sql_attrs_for(:customer, entry)

      puts %(>> Processing memberships for group (customer) '%s' ... %s) % [attrs[:name], inspect(entry)] if verbose
      next unless customer = Group.find_by_name(attrs[:name])

      entry[ldap_field].each do |base|
        puts %(   => Searching base '%s' ...) % base if verbose

        @ldap.search(:base => base, :filter => filter) do |group_entry|
          attrs = sql_attrs_for(:group, group_entry)

          puts %(      => Searching for group '%s' ... %s) % [attrs[:name], inspect(group_entry)] if verbose
          next unless group = Group.find_by_name(attrs[:name])

          puts %(      => Searching for membership between customer '%s' and group '%s' ...) % [customer[:name], group[:name]] if verbose
          next if customer.member_of_memberships.find_by_parent_id(group.id)

          puts %(      => Creating membership between customer '%s' and group '%s' ...) % [customer[:name], group[:name]] if verbose

          now = Time.now
          membership = customer.member_of_memberships.new(:parent => group, :created_at => now, :updated_at => now)

          # Let's see if our cache hash have stored the created_at value. If it exists in
          # the cache, we'd like to use this value to make sure the customer will see
          # the incidents reported after this created_at value for each specific group.

          action = :create
          if mb_cache = @group_memberships[[customer.id, group.id]]
            puts %(      => Reusing created_at (%s) ...) % mb_cache[:created_at] if verbose
            membership[:created_at] = mb_cache[:created_at]
            action = :update
          end

          before_membership_save(membership, entry, group_entry)

          if membership.save
            incr :group_membership, action

          else
            incr :group_membership, :error
            $stderr.puts "WARN: Failed to create group membership:",
              membership.attributes.inspect, membership.errors.full_messages,
              mb_cache.inspect, ""
          end
        end
      end

    end

    GroupMembership.record_timestamps = true
  end
end

module Disastrously
  class Sync
    class FromLDAP < Sync

      include FromLDAPHelpers
      include FromLDAPActions

      def initialize(config)
        super

        # Default values for config where possible ...
        @ldap = Net::LDAP.new({
          :host => nil,
          :port => 389,
          :auth => {
            :method => :simple,
            :username => nil,
            :password => nil
          }
        }.merge @config[:connection])

        @singles = @config[:sync_single_fields]
      end

    end
  end
end