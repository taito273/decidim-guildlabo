def sample
  puts 'a亜dsヴァ背r号jh'
end


require './lib/line_const'


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
    processes = ActiveRecord::Base.connection.select_all("select * from decidim_participatory_processes;")
    p 'line_bot_api.rb l7'
    caroucel = []
    hostname = 'https://7654a74b91ca.ngrok.io/'

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
                    "type": "uri",
                    "label": "詳細を見る",
                    "uri": ""
                  },
                  {
                    "type": "message",
                    "label": "このプロセスの提案一覧",
                    "text": ""
                  },
                  {
                    "type": "uri",
                    "label": "提案を作成",
                    "uri": ""
                  }
              ]
            }

    processes.each do |process|
      if process['published_at'] && process['promoted']
          button_tmp =  button.deep_dup
          print(process['id'])

          button_tmp['thumbnailImageUrl'] = process["banner_image"]
          button_tmp['title'] = extract_translation(process['title'])
          button_tmp['text'] = extract_translation(process['short_description']).gsub(%r{</?[^>]+?>},'')

          print('button_tmp')
          #print(button_tmp)
          #print(button_tmp[:defaultAction])
          #print(process)
          #print(process['slug'])
          print('end_____')

          button_tmp[:defaultAction][:uri] = hostname + 'processes/' + process['slug']
          button_tmp[:actions][0][:uri] = hostname + 'processes/' + process['slug']
          button_tmp[:actions][1][:text] = extract_translation(process['title']) + ' の提案一覧'
          button_tmp[:actions][2][:uri] = hostname + 'processes/' + process['slug']
          proposals_component_id = ''
          proposal_creation_enabled = false

          proposals_components = ActiveRecord::Base.connection.select_all("select * from decidim_components where participatory_space_id = #{process['id']} and manifest_name = 'proposals';")
          # 提案コンポーネントのURLはプロセスからはわからないので，それを見つける

          proposals_components.each do |proposals_component|
            proposals_component_id = ''
            proposal_creation_enabled = false
            if proposals_component['published_at'] #一つでもパブリッシュされていれば，それで決定 (提案コンポーネントは必ず存在するとしている)
              proposals_component_id = proposals_component['id']

              print('______aaaa_______')
              #print(proposals_component['settings'])

              if extract_proposal_creation_permission(proposals_component['settings']) == 'true'
                proposal_creation_enabled = true
              end  

              break
            end
          end

          print(extract_translation(process['title']))
          print(proposals_component_id)
          print(proposal_creation_enabled)
          
          #　提案作成が可能な場合のみ提案を作成アクションを残す
          if proposal_creation_enabled then
            button_tmp[:actions][2][:uri] = proposals_component_id != '' ? hostname + 'processes/' + process['slug'] + "/f/#{proposals_component_id}/proposals/new" : hostname + 'processes/' + process['slug']
          else
            #button_tmp[:actions].delete_at(2)
            # カルーセル，選択肢の数が同じじゃないといけないらしい

            button_tmp[:actions][2][:uri] = hostname + 'processes/' + process['slug'] + "/f/#{proposals_component_id}/proposals/new"

          end
          print(button_tmp)




          caroucel.push(button_tmp)
      end
    end

    message = 
              {
                "type": "template",
                "altText": "プロセス一覧を表示します．",
                "template": {
                    "type": "carousel",
                    "columns": caroucel
                }
              }
    client.reply_message(event['replyToken'], message)

end