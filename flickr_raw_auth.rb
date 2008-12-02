# (The MIT License)
# Copyright (c) 2008 Chris Tirpak <chris@tirpak.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'rubygems'
require 'flickraw'
require 'yaml'

# FlickrAuth uses the gem flickraw to authenticate and authorize
# against the Flickr API. More info on the Flickr API can be found on the 
# Flickr services page: http://www.flickr.com/services/api
# FlickrAuth uses a Hash 'config' for all of its parameters
module FlickrAuth
  
  # stores the Flickr token, api_key, and shared secret 
  # so we don't have to re-authorize eveery time
  def cache_flickr_credentials(token_cache_file, config)     
    config[:config_changed] = false
    f = File.open(token_cache_file, 'w+')
    f.write config.to_yaml
    f.close
  end
  
  # Do the work necessary to authenticate and authorize the user. If needed 
  # collect the Flickr _API_KEY_ and _SHARED_SECRET_. Defaults to requesting read
  # permissions.
  def get_flickr_authorization(config)
    config[:config_changed] = true  
    
    # we need the Flickr API key and the Shared Secret 
    # since they come as a pair always ask for both
    # it's possible for the user to revoke our privs without needing
    # a new api key and shared secret - we should only ever have to collect these once
    # unless the user deltes the cache file we create at the end of this
    if config[:api_key] == nil || config[:shared_secret] == nil
      puts "Please enter the Flickr API Key and press enter:"
      gets
      config[:api_key] = chomp
      
      puts "Please enter the Flickr Shared Secret for the API Key and press enter:"
      gets
      config[:shared_secret] = chomp
    end  

    FlickRaw.api_key = config[:api_key]
    FlickRaw.shared_secret = config[:shared_secret]
    
    # set permission requested to read only if not otherwise specified
    config[:perms] = 'read' if config[:perms] == nil

    # get frob from Flickr
    frob = flickr.auth.getFrob
    # construct url for user to visit to grant us access
    auth_url = FlickRaw.auth_url :frob => frob, :perms => config[:perms]

    puts "You must now visit the following Flickr url, log in to Flickr, and authorize this application.\n"+
         "Press enter when you have done so. This should be the only time you will have to do this.\n #{auth_url}"
    gets

    # get the auth token from Flickr
    token = flickr.auth.getToken(:frob => frob)
    # double check to make sure it is working
    login = flickr.test.login
    puts "Now authenticated with Flickr as #{login.username}"
    
    # grab all of the info from the token and then store it in our cache file 
    # so we can skip this in the future
    config[:token] = token.token
    config[:perms] = token.perms
    config[:username] = token.user.username
    config[:fullname] = token.user.fullname
    config[:nsid] = token.user.nsid        
  rescue FlickRaw::FailedResponse => e
    puts "Authentication failed : #{e.msg}"
  end
  
  # This is the main method to call. It checks to see if we have a valid Flickr
  # token. If not, it goes through the process of authorizing the user.
  def validate_flickr_credentials(config)  
    if config[:token] && config[:api_key] && config[:shared_secret]
      begin
        FlickRaw.api_key=config[:api_key]
        FlickRaw.shared_secret=config[:shared_secret]
        flickr.auth.checkToken :auth_token => config[:token]
        puts "Using cached credentials for Flickr user: #{config[:username]}"
      rescue FlickRaw::FailedResponse => e
        puts "Flickr authentication failed with message : #{e.msg}\n"+
          "Requesting a new token from Flickr."
        get_flickr_authorization(config)
      end
    else
      get_flickr_authorization(config)
    end    
    return config
  end
  
end