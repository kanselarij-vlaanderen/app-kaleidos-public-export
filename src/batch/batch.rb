class Batch
  KALEIDOS_GRAPH="http://mu.semte.ch/graphs/organizations/kanselarij"
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

  def fetch_zitting_ids
    result = @kaleidosdb.query("
    PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
    PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
    SELECT ?id
    WHERE {
      GRAPH <#{KALEIDOS_GRAPH}> {
         ?zitting a besluit:Zitting ;
            mu:uuid ?id ;
            besluit:geplandeStart ?start .
         FILTER(?start > \"2016-09-05T00:00:00.000\"^^xsd:dateTime)
      }
    } ORDER BY DESC(?start)")
    result.map(&:id)
  end

  def fetch_document_graphs
    result = @publicdb.query("
     SELECT ?docGraph WHERE {
       GRAPH <http://mu.semte.ch/graph/public-export-jobs> {
          ?s a <http://mu.semte.ch/vocabularies/ext/PublicExportJob> ;
              <http://mu.semte.ch/vocabularies/ext/status> \"done\" ;
              <http://mu.semte.ch/vocabularies/ext/graph> ?docGraph .
       }
     } LIMIT 5
     ")
    result.map(&:docGraph)
  end
end
