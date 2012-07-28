require 'rigor/middleware/cookie_jar'
require 'rigor/middleware/session'

module Rigor
  class Middleware
    def initialize(app, options={})
      @app, @options = app, options
    end

    attr_reader :app, :options

    def call(env)
      request = ::Rack::Request.new(env)
      cookies = Rigor::Middleware::CookieJar.new(request.cookies)
      session_id = request.cookies['rigor.session_id'] || Digest::SHA256.hexdigest(rand.to_s)
      session = Rigor::Middleware::Session.new(session_id)
      session.load_treatment_cookies(cookies)
      Rigor.subject = Rigor::Subject.new(session)

      status, headers, body = app.call(env)

      Rigor.subject.save

      response = ::Rack::Response.new(body, status, headers)
      response.set_cookie('rigor.session_id', value: session_id, path: '/', expires: 1.year.from_now)
      delete_treatment_cookies(response, cookies)

      response.finish
    end

    protected

    def delete_treatment_cookies(response, cookies)
      cookies.each do |key, value|
        response.delete_cookie(key)
      end
    end
  end
end
