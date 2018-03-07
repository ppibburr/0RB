module ORB::SendMail
  GMAIL_SMTP = 'smtp.gmail.com:587'

  def send_email to: nil, from: nil, body: nil, subject: nil, smtp: nil, user: nil, passwd: nil
    cmd = "sendEmail -f #{from} "+
          "-t #{to} "+
          "-u \"#{subject}\" "+
          "-m \"#{body}\"\ "+
          "-s #{smtp} "+
          "-o tls=yes -xu #{user} -xp #{passwd}"
    puts cmd if true 
    `#{cmd}`
  end

  def send_gmail to: nil, from: nil, user: nil, passwd: nil, subject: nil, body: nil
    send_email from:    from,
               to:      to,
               subject: subject,
               body:    body,
               smtp:    'smtp.gmail.com:587',
               user:    user,
               passwd:  passwd
  end
end
