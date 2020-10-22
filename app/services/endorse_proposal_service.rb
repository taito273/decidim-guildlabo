require "./lib/line/line_const"

class EndorseProposalService

    def confirm_endorsement(client, event, params)
        target_proposal = Decidim::Proposals::Proposal.find(params['id'].to_i)

        confirmation = const_button_templates.confirmation
  
        confirmation[:altText] = "提案 #{target_proposal.title} をいいねしますか？"
        confirmation[:template][:text] = "提案 #{target_proposal.title} をいいねしますか？"
        confirmation[:template][:actions][0][:data] = "id=#{params['id'].to_s}&action=endorse&flug=#{params["flug"]}&confirmed=true"
        confirmation[:template][:actions][1][:data] = "quit=true"

        result = client.reply_message(event['replyToken'], confirmation)

    end

    def check_if_endorsed(decidim_uid, proposal_id)
        #ans はそのユーザーが提案にエンドースしなければ nil になる
        ans = Decidim::Proposals::ProposalEndorsement.find_by(decidim_author_id: decidim_uid, decidim_proposal_id: proposal_id)

        if ans
            return true
        else
            return false
        end
    end

    def endorse_proposal(client, event, params)

        uid = event['source']["userId"]
        user = Decidim::Identity.find_by(uid: uid)
        decidim_uid = user.decidim_user_id

        proposal_id = params["id"].to_i
        proposal = Decidim::Proposals::Proposal.find(proposal_id)

        already_endorsed = check_if_endorsed(decidim_uid, proposal_id)

        if already_endorsed
            result = error_message(client, event, "提案 #{proposal.title} には既にいいねしています．")
            return
        end

        # ここからエンドース作業
        new_endorsement = Decidim::Proposals::ProposalEndorsement.create!(
            decidim_proposal_id: proposal_id.to_s, decidim_author_id: decidim_uid, decidim_author_type: Decidim::UserBaseEntity
        )

        success_message(client, event, proposal, params['flug'])

    end

    def success_message(client, event, proposal, process_flug)

        button = const_button_templates.result_button

        button["text"] = "提案 #{proposal.title} にいいねしました．"
        # 加えてURLを指定する必要あり
        button[:defaultAction][:uri] = "#{const_button_templates.home_uri}processes/#{process_flug}/f/#{proposal.decidim_component_id}/proposals/#{proposal.id}"
        button[:actions][0][:uri] = "#{const_button_templates.home_uri}processes/#{process_flug}/f/#{proposal.decidim_component_id}/proposals/#{proposal.id}"

        message = {
            "type": "template",
            "altText": "提案 #{proposal.title} にいいねしました．",
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
