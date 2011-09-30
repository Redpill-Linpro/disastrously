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

require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :user_memberships
  has_many :groups, :through => :user_memberships

  has_many :incidents_handled, :class_name => "Incident", :foreign_key => :handled_by_id
  has_many :incidents_created, :class_name => "Incident", :foreign_key => :created_by_id
  has_many :incidents_updated, :class_name => "Incident", :foreign_key => :updated_by_id

  has_many :deliveries_created, :class_name => "Delivery", :foreign_key => :created_by_id
  has_many :deliveries_updated, :class_name => "Delivery", :foreign_key => :updated_by_id

  has_many :history

  belongs_to :user_type

  validates_presence_of :username, :user_type
  validates_uniqueness_of :username

  before_create :encrypt_password
  before_create :set_id

  # The controller / helper code needs this.
  attr_accessor :group_checkboxes

  # Notice: The ID in the User table is not auto increment. This is to enable
  # smooth LDAP-synchronization. Populating ID for new objects is handled in
  # the admin/users controller.

  def to_label
    username
  end

  # valid_login? assumes that self is a new user with authentication data
  # that is supposed to match an existing user. If a user with the supplied
  # username is found and the users password matches the stored user is
  # returned, otherwise nil is returned.
  def valid_login?
    if user = User.find_by_username(self.username) and user.password == User.encrypt(self.password)
      user
    else
      nil
    end
  end

  # Update the users password to the given new password.
  # This is needed to encrypt the password.
  def update_password(new_password)
    self.password = User.encrypt(new_password)
  end

  protected

  SALT = %{PQcXxdmFC4itYWiSbXMdigPablItt6am9f1JGG7VOBi8wYHW0XfTCSQdxGSEVrVO}

  def self.encrypt(string)
    Digest::SHA1.hexdigest(SALT + "$" + string.to_s)
  end

  # encrypt the users password when the user is created
  def encrypt_password
    # Do not encrypt if there is no password.
    # This will ensure that an empty password is impossible to log in with
    # (since the login code *will* encrypt it and end up with a long string).
    # We don't want to require passwords in case LDAP is in use.
    self.password = User.encrypt(password) if password
  end

  # We've turned off auto-id in order to allow for external synchronization of
  # user table. So if someone actually creates a user, the ID needs to be set.
  def set_id
    # This is not thread safe :p But worse case scenario you get an exception,
    # in which you just retry to make it work.
    self.id = User.all.size + 1 if new_record? and not self.id
  end

end