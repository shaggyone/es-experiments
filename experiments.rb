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
                "stemmer",
                "trigrams_filter",
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
            # index_options: "docs"

            fields: {
              trigram: {
               type: "text",
               analyzer: "trigram_english"
              }
            }
          },
          title2: {
            type: "text",
            analyzer: "english",
            # index_options: "docs"

            fields: {
              trigram: {
                type: "text",
                analyzer: "trigram_english"
              }
            }
          },
          body: {
            type: "text",
            analyzer: "english",
            # index_options: "docs"

            fields: {
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

client.index index: 'myindex', type: 'foos', id: 1, body: { title: 'Test', body: "Foo bar",   val: 10 }
client.index index: 'myindex', type: 'foos', id: 2, body: { title: 'Test 2', body: "Foo bar", val: 11 }
client.index index: 'myindex', type: 'foos', id: 3, body: { title: 'foobar', body: "Test",    val: 12 }

client.index index: 'myindex', type: 'foos', id: 4, body: { title: 'foobar', title2: %w'test test test', body: "Test", val: 1 }
client.index index: 'myindex', type: 'foos', id: 5, body: { title: 'foobar', title2: 'test test', body: "Test", val: 5  }
client.index index: 'myindex', type: 'foos', id: 6, body: { title: 'test', title2: 'test test', body: "foo bar", val: 8  }
client.index index: 'myindex', type: 'foos', id: 7, body: { title: 'tests', title2: 'test test', body: "test foo bar"  }

client.index index: 'myindex', type: 'foos', id: 8, body: { title: 'footestbar' }
client.index index: 'myindex', type: 'foos', id: 9, body: { title: 'foo bar', body: 'footestbar' }

client.index index: 'myindex', type: 'foos', id: 10, body: { title: 'foobar', body: "Test", val: 15  }
client.index index: 'myindex', type: 'foos', id: 11, body: { title: 'foobar', body: "Test tests", val: 2  }
client.index index: 'myindex', type: 'foos', id: 12, body: { title: 'foobar', body: "foo Tests foo test", val: 21  }
client.index index: 'myindex', type: 'foos', id: 13, body: { title: 'afoobcbard', body: "Tests foo test", val: 21  }
client.index index: 'myindex', type: 'foos', id: 14, body: { title: 'foobar', body: "Tests afoob cbard test", val: 21  }
client.index index: 'myindex', type: 'foos', id: 15, body: { title: 'xxx', body: "afoo abar", val: 21  }


binding.pry

value = "foo bar"
client.search(
  index: ['myindex'],
  body: {
    from: 0,
    size: 100,
    query: {
      function_score: {
        query: { # This is basic query
          multi_match: {
            query: value,
            fields: [ 'title*', 'body', 'title*.trigram', 'body*.trigram']
          }
        },
        score_mode: "sum", # Use + operation when calculating score
        boost_mode: "sum", # Use + operation when boosting score
        functions: [
          {
            filter: { # Add 100 millions to score of docs, that have val between 10 and 20.
                      # Can be used to raise score of outfits registered within last 4 months
              range: { val: { gte: 10, lte: 20 } }
            },
            weight: 100_000_000,
          },
          { # Add 1 million to score for matches using full words
            filter: {
              multi_match: { query: value, fields: ['title*', 'body'] }
            },
            weight: 1000_000,
          },
          {
            filter: { # Add 10 000 to score for matches within title attributes
              multi_match: { query: value, fields: [ 'title*', 'title*.trigram'] }
            },
            weight: 10_000,
          },
          { # Add 100 to score for matches within body attributes
            filter: {
              multi_match: { query: value, fields: [ 'body', 'body.trigram'] }
            },
            weight: 100,
          },
        ],
      }
    }
  }
)
