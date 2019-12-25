require 'net/smtp'

from = 'wayne.duran@goabroad.com'
to   = 'asartalo@gmail.com'
subject = 'It is times like these'
message = <<MESSAGE
From: #{from}
To: #{to}
Subject: #{subject}

#{message}

MESSAGE

Net::SMTP.start(
  'mail.goabroad.com',
  25,
  'localhost',
  'wayne.duran@goabroad.com',
  'anantavijaya982'
) do |smtp| 
  status = smtp.send_message(message, from, to)
  puts status.message
end

