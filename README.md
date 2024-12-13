# Algorithmic, Exogenous Stablecoin

An algorithmic stablecoin pegged to the value of the US Dollar.

---

## Overview

This system comprises two contracts:

1. **StableCoin (STC)**
2. **DepositorCoin (DPC)**

The StableCoin minters pay only the amount of STC they mint. Over-collateralization is maintained by liquidity providers who deposit without intending to mint StableCoin.

---

## How It Works

### **Incentives for Liquidity Providers**

1. **DepositorCoin (DPC)**: Liquidity providers receive DPC tokens equivalent to the USD value of their provided liquidity.
2. **Leverage Trading Mechanism**: 
   - Example:
     - **ETH Price:** $1,000/ETH
     - **Minting Scenario:**
       - Person A mints 500 STC by depositing $500 worth of ETH (0.5 ETH).
       - Person B provides liquidity by depositing $1,000 worth of ETH (1 ETH) and receives 1,000 DPC.
       - **Total ETH in Pool:** 1.5 ETH ($1,500).

#### **Scenarios**

- **Scenario A:** ETH Price Decreases ($500/ETH)
  - Total ETH in Pool = 1.5 ETH = $750
  - Total DPC Supply = 1,000 DPC
  - Total DPC Value = $750 - $500 (STC liabilities) = $250
  - **DPC Price:** $0.25/DPC

- **Scenario B:** ETH Price Increases ($1,500/ETH)
  - Total ETH in Pool = 1.5 ETH = $2,250
  - Total DPC Supply = 1,000 DPC
  - Total DPC Value = $2,250 - $500 (STC liabilities) = $1,750
  - **DPC Price:** $1.75/DPC

---

### **Underwater Contract**

If the collateral falls below the value of minted StableCoins:

1. **Contract Freeze**: The StableCoin contract is frozen.
2. **DPC Devaluation**: DepositorCoins are deemed worthless.
3. **Re-Collateralization**: 
   - New liquidity providers must deposit a sufficient amount to over-collateralize and restore the pool's health.
   - **Incentives**: Exclusive liquidity provision rights for a specified duration.

---

## Key Benefits

- Algorithmic control ensures a stable peg to the US Dollar.
- DepositorCoin holders benefit from a leverage-based profit mechanism.
- Strong incentives for re-collateralization to maintain system stability.

---

## Disclaimer

This system is experimental and carries risks, especially during periods of high volatility. Please exercise caution and conduct thorough research before participating.

---
