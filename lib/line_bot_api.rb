def sample
  puts 'a亜dsヴァ背r号jh'
end


require './lib/line_const'


def extract_pattern(str)
  start_index = str.index('"ja": ') + 7
  end_index = str.index('"', start_index+1) -1
  str[start_index..end_index]
end

def show_processes(client, event)
    processes = ActiveRecord::Base.connection.select_all("select * from decidim_participatory_processes;")
    p 'line_bot_api.rb l7'
    caroucel = []

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
      if process['published_at']
          button_tmp =  button.deep_dup
          print(process['id'])

          button_tmp['thumbnailImageUrl'] = process["banner_image"]
          button_tmp['title'] = extract_pattern(process['title'])
          button_tmp['text'] = extract_pattern(process['short_description']).gsub(%r{</?[^>]+?>},'')

          print('button_tmp')
          #print(button_tmp)
          #print(button_tmp[:defaultAction])
          #print(process)
          #print(process['slug'])
          print('end_____')

          button_tmp[:defaultAction][:uri] = 'https://decidim-line.guild.engineer/' + process['slug']
          button_tmp[:actions][0][:uri] = 'https://decidim-line.guild.engineer/' + process['slug']
          button_tmp[:actions][2][:uri] = 'https://decidim-line.guild.engineer/' + process['slug'] #+ proposalコンポーネントのid f/#{}/proposals/new
          button_tmp[:actions][1][:text] = extract_pattern(process['title']) + ' の提案一覧'

          proposals_components = ActiveRecord::Base.connection.select_all("select * from decidim_components where participatory_space_id = #{process['id']} and manifest_name = 'proposals';")
          # 提案コンポーネントのURLはプロセスからはわからないので，それを見つける
          print(proposals_components)
          print(proposals_components.rows)

          proposals_components.each do |proposals_component|
            if proposals_component['published_at'] #一つでもパブリッシュされていれば，それで決定
              proposals_component_id = proposals_component['id']
            end
          end

          button_tmp[:actions][1][:text] = extract_pattern(process['title']) + ' の提案一覧'



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