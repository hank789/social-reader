#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

Rails.application.config.middleware.use OmniAuth::Builder do
  if Gitlab.config.services.twitter['enable']
    provider :twitter, Gitlab.config.services.twitter['key'], Gitlab.config.services.twitter['secret']
  end
  
  if Gitlab.config.services.tumblr['enable']
    provider :tumblr, Gitlab.config.services.tumblr['key'], Gitlab.config.services.tumblr['secret']
  end
  
  if Gitlab.config.services.facebook['enable']
    provider :facebook, Gitlab.config.services.facebook['app_id'], Gitlab.config.services.facebook['secret'], {
        scope: 'user_likes,publish_actions,publish_stream,public_profile,user_friends,email,user_birthday,user_events,user_photos,user_videos,read_stream,read_friendlists,user_activities'
    }
  end
  
  if Gitlab.config.services.wordpress['enable']
    provider :wordpress, Gitlab.config.services.wordpress['client_id'], Gitlab.config.services.wordpress['secret']
  end
end
