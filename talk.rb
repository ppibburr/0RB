
require 'pocketsphinx-ruby'
require 'json'

def text
  raw = `sox -d -b 16 -c 1 -r 16k  -t wav - trim 0 3.5 | curl -XPOST 'https://api.wit.ai/speech?v=20160526' -L -H "Authorization: Bearer VM7GFFHMNBBTZZTDS5NKD43L5FW45VXE" -H "Content-Type: audio/wav" -H "Transfer-Encoding: chunked" --data-binary @- -o -`
  
  JSON.parse(raw)["_text"]
rescue => e
  p e
end

c=configuration = Pocketsphinx::Configuration.default#::KeywordSpotting.new('Alexa');

c['vad_threshold'] = 4

r=Pocketsphinx::LiveSpeechRecognizer.new(c)

def r.pause &b
  super
rescue
  b.call
end

def r.algorithm
  :after_speech
end

r.recognize do |speech|
  begin
  r.pause do
    puts "Detected Wake: #{speech}"

  #  puts "STT: #{text}"
  end
 rescue => e
   p e
 end
end
