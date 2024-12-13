Artihmetic, Exogenous stablecoin pegged to the value of US Dollar.

How it works:

- There are two contracts StableCoin and DepositorCoin.

- The StableCoin(STC) minters pay only the amount of StableCoin they mint.

- The Over Collaterlization is maintained by people who choose to provide liquidity to the pool with no intention of minting the StableCoin.

- Incentives for the liquidty providers:
````
a. They get a token 'DepositorCoin'(DPC) in exchange of the amount they provide. Initially amount DepositorCoin = Usd Value of the Liquidity Provided.

b. Benefits: this coin acts as a leverage trading system.

eg: if 1 ETH = 1000$

let's say Person A Minted 500 STC depositing $500 in ETH (0.5 ETH)

Person B provides liquidty to the StableCoin contract depositing $1000 in ETH (1 ETH) and getting 1000 DPC.

Total ETH in pool = 1.5 = $1500
````

- Scenarios:
````
A: ETH price goes down (1 ETH = 500$)

total ETH in pool = 1.5 = $750

500 is the total DPC supply Hence total DPC value = 750 - 500 = $250

Now, 1000 DPC = $250 (1 DPC = $0.25)

B: ETH price goes up (1 ETH = 1500$)

total ETH in pool = 1.5 = $2250

500 is the total DPC supply Hence total DPC value = 2250 - 500 = $1750

Now, 1000 DPC = $1750 (1 DPC = $1.75)
````

\- If the contract goes underwater, then
````
a. The StableCoin contract is freezed

b. The DepositorCoins are deemed worthless

c. The only way to over collateralize again is someone providing liquidity above a certain amount to prevent immediate under collaterlization if people start withdrawing their STC.

Incentives for the provider:

They can be the sole liquidty provider for a certain period of time.
````

