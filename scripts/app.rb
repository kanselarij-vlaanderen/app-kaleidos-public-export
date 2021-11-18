require 'sparql/client'
require 'json'

fd = IO.sysopen("/proc/1/fd/1", "w")
log = IO.new(fd,"w")
log.sync = true # send log message immediately, don't wait

class Batch
  KALEIDOS_GRAPH = "http://mu.semte.ch/graphs/organizations/kanselarij"

  def initialize
    @publicdb = SPARQL::Client.new(ENV['MU_SPARQL_ENDPOINT'])
    @kaleidosdb = SPARQL::Client.new(ENV['KALEIDOS_SPARQL_ENDPOINT'])
  end

  def up
    begin
      @publicdb.query("ASK { ?s ?p ?o }")
      @kaleidosdb.query("ASK { ?s ?p ?o }")
    rescue
      false
    end
  end

  def request(uri, req)
    begin
      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
      res
    rescue => e
      puts e
      nil
    end
  end

  def fetch_meeting_ids(since)
    result = @kaleidosdb.query("
    PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
    PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
    SELECT ?id
    WHERE {
      GRAPH <#{KALEIDOS_GRAPH}> {
         ?meeting a besluit:Vergaderactiviteit ;
            mu:uuid ?id ;
            besluit:geplandeStart ?start .
         FILTER(?start > \"#{since}\"^^xsd:dateTime)
      }
    } ORDER BY DESC(?start)")
    result.map(&:id)
  end
end

batch = Batch.new
while ! batch.up do
  log.puts "Waiting for databases"
  sleep 5
end

meeting_ids = batch.fetch_meeting_ids("2019-10-01T00:00:00.000Z")
log.puts "Total meetings found: #{meeting_ids.length}"
export_jobs = {}
for uuid in meeting_ids do
  uri = URI("http://export/meetings/#{uuid}/publication-activities")
  req = Net::HTTP::Post.new(uri.request_uri)
  req["Accept"] = 'application/vnd.api+json'
  req["Content-Type"] = 'application/vnd.api+json'
  req.body = '{
	"data": {
		"type": "publication-activity",
		"attributes": {
                  "scope": ["newsitems", "documents"]
		}
	}
  }'
  res = batch.request(uri, req)
  if ! res.kind_of?(Net::HTTPAccepted)
    log.puts "Failure for meeting #{uuid}: #{res.inspect}"
  else
    log.puts "Export for meeting #{uuid} scheduled"
  end
  sleep 1
end
