pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "./P3TokenMintable.sol";

contract StartingCapital is Crowdsale, MintedCrowdsale {
    
    constructor (uint rate, address payable wallet, Capital token) 
        Crowdsale(rate, wallet, token)
        public
        {
            //constructor can stay empty
        }
    
}

contract CapitalTokenSaleDeployer {
    
    address public sct_sale_address;
    address public token_address;
    
    constructor (string memory name, string memory symbol, 
        address payable wallet) public {
            
            Capital token = new Capital(name, symbol, 100);
            token_address = address(token);
            
            StartingCapital sct_sale = new StartingCapital(1000000000000000000, wallet, token); //1 token = 1 eth
            sct_sale_address = address(sct_sale);
            
            token.addMinter(sct_sale_address);
            token.renounceMinter();
            
        }


// contract Ether2CompoundDeployer {
    
    
//     function mint() payable {}
    
//     function mint(uint mintAmount) returns (uint) {}
    
//     }

}