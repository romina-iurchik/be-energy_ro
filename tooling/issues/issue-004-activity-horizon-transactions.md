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
