require "./lib/line/line_const"

class SupportProposalService

    def confirm_support(client, event, params)
        target_proposal = Decidim::Proposals::Proposal.find(params['id'].to_i)

        confirmation = const_button_templates.confirmation
  
        confirmation[:altText] = "提案 #{target_proposal.title} に投票しますか？"
        confirmation[:template][:text] = "提案 #{target_proposal.title} に投票しますか？"
        confirmation[:template][:actions][0][:data] = "id=#{params['id'].to_s}&action=support&flug=#{params["flug"]}&confirmed=true"
        confirmation[:template][:actions][1][:data] = "quit=true"

        result = client.reply_message(event['replyToken'], confirmation)

    end

    def validate_support(decidim_uid, proposal)
        #そのユーザーの該当提案コンポーネントに対する投票
        supports_of_current_user = Decidim::Proposals::ProposalVote.where(decidim_author_id: decidim_uid)


        supports_of_current_user.each do |support| 
            if support.decidim_proposal_id.to_i == proposal.id
                #　既に投票していればここで終わり
                return [true, nil]
            end
        end


        # 該当提案コンポーネントに含まれる提案一覧
        proposals = Decidim::Proposals::Proposal.where(decidim_component_id: proposal.decidim_component_id.to_i)
        proposal_component = Decidim::Component.find(proposal.decidim_component_id.to_i)

        # 該当コンポーネントに含まれる提案のIDから，ユーザーの投票の中でも関連する投票だけ抜き出す
        proposal_ids = []
        proposals.each { |prop| proposal_ids.push(prop.id) }
        support_of_target_proposal = supports_of_current_user.select { |support| proposal_ids.include?(support.decidim_proposal_id) }

        reached_limit = support_of_target_proposal.length >= proposal_component.settings.vote_limit && proposal_component.settings.vote_limit != 0

        return [false, reached_limit]



    end


    def support_proposal(client, event, params)

        uid = event['source']["userId"]
        user = Decidim::Identity.find_by(uid: uid)
        decidim_uid = user.decidim_user_id

        proposal_id = params["id"].to_i
        proposal = Decidim::Proposals::Proposal.find(proposal_id)

        already_supported, support_reached_limit = validate_support(decidim_uid, proposal)

        if already_supported
            result = error_message(client, event, "提案 #{proposal.title} には既に投票しています．")
            return
        end

        if support_reached_limit
            result = error_message(client, event, "投票数が上限に達しています．")
            return
        end

        # ここから投票作業
        new_endorsement = Decidim::Proposals::ProposalVote.create!(
            decidim_proposal_id: proposal_id.to_s, decidim_author_id: decidim_uid
        )

        success_message(client, event, proposal, params['flug'])

    end


    def success_message(client, event, proposal, process_flug)

        button = const_button_templates.result_button

        button['title'] = "提案に投票しました!"
        button["text"] = "提案 #{proposal.title} に投票しました!"
        # 加えてURLを指定する必要あり
        button[:defaultAction][:uri] = "#{const_button_templates.home_uri}processes/#{process_flug}/f/#{proposal.decidim_component_id}/proposals/#{proposal.id}"
        button[:actions][0][:uri] = "#{const_button_templates.home_uri}processes/#{process_flug}/f/#{proposal.decidim_component_id}/proposals/#{proposal.id}"

        message = {
            "type": "template",
            "altText": "提案 #{proposal.title} に投票しました．",
            "template": button
        }
        

        result = client.reply_message(event['replyToken'], message)

    end

    def error_message(client, event, error_message)
        message = {
            "type": "text",
            "label": error_message,
            "text": error_message
        }
        result = client.reply_message(event['replyToken'], message)

    end

    def const_button_templates
        @const_button_templates = ButtonConst.new()
    end
end
