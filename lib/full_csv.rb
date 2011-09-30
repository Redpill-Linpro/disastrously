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

# Includes a module for generating CSV from an array of model objects, and a
# module for generating an array of attribute arrays from CSV.
module FullCsv

  CSV_FORMAT = {
    :col_sep => "|",
    :row_sep => "\n",
    :write_headers => true,
  }

  # Add to config/environment.rb to activate::
  #   Array.send :include, FullCsv::To
  #
  # To use:
  #   Incident.all.to_full_csv
  module To

    def to_full_csv
      return "" if empty?

      if self.select {|m| m.class != self.first.class}.any?
        raise "Container must include instances of the same class (#{self.inspect})"
      end

      csv_format = CSV_FORMAT.dup
      csv_format[:headers] = headers = self.first.attribute_names;

      # The reason we HTML escape it is to prevent newline and other funny
      # characters from messing up our lovely CSV. By using HTML escaping we're
      # using a known and understood standard.
      FasterCSV.generate(csv_format) do |csv|

        self.each do |m|
          csv << headers.map do |att|
            CGI.escape(m.send(att.to_sym).to_s)
          end
        end

      end
    end

  end

  # Add to config/environment.rb to activate::
  #   String.send :include, FullCsv::Parse
  #
  # To use:
  #   full_csv = Incident.all.to_full_csv
  #   data = full_csv.parse_full_csv
  module Parse

    def parse_full_csv
      split(CSV_FORMAT[:row_sep]).map do |line|
        line.parse_csv(CSV_FORMAT).map {|att| CGI.unescape(att)}
      end
    end

  end

end