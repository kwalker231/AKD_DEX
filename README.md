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

### Example Deployments

- **Dex.sol**: An example of the deployed `Dex.sol` contract can be found [here](https://www.oklink.com/amoy/address/0x2C56B6A6D20f3919294C8269254D45D6a7E64E68).
- **DexToken.sol**: The native token DXTK has been deployed with the following details:
  - **Token Name**: DX-token
  - **Symbol**: DXTK
  - **Token Address**: [0x43f507be49443683e0f7c4848f04ff9554b08783](https://www.oklink.com/amoy/address/0x43f507be49443683e0f7c4848f04ff9554b08783)


## Usage

1. **Clone the Repository:**
   ```sh
   git clone https://github.com/kwalker231/AKD_DEX.git
   cd AKD_DEX

