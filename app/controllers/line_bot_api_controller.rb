class LineBotApiController < ApplicationController
    require 'line/bot'
    require 'uri'

    skip_before_action :verify_authenticity_token
  
    def callback
      body = request.body.read
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
            line_bot_text_handler(event)
          end

        when Line::Bot::Event::Postback
          line_bot_postback_handler(event)
        
        end
      end


      head :ok
    end

    def line_bot_text_handler(event)
      # テキストの種類が
      # 1. プロセス一覧
      # 2. 提案一覧
      # 3. お問い合わせ
      # 4. プロセスX, ~~~~
      # 5. 提案X, ~~~~, 詳細
      # 6. 提案X, ~~~~, サポート
      # 7. 提案X, ~~~~, エンドース
      # 8. 提案X, ~~~~, コメント
      # の8種類
      #p event.message['text']

      if line_user_verification_service.decidim_user_verification(client, event)#ユーザーがDecidimにLINEを登録していない場合
        return
      end

      if event.message['text'] == 'プロセス一覧'
        show_process_service.show_processes(client, event)
      elsif event.message['text'] == '提案一覧'
        show_process_service.show_processes(client, event, true)
      elsif event.message['text'].slice(-6, 6) == ' の提案一覧'
        # メッセージは，[id] [process_name] の提案一覧　として来る
        show_proposal_service.show_all_proposals(client, event)
      end
    end


    def line_bot_postback_handler(event)
      query_array = URI::decode_www_form(event["postback"]["data"])
      query_params = Hash[query_array]


      if query_params["action"] == "endorse" && query_params["confirmed"] == 'true'
        endorse_proposal_service.endorse_proposal(client, event, query_params)
      elsif query_params["action"] == "endorse"
        endorse_proposal_service.confirm_endorsement(client, event, query_params)
      elsif query_params["action"] == "support" && query_params["confirmed"] == 'true'
        support_proposal_service.support_proposal(client, event, query_params)
      elsif query_params["action"] == "support"
        support_proposal_service.confirm_support(client, event, query_params)
      elsif query_params["quit"] == "true"
        error_message(client, event, 'ご利用ありがとうございました．')
      else
        error_message(client, event, '下のメニューを開いて閲覧したいコンテンツを選択してください．')
      end
      
    end

  def error_message(client, event, error_message)
    message = {
            "type": "text",
            "label": error_message,
            "text": error_message
        }
        result = client.reply_message(event['replyToken'], message)
  end
  private
  
  # LINE Developers登録完了後に作成される環境変数の認証
    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = 'ff8f07afcccd6fc178151f955903cf81'
        config.channel_token = '6NtlqSNccnaJpsxvEEoL2b4qCmFZcuGBhirLshdfEFnk+maIFem+NmtaUxTDCfyj8QJJSl3+nQn0hTDkWfNObF2YUnhYd+FUovgOe8XisKpVh9Svtcau/fRy+eP4p6rClubvmW9G/KzufLYaYL4cggdB04t89/1O/w1cDnyilFU='
      }
    end

    def show_proposal_service
      @show_proposal_service = ShowProposalsService.new
    end

    def show_process_service
      @show_process_service = ShowProcessesService.new
    end

    def endorse_proposal_service
      @endorse_proposal_service = EndorseProposalService.new
    end

    def support_proposal_service
      @support_proposal_service = SupportProposalService.new
    end

    def line_user_verification_service
      @line_user_verification_service = LineUserVerificationService.new
    end

end
