def decidim_user_verification(client, event)
    hostname = "https://decidim-line.guild.engineer"

    uid = event['source'][:userId]

    user = Decidim::Authorization.find_by(decidim_user_id: uid)

    if user
        return false
    else
        message = {
            "type": "template",
            "altText": "ユーザー情報が見つかりません",
            "template": {
                "type": "buttons",
                "thumbnailImageUrl": "https://decidim-line.guild.engineer",
                "imageAspectRatio": "rectangle",
                "imageSize": "cover",
                "imageBackgroundColor": "#FFFFFF",
                "title": "ユーザー情報が見つかりません",
                "text": "LINE登録はお済みですか？",
                "defaultAction": {
                    "type": "uri",
                    "label": "View detail",
                    "uri": "http://example.com/page/123"
                },
                "actions": [
                    {
                      "type": "uri",
                      "label": "LINEアカウントを登録する",
                      "uri": hostname + "/users/sign_up"
                    }
                ]
            }
          }
        client.reply_message(event['replyToken'], message)
        return true
        end
end
