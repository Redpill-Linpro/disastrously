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

module IncidentTimestampsHelper

  def time_range_from_form_column(record, options)
    options[:disabled] = true if record.unknown_start == "1"

    # Very strange that I need to manually add a prefix...
    name = options.delete(:name).sub(/\[from\]/, "")
    datetime_select :record, :from, options.merge(:prefix => name), :class => options[:class]
  end

  def time_range_to_form_column(record, options)
    options[:disabled] = true if record.still_ongoing == "1"

    # Very strange that I need to manually add a prefix...
    name = options.delete(:name).sub(/\[to\]/, "")
    datetime_select :record, :to, options.merge(:prefix => name), :class => options[:class]
  end

  # Add javascript to toggle the "from" datetime select on/off.
  def time_range_unknown_start_form_column(record, options)
    # Better id for the javascript
    options[:id] = options[:name].gsub(/\[|\]/, "_")

    # Toggle disabling/enabling the datetime_select
    options[:onchange] = checkbox_onchange(%(select.from-input), options[:id])

    center check_box(:record, :unknown_start, options)
  end

  # Add javascript to toggle the "to" datetime select on/off.
  def time_range_still_ongoing_form_column(record, options)
    # Better id for the javascript
    options[:id] = options[:name].gsub(/\[|\]/, "_")

    # Toggle disabling/enabling the datetime_select
    options[:onchange] = checkbox_onchange(%(select.to-input), options[:id])

    center check_box(:record, :still_ongoing, options)
  end

  def time_range_sla_form_column(record, options)
    center check_box(:record, :sla, options)
  end

  def time_range_service_window_form_column(record, options)
    center check_box(:record, :service_window, options)
  end

  def time_range_space_form_column(record, options)
    %(&nbsp;)
  end

  private

  def center(string)
    %(<center>#{string}</center>)
  end

  # Toggle disabling/enabling the datetime_select.
  def checkbox_onchange(selector, checkbox_id)
    # There's a bug somewhere (here? in firefox?) which renders the select with
    # the wrong state (enabled/disabled) when there's a validation error (but
    # the checkbox is correct). If we toggle the checkbox, the select state is
    # toggled, and continues to be wrong. The fix is to fetch the state from
    # the checkbox (which is always correct).
    %(
      $(this.parentNode.parentNode.parentNode.parentNode.parentNode).select('#{selector}').each(
        function(input){
          $(input).disabled = $('#{checkbox_id}').checked;
          input[input.disabled ? 'disable' : 'enable']();
        }
      );
    )
  end

end