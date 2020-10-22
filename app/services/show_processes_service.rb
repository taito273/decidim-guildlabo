require './lib/line/line_const'

class ShowProcessesService
    def extract_translation(str)
        start_index = str.index('"ja": ') + 7
        end_index = str.index('"', start_index+1) -1
        str[start_index..end_index]
    end

    def extract_proposal_creation_permission(str)
        start_index = str.index('"creation_enabled": ') + 20
        end_index = str.index(',', start_index+1) -1
        str[start_index..end_index]
    end  


    def show_processes(client, event, only_followed=false)
        processes = Decidim::ParticipatoryProcess.where(decidim_organization_id: 3, promoted: true)#organization_idは適宜変更する必要あり
        if processes.length == 0
            error_message(client, event, '現在議題はありません．')
        end
        
        if only_followed # そのユーザーがフォローしているものだけ
            line_uid = event['source']['userId']
            decidim_user = Decidim::Identity.find_by(uid: line_uid)
  
            follows = Decidim::Follow.where(decidim_user_id: decidim_user.decidim_user_id, decidim_followable_type: "Decidim::ParticipatoryProcess")

            follows_ids = follows.map {|follow|  follow.decidim_followable_id}

            processes = processes.select { |process|  follows_ids.include?(process.id) }

            if processes.length == 0
              error_message(client, event, '現在フォローしている議題はありません．')
            end
        end

        caroucel = []

        button = button_templates.button_process

        processes.each do |process|
        # 公開されている，かつハイライトされているものだけを表示
        if process.published_at && process.promoted
            button_tmp =  button.deep_dup

            button_tmp['thumbnailImageUrl'] = "https://google.com"#process.banner_image

            language = 'en'

            button_tmp['title'] = process.title[language]
            button_tmp['text'] = process.short_description[language].gsub(%r{</?[^>]+?>},'').slice(0, 50)


            button_tmp[:defaultAction][:uri] = button_templates.home_uri + 'processes/' + process.slug
            button_tmp[:actions][0][:uri] = button_templates.home_uri + 'processes/' + process.slug
            button_tmp[:actions][1][:text] = process.id.to_s + ' ' + process.title[language] + ' の提案一覧'
            button_tmp[:actions][2][:uri] = button_templates.home_uri + 'processes/' + process.slug
            proposals_component_id = ''
            proposal_creation_enabled = false

            proposals_components = Decidim::Component.where(participatory_space_id: process.id,  manifest_name: 'proposals')
            
            # 提案コンポーネントのURLはプロセスからはわからないので，それを見つける

            proposals_components.each do |proposals_component|
                proposals_component_id = ''
                proposal_creation_enabled = false
                if proposals_component.published_at #一つでもパブリッシュされていれば，それで決定 (提案コンポーネントは必ず存在するとしている)
                proposals_component_id = proposals_component.id

                proposal_creation_enabled = proposals_component.current_settings["creation_enabled"]

                break
                end
        end

            
            #　提案作成が可能な場合のみ提案を作成アクションを残す
        if proposal_creation_enabled then
            button_tmp[:actions][2][:uri] = proposals_component_id != '' ? button_templates.home_uri + 'processes/' + process.slug + "/f/#{proposals_component_id}/proposals/new" : button_templates.home_uri + 'processes/' + process.slug
        else
            button_tmp[:actions][2][:label] = '現在提案を作成できません．'
            button_tmp[:actions][2][:uri] = button_templates.home_uri + 'processes/' + process.slug + "/f/#{proposals_component_id}/proposals/"
        end

        caroucel.push(button_tmp)
        end
    end

       puts(caroucel)
        message = 
                {
                    "type": "template",
                    "altText": "プロセス一覧を表示します．",
                    "template": {
                        "type": "carousel",
                        "columns": caroucel
                    }
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

    def button_templates
        @button_templates = ButtonConst.new
    end
end


