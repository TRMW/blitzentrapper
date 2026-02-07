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

   **Required secrets (copy from your previous host):**
   - `DATABASE_URL` — Neon Postgres connection string
   - `COOKIE_SECRET_TOKEN` — Rails session secret
   - `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `AWS_BUCKET` — S3 storage
   - `BUGSNAG_API_KEY`, `BUGSNAG_RELEASE_STAGE` — Error tracking
   - `MEMCACHIER_SERVERS`, `MEMCACHIER_USERNAME`, `MEMCACHIER_PASSWORD` — Memcached (via [MemCachier](https://www.memcachier.com))
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

## Database (Neon Postgres)

Production and local development use [Neon](https://neon.tech) Postgres. The app expects `DATABASE_URL` to be set; when present, it overrides the default database config.

### Production

Set `DATABASE_URL` on Railway to your Neon production connection string (pooled is fine; the app sets `search_path` after connect). Get it from the [Neon Console](https://console.neon.tech) → your project → production branch → Connect.

### Local development — Neon branch clone of production

Use a **Neon branch** as a clone of production so local dev shares a copy of production data (you can refresh it by branching again from production).

1. **Create a dev branch in Neon**
   In [Neon Console](https://console.neon.tech) → your project → **Branches** → **Create branch**. Branch from your production branch (e.g. `main`) and name it e.g. `dev`. Copy the new branch's connection string (pooled is fine).

2. **Point local dev at the branch**
   Copy `.env.example` to `.env` and set `DATABASE_URL` to the branch connection string. Then:
   ```bash
   bundle install
   bin/rails db:migrate
   bin/rails db:seed     # optional
   ```

To refresh local from production: in Neon, create a new branch from production and update `DATABASE_URL` in `.env` to the new branch's connection string. Delete the old branch when done.

Without a `.env` file or with `DATABASE_URL` unset, development falls back to local Postgres (`blitzen_db_development`). The test environment always uses local Postgres (`blitzen_db_test`).
