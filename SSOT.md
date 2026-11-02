# QSLC Single Source of Truth (SSOT)

_Last verified against the connected GitHub repository on 2026-11-02._

## Authority and scope

This file is the repository-level technical baseline for QSLC. It records verified repository facts and clearly labels items that have not been verified on the local workstation. It does not replace the protected Microsoft 365 / SharePoint record system for confidential business or legal records.

## Repository baseline

- Repository: `Sovereign-maxeffort/QSLC`
- Default branch: `main`
- Repository type: public fork of `whiteantwan58-tech/QSLC`
- Current main head: `0a50d1ec1bfd`
- Latest source commit observed: 2026-10-15 07:22:44 UTC
- Fork comparison observed: 2 commits ahead of upstream main, 0 behind.
- Language: Python
- Last observed GitHub Actions results: CodeQL succeeded on 2026-10-28; Conda package/test workflow succeeded for commit `0a50d1ec1bfd` on 2026-10-15.

## Current repository inventory

| Path | Observed purpose | Current disposition |
|---|---|---|
| `qslc_dashboard_app.py` | QSLC-branded Streamlit dashboard | Retain for review; candidate primary app |
| `qsls_dashboard_app.py` | Alternate dashboard with simulated/random metrics and placeholder integration claims | Archive candidate; do not use as source of live operational truth |
| `streamlit_app.py` | Generic Streamlit starter app | Archive candidate only after launch configuration is changed |
| `environment.yml` | Conda environment, Python 3.10 | Retain; used by CI workflow |
| `requirements.txt` | Streamlit and pandas runtime dependencies | Retain; dependency pinning/cache policy remains to be defined |
| `tests/test_apps.py` | Basic dependency-import and Python compilation tests | Retain; expand before production |
| `.devcontainer/devcontainer.json` | Dev container configured for Python 3.11 and launches `streamlit_app.py` | Review; currently inconsistent with Conda Python 3.10 and QSLC app entry point |
| `.github/workflows/python-package-conda.yml` | Conda CI, lint, pytest | Retain; last observed run succeeded |
| `.github/workflows/codeql.yml` | CodeQL analysis | Retain; latest observed run succeeded |

## Verified findings

1. The repository contains three Streamlit entry-point files; the dev container still launches the generic `streamlit_app.py`.
2. The Conda environment specifies Python 3.10, while the dev container image specifies Python 3.11.
3. The alternate `qsls_dashboard_app.py` generates random values and displays integration states as fixed text. Those values are demonstration UI, not verified telemetry.
4. The existing tests verify imports and source compilation; they do not prove live API, database, SharePoint, Stripe, Power BI, or offline operation.
5. The CI workflow for commit `0a50d1ec1bfd` passed, but CI success is not a local-workstation health check.

## Offline-first toolchain policy

- Preferred Windows automation shell: PowerShell 7 (`pwsh`), subject to local presence/version verification.
- Repository runtime baseline: Python 3.10 until the runtime is deliberately upgraded and CI/tests pass.
- Version control: Git; local commits and diffs work offline after the repository is cloned.
- Editor: VS Code can edit local files offline; extensions and remote services may require network access.
- Offline Python execution requires the interpreter, virtual/Conda environment, and all required packages to already be installed or cached locally.
- Do not run package upgrades or deployment commands as part of an offline health check.

## Archive policy

No files have been moved or deleted by this audit. The two dashboard/starter files listed as archive candidates must remain until the local launch configuration, imports, scripts, and user workflows are checked. Archive by moving to a dated `archive/` path with Git history preserved; do not delete.

## Not yet verified

- Local ROG Ally X installed PowerShell, Python, Git, Conda, VS Code, and package versions.
- Local `$HOME\QSLC` working-tree status, uncommitted changes, branches, and file timestamps.
- Offline execution and dependency availability.
- Whether SharePoint, Cloudflare D1/Workers, Stripe, Power BI, or Teams are connected and functioning.
- Whether the legal ingestion source files exist and are correctly stored in the protected SharePoint library.

## Data protection boundary

Case-specific legal documents, identifiers, hearing details, personal information, credentials, API keys, and confidential operational records must remain in access-controlled systems such as the designated SharePoint site or approved secret stores. Do not commit those records to this public repository.

## Next verification gate

Run the local, read-only QSLC audit on the workstation. Compare local tool versions and repository state with this baseline. Then designate one dashboard entry point, align Python versions and launch configuration, verify offline dependencies, expand tests, and only then move confirmed-unused files into the archive.
