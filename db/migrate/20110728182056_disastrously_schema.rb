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
# Create initial schema for Disastrously.
#
# (Non-destructive.)
#
class DisastrouslySchema < ActiveRecord::Migration
  def self.up
    tables = ActiveRecord::Base.connection.tables

    create_table "deliveries", :force => true do |t|
      t.integer  "incident_id",      :null => false
      t.integer  "delivery_type_id", :null => false
      t.string   "recipient",        :null => false
      t.text     "message",          :null => false
      t.datetime "delivered_at"
      t.integer  "created_by_id",    :null => false
      t.integer  "updated_by_id",    :null => false
      t.datetime "created_at",       :null => false
      t.datetime "updated_at",       :null => false
    end unless tables.include? "deliveries"

    create_table "delivery_types", :force => true do |t|
      t.string   "code",                  :null => false
      t.text     "description"
      t.datetime "created_at",            :null => false
      t.datetime "updated_at",            :null => false
      t.string   "group_recipient_field"
    end unless tables.include? "delivery_types"

    create_table "group_memberships", :force => true do |t|
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
      t.string   "group_id",   :null => false
      t.string   "parent_id",  :null => false
    end unless tables.include? "group_memberships"

    add_index "group_memberships", ["group_id", "parent_id"], :name => "index_group_memberships_on_group_id_and_parent_id", :unique => true

    unless tables.include? "groups"
      create_table "groups", :id => false, :force => true do |t|
        t.string   "name",               :null => false
        t.text     "description"
        t.datetime "created_at",         :null => false
        t.datetime "updated_at",         :null => false
        t.string   "notification_mail"
        t.string   "reply_to"
        t.string   "id",                 :null => false
        t.string   "notification_phone"
        t.date     "valid_from"
        t.date     "valid_to"
      end

      # Make sure the user and group tables actually marks the id-field as
      # primary:
      execute %{ALTER TABLE groups ADD  PRIMARY KEY (id);}
    end

    add_index "groups", ["id"], :name => "index_groups_on_id"
    add_index "groups", ["name"], :name => "index_groups_on_name", :unique => true

    create_table "histories", :force => true do |t|
      t.integer  "user_id",     :null => false
      t.integer  "incident_id", :null => false
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end unless tables.include? "histories"

    add_index "histories", ["incident_id", "user_id"], :name => "index_histories_on_user_id_and_incident_id", :unique => true

    create_table "incident_timestamps", :force => true do |t|
      t.integer  "incident_id",                       :null => false
      t.datetime "datetime",                          :null => false
      t.boolean  "sla",            :default => false, :null => false
      t.boolean  "service_window", :default => false, :null => false
      t.string   "comment"
      t.datetime "created_at",                        :null => false
      t.datetime "updated_at",                        :null => false
    end unless tables.include? "incident_timestamps"

    create_table "incident_to_groups", :force => true do |t|
      t.integer  "incident_id", :null => false
      t.string   "group_id",    :null => false
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end unless tables.include? "incident_to_groups"

    create_table "incidents", :force => true do |t|
      t.string   "title"
      t.integer  "handled_by_id"
      t.text     "description",   :default => "Description:\n\n\n\nConsequences:\n\n\n\nResponse:\n\n"
      t.integer  "severity_id"
      t.integer  "created_by_id",                                                                       :null => false
      t.integer  "updated_by_id",                                                                       :null => false
      t.datetime "created_at",                                                                          :null => false
      t.datetime "updated_at",                                                                          :null => false
      t.boolean  "unknown_start", :default => false
      t.boolean  "ongoing",       :default => false
      t.integer  "parent_id"
    end unless tables.include? "incidents"

    create_table "severities", :force => true do |t|
      t.string   "title",       :null => false
      t.text     "description"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end unless tables.include? "severities"

    add_index "severities", ["title"], :name => "index_severities_on_title", :unique => true

    create_table "user_memberships", :force => true do |t|
      t.integer  "user_id",    :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
      t.string   "group_id",   :null => false
    end unless tables.include? "user_memberships"

    add_index "user_memberships", ["user_id", "group_id"], :name => "index_user_memberships_on_user_id_and_group_id", :unique => true

    create_table "user_types", :force => true do |t|
      t.string   "name",                                      :null => false
      t.text     "description"
      t.datetime "created_at",                                :null => false
      t.datetime "updated_at",                                :null => false
      t.boolean  "read_group_incidents",   :default => true,  :null => false
      t.boolean  "create_group_incidents", :default => false, :null => false
      t.boolean  "admin_access",           :default => false, :null => false
    end unless tables.include? "user_types"

    add_index "user_types", ["name"], :name => "index_user_types_on_name", :unique => true

    create_table "users", :force => true do |t|
      t.string   "username",     :null => false
      t.datetime "created_at",   :null => false
      t.datetime "updated_at",   :null => false
      t.integer  "user_type_id", :null => false
      t.string   "password"
      t.string   "full_name"
    end unless tables.include? "users"

    add_index "users", ["username"], :name => "index_users_on_username", :unique => true

    # Make user id non incremental:
    execute %{ALTER TABLE users ALTER COLUMN id SET DEFAULT NULL;}

    # Change group id to a unique string. This is needed for LDAP
    # synchronisation.
    change_column :groups, :id, :string, :unique => true, :null => false

    # Create foreign keys:
    add_foreign_key :group_membership,    :group,                   :deferrable => true
    add_foreign_key :group_membership,    :group,       :parent_id, :deferrable => true

    add_foreign_key :historie,            :incident
    add_foreign_key :historie,            :user

    add_foreign_key :incident,            :severitie,   :severity_id
    add_foreign_key :incident,            :incident,    :parent_id, :deferrable => true,  :cascade_delete => true

    add_foreign_key :incident_timestamp,  :incident,                                      :cascade_delete => true

    add_foreign_key :user_membership,     :group,                   :deferrable => true
    add_foreign_key :user_membership,     :user
    add_foreign_key :user,                :user_type
  end

  def self.down
    drop_table "deliveries"
    drop_table "delivery_types"
    drop_table "group_memberships"
    drop_table "groups"
    drop_table "histories"
    drop_table "incident_timestamps"
    drop_table "incident_to_groups"
    drop_table "incidents"
    drop_table "severities"
    drop_table "user_memberships"
    drop_table "user_types"
    drop_table "users"
  end
end