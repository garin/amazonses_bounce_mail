#!/usr/bin/env ruby
require 'json'

transport_file = "/etc/postfix/transport"
subscription_arn_file = "/etc/postfix/amazonses_bounse_mail_subscription_arn"
subscription_arn = File.open(subscription_arn_file).gets.chomp!
mail_raw = STDIN.readlines(nil)[0]
bounce_mails = []

# get subscription-arn
# SNS で設定している subscription_arn と メール の subscription_arn を使って認証する
# 同じ arm であれば SNS からメールとして許可する
mail_raw =~ /^x-amz-sns-subscription-arn:\s+(.*)\n/
mail_subscription_arn = $1
unless subscription_arn == mail_subscription_arn
  puts "invalid arn"
  exit 1
end

# exract json from raw mail
mail_raw =~ /(\{.*\})/m
params = JSON.parse($1)

# get bounced mails
params["bounce"]["bouncedRecipients"].each do |b|
  bounce_mails << b["emailAddress"]
end

# insert discart mail addr to transport
File.open(transport_file, "a") do |t|
  bounce_mails.each do |addr|
    str = "#{addr} discard:discard"
    puts str
    t.puts str
  end
end

# rehash transport db
`/usr/sbin/postmap #{transport_file}`
