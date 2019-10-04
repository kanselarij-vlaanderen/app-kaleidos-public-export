require 'sparql/client'
require 'json'
require_relative './batch'

batch = Batch.new
while ! batch.up do
  puts "waiting for db"
  sleep 5
end

document_graphs = batch.fetch_document_graphs
puts "total document graphs: #{document_graphs.length}"

document_graphs.each do |document_graph|
  uri = URI("http://file-packaging/simple-file-package-jobs")
  req = Net::HTTP::Post.new(uri.request_uri)
  req.body = "{\"graph\": \"#{document_graph}\"}"
  req.content_type = "application/json"
  res = batch.request(uri, req)
  puts res.inspect
end

puts "triggering pipeline"
uri = URI("http://file-packaging/simple-file-package-pipeline")
req = Net::HTTP::Post.new(uri.request_uri)
res = batch.request(uri, req)
puts res.inspect
