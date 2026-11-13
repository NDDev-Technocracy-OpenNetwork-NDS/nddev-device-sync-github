set shell := ["bash", "-euo", "pipefail", "-c"]

check:
    python3 -B -m unittest discover -s scripts -p 'test_*.py'
    cargo fmt -- --check
    cargo clippy --locked --all-targets --all-features -- -D warnings
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

# The checks the former CI library ran from .github/nddev-ci.toml; CI calls them through
# `just test` on a pull request and `just verify` on dev.
test:
    cargo clippy --locked --workspace --all-targets -- -D warnings
    cargo test --locked --workspace

ci-extras:
    python3 -B -m unittest discover -s scripts -p 'test_*.py'
    cargo audit --deny warnings
    cargo test --locked --features github-catalog
    cargo test --locked --all-features
    cargo check --locked --lib --features browser-bindings --target wasm32-unknown-unknown

ci-policy:
    cargo deny --locked check licenses sources

ci-build:
    cargo build --locked --workspace --release

verify:
    just check
    just test
    just ci-policy
    just ci-extras
    just ci-build
