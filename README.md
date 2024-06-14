# AKD_DEX
AKD DEX is a decentralized exchange project

This repository contains the source code for a decentralized exchange (Dex) and a native token (DXTK) implemented as smart contracts on the Polygon network. The Dex allows users to buy and sell the native token DXTK, swap tokens, add liquidity to pools, monitor assets and balance, get swap prices between tokens.

## Smart Contracts

### Dex.sol

`Dex.sol` is the main smart contract for the decentralized exchange. It provides the following functions:

- **Buy Native Token (DXTK):** Allows users to purchase the native token of the exchange.
- **Sell Native Token (DXTK):** Allows users to sell the native token of the exchange.
- **Swap Tokens:** Enables token swapping functionality between different tokens.
- **Add Liquidity to Pool:** Allows users to add liquidity to the pools.
- **Monitor Assets and Balance:** Provides functionality to check the assets and balance available.
- **Get Swap Price Between Tokens:** Calculates the swap price between tokens.

### DexToken.sol

`DexToken.sol` is the smart contract used to create the native token DXTK. It uses the ERC20 token standard and inherits from the OpenZeppelin ERC20 implementation.

## Deployment

These smart contracts are deployed on the Polygon network (specifically the Polygon Amoy Testnet).

## Usage

1. **Clone the Repository:**
   ```sh
   git clone https://github.com/kwalker231/AKD_DEX.git
   cd AKD_DEX

