# CLAUDE.md

@AGENTS.md

## Before opening a PR

Run `git fetch origin master && bin/lint` and fix every offense it reports
before you push or open a pull request. It runs the same RuboCop checks
houndci-bot uses on PRs, limited to the lines you changed. Re-run it after
fixing until it prints `0 offense(s) on changed lines`.
