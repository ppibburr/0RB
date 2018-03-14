
require 'pocketsphinx-ruby'
require 'json'

def input
  ``
end

def text
  raw = `sox -d -b 16 -c 1 -r 16k  -t wav - trim 0 5 | curl -XPOST 'https://api.wit.ai/speech?v=20160526' -i -L -H "Authorization: Beare VM7GFFHMNBBTZZTDS5NKD43L5FW45VXE" -H "Content-Type: audio/wav" -H "Transfer-Encoding: chunked"    --data-binary @-`
  puts raw
  JSON.parse(raw)["_text"]
rescue
end

c=configuration = Pocketsphinx::Configuration::KeywordSpotting.new('Alexa');
Pocketsphinx::LiveSpeechRecognizer.new(c).recognize do |speech|
  puts "Detected Wake: #{speech}"
  input 
  p text 
end
