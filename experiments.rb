require 'rubygems'
require 'bundler/setup'

require 'elasticsearch'
require 'pry'

$client = Elasticsearch::Client.new(
  url: "http://elastic:changeme@127.0.0.1:9200",
  log: true,
)

# $client.transport.reload_connections!

puts $client.cluster.health

$client.indices.delete(index: "myindex") rescue puts("No index yet")

$client.indices.create(
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
                # "stemmer",
                "lowercase",
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
              max_gram: 3,
            }
          }
        }
      }
    },
    mappings: {
      saved_searches: {
        properties: {
          keywords: {
            type: "text",
            analyzer: "english",
            fields: {
              trigram: {
                type: "text",
                analyzer: "trigram_english",
              }
            }
          }
        }
      },
      bars: {
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
          }
        }
      },
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

$client.index index: 'myindex', type: 'foos', id: 1, body: { title: 'Test', body: "Foo bar",   val: 10 }
$client.index index: 'myindex', type: 'foos', id: 2, body: { title: 'Test 2', body: "Foo bar", val: 11 }
$client.index index: 'myindex', type: 'foos', id: 3, body: { title: 'foobar', body: "Test",    val: 12 }

$client.index index: 'myindex', type: 'foos', id: 4, body: { title: 'foobar', title2: %w'test test test', body: "Test", val: 1 }
$client.index index: 'myindex', type: 'foos', id: 5, body: { title: 'foobar', title2: 'test test', body: "Test", val: 5  }
$client.index index: 'myindex', type: 'foos', id: 6, body: { title: 'test', title2: 'test test', body: "foo bar", val: 8  }
$client.index index: 'myindex', type: 'foos', id: 7, body: { title: 'tests', title2: 'test test', body: "test foo bar"  }

$client.index index: 'myindex', type: 'foos', id: 8, body: { title: 'footestbar' }
$client.index index: 'myindex', type: 'foos', id: 9, body: { title: 'foo bar', body: 'footestbar' }

$client.index index: 'myindex', type: 'foos', id: 10, body: { title: 'foobar', body: "Test", val: 15  }
$client.index index: 'myindex', type: 'foos', id: 11, body: { title: 'foobar', body: "Test tests", val: 2  }
$client.index index: 'myindex', type: 'foos', id: 12, body: { title: 'foobar', body: "foo Tests foo test", val: 21  }
$client.index index: 'myindex', type: 'foos', id: 13, body: { title: 'afoobcbard', body: "Tests foo test", val: 21  }
$client.index index: 'myindex', type: 'foos', id: 14, body: { title: 'foobar', body: "Tests afoob cbard test", val: 21  }
$client.index index: 'myindex', type: 'foos', id: 15, body: { title: 'xxx', body: "afoo abar", val: 21  }


$client.index index: 'myindex', type: 'bars', id: 1, body: { title: 'foo bar' }
$client.index index: 'myindex', type: 'bars', id: 2, body: { title: 'foo a bar' }
$client.index index: 'myindex', type: 'bars', id: 3, body: { title: 'foo a b bar' }
$client.index index: 'myindex', type: 'bars', id: 4, body: { title: 'foo a b c bar' }
$client.index index: 'myindex', type: 'bars', id: 5, body: { title: 'foo a b c d bar' }
$client.index index: 'myindex', type: 'bars', id: 6, body: { title: 'foo a b c d e bar' }
$client.index index: 'myindex', type: 'bars', id: 7, body: { title: 'foo a b c d e f bar' }
$client.index index: 'myindex', type: 'bars', id: 8, body: { title: 'foo a b c d e f g bar' }
$client.index index: 'myindex', type: 'bars', id: 9, body: { title: 'foo a b c d e f g h bar' }
$client.index index: 'myindex', type: 'bars', id: 10, body: { title: 'foo a b c d e f g h i bar' }
$client.index index: 'myindex', type: 'bars', id: 11, body: { title: 'foo a b c d e f g h i j bar' }
$client.index index: 'myindex', type: 'bars', id: 12, body: { title: 'foo a b c d e f g h i j' }
$client.index index: 'myindex', type: 'bars', id: 13, body: { title: 'a b c d e f g h i j bar' }


