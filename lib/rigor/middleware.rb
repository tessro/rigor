module Rigor
  class Middleware
    def initialize(app, options={})
      @app, @options = app, options
    end

    attr_reader :app, :options

    def call(env)
      request = ::Rack::Request.new(env)
      cookies = treatment_cookies(request)
      process_treatment_cookies(cookies)
      status, headers, body = app.call(env)
      response = ::Rack::Response.new(body, status, headers)
      delete_treatment_cookies(response, cookies)
      response.finish
    end

    protected

    def treatment_cookies(request)
      request.cookies.select { |k,v| k =~ /^_rigor_experiment_/ }
    end

    def process_treatment_cookies(cookies)
      Experiment.assign_all(cookies)
    end

    def delete_treatment_cookies(response, cookies)
      cookies.each do |key, value|
        response.delete_cookie(key)
      end
    end
  end
end
