module GetAstro
  module Api
    class Action
      def initialize()

      end

      def events
        response = Faraday.get('https://api.xmltime.com/astronomy?accesskey=j0TXcDOXLK&expires=2018-10-20T13%3A35%3A10%2B00%3A00&signature=5DUWylt3bKocQ8ihlNT3aLb4uRo%3D&version=2&object=sun&placeid=norway%2Foslo&startdt=2018-10-20')
        date = MultiJson.load(response.body, symbolize_keys: true)
        puts JSON.pretty_generate(date)
      end
    end
  end

end