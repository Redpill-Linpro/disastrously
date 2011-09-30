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

#!/usr/bin/env ruby

require 'rubygems'
require 'kramdown'

OUT_PATH = "html"
Dir.mkdir OUT_PATH unless File.exists? OUT_PATH and File.directory? OUT_PATH

files = ARGV.any? and ARGV
files ||= Dir["*.md"]

files.sort_by(&:size).each do |file|
  out = "%s.html" % link_name = File.join(OUT_PATH, File.basename(file))
  puts "%s -> %s" % [file, out]

  File.open(out, "w") do |f|
    f.puts Kramdown::Document.new(IO.read file).to_html
  end

  # The links point to the md files in order to work with e.g. github (which
  # automatically parse markdown files), so to work with our html files we
  # create a symlink to the html.
  File.unlink link_name if File.exists? link_name
  File.symlink File.basename(out), link_name
end