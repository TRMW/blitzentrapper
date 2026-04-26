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

The app runs on [Railway](https://railway.app) using [Railpack](https://railpack.com), which auto-detects the Ruby/Node stack and reads the `Procfile` for start and release commands. Postgres is also hosted on Railway as a managed service.

### Environments

- **`production`** — the only persistent environment. Auto-deploys from `master`. Includes the Postgres database service. Hosts `forum.blitzentrapper.net`.
- **PR environments** — temporary, spun up by Railway when a pull request is opened against `master` and torn down (including their Postgres volume) when the PR is merged or closed. Each PR env is duplicated from `production`, so it gets its own Postgres service whose data is auto-seeded from the production database on first deploy.

### First-time setup (already done; documented for reference)

1. **Create a new project** on [Railway](https://railway.app) and connect this GitHub repo.
2. Railway auto-detects the Gemfile and package.json, installs dependencies, and precompiles assets.
3. Add a **Postgres** service from Railway's database templates. Wire the app's `DATABASE_URL` to `${{Postgres.DATABASE_PUBLIC_URL}}` (the public TCP-proxy URL — required because Railway runs the Procfile `release:` command during the Docker build, which doesn't have access to the private network).
4. In the Railway dashboard, go to **Variables** and add the following:

   **Required platform vars (per service):**
   | Variable | Value |
   |---|---|
   | `RAILS_ENV` | `production` |
   | `RACK_ENV` | `production` |
   | `RAILS_SERVE_STATIC_FILES` | `true` |
   | `RAILS_LOG_TO_STDOUT` | `true` |
   | `NODE_ENV` | `production` |
   | `LANG` | `en_US.UTF-8` |
   | `DATABASE_URL` | `${{Postgres.DATABASE_PUBLIC_URL}}` |
   | `SEED_SOURCE_DATABASE_URL` | `${{shared.SEED_SOURCE_DATABASE_URL}}` |

   **Required secrets (copy from your previous host):**
   - `COOKIE_SECRET_TOKEN` / `SECRET_KEY_BASE` — Rails session secret
   - `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `AWS_BUCKET` — S3 storage
   - `BUGSNAG_API_KEY`, `BUGSNAG_RELEASE_STAGE` — Error tracking
   - `TUMBLR_API_KEY` — Tumblr integration
   - `RECAPTCHA_SITE_KEY`, `RECAPTCHA_SECRET_KEY` — reCAPTCHA

   **Shared variables (project-level, for PR-env auto-seeding):**
   - `SEED_SOURCE_DATABASE_URL` — production Postgres' public URL. PR environments inherit this when duplicated from production, and the release-phase `db:ensure_seeded` task uses it to copy production data into the empty PR database on first deploy.

5. Enable **PR Environments** in Project Settings → Environments. Set **Base Environment** to `production` so PR envs are duplicated from prod (services, variables, and Postgres-with-an-empty-volume).

### How deploys work

Each push to the deployed branch triggers a deploy:

1. **Build** — Railpack detects Ruby + Node, runs `bundle install`, `yarn install`, `rake assets:precompile`, and `rake db:migrate` (Railway runs the Procfile `release:` line as a build step).
2. **Release** — `bundle exec rake db:ensure_seeded db:migrate`. In production, `db:ensure_seeded` is a no-op. In PR envs, it `pg_dump`s production and `pg_restore`s into the new PR Postgres on first deploy only.
3. **Start** — `bundle exec puma -C config/puma.rb` launches the web server.

The release-phase seeding requires `pg_dump`/`pg_restore` in the deploy image; this is configured in [`railpack.json`](railpack.json) via `deploy.aptPackages`.

### Running one-off commands

```bash
railway run bundle exec rails console
railway run bundle exec rake db:seed
```

## Database (Railway Postgres)

Production uses a Railway-managed Postgres service in the `production` environment. The app expects `DATABASE_URL` to be set; when present, it overrides the default database config.

### Local development

Run a local Postgres (Postgres.app, Homebrew, Docker — your call) and you'll get a local `blitzen_db_development` database when you run `bin/rails db:setup`. The test env always uses a local `blitzen_db_test`.

If you'd like local dev to mirror production data, dump the production database via Railway's TCP proxy and restore it into your local Postgres:

```bash
# Get the production Postgres public URL from Railway
PROD_URL=$(railway variables --service Postgres --json --environment production | jq -r .DATABASE_PUBLIC_URL)

pg_dump --no-owner --no-acl -Fc -f /tmp/blitzen.dump "$PROD_URL"
dropdb blitzen_db_development
createdb blitzen_db_development
pg_restore --no-owner --no-acl -d blitzen_db_development /tmp/blitzen.dump
```

Without `DATABASE_URL` set, development falls back to local Postgres (`blitzen_db_development`) configured in `config/database.yml`.
