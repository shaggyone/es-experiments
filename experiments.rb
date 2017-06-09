require 'rubygems'
require 'bundler/setup'

require 'elasticsearch'
require 'pry'

client = Elasticsearch::Client.new(
  url: "http://elastic:changeme@127.0.0.1:9200",
  log: true,
)

client.transport.reload_connections!

puts client.cluster.health

client.indices.delete(index: "myindex") rescue puts("No index yet")

client.indices.create(
  index: 'myindex',
  body: {
    settings: {
      index: {
        analysis: {
          analyzer: {
            trigram_english: {
              type: "custom",
              tokenizer: "standard",
              filter: [
                "trigrams_filter",
                "stemmer"
              ]
            }
          },
          filter: {
            stemmer: {
              type: "stemmer",
              name: "english"
            },
            trigrams_filter: {
              type: "ngram",
              min_gram: 3,
              max_gram: 3
            }
          }
        }
      }
    },
    mappings: {
      foos: {
        properties: {
          title: {
            type: "text",
            analyzer: "english",
            fields: {
              en: {
                type: "text",
                analyzer: "english"
              },
              trigram: {
                type: "text",
                analyzer: "trigram_english"
              }
            }
          },
          title2: {
            type: "text",
            analyzer: "english",
            fields: {
              en: {
                type: "text",
                analyzer: "english"
              },
              trigram: {
                type: "text",
                analyzer: "trigram_english"
              }
            }
          },
          body: {
            type: "text",
            analyzer: "english",
            fields: {
              en: {
                type: "text",
                analyzer: "english"
              },
              trigram: {
                type: "text",
                analyzer: "trigram_english"
              }
            }
          }
        }
      }
    }
  }
)

client.index index: 'myindex', type: 'foos', id: 1, body: { title: 'Test', body: "Foo bar" }
client.index index: 'myindex', type: 'foos', id: 2, body: { title: 'Test 2', body: "Foo bar" }
client.index index: 'myindex', type: 'foos', id: 3, body: { title: 'foobar', body: "Test"  }

client.index index: 'myindex', type: 'foos', id: 4, body: { title: 'foobar', title2: %w'test test test', body: "Test"  }
client.index index: 'myindex', type: 'foos', id: 5, body: { title: 'foobar', title2: 'test test', body: "Test"  }
client.index index: 'myindex', type: 'foos', id: 6, body: { title: 'test', title2: 'test test', body: "foo bar"  }
client.index index: 'myindex', type: 'foos', id: 7, body: { title: 'tests', title2: 'test test', body: "test foo bar"  }

client.index index: 'myindex', type: 'foos', id: 8, body: { title: 'footestbar' }
client.index index: 'myindex', type: 'foos', id: 9, body: { title: 'foo bar', body: 'footestbar' }




binding.pry

client.search(
  index: ['myindex'],
  body: {
    query: {
      multi_match: {
        query: 'tests',
        fields: [
          "title*^1000000",
          "title*.trigram^1000",
          "body^100",
          "body.trigram^1"
        ]
      }
    }
  }
)
        # operator: "and",

# client.search index: 'myindex', body: { query: { multi_match: { query: 'test', fields: ['title', 'body'] } } }
# client.search index: 'myindex', body: { query: { query_string: { all_fields: true, query: "test" } } }
# client.search index: 'myindex', body: { query: { match: { title: 'test' } } }
