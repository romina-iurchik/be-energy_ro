#!/usr/bin/env bash
# Generate 5 diverse GitHub issue markdown files for BeEnergy
# Run from repo root: ./tooling/scripts/generate-issues.sh

set -e
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ISSUES_DIR="${REPO_ROOT}/tooling/issues"
rm -rf "$ISSUES_DIR"
mkdir -p "$ISSUES_DIR"

# --- Issue 1: Connect Dashboard to Real Contract Data ---
cat > "${ISSUES_DIR}/issue-001-dashboard-real-contract-data.md" << 'ISSUE1'
# Connect Dashboard to Real Contract Data

## Description

Replace all mock data on the dashboard with real contract and wallet data. The dashboard should show the connected wallet address, live HDROP balance from the energy_token contract, and proper loading, error, and retry behavior.

**Current state:** Dashboard uses `mockUser` for balance (`mockUser.balance = 1234`), wallet address (`mockUser.address`, `mockUser.shortAddress`), and copy behavior. No loading or error states for balance; no retry.

**What needs to happen:** Use `useEnergyToken()` for balance (with loading, error, and retry), and `useWallet().address` for display and copy. Remove reliance on mock user data for these concerns.

**Files to modify:**
- `apps/web/app/dashboard/page.tsx`
- `apps/web/hooks/useEnergyToken.ts` (if needed: ensure retry-friendly behavior and optional refresh API)

**Contract address (testnet):** `CD7W5YHANEHI4NTAJ7AIVGY55QOLOFXHZI7IGCMMYRHVTQY4XS3JT3ZL`

## Context

The dashboard is the main post-login view. Users should see their real Stellar address and real HDROP balance from testnet. Failures (RPC timeout, wrong network) should show a clear message and a retry option; loading should show a skeleton or spinner so the UI never shows stale or fake data as if it were real.

## Acceptance Criteria

- [ ] Balance card shows balance from `useEnergyToken().getBalance()` when wallet is connected; no hardcoded `mockUser.balance` for the main balance
- [ ] Wallet address and short address are derived from `useWallet().address`; copy button copies the real address
- [ ] Loading state is shown while balance is fetched (skeleton, spinner, or "Loading...")
- [ ] Error state is shown on failure with a "Retry" action that calls `getBalance()` again
- [ ] User can manually refresh the balance (e.g. refresh icon) without reloading the page; loading is shown during refetch
- [ ] All of the above work on testnet with Freighter; `NEXT_PUBLIC_ENERGY_TOKEN_CONTRACT` is used and documented in .env.example

## Technical Hints

- `useEnergyToken()` exposes `getBalance(userAddress?)`, `isLoading`, `error`; contract uses 7 decimals, hook converts to readable format
- `useWallet()` from `@/lib/wallet-context` provides `address`; short form: `${address.slice(0, 4)}...${address.slice(-4)}`
- `BalanceDisplay` accepts `amount` and `symbol="HDROP"`; handle loading/error in a wrapper or inline conditionals
- Ensure calling `getBalance()` again clears previous error and sets loading so retry/refresh is safe

## Suggested Steps

1. In `dashboard/page.tsx`, import `useEnergyToken` and `useWallet`; get `address`, and from the hook get `getBalance`, `isLoading`, `error`.
2. Add state for balance (e.g. `balance`); in `useEffect`, when `address` is set, call `getBalance()` and store the result.
3. Replace balance display: if `isLoading`, show skeleton/spinner; if `error`, show message + "Retry" calling `getBalance()`; else show `<BalanceDisplay amount={balance} symbol="HDROP" />`.
4. Replace all `mockUser.address` and `mockUser.shortAddress` with values from `address`; update copy handler to use `address`.
5. Add a refresh control (e.g. icon button) that calls `getBalance()` and disable it (or ignore extra clicks) while `isLoading`.
6. Verify `NEXT_PUBLIC_ENERGY_TOKEN_CONTRACT` is in `.env.example` and set in `.env.local`; run `pnpm dev`, connect Freighter on testnet, and confirm balance and address match.
ISSUE1

# --- Issue 2: Marketplace P2P Trading Integration ---
cat > "${ISSUES_DIR}/issue-002-marketplace-p2p-trading.md" << 'ISSUE2'
# Marketplace P2P Trading Integration

## Description

Connect the marketplace page to the energy_distribution contract (and energy token where needed) so users can create offers and buy energy from peers, instead of relying only on mock data and localStorage.

**Current state:** Marketplace shows 6 mock offers from `mockOffers`; "Create offer" and "Buy" flows update local state and localStorage only. No on-chain reads or writes.

**What needs to happen:** Integrate with the energy_distribution contract for listing/creating offers (or equivalent on-chain state) and with the energy token for transfers when buying. Use a dedicated hook (e.g. `useEnergyDistribution`) for contract calls and surface real or hybrid data on the marketplace.

**Files to modify:**
- `apps/web/app/marketplace/page.tsx`
- `apps/web/hooks/useEnergyDistribution.ts` (extend with any offer/list/buy-related reads and, if applicable, write helpers)

