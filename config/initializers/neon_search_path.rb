# Neon (and some Postgres hosts) leave search_path unset. Neon's pooler rejects
# search_path as a startup parameter, so set it in configure_connection (runs
# after the connection is established) via a normal SQL command.
# Rails 7.1 loads the adapter lazily, so hook in when it loads.
ActiveSupport.on_load(:active_record_postgresqladapter) do
  prepend(Module.new do
    def configure_connection
      execute("SET search_path TO public")
      super
    end
  end)
end
