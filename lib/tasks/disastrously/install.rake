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

#plugin_root = "vendor/plugins/disastrously"
plugin_root = File.dirname(__FILE__).sub(%r|/lib/tasks/.*$|, "")

# We need the latest version of active scaffold due to the advanced
# functionality we're using, however the master branch is not tagged so while
# it's probably OK to use the latest version we'll play it safe and use a
# commit we know works.
ac_commit  = "821716bb5af1a7d324ad8901d3678045cb2a69c6"
ac_git_url = "git://github.com/activescaffold/active_scaffold.git"

# Based on code from gems/rails-2.3.11/lib/commands/plugin.rb:
def run_install_hook(name)
  install_hook_file = "#{Rails.root}/vendor/plugins/#{name}/install.rb"
  load install_hook_file if File.exist? install_hook_file
end

namespace :disastrously do

  desc "Completely install Disastrously and dependencies into this Rails project."
  task :install do
    Rake::Task['disastrously:install:files'].execute
    Rake::Task['disastrously:install:bundler'].execute
    Rake::Task['disastrously:install:gemfile'].execute
    Rake::Task['disastrously:install:index'].execute
    Rake::Task['disastrously:install:deps'].execute
  end

  namespace :install do

    desc "Sync necessary files from Disastrously plugin."
    task :files do
      puts ">> Syncronizing necessary files from Disastrously ..."
      [
        [File.join(plugin_root, "db/migrate"),            Rails.root.join("db")],
        [File.join(plugin_root, "db/schema_extra.rb"),    Rails.root.join("db/schema_extra.rb")],
        [File.join(plugin_root, "public"),                Rails.root],
        [File.join(plugin_root, "script"),                Rails.root],
        [File.join(plugin_root, "config/initializers"),   Rails.root.join("config")]
      ].each do |(from, to)|
        puts cmd = "rsync -ruv %s %s" % [from, to]
        system cmd
        puts
      end
    end

    desc "Properly setup bundler (needed since we're using Rails 2.3)."
    task :bundler do
      data = (IO.read(File.expand_path __FILE__) =~ /__END__\n/ && $')
      yaml = YAML.load(data)

      preinitializer = Rails.root.join("config/preinitializer.rb")
      unless File.exists? preinitializer
        File.open(preinitializer, "w+") { |f| f.puts yaml[:preinitializer] }
      end

      boot = Rails.root.join("config/boot.rb")
      contents = (IO.read(boot) =~ /^Rails\.boot!/ && $`)
      unless contents =~ /Bundler/
        File.open(boot, "w") { |f| f.puts contents + yaml[:boot] + "\nRails.boot!" }
      end
    end

    desc "Add disastrously to the Gemfile and run bundle install to install dependencies."
    task :gemfile do
      gemfile = Rails.root.join("Gemfile")
      unless (contents = IO.read(gemfile)) =~ /^\s*gem\s+['"]disastrously['"]/
        File.open(gemfile, "a") do |f|
          f.puts %(gem "disastrously", :path => "vendor/plugins/disastrously")

          # We need rdoc to get rid of annoying message printed to stderr.
          f.puts %(gem "rdoc") unless contents =~ /['"]rdoc['"]/
        end
      end

      puts cmd = "bundle install"
      system cmd
    end

    desc "Move public/index.html out of the way."
    task :index do
      date = DateTime.now.strftime("%Y%m%d.%H%M%S")
      index  = Rails.root.join("public/index.html")
      backup = "%s.disastrously.%s.bk" % [index, date]

      if File.exists? index
        abort("Both index file (%s) and proposed backup file (%s) exists!" % [index, backup]) if File.exists? backup
        File.rename index, backup
        puts ">> %s -> %s" % [index, backup]
      end
    end

    desc "Install dependencies required by Disastrously."
    task :deps do
      Rake::Task['disastrously:install:deps:active_scaffold'].execute
    end

    namespace :deps do

      desc "Install/update Active Scaffold plugin required by Disastrously."
      task :active_scaffold do

        # Turns out it's impossible to fetch a specific commit from a remote
        # git repository (per design apparently), so we need to fetch the
        # entire master branch and then select our "known good" commit via
        # reset.
        #
        # In other words, we can't use the normal 'script/plugin install'
        # command (since it is hardcoded to only fetch the last commit on the
        # branch/tag, which might not be the commit we want).
        Dir.chdir Rails.root.join("vendor/plugins") do

          if File.directory? "active_scaffold"
            Dir.chdir Rails.root.join("vendor/plugins/active_scaffold") do
              if File.directory? ".git" # just a safety check so we don't mess up the main repo.
                puts %(>> Updating Active Scaffold plugin ...)
                puts cmd = "git pull"
                system cmd
              end
            end

          else
            puts ">> Installing Active Scaffold plugin ..."
            puts cmd = "git clone %s" % ac_git_url
            system cmd
            puts
          end

          Dir.chdir Rails.root.join("vendor/plugins/active_scaffold") do
            if File.directory? ".git" # just a safety check so we don't mess up the main repo.
              puts %(=> Resetting Active Scaffold to "known good" commit %s ...) % ac_commit
              puts cmd = "git reset --hard %s" % ac_commit
              system cmd
            end

            run_install_hook("active_scaffold")
          end
        end

        puts

        Rake::Task['disastrously:install:deps:render_component'].execute
      end

      desc "Install Render Component plugin required by Active Scaffold."
      task :render_component do
        puts ">> Installing Render Component plugin ..."
        Dir.chdir Rails.root
        puts cmd = "script/plugin install git://github.com/ewildgoose/render_component.git -r rails-2.3"
        system cmd
        puts
      end

    end
  end
end

__END__
---
:boot: >
  class Rails::Boot
    def run
      load_initializer

      Rails::Initializer.class_eval do
        def load_gems
          @bundler_loaded ||= Bundler.require :default, Rails.env
        end
      end

      Rails::Initializer.run(:set_load_path)
    end
  end

:preinitializer: >
  begin
    require "rubygems"
    require "bundler"

  rescue LoadError
    raise "Could not load the bundler gem. Install it with `gem install bundler`."
  end

  if Gem::Version.new(Bundler::VERSION) <= Gem::Version.new("0.9.24")
    raise RuntimeError,
      "Your bundler version is too old for Rails 2.3." +
      "Run `gem install bundler` to upgrade."
  end

  begin
    # Set up load paths for all bundled gems
    ENV["BUNDLE_GEMFILE"] = File.expand_path("../../Gemfile", __FILE__)
    Bundler.setup

  rescue Bundler::GemNotFound
    raise RuntimeError, "Bundler couldn't find some gems. Did you run `bundle install`?"
  end

