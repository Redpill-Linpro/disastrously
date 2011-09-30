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

# Word wrap a string into lines with 'n' length without splitting up words.
# Include in String class:
#   String.send :include, WordWrap
module WordWrap
  def word_wrap(n=79, keep_newlines=false)
    # Keep paragraphs.
    split(/\n\n/).map do |part|
      part = part.gsub(/\n/, " ") unless keep_newlines

      # The last case catches "words" that are longer than n characters.
      part.scan(/
        (?:
         (.{1,#{n}}) # Any characters, 1-n
         (?:\s|$)    # followed by space or end
         |
         (\S{#{n}})  # Or no space, exactly n.
        )/x
      ).flatten.compact.join("\n")
    end.join("\n\n")
  end
end