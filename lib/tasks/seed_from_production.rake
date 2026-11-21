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

    ensure_pg_client!(src)

    dump = "/tmp/seed.dump"
    Rails.logger.info("[ensure_seeded] dumping production snapshot to #{dump}")
    # Pass connection URLs through the environment so Rake's command echo
    # (and its failure message) never prints the database password.
    sh %(pg_dump --no-owner --no-acl -Fc -f #{dump} --dbname="$SEED_SOURCE_DATABASE_URL")
    Rails.logger.info("[ensure_seeded] restoring snapshot into PR DB")
    sh %(pg_restore --no-owner --no-acl --clean --if-exists --dbname="$DATABASE_URL" #{dump})
    Rails.logger.info("[ensure_seeded] done")
  end

  # pg_dump refuses to dump a server newer than itself. The build image's
  # postgresql-client (if any) is older than production's Postgres, so install
  # a matching client from the PostgreSQL apt repo. This only runs when a
  # preview DB actually needs seeding, so production builds are unaffected.
  def ensure_pg_client!(src)
    conn = PG.connect(src)
    server_major = conn.server_version / 10_000
    conn.close
    client_major = `pg_dump --version 2>/dev/null`[/\d+/].to_i
    return if client_major >= server_major

    Rails.logger.info("[ensure_seeded] installing postgresql-client-#{server_major} (have #{client_major.zero? ? 'none' : client_major})")
    sudo = Process.uid.zero? ? "" : "sudo "
    sh <<~SH
      set -e
      #{sudo}install -d /usr/share/postgresql-common/pgdg
      #{sudo}curl -fsSL -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc
      . /etc/os-release
      echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt ${VERSION_CODENAME}-pgdg main" | #{sudo}tee /etc/apt/sources.list.d/pgdg.list
      #{sudo}apt-get update -qq
      #{sudo}apt-get install -y -qq --no-install-recommends postgresql-client-#{server_major}
    SH
    # Debian's wrapper picks the newest installed client, but call it directly
    # in case an older pg_dump comes first on PATH.
    ENV["PATH"] = "/usr/lib/postgresql/#{server_major}/bin:#{ENV['PATH']}"
  end
end
