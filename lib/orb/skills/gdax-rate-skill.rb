$: << File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')

require 'open-uri'
require 'orb/skill'

class GDAXRateSkill < ORB::Skill
  def initialize *o
    super
    
    matches(
      /price.*(ltc|btc|bch|eth|bitcoin|litecoin|lightcoin|ethereum|ether)/,
      /(ltc|btc|bch|eth|bitcoin|litecoin|lightcoin|ethereum|ether).*price/
    )
  end
  
  def execute text: '', response: {}
    fetch(@match[2])
    ''
  end
  
  def fetch coin
    case coin
    when /litecoin|lightcoin|ltc/
      coin = :ltc
    when /athyrium|ethereum|ether|either|weather|beth|eth/
      coin = :eth 
    when /btc|bitcoin/
      coin = :btc
    else
      return
    end
  
    ticker = JSON.parse(open("https://api.gdax.com/products/#{coin}-usd/ticker").read)
    
    say "The #{@match[2]} last trade is #{"%.2f" % ticker['price'].to_f}"
  end
end
