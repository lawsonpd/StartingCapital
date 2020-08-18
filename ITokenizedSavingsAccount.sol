pragma experimental ABIEncoderV2;
pragma solidity ^0.5.0;

interface ITokenized {
    
    struct IToken {
        address owner;
        string uri;
    } 
    
    
    event Auction();
    event Withdraw();
    
    
    function createNFT(uint NFT_id, address owner, string reference_uri) external;
    function auctionBid() external;
    function endAuction() external;
    function withdrawETH() external;
    function transferNFT() external;
     
    }