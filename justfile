set shell := ["bash", "-euo", "pipefail", "-c"]

# Build-free source policy. Execution belongs in the recipes below.
check:
    cargo fmt --all --check
    cargo deny --locked --all-features check licenses sources
    cargo shear --locked --deny-warnings

# Execution host or runner only; retain the complete harness and feature checks.
test:
    python3 -B -m unittest discover -s scripts -p 'test_*.py'
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
