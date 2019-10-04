require 'sparql/client'
require 'json'
require_relative './batch'

batch = Batch.new
while ! batch.up do
  puts "waiting for db"
  sleep 5
end

zitting_ids =  batch.fetch_zitting_ids
puts "total meetings: #{zitting_ids.length}"
export_jobs = {}
zitting_ids.each do |uuid|
  uri = URI("http://export/export/#{uuid}")
  req = Net::HTTP::Post.new(uri.request_uri)
  req["Accept"] = 'application/vnd.api+json'
  res = batch.request(uri, req)
  if ! res.kind_of?(Net::HTTPAccepted)
    puts "failure for #{uuid}: #{res.inspect}"
  else
    res = JSON.parse(res.body)
    export_jobs[uuid]=res["jobId"]
    puts "zitting #{uuid} handled in #{res["jobId"]}"
  end
end

puts "Job UUIDs"
puts export_jobs
