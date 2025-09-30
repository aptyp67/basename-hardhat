# Basename Hardhat Repo (Watchlist + RegisterWithFeeV2)

Two contracts:
- `Watchlist.sol` — on-chain watch/unwatch with events.
- `RegisterWithFeeV2.sol` — wrapper over Basename Registrar (collects fee, forwards value).

## Quickstart

1) Install
```bash
npm i
```

2) Configure `.env` (copy `.env.example` and fill in)
```env
PRIVATE_KEY=0x...
BASE_RPC_URL=https://mainnet.base.org
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
BASESCAN_API_KEY=...
REGISTRAR_ADDRESS=0x4cCb0BB02FCABA27e82a56646E81d8c5bC4119a5
FEE_RECIPIENT=0xYourWallet
FEE_BPS=10
```

3) Compile
```bash
npm run build
```

4) Deploy (Base Sepolia first)
```bash
npm run deploy:watchlist:baseSepolia
npm run deploy:register:baseSepolia
```

5) Verify on BaseScan
```bash
# replace with addresses printed on deploy
WATCHLIST_ADDRESS=0x... REGISTER_WITH_FEE_ADDRESS=0x... # RegisterWithFeeV2
REGISTRAR_ADDRESS=0x4cCb0BB02FCABA27e82a56646E81d8c5bC4119a5
FEE_RECIPIENT=0xYourWallet
FEE_BPS=10

npm run verify:watchlist:baseSepolia
npm run verify:register:baseSepolia
```

6) Mainnet (optional)
```bash
npm run deploy:watchlist:base
npm run deploy:register:base
npm run verify:watchlist:base
npm run verify:register:base
```
