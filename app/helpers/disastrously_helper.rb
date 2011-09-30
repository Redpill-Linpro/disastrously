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

# Methods added to this helper will be available to all templates in the application.
module DisastrouslyHelper

  # logged_in? returns the user id of the currently logged in user or nil if
  # the user isn't authorized
  def logged_in?
    session[:user_id]
  end

  # Returns given seconds as a string with "hours:minutes:seconds". Optional
  # string format can be given as trailing argument.
  def seconds_to_text(seconds, format="%d:%02d:%02d")
    format % [seconds/3600, (seconds/60).modulo(60), seconds.modulo(60)]
  end

  def select_links(column_name)
    # After changing the checkboxes, we need to fire the onchange manually.
    javascript = %(
      elements = $(this.parentNode.parentNode).select('.%s input');
      elements.each(function(box){%s});
      if (elements[0].onchange) {
        elements[0].onchange();
      }
    )

    out =  %(<label>) << link_to_function("Select all",  javascript % [column_name, "box.checked=true", column_name]) << %(</label> / )
    out << %(<label>) << link_to_function("Select none", javascript % [column_name, "box.checked=false", column_name]) << %(</label> / )
    out << %(<label>) << link_to_function("Invert selection", javascript % [column_name, "box.checked=!box.checked", column_name]) << %(</label>)
  end

end