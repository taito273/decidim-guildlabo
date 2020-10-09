require './lib/line/line_const'



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

def show_processes(client, event)
    processes = Decidim::ParticipatoryProcess.where(decidim_organization_id: 1)#organization_idは適宜変更する必要あり
    caroucel = []
    hostname = 'https://3c5c61fd887a.ngrok.io/'

    button_templates = ButtonConst.new
    button = button_templates.button_process

    processes.each do |process|
       # 公開されている，かつハイライトされているものだけを表示
      if process.published_at && process.promoted
          button_tmp =  button.deep_dup

          button_tmp['thumbnailImageUrl'] = "https://google.com"#process.banner_image

          button_tmp['title'] = process.title["ja"]
          button_tmp['text'] = process.short_description["ja"].gsub(%r{</?[^>]+?>},'')


          button_tmp[:defaultAction][:uri] = hostname + 'processes/' + process.slug
          button_tmp[:actions][0][:uri] = hostname + 'processes/' + process.slug
          button_tmp[:actions][1][:text] = process.id.to_s + ' ' + process.title['ja'] + ' の提案一覧'
          button_tmp[:actions][2][:uri] = hostname + 'processes/' + process.slug
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
            button_tmp[:actions][2][:uri] = proposals_component_id != '' ? hostname + 'processes/' + process.slug + "/f/#{proposals_component_id}/proposals/new" : hostname + 'processes/' + process.slug
          else
            button_tmp[:actions][2][:label] = '現在提案を作成できません．'
            button_tmp[:actions][2][:uri] = hostname + 'processes/' + process.slug + "/f/#{proposals_component_id}/proposals/"

          end

          caroucel.push(button_tmp)
      end
    end

    print(caroucel)
    print(event['replyToken'])
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
    print('result')
    print(result.entity)

end