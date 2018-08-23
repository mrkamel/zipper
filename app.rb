#!/usr/bin/env ruby

require "bundler/setup"
require "sinatra"
require "zip_tricks"
require "json"
require "rest-client"

set :server, :puma
set :port, ENV["PORT"] || 8080
set :bind, ENV["BIND"] || "localhost"

get "/download" do
  halt(403) if params[:token].to_s.empty? || params[:token] != ENV["TOKEN"]
  
  json_request = JSON.parse(RestClient.get(params[:url]).body)

  content_type "application/zip"

  ZipTricks::RackBody.new do |zip|
    json_request["entries"].each do |entry|
      zip.write_stored_file(entry["filename"]) do |sink|
        sink.write RestClient.get(entry["url"])
      end
    end
  end
end

get "/status" do
  status 200
  body ''
end

