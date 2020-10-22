Rails.application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  mount Decidim::Core::Engine => '/'
  post '/line_bot_api/callback' => 'line_bot_api#callback'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
