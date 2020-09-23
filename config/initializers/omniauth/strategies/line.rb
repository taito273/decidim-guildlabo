require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Line < OmniAuth::Strategies::OAuth2
      option :scope, 'email profile openid' #追記

      info do
        {
          name:        raw_info['displayName'],
          image:       raw_info['pictureUrl'],
          nickname:    'nickname_sample',
          description: raw_info['statusMessage'],
          email:    JWT.decode(access_token.params['id_token'], ENV['0eddb092288cbdd669e1bbe71118df3a']).first['email']#追記
        }
      end
    end
  end
end