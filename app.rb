
require "bundler/setup"
require "sinatra"
require "zip_tricks"
require "json"
require "rest-client"

post "/generate" do
  halt(403) if params[:token].to_s.empty? || params[:token] != ENV["TOKEN"]
  
  json_request = JSON.parse(RestClient.get(params[:url]).body)

  ZipTricks::RackBody.new do |zip|
    json_request["entries"].each do |entry|
      zip.write_stored_file(entry["filename"]) do |sink|
        sink.write RestClient.get(entry["url"])
      end
    end
  end
end

