require 'rubygems'
require 'bundler/setup'

require 'elasticsearch'
require 'pry'

$client = Elasticsearch::Client.new(
  url: "http://elastic:changeme@127.0.0.1:9200",
  log: true,
)

begin
  $client.transport.reload_connections!
rescue Faraday::ConnectionFailed => e
  puts "Unable to connect to elasticsearch"
  puts "you can start it using command:"
  puts ""
  puts "> docker-compose up"
  exit 1
end

puts $client.cluster.health

$client.indices.delete(index: "myindex") rescue puts("No index yet")

$client.indices.create(
  index: 'myindex',
  body: {
    mappings: {
      outfits: {
        properties: {
          title: {
            type: "text",
            analyzer: "english",
          },
          body: {
            type: "text",
            analyzer: "english",
          },
          products_uris: {
            type: "text",
            analyzer: "whitespace", # <- разбиение по пробелам
          }
        }
      }
    }
  }
)

$client.index index: 'myindex', type: 'outfits', id: 1, body: {
  title: (("a".."l").to_a - ["d"]).join(" "),
  body: (("a".."l").to_a - ["a", "b", "c"]).join(" "),
  products_uris: ("l".."q").to_a.join(" "),
}

$client.index index: 'myindex', type: 'outfits', id: 2, body: {
  title: (("a".."l").to_a - ["d"]).join(" "),
  body: ("l".."q").to_a.join(" "),
  products_uris: (("a".."l").to_a - ["a", "b", "c"]).join(" "),
}

$client.index index: 'myindex', type: 'outfits', id: 3, body: {
  title: ("l".."q").to_a,
  body: (("a".."l").to_a - ["a", "b", "c"]).join(" "),
  products_uris: (("a".."l").to_a - ["a", "b", "c"]).join(" "),

}

$client.index index: 'myindex', type: 'outfits', id: 4, body: {
  title: (("a".."l").to_a - ["d", "e", "f"]).join(" "),
  body: (("a".."l").to_a - ["a", "b", "c"]).join(" "),
  products_uris: ("l".."q").to_a.join(" "),
}

$client.index index: 'myindex', type: 'outfits', id: 5, body: {
  title: (("a".."l").to_a - ["d", "e", "f"]).join(" "),
  body: ("l".."q").to_a.join(" "),
  products_uris: (("a".."l").to_a - ["a", "b", "c", "d", "e"]).join(" "),
}

$client.index index: 'myindex', type: 'outfits', id: 6, body: {
  title: ("l".."q").to_a,
  body: (("a".."l").to_a - ["a", "b", "c", "d"]).join(" "),
  products_uris: (("a".."l").to_a - ["a", "b", "c", "d", "e"]).join(" "),
}



title = ("a".."l").to_a.join(" ")
body =  ("a".."l").to_a.join(" ")
products_uris =  ("a".."l").to_a.join(" ")

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
              query: products_uris,
              fields: "products_uris",
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
        query: products_uris,
        fields: "products_uris",
        minimum_should_match: "75%",
      }
    },
  },
  pretty: true
)


$client.termvectors(index: "myindex", type: "outfits", id: 1,
  fields: ["*"],
)["term_vectors"].map { |k,v| [k, v["terms"].keys] }.to_h
