set shell := ["bash", "-euo", "pipefail", "-c"]

# List the project commands.
default:
    @just --list

check:
    just --fmt --check
    cargo deny --locked check licenses sources
    cargo fmt -- --check

provider-check:
    cargo test --locked --test provider --test isolation

catalog-check:
    cargo test --locked --features github-catalog

commit-check:
    cargo test --locked --features catalog-runtime,commit-sync

github-negative-check:
    cargo test --locked --features github-catalog --test github_provider -- --ignored

# Fetch locked source dependencies without compiling.
setup:
    cargo fetch --locked

# Run the native workspace and tooling regressions.
test: build audit
    cargo test --locked --workspace
    cargo test --locked --features github-catalog
    cargo check --locked --lib --features browser-bindings --target wasm32-unknown-unknown
    python3 -B -m unittest discover -s scripts -p 'test_*.py'
    cargo clippy --locked --all-targets --all-features -- -D warnings
    cargo test --locked --all-features
    cargo clippy --locked --all-targets --features github-catalog -- -D warnings
    cargo clippy --locked --all-targets --features catalog-runtime,commit-sync -- -D warnings

# Compile the locked release workspace.
build:
    cargo build --locked --workspace --release

# Check current RustSec advisories.
audit:
    cargo audit --deny warnings

# Run source checks, native tests and the advisory audit.
verify: check test audit build
