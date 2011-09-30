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

class Incident < ActiveRecord::Base
  has_many :history, :autosave => true, :dependent => :destroy
  has_many :deliveries

  has_many :group_relations, :class_name => "IncidentToGroup", :dependent => :destroy
  has_many :groups, :through => :group_relations, :after_add => :remember_new

  has_many :timestamps, :class_name => "IncidentTimestamp", :dependent => :destroy, :order => "datetime ASC"

  has_many   :children, :class_name => "Incident", :foreign_key => :parent_id, :dependent => :destroy, :order => "created_at ASC"
  belongs_to :parent,   :class_name => "Incident"

  belongs_to :handled_by, :class_name => "User", :foreign_key => :handled_by_id
  belongs_to :created_by, :class_name => "User", :foreign_key => :created_by_id
  belongs_to :updated_by, :class_name => "User", :foreign_key => :updated_by_id

  belongs_to :severity

  include Incident::ActiveScaffoldCode
  include Incident::Deliveries
  include Incident::ValidationCode

  def started_at
    return nil if inherit_column(:unknown_start?)
    # Unsaved data may have datetime = nil
    inherit_column(:timestamps).map{|t| t.datetime}.compact.sort.first
  end

  def ended_at
    return nil if inherit_column(:ongoing?)
    # Unsaved data may have datetime = nil
    inherit_column(:timestamps).map{|t| t.datetime}.compact.sort.last
  end

  # Returns the number of SLA seconds for this incident (the number of seconds
  # this incident affected SLA).
  def sla_time
    # Unsaved data may have datetime = nil
    timestamps = inherit_column(:timestamps).select {|ts| ts.datetime }.sort_by(&:datetime)
    timestamps.reduce([0, nil, false]) do |sum,t|

      # Add the difference between this timestamp and the last one to the total
      # if the last timestamp was marked as service_window.
      sum[0] += (t.datetime - sum[1]) if sum[2]
      sum[1] = t.datetime
      sum[2] = t.sla
      sum

    end.first
  end

  # Returns the number of service window seconds for this incident (the number
  # of seconds this incident was a service window / planned downtime).
  def service_window_time
    # Unsaved data may have datetime = nil
    timestamps = inherit_column(:timestamps).select {|ts| ts.datetime }.sort_by(&:datetime)
    timestamps.reduce([0, nil, false]) do |sum,t|

      # Add the difference between this timestamp and the last one to the total
      # if the last timestamp was marked as service_window.
      sum[0] += (t.datetime - sum[1]) if sum[2]
      sum[1] = t.datetime
      sum[2] = t.service_window
      sum

    end.first
  end

  # Retrieve column from parent if value is nil.
  def inherit_column(column)
    value = send(column)
    if not parent
      value

    elsif value.nil? or value.is_a?(Array) && value.empty?
      parent.inherit_column column

    else
      value
    end
  end

  private

  # @new_groups is needed by the after_save callback in Incident::Deliveries
  # module.
  def remember_new(group)
    @new_groups ||= []
    @new_groups << group
  end

end