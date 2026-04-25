## 1.9.0

- Coordinated ecosystem release alignment to version 1.9.0.
- Updated instructional scripts to avoid hard-wiring `alive`/`active_followup` into the urban delivery starter schema and observation paths.
- Clarified bundle guidance for terminal-event-driven lifecycle semantics and explicit `Entity$new()` initialization.
- Dependency floor updated to `fluxCore (>= 1.9.0)`.

## 1.8.1

- Converted staged template scripts into runnable defaults while preserving
  instructional comments.
- Activated the urban-delivery worked example across schema, event proposal,
  transition, stop, observe, and derived-variable scaffolds.
- Expanded template tests to validate end-to-end run behavior with the default
  bundle wiring and derived-variable output checks.
- Added optional `refresh_rules` guidance in bundle scaffolding and README,
  with safe default behavior still documented as refresh-all.

## 1.8.0

- Refreshed template onboarding scripts to better explain lifecycle semantics,
  event contracts, and where model-time declarations belong in bundle wiring.
- Updated template guidance and examples to align with current core/forecast
  lifecycle fallback behavior.
- Added README release/download badges.

## 1.7.0

- Coordinated ecosystem release alignment to version 1.7.0.
- Dependency floor updated to `fluxCore (>= 1.7.0)`.
- Retains 1.6.0 JSON-backed canonical model-time config
  (`inst/model_config/time_spec.json` + `model_time_spec()` wiring).

## 1.6.0

- Added canonical model-time configuration via
  `inst/model_config/time_spec.json` and new `model_time_spec()` accessor.
- Updated `model_bundle()` default wiring to source canonical time from
  `model_time_spec()` while still attaching `bundle$time_spec` for Engine
  runtime contract compatibility.
- Rewrote staged template scripts (`R/01_...07_`) for stronger alignment with the current flux ecosystem contracts.
- Shifted teaching examples to domain-neutral operational scenarios (urban delivery operations) to reduce conceptual drift.
- Consolidated onboarding guidance into `README.md` as the single primary walkthrough.
- Removed legacy guide artifacts (`docs/MODEL_PACKAGE_GUIDE.*`) and old template snippet files.
- Removed `docs/optional_extensions/` and package `man/` files to keep the template focused on minimal starter scaffolding.
- Expanded template unit tests to check schema and bundle-hook scaffolding more explicitly.

## 1.5.0

- Packaging contract cleanup for template consumers: dependency declarations updated and testthat Suggests declared.

- Documentation remains manual (non-roxygen) and aligned with exported template functions.

- Licensing update: switched package license to Apache License 2.0.

## 1.4.0

- Documentation/workflow hygiene: removed roxygen-style blocks from `R/` and continued manual `.Rd` maintenance.
- Packaging hygiene: standardized filenames to underscore style and aligned references with current ecosystem naming conventions.

## 1.3.0

- Coordinated ecosystem release v1.3.0.
- Schema validation and schema helper workflows are consolidated to `fluxCore`.

## 1.2.0

## 1.2.1

- Bring template time-field references in line with Core (entity$last_time, ctx$time$unit) and add LICENSE file.

- Version bump to align with flux ecosystem v1.2.0. No functional changes.