**Contract address (testnet):** `CD3LXNS5NLGYDWMP5JQHUD2GW37FQXJNV55ZI4HS42D6LMLSB6IHG6QK`

## Context

The marketplace is the P2P energy trading surface. Today it is fully mocked. The goal is to have at least one meaningful integration with the distribution contract (e.g. listing members or distribution stats as "sellers" or validating against contract state) and to use the energy_token for actual transfers when a user "buys" energy, so that trades reflect on-chain.

## Acceptance Criteria

- [ ] Marketplace does not rely solely on the static `mockOffers` list; at least one data source (e.g. list of members, offers, or distribution stats) comes from the energy_distribution contract via `useEnergyDistribution` or similar
- [ ] Creating an "offer" and/or buying energy triggers or reflects real contract interactions (e.g. token transfer for buy, or recording on distribution contract if the contract supports it)
- [ ] Contract ID is configurable via `NEXT_PUBLIC_ENERGY_DISTRIBUTION_CONTRACT`; testnet deployment is used and documented
- [ ] Loading and error states are handled so the page does not crash on RPC or network errors
- [ ] Flows work on testnet with Freighter (create offer and/or buy energy and see on-chain effect where applicable)

## Technical Hints

- `useEnergyDistribution.ts` already exists and can be extended; `energy_distribution` exposes `get_member_list`, `get_member_percent`, `get_total_generated`, etc. Use these to drive or validate marketplace data
- For "buy" (transfer of HDROP), use the energy_token contract (transfer or similar) via existing or new hook; ensure `useEnergyToken` or a small wrapper is used for sending tokens
- Reuse patterns from `useEnergyToken`: Soroban RPC, `Contract.call`, simulate then send for state-changing ops
- If the distribution contract does not have an "offers" table, document that the issue may require adding read-only views for offers or implementing a hybrid (e.g. list from contract where possible, token transfer on buy)

## Suggested Steps

1. Review `apps/contracts/energy_distribution/src/lib.rs` for functions that can represent "sellers" or "offers" (e.g. member list, totals); review energy_token for `transfer` or equivalent.
2. Extend `useEnergyDistribution.ts` with functions to fetch data needed for the marketplace (e.g. member list, total generated) and, if applicable, a function to submit a "create offer" or "buy" transaction (using token contract for transfers).
3. In `marketplace/page.tsx`, replace or supplement `mockOffers` with data from `useEnergyDistribution()` (and token hook for balance/transfer); keep a clear loading/error UI.
4. Wire "Create offer" to the appropriate contract call or document why it is deferred; wire "Buy" to an energy_token transfer (or contract call that performs the transfer) so the buyer's and seller's balances change on-chain.
5. Add `NEXT_PUBLIC_ENERGY_DISTRIBUTION_CONTRACT` to `.env.example` if not present; test on testnet with Freighter and verify list and buy behavior.
ISSUE2

# --- Issue 3: Admin Token Minting Interface ---
cat > "${ISSUES_DIR}/issue-003-admin-mint-tokens-ui.md" << 'ISSUE3'
# Admin Token Minting Interface

## Description

Create an admin-only UI to mint HDROP tokens (simulating solar generation) for testing. This allows testnet accounts to receive tokens without going through the full distribution flow.

**What needs to happen:** Add a component that lets an admin (or authorized minter) call the energy_token contract's `mint_energy` function with a recipient address and amount. Optionally restrict the UI by checking that the connected wallet is the admin or has the minter role.

**Files to create/modify:**
- Create `apps/web/components/admin/MintTokens.tsx`
- Update `apps/web/hooks/useEnergyToken.ts` to expose a `mintEnergy(to: string, amount: string | number)` (or similar) that builds and submits the mint transaction

**Contract function:** `mint_energy(to: Address, amount: i128, minter: Address)` — the minter must have the minter role and sign the transaction.

## Context

The energy_token contract allows minting only for addresses with the minter role (e.g. the distribution contract or an admin-granted minter). For testing and demos, an admin UI that calls `mint_energy` makes it easy to credit test accounts with HDROP. The frontend must send a Soroban transaction that invokes `mint_energy` with the connected wallet as the minter.

## Acceptance Criteria

- [ ] New component `MintTokens.tsx` under `apps/web/components/admin/` with inputs for recipient address and amount, and a button to submit the mint
- [ ] `useEnergyToken.ts` (or a dedicated admin hook) exposes a function that invokes `mint_energy(to, amount, minter)` on the energy_token contract and returns success/error; amount is converted to 7-decimal contract format
- [ ] Only the connected wallet can submit the mint (minter is the signer); optionally hide or disable the component when the connected wallet is not the admin or a known minter
- [ ] User feedback: loading state during submit, success message or error message after the transaction is confirmed or fails
- [ ] Works on testnet: mint to a test address and verify balance increase

## Technical Hints

