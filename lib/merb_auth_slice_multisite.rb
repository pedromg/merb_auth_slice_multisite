if defined?(Merb::Plugins)

  $:.unshift File.dirname(__FILE__)

  dependency 'merb-slices', :immediate => true
  Merb::Plugins.add_rakefiles "merb_auth_slice_multisite/merbtasks", "merb_auth_slice_multisite/slicetasks", "merb_auth_slice_multisite/spectasks"

  # Register the Slice for the current host application
  Merb::Slices::register(__FILE__)
  
  # Slice configuration - set this in a before_app_loads callback.
  # By default a Slice uses its own layout, so you can swicht to 
  # the main application layout or no layout at all if needed.
  # 
  # Configuration options:
  # :layout - the layout to use; defaults to :merb_auth_slice_multisite
  # :mirror - which path component types to use on copy operations; defaults to all
  Merb::Slices::config[:merb_auth_slice_multisite][:layout] ||= :application
  
  # All Slice code is expected to be namespaced inside a module
  module MerbAuthSliceMultisite
    
    # Slice metadata
    self.description = "see gem description"
    self.version = "see gem version"
    self.author = "see gem authors"
    
    # Stub classes loaded hook - runs before LoadClasses BootLoader
    # right after a slice's classes have been loaded internally.
    def self.loaded
    end
    
    # Initialization hook - runs before AfterAppLoads BootLoader
    def self.init
      
        # Actually check if the user belongs to the site 
        ::Merb::Authentication.after_authentication do |user, request, params|
          # clean this up somehow
          if request.first_subdomain != nil
            current_site = Site.first(:subdomain => request.first_subdomain)
            if user.site_id != current_site.id
              errors = request.session.authentication.errors
              errors.clear!
              errors.add("Label", "User does not belong to this site.")
              nil
            else
              user
            end
          else
            current_site = Site.first(:domain => request.domain)
            if user.site_id != current_site.id
              errors = request.session.authentication.errors
              errors.clear!
              errors.add("Label", "User does not belong to this site.")
              nil
            else
              user
            end
          end
        end
        
    end
    
    # Activation hook - runs after AfterAppLoads BootLoader
    def self.activate
    end
    
    # Deactivation hook - triggered by Merb::Slices.deactivate(MerbAuthSliceMultisite)
    def self.deactivate
    end
    
    # Setup routes inside the host application
    #
    # @param scope<Merb::Router::Behaviour>
    #  Routes will be added within this scope (namespace). In fact, any 
    #  router behaviour is a valid namespace, so you can attach
    #  routes at any level of your router setup.
    #
    # @note prefix your named routes with :merb_auth_slice_multisite_
    #   to avoid potential conflicts with global named routes.
    def self.setup_router(scope)
      # # example of a named route
      # scope.match('/index(.:format)').to(:controller => 'main', :action => 'index').name(:index)
      # # the slice is mounted at /merb_auth_slice_multisite - note that it comes before default_routes
      # scope.match('/').to(:controller => 'main', :action => 'index').name(:home)
      # # enable slice-level default routes by default
      # scope.default_routes
    end
    
  end
  
  # Setup the slice layout for MerbAuthSliceMultisite
  #
  # Use MerbAuthSliceMultisite.push_path and MerbAuthSliceMultisite.push_app_path
  # to set paths to merb_auth_slice_multisite-level and app-level paths. Example:
  #
  # MerbAuthSliceMultisite.push_path(:application, MerbAuthSliceMultisite.root)
  # MerbAuthSliceMultisite.push_app_path(:application, Merb.root / 'slices' / 'merb_auth_slice_multisite')
  # ...
  #
  # Any component path that hasn't been set will default to MerbAuthSliceMultisite.root
  #
  # Or just call setup_default_structure! to setup a basic Merb MVC structure.
  MerbAuthSliceMultisite.setup_default_structure!
  
  # Add dependencies for other MerbAuthSliceMultisite classes below. Example:
  # dependency "merb_auth_slice_multisite/other"
  
end