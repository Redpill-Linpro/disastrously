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

class FrontpageController < DisastrouslyController
  before_filter :authenticate, :except => [:unknown_path]

  def index
    if current_user
      redirect_to list_history_url
    else
      @user = User.new
    end
  end

  def unknown_path
    use_layout = (not request.xhr?)
    render :partial => "shared/box",
      :layout => use_layout,
      :status => :not_found,
      :locals => {
        :msg => %(Invalid path: "#{(params[:path]||[]).join("/")}".),
        :classes => "red_box medium_vspace hspace"
      }
  end

end