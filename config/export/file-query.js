import { querySudo as query } from '@lblod/mu-auth-sudo';
import { uuid } from 'mu';

const fileQuery = async function( jobsParamsProvidedAsJsonPostBody ){
    const graph = jobsParamsProvidedAsJsonPostBody['graph'];
    const result = await query(`
        PREFIX nie: <http://www.semanticdesktop.org/ontologies/2007/01/19/nie#>
        PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
        PREFIX nfo: <http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#>

        SELECT ?file ?filename WHERE {
          GRAPH <${graph}> {
            ?file mu:uuid ?uuid.
            ?file nie:dataSource ?logicalFile.
            ?logicalFile nfo:fileName ?filename.
          }
       }
  `);
    return {
	files: result.results.bindings || [],
	packageName: `${new Date().toISOString()}_${uuid()}.zip`
    };
};

export default fileQuery;
