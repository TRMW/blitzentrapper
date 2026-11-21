# AGENTS.md

## Cursor Cloud specific instructions

This is a Ruby on Rails 7.1 web application (Blitzen Trapper band site) with a small React 19 widget (the setlist editor on show pages) bundled by esbuild through jsbundling-rails.

### Key facts

- **Ruby 3.3.14** (the Gemfile's `ruby` line; Railway's Nixpacks build installs that exact version). Any local 3.3.x works if you temporarily match the Gemfile line, e.g. rbenv's `~/.rbenv/versions/3.3.6`
- **PostgreSQL 16** local instance (trust auth configured for localhost)
- **Node.js >=22.12** + **Yarn >=1.22** for the JS build and tests
- React code lives in `app/javascript` (entry point `setlist.jsx`). `yarn build` bundles it into `app/assets/builds/setlist.js` (git-ignored), which Sprockets serves; `rake assets:precompile` runs it automatically. In development, run `yarn build --watch` alongside the server (see `Procfile.dev`).
- JS tests: `yarn test` (Vitest + Testing Library, in `test/javascript`)
- `bin/lint` runs RuboCop and ESLint; run it before opening a PR (see "Linting" below)
- Rails tests: `bin/rails test` (run `yarn build` first so the setlist asset exists). CI runs them in `.github/workflows/rails-test.yml`.
- `db/schema.rb` was corrected on 2026-11-21 to match the production database (it had drifted since 2018). Keep it in step with production: run new migrations locally and commit the regenerated schema.rb.

### Running the dev server

The injected environment includes production secrets (`RAILS_ENV=production`, `DATABASE_URL`, etc.). You **must** override them for local development:

```bash
export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
export RAILS_ENV=development RACK_ENV=development NODE_ENV=development
unset DATABASE_URL
bin/rails server -p 3000
```

### Database

- Dev DB: `blitzen_db_development` (local PG, no password needed — trust auth)
- Test DB: `blitzen_db_test` (local PG, no password needed)
- Migrations: `RAILS_ENV=development bin/rails db:migrate` (must unset `DATABASE_URL` first)
- The `DATABASE_URL` secret points to a remote Neon Postgres instance; unset it when working with local PG.

### Running tests

```bash
export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
unset DATABASE_URL
bin/rails test
```

### Linting

`bin/lint` lints the whole repo and exits 1 if anything is wrong:

- **Ruby**: RuboCop with Rails' default config, [rubocop-rails-omakase](https://github.com/rails/rubocop-rails-omakase) (`.rubocop.yml`). Mostly layout and consistency: double-quoted strings, `[ :a, :b ]` with spaces inside array brackets, Ruby 1.9 hash syntax, 2-space indentation, no trailing whitespace.
- **JavaScript/React**: ESLint 9 (`eslint.config.mjs`) with `@eslint/js` recommended, `eslint-plugin-react` and `eslint-plugin-react-hooks`. Components are function components using hooks; `react/prop-types` is off because React 19 ignores propTypes.

```bash
bin/lint          # report offenses
bin/lint --fix    # autocorrect what's safe (rubocop -a, eslint --fix), then report the rest
```

Run `bin/lint` before opening or updating a PR and fix everything it reports. The repo is fully clean, so any offense is from your change. The same command runs in GitHub Actions (`.github/workflows/lint.yml`) on every PR. Hound's checks are turned off in `.hound.yml` because its old rules conflict with these.

`bin/lint` uses `bundle exec rubocop` when the bundle loads. If your Ruby doesn't match the Gemfile's pinned version, it installs the RuboCop gem versions from `Gemfile.lock` as standalone gems. It runs `yarn install` first if ESLint isn't installed.

### Gotchas

- reCAPTCHA is enabled on user signup and contact pages. The injected `RECAPTCHA_SITE_KEY`/`RECAPTCHA_SECRET_KEY` are for the production domain, not localhost. To create users locally, use `bin/rails console` (e.g. `User.new(login: "name", email: "e@x.com", password: "pw").save!`).
- Run `yarn install` after switching branches if JS deps changed. `esbuild` is a regular dependency (not a devDependency) because production installs with `NODE_ENV=production`, which skips devDependencies.
- Standard dev commands are in README.md and `Procfile`. `bin/rails server` starts Puma on port 3000.
