print('initializers¥n')
print(ActiveRecord::Base.connection.execute("select last_value from decidim_users_id_seq;").first['last_value'])
#print(ActiveRecord::Base.connection.execute("select nextval('decidim_users_id_seq')").first)
#print('  ')
#print('initializers¥n')
#print(ActiveRecord::Base.connection.execute("select last_value from decidim_users_id_seq;").first['last_value'])


=begin
require "csv"
data_list = CSV.read("../seed/sample_users.csv")

i=3
#p data_list
p data_list[i]



user = Decidim::User.create!(
    name: data_list[i][2],
    email: data_list[i][0],
    nickname: data_list[i][3],
    password: data_list[i][1],
    password_confirmation: data_list[i][1],
    organization: Decidim::Organization.find(1),
    tos_agreement: true,
    email_on_notification: true,
    accepted_tos_version: Time.new #これが必要らしい，めんどくさすぎ
  )

=end


require 'net/smtp'

# Replace sender@example.com with your "From" address.
# This address must be verified with Amazon SES.
sender = "yufune@gild.work"
senderName = "サンプル ギルド"

# Replace recipient@example.com with a "To" address. If your account 
# is still in the sandbox, this address must be verified.
recipient = "tomakatay@g.ecc.u-tokyo.ac.jp"

# Replace smtp_username with your Amazon SES SMTP user name.
smtp_username = "AKIA2CG7US2YGWJWE546"

# Replace smtp_password with your Amazon SES SMTP password.
smtp_password = "BFiZeCfetCeQZZBovY6+tJfeGPr0ZltQbvvFiH7Qu++Y"

# If you're using Amazon SES in an AWS Region other than 米国西部 (オレゴン), 
# replace email-smtp.us-west-2.amazonaws.com with the Amazon SES SMTP  
# endpoint in the appropriate region.
server = "email-smtp.us-east-1.amazonaws.com"
port = 587 

# The subject line of the email.
subject = "Amazon SES Test (Ruby Net::SMTP library)"

# Specify the headers and body of the message as a variable.
message = [
    #Remove the next line if you are not using a configuration set
    "Content-Type: text/html; charset=UTF-8",
    "Content-Transfer-Encoding: 7bit",
    "From: #{senderName} <#{sender}>",
    "To: #{recipient}",
    "Subject: #{subject}",
    "",
    "<h1>Amazon SES Test (Ruby Net::SMTP library)</h1>",
    "<p>This email was sent with \
    <a href='https://aws.amazon.com/ses/'>\
    Amazon SES</a> using the Ruby Net::SMTP library.</p>"
    ].join("\n")
			
# Create a new SMTP object called "smtp."
smtp = Net::SMTP.new(server, port)

# Tell the smtp object to connect using TLS.
smtp.enable_starttls

# Open an SMTP session and log in to the server using SMTP authentication.
smtp.start(server,smtp_username,smtp_password, :login)

# Try to send the message.
begin
  smtp.send_message(message, sender, recipient)
  puts "Email sent!"
# Print an error message if something goes wrong.
rescue => e
  puts e
end