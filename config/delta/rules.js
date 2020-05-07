export default [
  {
    match: {
      object: { type: "uri", value: "http://mu.semte.ch/vocabularies/ext/TtlToDeltaTask" }
    },
    callback: {
      url: "http://ttl-to-delta/new-ttl", method: "POST"
    },
    options: {
      resourceFormat: "v0.0.1",
      gracePeriod: 1000,
      ignoreFromSelf: true
    }
  }
]