$client.index index: 'myindex', type: 'saved_searches', id: 1, body: { keywords:  "catherine" }
$client.index index: 'myindex', type: 'saved_searches', id: 2, body: { keywords:  "'Super Duper'" }
$client.index index: 'myindex', type: 'saved_searches', id: 3, body: { keywords:  "Other Accessories" }
$client.index index: 'myindex', type: 'saved_searches', id: 4, body: { keywords:  "696 Metallic Detailed Leather Trainer" }
$client.index index: 'myindex', type: 'saved_searches', id: 5, body: { keywords:  "rings" }
$client.index index: 'myindex', type: 'saved_searches', id: 6, body: { keywords:  "Everlane" }
$client.index index: 'myindex', type: 'saved_searches', id: 7, body: { keywords:  "Christmas" }
$client.index index: 'myindex', type: 'saved_searches', id: 8, body: { keywords:  "Sweaters" }
$client.index index: 'myindex', type: 'saved_searches', id: 9, body: { keywords:  "Bergdorfgoodman" }
$client.index index: 'myindex', type: 'saved_searches', id: 10, body: { keywords: "Editorialist" }

$client.index index: 'myindex', type: 'saved_searches', id: 11, body: { keywords: "query" }

$client.index index: 'myindex', type: 'saved_searches', id: 12, body: { keywords: "testfoobar" }

binding.pry

value = "query"
$client.search(
  index: ['myindex'],
  from: 0,
  size: 100,
  body: {
    query: {
      multi_match: {
        query: value,
        fields: ["keywords*"],
        minimum_should_match: "100%", # If only 30% of query string matches, that's ok
      }
    }
  },
  pretty: true
)

$client.termvectors(index: 'myindex', type: 'foos', id: 14,
  fields: ["*"],
)["term_vectors"].map { |k,v| [k, v["terms"].keys] }.to_h
  # term_statistics:  true,
  # field_statistics: true,
  # offsets:   true,
  # positions: true,
  # payloads:  true,
  # pretty: true,
  # :fields (List) — A comma-separated list of fields to return
  # :body (Hash) — The request definition
  # :preference (String) — Specify the node or shard the operation should be performed on (default: random)
  # :realtime (String) — Specifies if requests are real-time as opposed to near-real-time (default: true)
  # :routing (String) — Specific routing value
  # :parent (String) — Parent ID of the documents
# )

value = "query"
$client.explain(
  index: 'myindex',
  type: 'saved_searches',
  id: 11,
  body: {
    query: {
      multi_match: {
        query:"query",
        fields: ["keywords.trigram"],
        minimum_should_match: "100%", # If only 30% of query string matches, that's ok
      }
    }
  }
)

value = "foo bar"
$client.search(
  index: ['myindex'],
  body: {
    from: 0,
    size: 100,
    query: {
      function_score: {
        query: { # This is basic query
          bool: {
            must: [
              { multi_match: { query: value, fields: [ 'title*', 'body', 'title*.trigram', 'body*.trigram'] } },
              { type: { value: "foos" } },
            ]
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
          { # Add 100 to score for matches within body attributes
            filter: {
              multi_match: { query: value, fields: [ 'body', 'body.trigram'] }
            },
            weight: -100,
          },
        ],
      }
    }
  }
)


value = "foo bar"
$client.search(
  index: ['myindex'],
  type: "bars",
  body: {
    from: 0,
    size: 100,
    query: {
      function_score: {
        query: { # This is basic query
          multi_match: {
            query: value,
            fields: ['title', 'title.trigram'],
            minimum_should_match: "30%", # If only 30% of query string matches, that's ok
          },
        },
        score_mode: "sum", # Use + operation when calculating score
        boost_mode: "sum", # Use + operation when boosting score
        functions: [
          { # Add 1 million to score for matches using full words
            filter: {
              multi_match: {
                query: value,
                fields: ['title'],
                type: "phrase",
                slop: 5 # Docs, with matchig words within 5 other words will appear higher
              },
            },
            weight: 10,
          },
          { # Add 1 million to score for matches using full words
            filter: {
              multi_match: {
                query: value,
                fields: ['title', 'title.trigram'],
                minimum_should_match: "100%", # Full matches are put to top
              },
            },
            weight: 100,
          },
        ],
      }
    }
  }
)
