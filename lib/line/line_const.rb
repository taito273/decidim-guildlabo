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
            "type": "postback",
            "label": "投票する",
            "data": ""
          },
          {
            "type": "postback",
            "label": "いいねする",
            "data": ""
          },
      ]
    }
  
        button
    end


    def result_button
      button = {
        "type": 'buttons',
        "title": "提案にいいねしました！",
        "text": "提案にいいねしました！",
        "defaultAction": {
            "type": "uri",
            "label": "詳細を見る・コメントする",
            "uri": "https://example.com/page/123"
        },
        "actions": [
            {
              "type": "uri",
              "label": "詳細を見る・コメントする",
              "uri": "https://decidim-line.guild.engineer"
            }]
        }
        button
      end

      def home_uri
        home_uri = "https://decidim-line.guild.engineer/"
        home_uri
      end

      def confirmation
        confirmation = {
          "type": "template",
          "altText": "",
          "template": {
              "type": "confirm",
              "text": "",
              "actions": [
                  {
                    "type": "postback",
                    "label": "はい",
                    "data": "yes"
                  },
                  {
                    "type": "postback",
                    "label": "いいえ",
                    "data": "no"
                  }
              ]
          }
        }
        confirmation
      end
  end