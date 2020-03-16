# copied from https://github.com/rails/rails/issues/22965#issuecomment-568655496
# fixes an issue that caused the login form not to persist the session (see above for detail)

# frozen_string_literal: true

require 'json'

class CloudflareProxy
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) unless env['HTTP_CF_VISITOR']

    env['HTTP_X_FORWARDED_PROTO'] = JSON.parse(env['HTTP_CF_VISITOR'])['scheme']
    @app.call(env)
  end
end
