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

# Add SLA calculations to Group class.
#
# (Note: Due to the way Rails handles dates, we need to use their built in
# TimeWithZone class when comparing with e.g. created_by. We reach this via
# e.g. Time.zone.now.)
module Group::SLA

  private

  # Calculate intersection between this incidents start time/end time and the
  # supplied dates to/from. Return intersection start time/end time in array,
  # or nil if no intsersection.
  #
  # Uses today as possible end time unless trailing false is supplied.
  #
  # Adjust the end to the end of the month unless valid_to or today is used and
  # comes first. This is because we're using this to calculate the SLA, which
  # is relevant up to the month crossover.
  #
  # :created_at => true # Adjust for self.created_at at the start of the intersection.
  # :today => true      # Adjust for today for the end of the intersection.
  def date_intersect(date, options={})
    raise "Group must be persistent (saved to database)!" if self.new_record? # we need created_at ..

    inter_start = [date]
    inter_start << valid_from if valid_from
    inter_start << created_at if options[:created_at]

    inter_start = inter_start.map {|d| d.is_a?(DateTime) ? Time.zone.at(d.to_f) : d }.max

    # End date is midnight (00:00) first day of next month, unless valid_to
    # comes before that or if todays date is used and comes before that.
    if date.month == 12
      month_end = Time.zone.local(date.year+1, 1)
    else
      month_end = Time.zone.local(date.year, date.month+1)
    end

    inter_end = [month_end]
    inter_end << valid_to if valid_to
    inter_end << Time.zone.now if options[:today]

    inter_end = inter_end.map {|d| d.is_a?(DateTime) ? Time.zone.at(d.to_f) : d }.min

    return nil unless inter_start < inter_end
    [inter_start, inter_end]
  end

  # Returns all incidents appliable for SLA for this group.
  def sla_incidents
    # Aggregate incidents from all the groups that this group is
    # (directly/indirectly) a member of.
    all_incidents = self.incidents + self.all_member_of_incidents

    # Filter on SLA
    all_incidents.flatten.select {|i| i.sla_time.to_i > 0 }
  end

  # Adjust incident timestamps so no timestamps exist outside given time
  # intersect.
  def set_sla_intersect(incident, date_intersect)
    return unless incident.timestamps.any?

    # Manipulate in-memory objects to better fit the reality we desire, so
    # be careful not to save these incidents!
    too_early, too_late = nil, nil
    incident.timestamps.each do |ts|

      # Move start into the future if needed.
      if ts.datetime < date_intersect.first
        too_early = ts
        ts.datetime = nil

      elsif too_early
        # Move the last timestamp before the intersect to the start of the
        # intersect.
        too_early.datetime = date_intersect.first
        too_early = nil
      end

      # Move end into the past if needed.
      if ts.datetime and ts.datetime > date_intersect.last and not too_late
        # Move the first timestamp after the intersect to the end of the
        # intersect.
        ts.datetime = date_intersect.last
        too_late = true

      elsif too_late
        ts.datetime = nil
      end

    end

    incident
  end

  public

  # Calculate returns the total uptime in percentage (or 'N/A') for the given
  # year and month and returns this in a hash.
  def sla_for(year, month)

    # Don't return 100 SLA for periods outside group validity.
    return {:sla => "N/A"} unless start_end = date_intersect(Time.zone.local(year, month), :today => true)

    # The SLA is calculated as (seconds with unexpected downtime) / (seconds in month)
    downtime_seconds = sla_incidents.inject(0) do |sum, incident|
      sum + set_sla_intersect(incident, start_end).sla_time
    end

    total_seconds = start_end.last.to_i - start_end.first.to_i

    {
      :downtime_secs => downtime_seconds,
      :total_secs => total_seconds,

      # We want decimals in our answer (thus +0.0)
      :sla => (1 - downtime_seconds / (total_seconds + 0.0)) * 100,
    }
  end
end