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
