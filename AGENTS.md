# AGENTS.md

## Cursor Cloud specific instructions

This is a Ruby on Rails 6.0.6 web application (Blitzen Trapper band site) with a React frontend via Webpacker.

### Key facts

- **Ruby 3.1.0** installed via rbenv at `~/.rbenv/versions/3.1.0`
- **PostgreSQL 16** local instance (trust auth configured for localhost)
- **Node.js >=18** + **Yarn >=1.22** for Webpacker/JS assets
- RuboCop mirrors houndci-bot's PR review: run `bin/lint` before opening a PR (see "Linting" below)
- One integration test exists: `bin/rails test`

### Running the dev server

The injected environment includes production secrets (`RAILS_ENV=production`, `DATABASE_URL`, etc.). You **must** override them for local development:

```bash
export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
export RAILS_ENV=development RACK_ENV=development NODE_ENV=development
unset DATABASE_URL
export COOKIE_SECRET_TOKEN=$(ruby -rsecurerandom -e 'puts SecureRandom.hex(64)')
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

houndci-bot reviews every PR with RuboCop and comments on offenses in changed lines. `bin/lint` runs the same checks locally (config in `.rubocop.yml`, tuned to Hound's defaults) and reports only offenses on lines changed since `origin/master`, including uncommitted and untracked files.

```bash
git fetch origin master
bin/lint          # offenses on changed lines; exit 1 if any
bin/lint --all    # every offense in the changed files
```

Before opening or updating a PR, run `bin/lint` and fix everything it reports, so Hound has nothing to flag. Common ones: `# frozen_string_literal: true` at the top of new Ruby files, single quotes, `%i[]`/`%w[]` arrays, new-style hash syntax, 80-char lines, alphabetical gems in the Gemfile, and Metrics limits (methods <= 10 lines, ABC size <= 15; extract private methods). Don't reformat untouched legacy code. Repo-wide RuboCop shows ~1,000 old offenses, which is why `bin/lint` filters to changed lines.

`bin/lint` uses `bundle exec rubocop` when the bundle loads. If your Ruby doesn't match the Gemfile's pinned 3.1.0, it installs and runs the same RuboCop version from `Gemfile.lock` as a standalone gem.

### Gotchas

- reCAPTCHA is enabled on user signup and contact pages. The injected `RECAPTCHA_SITE_KEY`/`RECAPTCHA_SECRET_KEY` are for the production domain, not localhost. To create users locally, use `bin/rails console` (e.g. `User.new(login: "name", email: "e@x.com", password: "pw").save!`).
- `yarn install --check-files` may be needed after switching branches if JS deps change; Webpacker's integrity check will refuse to start the server otherwise.
- Standard dev commands are in README.md and `Procfile`. `bin/rails server` starts Puma on port 3000.
