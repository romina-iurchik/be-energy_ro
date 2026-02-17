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
