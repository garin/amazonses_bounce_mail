#!/usr/bin/env ruby
require 'json'

transport_file = "transport"
bounce_mails = []

# exract json from raw mail
STDIN.readlines(nil)[0] =~ /(\{.*\})/m
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
#`postmap #{transport_file}`
