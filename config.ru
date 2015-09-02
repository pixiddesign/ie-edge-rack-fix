# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

require 'rack'
require 'grape'
require 'pry'
require 'pry-doc'

class Middleware
  def initialize(app)
    @app = app
  end

  APPLICATION_JSON = 'application/json'.freeze
  CONTENT_LENGTH   = 'CONTENT_LENGTH'.freeze
  CONTENT_TYPE     = 'CONTENT_TYPE'.freeze
  HTTP_USER_AGENT  = 'HTTP_USER_AGENT'.freeze
  NAN              = 'NaN'.freeze
  NULL             = 'null'.freeze
  RACK_INPUT       = 'rack.input'.freeze
  TEXT_PLAIN       = 'text/plain'.freeze
  UNDEFINED        = 'undefined'.freeze

  def call(env)
    if env[Middleware::CONTENT_TYPE] and env[Middleware::CONTENT_TYPE].downcase.include?(Middleware::TEXT_PLAIN)
      env[Middleware::CONTENT_TYPE] = Middleware::APPLICATION_JSON
    end
    if env[Middleware::RACK_INPUT] and env[Middleware::RACK_INPUT].respond_to?(:size)
      size = env[Middleware::RACK_INPUT].size
      if size == 3 or size == 4 or size == 9
        body = env[Middleware::RACK_INPUT].string
        if body == Middleware::NAN or body == Middleware::NULL or body == Middleware::UNDEFINED
          env[Middleware::RACK_INPUT] = StringIO.new
          if env[Middleware::CONTENT_LENGTH]
            env[Middleware::CONTENT_LENGTH] = '0'
          end
        end
      end
    end
    return @app.call(env)
  end
end

class API < Grape::API
  format :json

  use Middleware

  get do
    present :ok, true
  end

  params do
    optional :option, type: String
  end
  post do
    present :ok, true
    present :option, params[:option] if params.has_key?(:option)
  end
end

run API