- Contract signature: `mint_energy(e, to: Address, amount: i128, minter: Address)`. The minter must have the minter role and must sign; use the connected wallet address as `minter` and pass it to the contract
- Amount in the contract uses 7 decimals; convert from user input: e.g. `Math.round(parseFloat(amount) * 1e7)` and pass as i128
- Use Stellar SDK: build an invocation for the energy_token contract, then use the wallet (e.g. Freighter) to sign and submit via Soroban RPC; follow the same pattern as other contract write flows in the app
- Restrict access: check `useWallet().address` against `ADMIN_ADDRESS` or a list of minter addresses from env, and only render the form if allowed

## Suggested Steps

1. In `useEnergyToken.ts`, add `mintEnergy(toAddress: string, amountHuman: string)` that builds a transaction calling `mint_energy` with `toAddress`, amount in 7 decimals, and the connected address as minter; sign and submit via the wallet kit; return promise that resolves on success or rejects on error
2. Create `apps/web/components/admin/MintTokens.tsx`: form with recipient input, amount input, and "Mint" button; call `mintEnergy(recipient, amount)` on submit; show loading and success/error message
3. Optionally add an admin check (e.g. `NEXT_PUBLIC_ADMIN_ADDRESS` or `ALLOWED_MINTERS`) and only render the component when the connected wallet is in that list
4. Mount the component on an admin-only page or a dedicated route (e.g. `/admin/mint`) so it is not visible to regular users
5. Test on testnet: connect as minter/admin, mint to another address, then check that address balance (e.g. on dashboard or Stellar Lab)
ISSUE3

# --- Issue 4: Transaction History from Horizon API ---
cat > "${ISSUES_DIR}/issue-004-activity-horizon-transactions.md" << 'ISSUE4'
# Transaction History from Horizon API

## Description

The Activity page currently only shows two placeholder cards (Purchases and Sales) with no real data. Implement fetching of the connected account's transaction history from the Stellar Horizon API and display it on the Activity page (or on the linked Purchases/Sales views).

**What needs to happen:** Use the Horizon API to fetch payments and/or transactions for the connected wallet address and display them in a clear list (e.g. date, type, counterparty, amount). Prefer the testnet Horizon URL so the app works against testnet data.

**Files to modify/create:**
- `apps/web/app/activity/page.tsx` (and optionally `apps/web/app/activity/purchases/page.tsx`, `apps/web/app/activity/sales/page.tsx` if they exist)
- Create a new hook or module for Horizon queries (e.g. `apps/web/hooks/useHorizonTransactions.ts` or `apps/web/lib/horizon.ts`)

**API base URL (testnet):** `https://horizon-testnet.stellar.org`

## Context

Users expect to see their recent activity (payments, token transfers, etc.) on the Activity page. The Stellar Horizon API exposes account payments and transactions. The frontend should call Horizon for the connected account and render the results, with loading and error handling, so the Activity section is no longer empty.

## Acceptance Criteria

- [ ] Activity page (or its sub-pages) displays a list of transactions or payments for the connected wallet address
- [ ] Data is fetched from the Horizon API (testnet URL configurable, e.g. via `NEXT_PUBLIC_STELLAR_HORIZON_URL` or existing config)
- [ ] At least payments (and optionally other operation types) are shown with useful fields (e.g. date, type, amount, counterparty or asset)
- [ ] Loading state is shown while fetching; error state is shown if the request fails (e.g. network or invalid address)
- [ ] No crash when the user is not connected (redirect or hide content as per existing auth flow)

## Technical Hints

- Use `@stellar/stellar-sdk` Server or the fetch API to call Horizon endpoints: e.g. `GET /accounts/{address}/payments` or `GET /accounts/{address}/transactions`; use limit and order params for pagination
- Horizon URL is already available in the codebase (e.g. `STELLAR_CONFIG.HORIZON_URL` or `getHorizonHost()` in stellar-config); reuse it for the new hook
- Parse the response and map to a simple shape (date, type, amount, asset, from/to) for display; filter or label "purchases" vs "sales" based on direction relative to the connected account
- New hook: e.g. `useHorizonTransactions(address)` that returns `{ transactions, isLoading, error }` and fetches when `address` is set

## Suggested Steps

1. Add a small module or hook that takes an account ID and fetches from `https://horizon-testnet.stellar.org/accounts/{id}/payments` (or transactions); return normalized list, loading, and error
2. Ensure Horizon base URL is configurable (env or existing `stellar-config` / `contracts-config`) so it can point to testnet or mainnet
3. In `activity/page.tsx`, use the connected wallet address and the new hook to fetch history; display a list (e.g. table or cards) with date, type, amount, and any relevant counterparty/asset info
4. Add loading (skeleton or spinner) and error (message and optional retry); handle empty list with a friendly "No activity yet" message
5. If Purchases and Sales are separate routes, either reuse the same hook and filter by direction or call the same API and split the list by direction on each page
6. Test with a testnet account that has some payments and verify they appear on the Activity page
ISSUE4

# --- Issue 5: Extract Shared Stellar Package ---
cat > "${ISSUES_DIR}/issue-005-extract-shared-stellar-package.md" << 'ISSUE5'
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
ISSUE5

echo "Generated 5 issue files in ${ISSUES_DIR}:"
ls -la "${ISSUES_DIR}"
