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
            split: {
              type: "custom",
              tokenizer: "standard",
              filter: [
                # "stemmer",
                "lowercase",
                # "trigrams_filter",
              ]
            }
          },
          # filter: {
          #   split: {
          #     # type: "split",
          #   },
          # }
        }
      }
    },
    mappings: {
      outfits: {
        properties: {
          title: {
            type: "text",
            # analyzer: "english",
            # fields: {
            #   trigram: {
            #     type: "text",
            #     analyzer: "trigram_english",
            #   }
            # }
          },
          body: {
            type: "text",
            # analyzer: "english",
            # fields: {
            #   trigram: {
            #     type: "text",
            #     analyzer: "trigram_english",
            #   }
            # }
          },
          products_names: {
            type: "text",
            # analyzer: "english",
            # fields: {
            #   trigram: {
            #     type: "text",
            #     analyzer: "trigram_english",
            #   }
            # }
          }
        }
      }
    }
  }
)

$client.index index: 'myindex', type: 'outfits', id: 1, body: {
  title: (("a".."l").to_a - ["d"]).join(" "),
  body: (("a".."l").to_a - ["a", "b", "c"]).join(" "),
  products_names: ("l".."q").to_a.join(" "),
}

$client.index index: 'myindex', type: 'outfits', id: 2, body: {
  title: (("a".."l").to_a - ["d"]).join(" "),
  body: ("l".."q").to_a.join(" "),
  products_names: (("a".."l").to_a - ["a", "b", "c"]).join(" "),
}

$client.index index: 'myindex', type: 'outfits', id: 3, body: {
  title: ("l".."q").to_a,
  body: (("a".."l").to_a - ["a", "b", "c"]).join(" "),
  products_names: (("a".."l").to_a - ["a", "b", "c"]).join(" "),

}

$client.index index: 'myindex', type: 'outfits', id: 4, body: {
  title: (("a".."l").to_a - ["d", "e", "f"]).join(" "),
  body: (("a".."l").to_a - ["a", "b", "c"]).join(" "),
  products_names: ("l".."q").to_a.join(" "),
}

$client.index index: 'myindex', type: 'outfits', id: 5, body: {
  title: (("a".."l").to_a - ["d", "e", "f"]).join(" "),
  body: ("l".."q").to_a.join(" "),
  products_names: (("a".."l").to_a - ["a", "b", "c", "d", "e"]).join(" "),
}

$client.index index: 'myindex', type: 'outfits', id: 6, body: {
  title: ("l".."q").to_a,
  body: (("a".."l").to_a - ["a", "b", "c", "d"]).join(" "),
  products_names: (("a".."l").to_a - ["a", "b", "c", "d", "e"]).join(" "),
}



title = ("a".."l").to_a.join(" ")
body =  ("a".."l").to_a.join(" ")
products_names =  ("a".."l").to_a.join(" ")

binding.pry

$client.search(
  index: ["myindex"],
  type: "outfits",
  from: 0,
  size: 100,
  body: {
    query: {
      bool: {
        should: [
          {
            multi_match: {
              query: title,
              fields: "title",
              minimum_should_match: "90%",
            }
          },
          {
            multi_match: {
              query: body,
              fields: "body",
              minimum_should_match: "75%",
            }
          },
          {
            multi_match: {
              query: products_names,
              fields: "products_names",
              minimum_should_match: "75%",
            }
          },
        ],
        minimum_should_match: 2
      }
    }
  },
  pretty: true
)


$client.search(
  index: ["myindex"],
  type: "outfits",
  from: 0,
  size: 100,
  body: {
    # query: {
    #   multi_match: {
    #     query: title,
    #     fields: "title",
    #     minimum_should_match: "90%",
    #   }
    # },
    # query: {
    #   multi_match: {
    #     query: body,
    #     fields: "body",
    #     minimum_should_match: "75%",
    #   }
    # },
    query: {
      multi_match: {
        query: products_names,
        fields: "products_names",
        minimum_should_match: "75%",
      }
    },
  },
  pretty: true
)


$client.termvectors(index: "myindex", type: "outfits", id: 1,
  fields: ["*"],
)["term_vectors"].map { |k,v| [k, v["terms"].keys] }.to_h
