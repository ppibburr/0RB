$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'orb/mail'
require 'orb/skill'

class SendMailSkill < ORB::Skill
  include ORB::Mail

  attr_reader :contacts, :config
  def initialize contacts: ORB::CONTACTS_CONFIG_PATH, config: ORB::MAIL_CONFIG_PATH
    super()
    
    @contacts = {}
    
    if contacts
      load_contacts contacts
    end
    
    @config = {}
    
    if config
      load_config config
    end
    
    matches /email (.*?) (.*)/
  end
  
  def load_config file
    @config = JSON.parse(open(file).read)
  end  
  
  def load_contacts file
    @contacts = JSON.parse(open(file).read)
  end
  
  def execute text
    contact = get_contact(@match[2])
    msg     = @match[3]
    
    unless contact
      say "Sorry. I cant find that contact"
      return
    end
    
    send contact, '', msg
    
    ''
  end
  
  def send contact, subject, msg
    send_email to:      "#{contact['email']}", 
               subject: subject,
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
