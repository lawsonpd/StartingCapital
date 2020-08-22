# StartingCapital

## Summary
Harold is tasked with hiring a team who can help him build the essential smart contracts to host a token sale for his new business. However, he does not plan to use all the proceeds from the sale to fund development. He has recently heard of DeFi on top of Ethereum and has heard about how people use protocols to collateralize, borrow, lend, and make payments. Harold would like to raise 100 Ether and with that Ether lend it out so it continually earns interest while borrowing only 10% of the dollar value of 100 Ether. With that 10% he knows he can fund the integral parts of his startups business over the next 6 months. While the debt is held it is assumed the interest rate received from lending the Ether will outweigh the interest payments on the DAI, effectively growing the amount of Ether in the pool. When Harold and his team have built their product and have revenue they will pay back the debt and return the crowdsale depositors Ether back with interest accrued from the pool. The team will also receive payments in $COMP, compound.finance native governance token. This token can be converted into Ether to pay for gas costs associated with returning investors investments.

## Requirements
* Crowdsale Contract
* Deployment Contract
* ERC20, ERC20 Detailed, ERC20 Mintable Contracts
* Compound Interaction Contract

## Inner Workings
* Conduct Crowdsale (raise 100 Ether)
* Mint cETH using 100 Ether and Compound.finance
* Borrow DAI agasint the minted cETH
* Transfer DAI to team wallet

## Important Addresses and Contract Addresses
* Harold's Address (Deploys Contract and Receives USDC): 0xf7171695A9B0B9E01423420F53419D36479515cf
* Crowdsale Contract Deployment Address: 
* cETH Address: 0x41b5844f4680a8c38fbb695b7f9cfd1f64474a72
* USDC ERC20 Address: 0xb7a4f3e9097c08da09517b5ab877f7a917224ede
* COMP ERC20 Address: 0x61460874a7196d6a22d1ee4922473664b3e95270

## Process
* CapitalTokenSaleDeployer (3 arguments)
* Grab sct_sale_address from contract, use it for At Address, deploy Starting Capital
* Use 1 for value box and ether to get 1 token
* Grab token address from token_address to add token to metamask
