module IMDB
  class Configuration
    class << self
      def caching=(caching)
        @caching = caching
      end
      
      def caching
        @caching
      end
      
      def db(param={})

      end
    end
  end
end