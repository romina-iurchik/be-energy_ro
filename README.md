# BeEnergy

Tokenized green energy for cooperative communities.

## 🐝 What is BeEnergy?

BeEnergy transforms communities into their own energy marketplace, where neighbors tokenize and trade solar power among themselves using blockchain technology.

## 🏗️ Project Structure
```
be-energy/
├── apps/
│   ├── contracts/       # Soroban smart contracts (Rust)
│   │   ├── energy_token/
│   │   ├── energy_distribution/
│   │   └── community_governance/
│   └── web/            # Next.js frontend
├── packages/           # Shared code (coming soon)
│   ├── stellar/       # Stellar SDK wrappers
│   ├── types/         # TypeScript types
│   ├── ui/            # Design system
│   └── config/        # Shared configs
└── tooling/
    └── scripts/       # Deploy & maintenance scripts
```

## 🚀 Getting Started

### Prerequisites

- Node.js v18+
- Rust + Cargo
- pnpm v10+

### Instals/contracts
cargo build --release
```

## 🌐 Stack

- **Frontend**: Next.js 16 + React 19 + TypeScript
- **Smart Contracts**: Soroban (Rust)
- **Blockchain**: Stellar
- **UI**: Tailwind CSS v4 + shadcn/ui
- **Monorepo**: Turborepo + pnpm workspaces

## 📦 Current Status

- [x] Monorepo structure
- [x] Smart contracts (energy_token, energy_distribution, community_governance)
- [x] Frontend with wallet connection
- [x] All routes working (dashboard, marketplace, activity, consumption, profile)
- [ ] Deploy contracts to testnet
- [ ] Connect frontend to real contract data
- [ ] Replace mock data with blockchain queries

## 🔗 Resources

- [Pitch Deck](docs/pitch.md)
- [Architecture Guide](beenergy-monorepo-guide.docx)

## 📄 License

Apache-2.0
