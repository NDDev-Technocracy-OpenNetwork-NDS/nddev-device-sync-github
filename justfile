set shell := ["bash", "-euo", "pipefail", "-c"]

# Build-free source policy. Execution belongs in the recipes below.
check:
    just --fmt --check
    cargo fmt --all --check
    cargo deny --frozen --all-features check licenses sources
    cargo shear --frozen --deny-warnings

# Execution host or runner only; retain the complete harness and feature checks.
test:
    python3 -B -m unittest discover -s scripts -p 'test_*.py'
    cargo clippy --locked --workspace --all-targets -- -D warnings
    cargo clippy --locked --all-targets --all-features -- -D warnings
    cargo test --locked --workspace
    cargo test --locked --all-features

provider-check:
    cargo test --locked --test provider --test isolation

catalog-check:
    cargo clippy --locked --all-targets --features github-catalog -- -D warnings
    cargo test --locked --features github-catalog

commit-check:
    cargo clippy --locked --all-targets --features catalog-runtime,commit-sync -- -D warnings
    cargo test --locked --features catalog-runtime,commit-sync

github-negative-check:
    cargo test --locked --features github-catalog --test github_provider -- --ignored

ci-extras:
    cargo audit --deny warnings
    cargo test --locked --features github-catalog
    cargo check --locked --lib --features browser-bindings --target wasm32-unknown-unknown

ci-policy:
    cargo deny --frozen --all-features check licenses sources

ci-build:
    cargo build --locked --workspace --release

verify:
    just check
    just test
    just ci-extras
    just ci-build

# GitHub's runners lack the credential-store build inputs this workspace links; CI runs this
# before the checks (setup: true).
setup:
    if [ "${GITHUB_ACTIONS:-}" = true ] && [ "${RUNNER_ENVIRONMENT:-}" = github-hosted ]; then sudo apt-get update -qq && sudo apt-get install -qq --no-install-recommends -y libsecret-1-dev pkg-config; fi
    cargo fetch --locked
