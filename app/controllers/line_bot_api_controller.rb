class LineBotApiController < ApplicationController
    require 'line/bot'

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
            line_bot_handler(event)
          end
        end
      end
      head :ok
    end

    def line_bot_handler(event)
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

  def error_message(client, event, error_message)
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

    def line_user_verification_service
      @line_user_verification_service = LineUserVerificationService.new
    end

end
