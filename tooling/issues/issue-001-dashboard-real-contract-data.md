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
