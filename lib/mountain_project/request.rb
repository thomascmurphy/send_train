module MountainProject
  class NotFound < StandardError; end
  class TooManyRequests < StandardError; end
  class InvalidAPIResponse < StandardError; end

  class Request

    include HTTParty
    base_uri 'https://mountainproject.com/data'

    def initialize()
      @options = { query: {key: Rails.application.secrets.mountainproject_api_key} }
    end

    def call(url, extra_query={})
      @options[:query] = @options[:query].merge(extra_query)
      response = self.class.get(url, @options)
      if response.respond_to?(:code) && !(200...300).include?(response.code)
        raise NotFound.new("404 Not Found #{url} #{extra_query}") if response.not_found?
        raise TooManyRequests.new("429 Rate limit exceeded, retry after: #{response.headers['retry-after']}, type: #{response.headers['x-rate-limit-type']}") if response.code == 429
        raise InvalidAPIResponse.new(response)
      end
      response
    end

    def get_user_by_email(user_email)
      call('', {action: "getUser", email: user_email})
    end

    def get_user_by_id(user_id)
      call('', {action: "getUser", userId: user_id})
    end

    def get_ticks(user_id)
      call('', {action: "getTicks", userId: user_id})
    end

    def get_to_dos(user_id)
      call('', {action: "getToDos", userId: user_id})
    end

    def get_routes(route_ids)
      call('', {action: "getRoutes", routeIds: route_ids.join(',')})
    end
  end
end
