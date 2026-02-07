# Neon (and some Postgres hosts) leave search_path unset. Neon's pooler rejects
# search_path as a startup parameter, so set it after connect via a normal SQL command.
Rails.application.config.after_initialize do
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(Module.new do
    def connect
      super
      execute("SET search_path TO public")
    end
  end)
end
