pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "./P3TokenMintable.sol";

contract TokenizedSavingsAccount is Crowdsale, MintedCrowdsale {
    
    constructor (uint rate, address payable wallet, SavingsAccount token) 
        Crowdsale(rate, wallet, token)
        public
        {
            //constructor can stay empty
        }
    
}

contract SavingsTokenSaleDeployer {
    
    address public tsa_sale_address;
    address public token_address;
    
    constructor (string memory name, string memory symbol, 
        address payable wallet) public {
            
            SavingsAccount token = new SavingsAccount(name, symbol);
            token_address = address(token);
            
            TokenizedSavingsAccount tsa_sale = new TokenizedSavingsAccount(1, wallet, token); //1 token = 1 wei
            tsa_sale_address = address(tsa_sale);
            
            token.addMinter(tsa_sale_address);
            token.renounceMinter();
            
        }


// contract Ether2CompoundDeployer {
    
    
//     function mint() payable {}
    
//     function mint(uint mintAmount) returns (uint) {}
    
//     }

}