# CLAUDE.md

@AGENTS.md

## Before opening a PR

Run `bin/lint` (RuboCop and ESLint over the whole repo) and fix every
offense before you push or open a pull request. `bin/lint --fix` autocorrects
the safe ones. CI runs the same command, so a PR with offenses fails the Lint
check.
