ActiveSupport.on_load(:active_record) do
  require "active_record/connection_adapters/postgresql_adapter"
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(Module.new do
    def configure_connection
      execute("SET search_path TO public")
      super
    end
  end)
end
