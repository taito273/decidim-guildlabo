class ButtonConst
    def button_process
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
            "uri": "https://google.com"
          },
          {
            "type": "message",
            "label": "このプロセスの提案一覧",
            "text": "aaa"
          },
          {
            "type": "uri",
            "label": "提案を作成",
            "uri": "https://google.com"
          }
      ]
    }
  
        button
    end
  
    def button_proposal
      button = {
      "title": "Menu",
      "text": "Please select",
      "defaultAction": {
          "type": "uri",
          "label": "View detail",
          "uri": "https://example.com/page/123"
      },
      "actions": [
          {
            "type": "uri",
            "label": "詳細を見る・コメントする",
            "uri": "https://decidim-line.guild.engineer"
          },
          {
            "type": "message",
            "label": "サポートする",
            "text": "サポートする"
          },
          {
            "type": "uri",
            "label": "エンドースする",
            "uri": "https://google.com"
          },
      ]
    }
  
        button
    end
  end