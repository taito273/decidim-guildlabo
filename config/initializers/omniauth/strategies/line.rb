require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Line < OmniAuth::Strategies::OAuth2
      option :scope, 'email profile openid' #追記

      info do
        {
          name:        raw_info['displayName'],
          image:       raw_info['pictureUrl'],
          nickname:    '',
          description: raw_info['statusMessage'],
          email:    JWT.decode(access_token.params['id_token'], '0eddb092288cbdd669e1bbe71118df3a').first['email']#追記
        }
      end

      def callback_url # これでクエリパラメータのおかしな点を修正
        # Fixes regression in omniauth-oauth2 v1.4.0 by https://github.com/intridea/omniauth-oauth2/commit/85fdbe117c2a4400d001a6368cc359d88f40abc7
        options[:callback_url] || (full_host + script_name + callback_path)
      end

    end
  end
end