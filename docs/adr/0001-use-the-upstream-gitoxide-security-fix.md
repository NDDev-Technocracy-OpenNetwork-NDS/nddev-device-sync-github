# Use the upstream Gitoxide security fix pending release

Accepted on 20 November 2026.

## Context

Gitoxide 0.90.0 resolves `faster-hex 0.10.1` and the affected `heapless 0.8.0`. The current releases of `gix-hash` and `gix-packetline` retain that dependency. RustSec records the repaired `heapless` line in [RUSTSEC-2026-0574](https://rustsec.org/advisories/RUSTSEC-2026-0574.html).

## Decision

Pin [Gitoxide revision `945b52aa300665c69f0be80f8ae941505f2128b3`](https://github.com/GitoxideLabs/gitoxide/commit/945b52aa300665c69f0be80f8ae941505f2128b3) from its canonical repository. It replaces `faster-hex 0.10.1` with 1.0.0 and removes `heapless` from this dependency chain. [Upstream CI](https://github.com/GitoxideLabs/gitoxide/actions/runs/43810272435) passed on that revision. Source policy permits the exact canonical repository and requires commit revisions for Git sources. The normal audit, license, source and native checks still apply.

## Consequences

Consumers may take this checked graph with the same upstream revision. When Gitoxide publishes a compatible stable version with the fix and it passes the existing checks, return to crates.io and remove the temporary upstream repository from the source allowlists.
