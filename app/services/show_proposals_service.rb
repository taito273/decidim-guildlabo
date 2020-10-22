require './lib/line/line_const'


class ShowProposalsService

    def show_all_proposals(client, event)


        space_index = event.message['text'].index(' ')
        process_name = event.message['text'][space_index+1, event.message['text'].length - space_index - 7]
        process_id = event.message['text'].slice(0, space_index).to_i
        target_process = Decidim::ParticipatoryProcess.find(process_id)

        title = target_process.title['ja'] ? target_process.title['ja'] : target_process.title['en']

        if !target_process || title != process_name #該当プロセスが存在しないとき，もしくはidと名前が一致しない時
        error_message(client, event, 'そのような議題は存在しません．お手数ですが，画面下のタップボタンよりもう一度お試しください．')
        return
        end

        process_slug = target_process.slug

        #まず，与えられたプロセスのIDから，どのProposalsコンポーネントがこのプロセスに対応しているのかを調べる
        proposals_components = Decidim::Component.where(manifest_name: 'proposals', participatory_space_id: process_id, )
        proposals_component_id = ''
        caroucel = []

        proposal_support_enabled = false
        proposal_endorsements_enabled = false


        proposals_components.each do |proposals_component|
        
            if proposals_component.published_at #一つでも公開されていれば，それで決定 (公開された提案コンポーネントは必ず存在するとしている)
                proposals_component_id = proposals_component.id
                proposal_support_enabled = proposals_component.current_settings.votes_enabled
                proposal_endorsements_enabled = proposals_component.current_settings.endorsements_enabled 
                break
            end
        end

        proposals_component_id = proposals_component_id.to_i.to_s

        proposals = Decidim::Proposals::Proposal.where(decidim_component_id: proposals_component_id)

        proposals = proposals.select{ |proposal| proposal.state != 'withdrawn' and proposal.state != 'rejected'}

        if proposals.length == 0 || !proposals
            error_message(client, event, '現在提案はありません．')
            return 
        end

        button = button_templates.button_proposal

        proposals = proposals.length > 10 ? proposals.sample(10) : proposals

        

        proposals.each do |proposal|
            button_tmp = button.deep_dup
            button_tmp[:title] = proposal.title
            button_tmp[:text] = proposal.body.gsub(%r{</?[^>]+?>},'').slice(0, 50)

            # URLの指定
            button_tmp[:defaultAction][:uri] =  button_templates.home_uri + 'processes/' + process_slug + "/f/" + proposals_component_id + "/proposals/" + proposal.id.to_s + "/?locale=ja"
            button_tmp[:actions][0][:uri] = button_templates.home_uri + 'processes/' + process_slug + "/f/" + proposals_component_id + "/proposals/" + proposal.id.to_s + "/?locale=ja"


            # サポート，エンドースアクションの指定
            button_tmp[:actions][1][:data] = "id=#{proposal.id.to_s}&action=support&flug=#{process_slug}&confirmed=false"
            button_tmp[:actions][2][:data] = "id=#{proposal.id.to_s}&action=endorse&flug=#{process_slug}&confirmed=false"


            if !proposal_support_enabled
            #サポートができない場合はサポートの選択肢を削除
              button_tmp[:actions].delete_at(-2)
            end
            if !proposal_endorsements_enabled
                #エンドースができない場合はエンドースの選択肢を削除
                button_tmp[:actions].delete_at(-1)
            end
            
            caroucel.push(button_tmp)


        end


        message = 
                {
                    "type": "template",
                    "altText": "提案一覧を表示します．",
                    "template": {
                        "type": "carousel",
                        "columns": caroucel
                    }
                }
        result = client.reply_message(event['replyToken'], message)
        Rails.logger.fatal(result.body)
    end


    def error_message(client, event, error_message)
        message = {
            "type": "text",
            "label": error_message,
            "text": error_message
        }
        result = client.reply_message(event['replyToken'], message)
        print(result.message)
    end

    def button_templates
        @button_templates = ButtonConst.new
    end
end


