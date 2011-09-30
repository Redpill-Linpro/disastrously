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

class AuthController < DisastrouslyController

  def login
    if request.post?
      user = User.new(params[:user])

      if @user = user.valid_login?
        session[:user_id] = @user.id

        if request.xhr?
          render :update do |page|
            # the javascript will actually show up in the div while the page
            # is redirecting, so hide/replace it first with something else
            page.replace :login_form, :partial => "shared/box", :locals => { :msg => "Logging in, please wait ..." }
            page.redirect_to list_history_url
          end
        else
          redirect_to list_history_url
        end

      else
        # invalid login
        flash[:login_notice] = "Username and/or password invalid"
        render :partial => "login" if request.xhr?
      end
    else
      render :partial => "login" if request.xhr?
    end
  end

  def logout
    session.delete :user_id
    redirect_to root_url
  end

end