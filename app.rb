#!/usr/bin/env ruby

require "bundler/setup"
require "sinatra"
require "zip_tricks"
require "json"
require "rest-client"
require "down"

set :server, :puma
set :port, ENV["PORT"] || 8080
set :bind, ENV["BIND"] || "localhost"

get "/download" do
  halt(403) if params[:token].to_s.empty? || params[:token] != ENV["TOKEN"]
  
  lines = RestClient.get(params[:url]).body.lines

  content_type "application/zip"
  attachment params[:filename] || "download.zip"

  ZipTricks::RackBody.new do |zip|
    lines.each do |line|
      json = JSON.parse(line)

      zip.write_stored_file(json["filename"]) do |sink|
        down = Down.open(json["url"])
        down.each_chunk { |chunk| sink.write chunk }
        down.close
      end
    end
  end
end

get "/status" do
  status 200
  body ''
end

