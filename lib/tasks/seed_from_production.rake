namespace :db do
  desc "Seed the current DB from the production snapshot if this is a non-production env with an empty DB"
  task :ensure_seeded => :environment do
    env_name = ENV["RAILWAY_ENVIRONMENT_NAME"].to_s
    src      = ENV["SEED_SOURCE_DATABASE_URL"].to_s
    dst      = ENV["DATABASE_URL"].to_s

    if env_name == "production"
      Rails.logger.info("[ensure_seeded] production env, skipping")
      next
    end

    if src.empty? || dst.empty?
      Rails.logger.info("[ensure_seeded] SEED_SOURCE_DATABASE_URL or DATABASE_URL not set, skipping")
      next
    end

    if src == dst
      Rails.logger.info("[ensure_seeded] source and destination are the same DB, skipping")
      next
    end

    has_data = begin
      conn = ActiveRecord::Base.connection
      conn.tables.include?("schema_migrations") &&
        conn.execute("SELECT 1 FROM schema_migrations LIMIT 1").any?
    rescue ActiveRecord::StatementInvalid, PG::Error => e
      Rails.logger.warn("[ensure_seeded] could not introspect DB (#{e.class}: #{e.message}), assuming empty")
      false
    end

    if has_data
      Rails.logger.info("[ensure_seeded] DB already populated, skipping")
      next
    end

    dump = "/tmp/seed.dump"
    Rails.logger.info("[ensure_seeded] dumping production snapshot to #{dump}")
    sh "pg_dump --no-owner --no-acl -Fc -f #{dump} '#{src}'"
    Rails.logger.info("[ensure_seeded] restoring snapshot into PR DB")
    sh "pg_restore --no-owner --no-acl --clean --if-exists -d '#{dst}' #{dump}"
    Rails.logger.info("[ensure_seeded] done")
  end
end
