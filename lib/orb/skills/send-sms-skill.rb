$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/skills/send-mail-skill'

class SMSSkill < SendMailSkill
  def initialize contacts: ORB::CONTACTS_CONFIG_PATH, config: ORB::MAIL_CONFIG_PATH
    super
    
    matches(/text (.*?) (.*)/, /message (.*?) (.*)/)
  end
  
  def send contact, subject, msg
    send_email to:      "#{contact['number']}@#{contact['gateway']}", 
               subject: '',
               body:    msg,
               from:    (config['from']||config['user']),
               smtp:    config['smtp'],
               passwd:  config['passwd'],
               user:    config['user']
  end
  
  def get_contact name
    @contacts[name]
  end
end
