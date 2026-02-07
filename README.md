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

## Database (Neon Postgres)

Production and local development use [Neon](https://neon.tech) Postgres. The app expects `DATABASE_URL` to be set; when present, it overrides the default database config.

### Production (Heroku)

Set the Heroku config var `DATABASE_URL` to your Neon **direct** (non-pooled) connection string. Get it from the [Neon Console](https://console.neon.tech) → your project → Connect. Use the direct connection so release-phase migrations (`bin/rake db:migrate`) run correctly.

### Local development

1. Create a dedicated dev/staging database on Neon (e.g. a branch in your Neon project or a second project). Copy its **direct** connection string.
2. Copy `.env.example` to `.env` and set `DATABASE_URL` to that Neon dev connection string.
3. Run `bundle install` (the `dotenv-rails` gem loads `.env` in development/test).
4. Bootstrap the dev database: `bin/rails db:create` (if needed), `bin/rails db:migrate`, and optionally `bin/rails db:seed`.

Without a `.env` file or with `DATABASE_URL` unset, development falls back to local Postgres (`blitzen_db_development`). The test environment always uses local Postgres (`blitzen_db_test`) for CI and `rails test`.
