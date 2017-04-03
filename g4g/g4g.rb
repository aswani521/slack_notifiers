require 'mechanize'
require 'byebug'
require 'slack-notifier'
# require 'active-record'

require 'active_record'

ActiveRecord::Base.establish_connection( 
 :adapter => "mysql2",
 :host => "localhost",
 :username => "root",
 :password => "",
 :database => "slack_notifier"
)

class ArticleLink < ActiveRecord::Base
  has_many :article_links
end

mechanize = Mechanize.new

def notify_slack(href, title)
  notifier = Slack::Notifier.new "<slack_notifier_url>"
  message = "<!channel> New article: #{title} : #{href}"
  # notifier.ping message
  puts message  
end

page = mechanize.get('http://www.geeksforgeeks.org/')
site = 'geeksforgeeks.org'
page.search('article header h2 a').each{|a| 
  # puts a["href"], a['title']
  article = ArticleLink.find_by_url(a['href'])
  if article.nil?
    new_article = ArticleLink.new()
    new_article.url = a['href']
    new_article.title = a['title']
    new_article.site = site
    new_article.date_created = Time.now
    new_article.save!
    notify_slack(a["href"], a["title"])
  else
    puts "existing article #{a['href']}"
  end
  
}
# all_articles = page.search('article')
# all_articles.each{ |latest_article|
#   byebug
#   latest_article = page.at('article')
#   latest_article_id = page.at('article')["id"]
#   latest_article_title = page.at('article header h2 a')['title']
#   latest_article_link = page.at('article header h2 a')['href']
#   puts page.title

#   notifier = Slack::Notifier.new "https://hooks.slack.com/services/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"
#   message = "<!channel> New article posted on geeks4geeks : #{latest_article_link}"
#   # notifier.ping message
#   put message
# }

# notes
# my sql commands
=begin
create database slack_notifier;
create table article_links (id int(11) not null auto_increment ,site VARCHAR(512) NOT NULL, url VARCHAR(512) NOT NULL, title VARCHAR(1024), date_created DATE, PRIMARY KEY(id,url));
create index  url_index on article_links (url);
=end