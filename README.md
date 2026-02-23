# Lightchain AI Identity

A decentralized identity management system built on the **Lightchain AI Testnet**. This project allows users to verify, revoke, and manage on-chain identities while interacting with the **AIVM Visionary Oracle** for predictive insights.

## 🚀 Overview

The Lightchain AI Identity system serves as a gateway for users to establish a verified presence on the Lightchain network. It integrates a Solidity-based identity contract with a web-based management portal.

### Key Components

* **Identity Admin:** Tools to lookup, verify, and revoke target addresses.
* **Oracle Integration:** Direct interface with the **AIVM Oracle** for inference queries.
* **Oracle Ownership:** Management suite for syncing oracle data and monitor accumulated revenue.

---

## 🛠 Technical Stack

* **Smart Contracts:** Solidity (deployed via the [Lightchain IDE](https://deploy.lightchain.ai/))
* **Frontend:** HTML/JavaScript (Web3 integration via `ethers.js` or `web3.js`)
* **Network:** [Lightchain AI Testnet](https://docs.lightchain.ai/docs/getting-started/testnet/connect-to-testnet) (Chain ID: `1891`)

---

## ⚙️ Configuration

To interact with the contracts or run the portal locally, ensure your wallet is connected to the Lightchain AI Testnet:

| Field | Value |
| --- | --- |
| **RPC URL** | `https://light-testnet-rpc.lightchain.ai` |
| **Chain ID** | `1891` |
| **Symbol** | `LCAI` |
| **Explorer** | [Testnet Explorer](https://www.google.com/search?q=https://testnet-explorer.lightchain.ai) |

### Deployment

The primary contract `LightchainIdentity.sol` should be compiled and deployed using the [Lightchain IDE](https://deploy.lightchain.ai/). Ensure you have testnet tokens from the [LCAI Faucet](https://lightfaucet.ai/).

---

## 📖 Usage

### 1. Identity Management

Users can query the status of any `0x` address through the **Identity Portal**. If you are the contract owner, you can use the **Verify** or **Revoke** functions to manage the registry.

### 2. AIVM Consultations

Submit natural language queries to the **AIVM Oracle**.

### 3. Revenue & Fees

The Oracle Owner can toggle fee collection on/off, gas is still necessary for netowrk computation.
---

## 📜 License

This project is part of the Lightchain ecosystem. Refer to the [Lightchain Documentation](https://docs.lightchain.ai/) for broader protocol rules.

---

Would you like me to add a specific **"Quick Start"** section with the `ethers.js` code needed to connect the `index.html` to your deployed contract address?
