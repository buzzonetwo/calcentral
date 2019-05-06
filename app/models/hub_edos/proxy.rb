module HubEdos
  class Proxy < BaseProxy

    include ClassLogger
    include Proxies::Mockable
    include CampusSolutions::ProfileFeatureFlagged
    include User::Identifiers
    include SafeJsonParser
    include ResponseHandler

    def initialize(options = {})
      super(Settings.hub_edos_proxy, options)
      if @fake
        @campus_solutions_id = lookup_campus_solutions_id
        initialize_mocks
      end
    end

    def instance_key
      @uid
    end

    def json_filename
      ''
    end

    def mock_json
      read_file('fixtures', 'json', json_filename)
    end

    def mock_request
      super.merge(uri_matching: url)
    end

    def get
      if is_feature_enabled
        wrapped_response = self.class.handling_exceptions(instance_key) do
          get_internal
        end
        internal_response = wrapped_response ? wrapped_response[:response] : {}
        process_response_after_caching internal_response
      else
        {}
      end
    end

    def process_response_after_caching(internal_response)
      if internal_response[:noStudentId] || internal_response[:studentNotFound] || internal_response[:statusCode] < 400
        internal_response
      else
        internal_response.merge({
          errored: true
        })
      end
    end

    def get_internal(opts = {})
      @campus_solutions_id ||= lookup_campus_solutions_id
      if @campus_solutions_id.nil?
        logger.warn "Lookup of campus_solutions_id for uid #{@uid} failed, cannot call Campus Solutions API"
        {
          feed: empty_feed,
          noStudentId: true
        }
      else
        logger.info "Fake = #{@fake}; Making request to #{url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
        opts = opts.merge(request_options)
        response = get_response(url, opts)
        logger.debug "Remote server status #{response.code}, Body = #{response.body.force_encoding('UTF-8')}"
        if response.code == 404
          if response['StudentResponse'] && response['StudentResponse']['message'].in?(['Student Not Found', 'Data not found.'])
            logger.warn "Response '#{response['StudentResponse']['message']}' for UID #{@uid}, Campus Solutions ID #{@campus_solutions_id}"
            feed = build_feed response
            student_not_found = true
          else
            logger.error "Unexpected 404 response for UID #{@uid}, Campus Solutions ID #{@campus_solutions_id}: #{response}"
            feed = empty_feed
          end
        else
          feed = build_feed response
        end
        {
          statusCode: response.code,
          feed: feed,
          studentNotFound: student_not_found
        }
      end
    end

    def url
      @settings.base_url
    end

    def request_options
      opts = {
        headers: {
          'Accept' => 'application/json'
        },
        on_error: {
          rescue_status: 404
        }
      }
      if @settings.app_id.present? && @settings.app_key.present?
        # app ID and token are used on the prod/staging Hub servers
        opts[:headers]['app_id'] = @settings.app_id
        opts[:headers]['app_key'] = @settings.app_key
      else
        # basic auth is used on Hub dev servers
        opts[:basic_auth] = {
          username: @settings.username,
          password: @settings.password
        }
      end
      opts
    end

    def parse_response(response)
      safe_json response.body.force_encoding('UTF-8')
    end

    def build_feed(response)
      unwrap_response parse_response(response)
    end

    def empty_feed
      {}
    end

  end
end

