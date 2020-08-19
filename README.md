# StartingCapital

## Summary
Harold is tasked with hiring a team who can help him build the essential smart contracts to host a token sale for his new business. However, he does not plan to use all the proceeds from the sale to fund development. He has recently heard of DeFi on top of Ethereum and has heard about how people use protocols to collateralize, borrow, lend, and make payments. Harold would like to raise 100 Ether and with that Ether lend it out so it continually earns interest while borrowing only 10% of the dollar value of 100 Ether. With that 10% he knows he can fund the integral parts of his startups business over the next 6 months. While the debt is held it is assumed the interest rate received from lending the Ether will outweigh the interest payments on the DAI, effectively growing the amount of Ether in the pool. When Harold and his team have built their product and have revenue they will pay back the debt and return the crowdsale depositors Ether back with interest accrued from the pool.

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
