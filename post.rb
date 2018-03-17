require 'json'

module AVS
  class SpeechRecognizer;
    def initialize token;end
  end
  
  class AppV1
    attr_reader :client_id, :client_secret, :refresh_token
    def initialize client_id: nil, client_secret: nil, refresh_token: nil
      @client_id     = client_id
      @client_secret = client_secret
      @refresh_token = refresh_token
      
      @speech_recognizer = AVS::SpeechRecognizer.new(token)
    end
  
    def token
      return @token if @token   
      
      payload = {"client_id": client_id, "client_secret": client_secret, "refresh_token": refresh_token, "grant_type": "refresh_token", }
      url = "https://api.amazon.com/auth/o2/token"

      cmd="curl -o - -X POST -H 'Content-Type: application/json' -d '#{payload.to_json}' #{url}"
      puts cmd if false
   
      JSON.parse(`#{cmd}`)['access_token']
    end
    
    def directive obj
      p obj
    end
    
    def listen voice_file = './input.wav'
      speech_recognizer.recognize(voice_file)     
    end
    
    def speak file: nil, data: nil
      SpeechSynthesizer.speak(data ? data : open(file).read)
    end
  end
  
  class OnDeviceWake < AppV1
    def run
      Thread.new do
        loop do
          until @wake; end
          
          @wake = false
          
          listen
        end
      end
    end
    
    def wake;
      @wake = true
    end
  end
end

CLIENT_ID     = "amzn1.application-oa2-client.62d2fef790244a9c9276fc42a6314950"
CLIENT_SECRET = "6afa76a4a1082ed32b26a7f6780963aa6f8a04d0a63964afb0007cfde0270111"
REFRESH_TOKEN = "Atzr|IwEBINGAodV0ucV74csbeIXLbO_o-uoc5nnvCwLVhObNzS1w-hToPYx2TGvOok2W5xLXn2Yd2QWVlLQHonSdrA7cVHmE_MIEjZyK7AgaCt25D14Y0j-km7fQa3vtcZDh46dy-ULEGsnbLQgSNXj_g-gIHwzZFqYbY-C7ktwfaKomU2y4KoXinheCLwXhAiK_O2fmPbVdP1vX87nRKQTPinYdwp_Fv9uEMDlHgIg_43-lmg6H2GS0P0v4UxY_hSOmb70eAdbGCzdJpQ6oOIvCyog3vuOCHWLgwnNQGYWF-ln9MNLUZpWcJ1EINFUyQ4ra3HmPgjz3xDFuTnsgrDdfQPFDipIC5EXNG13ZeItdcgPkY07GzgfZI1lCylHvkpULjoexjJoh5OP7m6lH3p0cLE9IMifQUXCFmSWJuI07XBSEW7SpR77EeOMY7132JS9nTC62NGFVoJGGEm5uGJQhktCQXHV8OAEVwXXbFedArVt9Gh1ih-D5yn7UJKVso1f8sOl4XVvnnY3z_AvFwWq0QfmMHDtD"

class App < AVS::OnDeviceWake
  def listen time: 5
    record time: time
    super
  end
  
  def record time: 5
    `paplay /usr/share/sounds/purple/alert.wav`
   
    `rec -c 1 ./input.wav trim 0 #{time}`
   
    Thread.new do
      `paplay /usr/share/sounds/purple/alert.wav`
    end
  end
end

app = App.new(client_id: CLIENT_ID, client_secret: CLIENT_SECRET, refresh_token: REFRESH_TOKEN)
app.record
app.run


while true; Thread.pass; end
