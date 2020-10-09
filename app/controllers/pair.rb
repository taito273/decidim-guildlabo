class LineBotApiController < ApplicationController
    require 'line/bot'
    require './lib/line_bot_api'

    skip_before_action :verify_authenticity_token
  
    def callback
      body = request.body.read
      p 'リクエストボディ'
      p body
      signature = request.env['HTTP_X_LINE_SIGNATURE']
      unless client.validate_signature(body, signature)
        error 400 do 'Bad Request' end
      end
      events = client.parse_events_from(body)
  
      events.each do |event|
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            if event.message['text'] == 'プロセス一覧'
              button = { "thumbnailImageUrl": "https://example.com/bot/images/image.jpg",
              "imageAspectRatio": "rectangle",
              "imageSize": "cover",
              "imageBackgroundColor": "#FFFFFF",
              "title": "Menu",
              "text": "Please select",
              "defaultAction": {
                  "type": "uri",
                  "label": "View detail",
                  "uri": "http://example.com/page/123"
              },
              "actions": [
                  {
                    "type": "postback",
                    "label": "Buy",
                    "data": "action=buy&itemid=123"
                  },
                  {
                    "type": "postback",
                    "label": "Add to cart",
                    "data": "action=add&itemid=123"
                  },
                  {
                    "type": "uri",
                    "label": "View detail",
                    "uri": "http://example.com/page/123"
                  }
              ]
            }
              message = 
              {
                "type": "template",
                "altText": "This is a buttons template",
                "template": {
                    "type": "carousel",
                    "columns": [button, button, button]
                }
              }
            else
              message = {
                type: 'text',
                text: "エラー"
              }
            end
          end
        end
        client.reply_message(event['replyToken'], message)
      end
      head :ok
    end
  
  private
  
  # LINE Developers登録完了後に作成される環境変数の認証
    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = 'ff8f07afcccd6fc178151f955903cf81'
        config.channel_token = '6NtlqSNccnaJpsxvEEoL2b4qCmFZcuGBhirLshdfEFnk+maIFem+NmtaUxTDCfyj8QJJSl3+nQn0hTDkWfNObF2YUnhYd+FUovgOe8XisKpVh9Svtcau/fRy+eP4p6rClubvmW9G/KzufLYaYL4cggdB04t89/1O/w1cDnyilFU='
      }
    end
end
