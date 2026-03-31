```
    ____  ___ __
   / __ )/ (_) /_____  ___  ____
  / __  / / / __/_  / / _ \/ __ \
 / /_/ / / / /_  / /_/  __/ / / /
/_______/_/\__/ /___/\___/_/ /_/
 /_  __/________ _____  ____  ___  _____
  / / / ___/ __ `/ __ \/ __ \/ _ \/ ___/
 / / / /  / /_/ / /_/ / /_/ /  __/ /
/_/ /_/   \__,_/ .___/ .___/\___/_/
              /_/   /_/
```

## This is the code that makes up the official [Blitzen Trapper band site](http://www.blitzentrapper.net).

If you see a bug, please
feel free to [submit a fix](https://github.com/TRMW/blitzentrapper/pulls), or [file an issue](https://github.com/TRMW/blitzentrapper/issues).

**Thanks for trapping!**

## Deployment (Railway)

The app runs on [Railway](https://railway.app). Railway auto-detects the Ruby/Node stack via Nixpacks and reads the `Procfile` for start and release commands.

### First-time setup

1. **Create a new project** on [Railway](https://railway.app) and connect your GitHub repo.
2. Railway auto-detects the Gemfile and package.json, installs dependencies, and precompiles assets.
3. In the Railway dashboard, go to **Variables** and add the following environment variables:

   **Required platform vars:**
   | Variable | Value |
   |---|---|
   | `RAILS_ENV` | `production` |
   | `RACK_ENV` | `production` |
   | `RAILS_SERVE_STATIC_FILES` | `true` |
   | `RAILS_LOG_TO_STDOUT` | `true` |
   | `NODE_ENV` | `production` |
   | `LANG` | `en_US.UTF-8` |

   **Required secrets:**
   - `DATABASE_URL` — Railway Postgres connection string (add a Postgres plugin to your Railway project and use its `DATABASE_URL`)
   - `COOKIE_SECRET_TOKEN` — Rails session secret
   - `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `AWS_BUCKET` — S3 storage
   - `BUGSNAG_API_KEY`, `BUGSNAG_RELEASE_STAGE` — Error tracking
   - `TUMBLR_API_KEY` — Tumblr integration
   - `RECAPTCHA_SITE_KEY`, `RECAPTCHA_SECRET_KEY` — reCAPTCHA

4. Deploy. Railway runs the Nixpacks build (bundle install + yarn install + asset precompile), then `rake db:migrate` (release phase), then starts Puma.

### How deploys work

Each push to the connected branch triggers a deploy:

1. **Build** — Nixpacks detects Ruby + Node, runs `bundle install`, `yarn install`, and `rake assets:precompile`.
2. **Release** — `bundle exec rake db:migrate` runs pending migrations (from `Procfile`).
3. **Start** — `bundle exec puma -C config/puma.rb` launches the web server (from `Procfile`).

### Running one-off commands

Use the Railway CLI to run console sessions or rake tasks:

```bash
railway run bundle exec rails console
railway run bundle exec rake db:seed
```

## Database (Railway Postgres)

Production uses a Railway Postgres plugin. The app reads `DATABASE_URL`; when present, it overrides the default database config.

### Production

Add a **Postgres plugin** to your Railway project. Railway automatically provisions a PostgreSQL instance and exposes `DATABASE_URL` (along with individual `PGHOST`, `PGPORT`, etc. variables) to your service. No extra configuration is needed — the app picks up `DATABASE_URL` at boot.

### Migrating from Neon

A one-step migration script is included at `bin/migrate-neon-to-railway`. It dumps the Neon database, restores it into the Railway Postgres plugin, and verifies row counts.

```bash
# 1. Install & authenticate Railway CLI
npm install -g @railway/cli
railway login
railway link   # select your project + environment

# 2. Run the migration (set NEON_DATABASE_URL to your Neon connection string)
NEON_DATABASE_URL="postgres://user:pass@ep-xyz.us-east-2.aws.neon.tech/neondb" \
  bin/migrate-neon-to-railway

# If Neon runs PG 17 and your local pg_dump is older, point to PG 17 tools:
PG_DUMP=/usr/lib/postgresql/17/bin/pg_dump \
PG_RESTORE=/usr/lib/postgresql/17/bin/pg_restore \
NEON_DATABASE_URL="postgres://..." \
  bin/migrate-neon-to-railway
```

The script fetches the Railway `DATABASE_URL` automatically via `railway variables`.

### Local development

For local development, you have two options:

1. **Use a local Postgres instance** (default) — with `DATABASE_URL` unset, the app connects to `blitzen_db_development` on localhost.
2. **Connect to a remote database** — copy `.env.example` to `.env` and set `DATABASE_URL` to a Postgres connection string. Then:
   ```bash
   bundle install
   bin/rails db:migrate
   bin/rails db:seed     # optional
   ```

Without a `.env` file or with `DATABASE_URL` unset, development falls back to local Postgres (`blitzen_db_development`). The test environment always uses local Postgres (`blitzen_db_test`).
