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
    sh %(pg_dump --no-owner --no-acl -Fc -f #{dump} ) +
       %(--dbname="$SEED_SOURCE_DATABASE_URL")
    Rails.logger.info("[ensure_seeded] restoring snapshot into PR DB")
    sh %(pg_restore --no-owner --no-acl --clean --if-exists ) +
       %(--dbname="$DATABASE_URL" #{dump})
    Rails.logger.info("[ensure_seeded] done")
  end

  # pg_dump refuses to dump a server newer than itself. The build image's
  # postgresql-client (if any) is older than production's Postgres, so install
  # a matching client from the PostgreSQL apt repo. This only runs when a
  # preview DB actually needs seeding, so production builds are unaffected.
  def ensure_pg_client!(src)
    server_major = pg_server_major(src)
    client_major = `pg_dump --version 2>/dev/null`[/\d+/].to_i
    return if client_major >= server_major

    Rails.logger.info("[ensure_seeded] installing postgresql-client-" \
                      "#{server_major} (have #{client_major})")
    install_pg_client(server_major)
    # Call the new client directly in case an older pg_dump is first on PATH.
    ENV['PATH'] = "/usr/lib/postgresql/#{server_major}/bin:#{ENV['PATH']}"
  end

  def pg_server_major(url)
    conn = PG.connect(url)
    conn.server_version / 10_000
  ensure
    conn&.close
  end

  PGDG_KEY = '/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc'
  PGDG_KEY_URL = 'https://www.postgresql.org/media/keys/ACCC4CF8.asc'
  PGDG_REPO = 'https://apt.postgresql.org/pub/repos/apt'

  def install_pg_client(major)
    sudo = Process.uid.zero? ? '' : 'sudo '
    sh <<~SH
      set -e
      #{sudo}install -d #{File.dirname(PGDG_KEY)}
      #{sudo}curl -fsSL -o #{PGDG_KEY} #{PGDG_KEY_URL}
      . /etc/os-release
      echo "deb [signed-by=#{PGDG_KEY}] #{PGDG_REPO}" \
        "${VERSION_CODENAME}-pgdg main" \
        | #{sudo}tee /etc/apt/sources.list.d/pgdg.list
      #{sudo}apt-get update -qq
      #{sudo}apt-get install -y -qq --no-install-recommends \
        postgresql-client-#{major}
    SH
  end
end
