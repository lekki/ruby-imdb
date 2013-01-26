module IMDB
  class Search
    def movie(keyword, options = {:exact => false})
      url = "http://www.imdb.com/find?s=tt&q=#{CGI.escape(keyword)}"
      url += "&exact=true" if options.key?(:exact) && options[:exact]

      doc = Nokogiri::HTML(open(url))
      @ret_val = []
      if doc.at("h1.header")   # we're already being redirected to movie's page
        single_result(doc)
      else
        result_list(doc)
      end
      @ret_val
    end

    def to_hash
      i = 0
      tmp_hash = {}
      @ret_val.each {|r|
        tmp_hash[i] = r.to_hash
        i = i + 1
      }
      tmp_hash
    end

    def to_json
      to_hash.to_json
    end

    private
    def single_result(doc)
      title = doc.at("h1.header")
      link = doc.at("link[rel=canonical]")["href"]
      title = title.text.strip.gsub(/\s+/, " ")
      @ret_val <<  IMDB::Result.new( link[/\d+/], title , link )
    end

    def result_list(doc)
      @ret_val = doc.search('td[@class="result_text"]').reduce([]) do |ret_val, node|
         id =  node.children[1]["href"][/\d+/]
         link =  "http://www.imdb.com#{node.children[1]['href']}"
         year =  node.children[2].to_s.gsub(/[\s\(\)]/, '').to_i
         title =  node.children[1].content
         aka =  node.children.length >= 6 ? node.children[5].content.gsub(/[\"]/, '') : nil
         ret_val << IMDB::Result.new(id, title, link, year, aka)
         ret_val
      end
    end
  end # Search

  class Result < IMDB::Skeleton
    def initialize(imdb_id, title, link, year = nil, aka = nil)
      super("Result",{
        :title => String,
        :link => String,
        :imdb_id => String,
        :year => Integer,
        :aka => String}, [:imdb_id])
      @title   = title
      @link    = link
      @imdb_id = imdb_id
      @year = year
      @aka = aka
    end

    def title
      @title
    end

    def link
      @link
    end

    def imdb_id
      @imdb_id
    end

    def year
      @year
    end

    def aka
      @aka
    end

    def movie
      Movie.new(@imdb_id)
    end

  end
end

