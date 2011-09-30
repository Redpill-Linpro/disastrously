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

class ExportController < DisastrouslyController
  before_filter :authenticate

  before_filter :personal, :only => [:past_personal, :future_personal]
  before_filter :group, :only => [:past_group, :future_group, :sla]

  # this is a web service:
  layout false

  # The export routes are kind of complicated (sorry about that),
  # so if you just hit /export a nice description will explain the routes.
  def description
    # This is stolen from the file
    # "vendor/rails/railties/lib/tasks/routes.rake" which is the "routes" rake
    # task. It won't work in Rails 3 (different API).
    @routes = ActionController::Routing::Routes.routes.collect do |route|
      name = ActionController::Routing::Routes.named_routes.routes.index(route).to_s
      verb = route.conditions[:method].to_s.upcase
      segs = route.segments.inject("") { |str,s| str << s.to_s }
      segs.chop! if segs.length > 1
      #reqs = route.requirements.empty? ? "" : route.requirements.inspect
      reqs = route.requirements
      {:name => name, :verb => verb, :segs => segs, :reqs => reqs}
    end

    @routes = @routes.select {|route| route[:reqs][:controller] == "export" }
  end

  def past_group
    @incidents = @group.incidents + @group.all_member_of_incidents
    filter_past_incidents

    respond_to do |format|
      format.html { render :group }
      format.csv  { render :text => @incidents.to_full_csv }
    end
  end

  def future_group
    @incidents = @group.incidents + @group.all_member_of_incidents
    filter_future_incidents

    respond_to do |format|
      format.html { render :group }
      format.csv  { render :text => @incidents.to_full_csv }
    end
  end

  def past_personal
    @incidents = @user.history.map { |history| history.incident }
    filter_past_incidents

    respond_to do |format|
      format.html { render :personal }
      format.csv  { render :text => @incidents.to_full_csv }
    end
  end

  def future_personal
    @incidents = @user.history.map { |history| history.incident }
    filter_future_incidents

    respond_to do |format|
      format.html { render :personal }
      format.csv  { render :text => @incidents.to_full_csv }
    end
  end

  # Service Level Agreement.
  # Export statistics about the level uptime reached for given customer.
  def sla
    # Calculate SLAs for a 12 month period starting with this month
    @slas = []
    today = Date.today

    # We unshift instead of putting (<<) in order to reverse the whole list,
    # and this way we get the array sorted with the most recent month at the
    # top (the current month).
    ((today.month+1)..12).each do |month|
      date = Date.new(today.year-1, month)
      @slas.unshift [date, @group.sla_for(date.year, date.month)]
    end

    (1..today.month).each do |month|
      date = Date.new(today.year, month)
      @slas.unshift [date, @group.sla_for(date.year, date.month)]
    end

    respond_to do |format|
      format.html

      format.csv do
        config = FullCsv::CSV_FORMAT.merge( :headers => %w(date downtime_secs total_secs sla) )
        csv = FasterCSV.generate(config) do |csv|
          @slas.each do |row|
            date = "%s-%s" % row.first.to_s.split("-")
            sla = row.last
            csv << [date, sla[:downtime_secs], sla[:total_secs], sla[:sla]]
          end
        end

        render :text => csv
      end

    end
  end

  def recipient_fields
    groups = params[:groups].split(",")

    @groups = groups.map do |group_name|
      current_user.groups.find_by_name(group_name) or current_user.user_type.admin_access? && @group = Group.find_by_name(group_name)
    end.compact

    @recipients = @groups.inject({}) {|inj, group| inj.merge group.delivery_recipients }
    render(:partial => "recipient_fields", :locals => { :groups => @groups, :recipients => @recipients })
  end

  private

  def personal
    username = params[:username] || params[:name] || current_user.username

    if username == current_user.username
      @user = current_user
      # OK

    elsif current_user.user_type.admin_access? and @user = User.find_by_username(username.to_s)
      # OK

    else
      render :text => "No user with name \"#{username}\", or you are not authorized to view that user."
      return
    end
  end

  def group
    group_name = params[:name] || params[:group]

    if @group = current_user.groups.find_by_name(group_name)
      # OK

    elsif current_user.user_type.admin_access? and @group = Group.find_by_name(group_name)
      # OK

    else
      render :text => "No group with name \"#{group_name}\", or you are not authorized to view that group."
      return
    end
  end

  def filter_past_incidents
    @period = "Past"
    @type = params[:type].to_s

    now = Time.now
    if @type == "incidents"
      @incidents = @incidents.select { |incident| incident.service_window_time == 0 and incident.ended_at < now }

    elsif @type == "service_windows"
      # Note that service windows that started in the past but ends in the
      # future are regarded as 'future' service windows
      @incidents = @incidents.select { |incident| incident.service_window_time > 0 and incident.ended_at < now }

    else
      @incidents = []
    end
  end

  def filter_future_incidents
    @period = "Future"
    @type = params[:type].to_s

    now = Time.now
    if @type == "incidents"
      # Incidents that started in the past and ends in the future (still
      # ongoing?) are regarded as future incidents. strange, but okay.
      @incidents = @incidents.select { |incident| incident.service_window_time == 0 and incident.ended_at > now }

    elsif @type == "service_windows"
      @incidents = @incidents.select { |incident| incident.service_window_time > 0 and incident.ended_at > now }

    else
      @incidents = []
    end
  end
end