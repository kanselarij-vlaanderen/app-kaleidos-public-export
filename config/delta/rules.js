export default [
  {
    match: {
      predicate: {
        type: 'uri',
        value: 'http://mu.semte.ch/vocabularies/ext/status'
      },
      object: {
        type: 'string',
        value: 'done'
      }
    },
    callback: {
      url: "http://simple-file-package-pipeline",
      method: "POST"
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 250,
      ignoreFromSelf: true
    }
  }
]
