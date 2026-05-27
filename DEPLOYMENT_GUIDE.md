# Paulien's Sky Deployment Guide

This document outlines the finalized production deployment flow for Paulien's Sky.

## CI/CD Pipeline
- **Branch Strategy:** `main` (Production), `develop` (Staging).
- **Automation:** GitHub Actions automatically builds and tests on every push.
- **Observability:** Sentry is integrated into the build process using the `SENTRY_DSN` environment variable.

## Deployment Steps
1. **Prepare Environment:** Ensure `SENTRY_DSN`, `SUPABASE_URL`, and other required keys are set in the deployment environment (e.g., Vercel settings).
2. **Push to Main:** Pushing to the `main` branch triggers the production build.
3. **Automated Build:** The `vercel_build.sh` script executes, injecting necessary environment variables using `--dart-define`.
4. **Verification:** Monitor production logs via Sentry and ensure web performance metrics are within targets.

## Sentry Configuration
The Sentry DSN must be provided via the `SENTRY_DSN` environment variable in your hosting platform. It will be automatically injected into the build via the `vercel_build.sh` script.

## Verification
- Confirm that the build output succeeds without errors.
- Ensure the Sentry DSN is correctly recognized by the application (via observability dashboard).
