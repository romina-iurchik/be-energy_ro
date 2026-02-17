# Extract Shared Stellar Package

## Description

Move reusable Stellar and Soroban-related code from `apps/web` into a shared package `packages/stellar` following monorepo best practices. This improves reuse across apps and keeps contract config, wallet helpers, and shared hooks in one place.

**What needs to happen:** Create `packages/stellar` and move (or re-export) contract config, wallet utilities, and shared hooks there. Update `apps/web` to consume from `packages/stellar` so that the web app continues to work without duplication.

**Files to move/create:**
- Move (or copy and refactor) `apps/web/lib/contracts-config.ts` into `packages/stellar`
- Move (or copy and refactor) `apps/web/lib/stellar-wallet.ts` into `packages/stellar` (and any dependencies such as `stellar-config`, `storage` if they are Stellar-specific)
- Move shared contract hooks (e.g. `useEnergyToken`, `useEnergyDistribution`) or their core logic into `packages/stellar` and re-export from the web app if needed
- Create `packages/stellar/package.json`, `tsconfig.json`, and entry points so that `apps/web` can import from `@be-energy/stellar` or `stellar` workspace package

## Context

The monorepo has a `packages/` directory for shared code. Stellar config, wallet connection helpers, and contract hooks are currently only in `apps/web`. Extracting them into `packages/stellar` allows other apps (e.g. future back-office or scripts) to use the same config and logic, and keeps the web app focused on UI while shared logic lives in one place.

## Acceptance Criteria

- [ ] New package `packages/stellar` exists with a valid `package.json` and build/export setup (e.g. TypeScript, main/export fields)
- [ ] Contract configuration (contract IDs, RPC URL, network passphrase) lives in `packages/stellar` and is consumed by `apps/web` (no duplicate config in apps/web)
- [ ] Wallet connection / Stellar wallet utilities (e.g. connect, disconnect, get address) live in `packages/stellar` or are re-exported from there; `apps/web` uses the package
- [ ] Shared hooks (`useEnergyToken`, `useEnergyDistribution`) either live in `packages/stellar` or in `apps/web` but depend on config and types from `packages/stellar`; document the chosen approach
- [ ] `apps/web` builds and runs without errors; wallet and contract features still work on testnet
- [ ] Dependencies (e.g. `@stellar/stellar-sdk`, `@creit.tech/stellar-wallets-kit`) are declared in the appropriate package(s) and the dependency tree is clean (no hoisting issues that break the app)

## Technical Hints

- Turborepo: add `packages/stellar` to the workspace in `pnpm-workspace.yaml` if not already included; use `"@be-energy/stellar"` or similar as the package name and add it as a dependency in `apps/web/package.json`
- `stellar-wallet.ts` may depend on `stellar-config` and `storage`; move or re-export those from `packages/stellar` or keep a thin wrapper in `apps/web` that delegates to the package
- Hooks that use React and `useWallet()` may need to stay in the app if they depend on app-specific context; in that case, move only the pure Stellar/contract logic (e.g. RPC calls, tx building) to `packages/stellar` and keep hooks in the app that call the package
- Use `packages/stellar/src/index.ts` to re-export public API (config, wallet helpers, types) so that `apps/web` can `import { CONTRACTS, connectWallet } from '@be-energy/stellar'` (or similar)

## Suggested Steps

1. Create `packages/stellar` directory with `package.json` (name, version, main/exports, dependencies), `tsconfig.json`, and `src/` (e.g. `config.ts`, `wallet.ts`, `index.ts`).
2. Move contract and network config from `apps/web/lib/contracts-config.ts` into `packages/stellar` (e.g. `src/config.ts`); keep env reads in the package or pass them in at app init; export from `index.ts`.
3. Move or replicate `stellar-wallet.ts` and its dependencies (`stellar-config`, `storage`) into `packages/stellar`; resolve any Node vs browser or app-specific imports so the package is usable from Next.js.
4. Update `apps/web` to import config and wallet from `@be-energy/stellar`; adjust `useEnergyToken` and `useEnergyDistribution` to use the package (either by moving the non-React logic into the package and keeping hooks in the app, or by moving hooks into the package if they have no app-specific deps).
5. Add `packages/stellar` to the workspace and run `pnpm install`; run `pnpm build` from repo root and `pnpm dev` in `apps/web`; verify wallet connect and contract calls still work.
6. Document in the package README what the package exports and how the web app (and future consumers) should use it.
