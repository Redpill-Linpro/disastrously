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

ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # See how all your routes lay out with "rake routes"

  map.root      :controller => "frontpage"

  map.login     'login',                  :controller => "auth", :action => "login"
  map.logout    'logout',                 :controller => "auth", :action => "logout"

  # create new incident
  # (also used to update group incident, if admin)
  map.resources :incidents,               :active_scaffold => true, :only => [:new, :create, :edit, :update, :index]

  # user history:
  map.resources :history,                 :active_scaffold => true, :only => [:list, :show, :index]

  # group incidents:
  map.namespace :groups do |groups|
    groups.resources :incidents,
      :active_scaffold => true,
      :path_prefix => "groups/:group_name",
      :name_prefix => "groups_",
      :requirements => {
        :group_name => /.+/ # needed to pick up everything (e.g. periods)
      },
      :only => [:list, :index, :show, :new, :create, :edit, :update]
  end

  map.namespace :admin do |admin|
    admin.resources :incidents,           :active_scaffold => true, :except => [:destroy]
    admin.resources :groups,              :active_scaffold => true, :requirements => { :id => /.+/ } # id with period..
    admin.resources :group_memberships,   :active_scaffold => true
    admin.resources :severities,          :active_scaffold => true
    admin.resources :users,               :active_scaffold => true
    admin.resources :user_memberships,    :active_scaffold => true
    admin.resources :user_types,          :active_scaffold => true
    admin.resources :deliveries,          :active_scaffold => true
    admin.resources :delivery_types,      :active_scaffold => true
  end

  # web services:
  # map.connect 'export/:past_or_future/:action/:type/:name',
  #   :past_or_future => /past|future/,
  #   :action => /group|personal/,
  #   :type => /incidents|service_windows/,
  #   :controller => "export"

  # map.connect 'export/:past_or_future/:action/:type',
  #   :past_or_future => /past|future/,
  #   :action => /group|personal/,
  #   :type => /incidents|service_windows/,
  #   :controller => "export"

  # This used to be only to map.connect-s, but it was confusing and impossible
  # to remember what the different variables could be, so I've split it up to
  # make the output of rake routes readable. (The API should be changed, but
  # foyer is already using it, so it has to be coordinated.)
  map.export_past_group 'export/past/group/:type/:group.:format',
    :type => /incidents|service_windows/,
    :controller => "export",
    :action => "past_group",
    :conditions => { :method => :get }

  map.export_future_group 'export/future/group/:type/:group.:format',
    :type => /incidents|service_windows/,
    :controller => "export",
    :action => "future_group",
    :conditions => { :method => :get }

  map.export_past_user 'export/past/personal/:type/:username.:format',
    :type => /incidents|service_windows/,
    :controller => "export",
    :action => "past_personal",
    :conditions => { :method => :get }

  map.export_future_user 'export/future/personal/:type/:username.:format',
    :type => /incidents|service_windows/,
    :controller => "export",
    :action => "future_personal",
    :conditions => { :method => :get }

  # For current_user:
  map.export_past_personal 'export/past/personal/:type.:format',
    :type => /incidents|service_windows/,
    :controller => "export",
    :action => "past_personal",
    :conditions => { :method => :get }

  map.export_future_personal 'export/future/personal/:type.:format',
    :type => /incidents|service_windows/,
    :controller => "export",
    :action => "future_personal",
    :conditions => { :method => :get }

  map.export_sla 'export/sla/:group.:format', :action => "sla", :controller => "export", :conditions => { :method => :get }
  map.export_desc 'export', :action => "description", :controller => "export", :conditions => { :method => :get }

  map.recipient_fields 'recipient_fields',
    :controller => "export", :action => "recipient_fields", :conditions => { :method => :post }

  # catch all remaining:
  map.connect '*path', :controller => "frontpage", :action => "unknown_path"
end