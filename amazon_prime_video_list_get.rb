#! /usr/bin/env ruby

require 'pp'
require 'open-uri'
require 'nokogiri'

url = 'https://www.amazon.co.jp/s/ref=sr_rot_p_n_ways_to_watch_0?fst=as%3Aoff&rh=n%3A2351649051%2Cp_n_feature_twenty_browse-bin%3A2317600051%2Cp_n_entity_type%3A4174098051%2Cp_n_ways_to_watch%3A3746328051&bbn=2351649051&ie=UTF8&qid=1518757785&rnid=3746327051'

proxy = nil
# refer http://q.hatena.ne.jp/1451205850
# refer http://i101330.hatenablog.com/entry/2016/03/25/221337
user_agent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.167 Safari/537.36'

disp_list = {
  'title'               => 'div[1]/div/a/h2',
  'year'                => 'div[1]/div/span[3]',
  'price'               => 'div[2]/div[1]/div/a/span[2]',
  'rent_purchase'       => 'div[2]/div[1]/div/span[2]',
  'star_rating'         => 'div[2]/div[2]/div[1]/span/span/a/i[1]/span',
  'comment'             => 'div[2]/div[2]/div[1]/a',
  'starring'            => 'div[2]/div[2]/div[2]/div/div[1]/span',
  'starrings'           => 'div[2]/div[2]/div[2]/div/div[2]/span',
  'director'            => 'div[2]/div[2]/div[3]/div/div[1]/span',
  'director_name'       => 'div[2]/div[2]/div[3]/div/div[2]/span',
  'playing_time0'       => 'div[2]/div[2]/div[4]/div/div[1]/span',
  'playing_time1'       => 'div[2]/div[2]/div[4]/div/div[2]/span',
}

n = 0

loop do
  # https://docs.ruby-lang.org/ja/latest/library/open=2duri.html
  begin
    document = Nokogiri::HTML(open(url,
                                   :proxy       => proxy,
                                   "User-Agent" => user_agent))
  rescue => e
    puts e.message
    puts "set proxy = 'http://proxy.example.com:8000/' in the top of this file!" if proxy.nil?
    exit
  end

  xpath = '//*[contains(@id,"result")]/div/div/div/div[2]'
  elements = document.xpath(xpath)

  elements.each do |element|
    puts '*****'
    disp_list.each do |k,xpath|
      value = element.xpath(xpath).text
      case k
      when 'title'
        n += 1
        puts "#{k}[#{n}]: #{value}"
      when 'year','price','star_rating','comment'
        puts "#{k}: #{value}"
      when 'starring','director','playing_time0'
        print "#{value} " # no newline
      else
        puts "#{value}"
      end
    end
  end

  xpath = '//*[@id="pagnNextLink"]'
  elements = document.xpath(xpath)
  nlink = nil # nlink: next link
  elements.each do |element|
    x = element.attributes["href"].value
    if x != ""
      nlink = x
    end
  end

  if nlink.nil? then
    break
  else
    url = 'https://www.amazon.co.jp' + nlink
#   puts "url: #{url}"
  end

  sleep 2
end
