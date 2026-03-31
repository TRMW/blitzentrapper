# Some managed Postgres providers (connection poolers, serverless proxies, etc.)
# leave search_path unset or reject it as a startup parameter. Set it explicitly
# after the connection is established so Rails always finds the public schema.
Rails.application.config.after_initialize do
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(Module.new do
    def configure_connection
      execute("SET search_path TO public")
      super
    end
  end)
end
