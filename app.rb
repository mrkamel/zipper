#!/usr/bin/env ruby

require "bundler/setup"
require "sinatra"
require "zip_tricks"
require "json"
require "http"

set :server, :puma
set :port, ENV["PORT"] || 8080
set :bind, ENV["BIND"] || "localhost"

get "/download" do
  halt(403) if params[:token].to_s.empty? || params[:token] != ENV["TOKEN"]
  
  response = HTTP.get(params[:url])
  halt(422) unless response.status.success?

  lines = response.body.to_s.lines

  content_type "application/zip"
  attachment params[:filename] || "download.zip"

  ZipTricks::RackBody.new do |zip|
    lines.each do |line|
      json = JSON.parse(line)

      zip.write_stored_file(json["filename"]) do |sink|
        HTTP.get(json["url"]).body.each do |chunk|
          sink.write chunk
        end
      end
    end
  end
end

get "/status" do
  status 200
  body ''
end

