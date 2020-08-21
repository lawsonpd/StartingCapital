pragma solidity ^0.5.12;

// import "https://github.com/compound-finance/compound-protocol/blob/master/contracts/CEther.sol";
import "https://github.com/compound-finance/compound-protocol/blob/master/contracts/CErc20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20.sol";


contract MyContract {
    event MyLog(string, uint256);

    function supplyErc20ToCompound(
        address _erc20Contract,
        address _cErc20Contract,
        uint256 _numTokensToSupply
    ) public returns (uint) {
        require (_numTokensToSupply > 0, "Token needs to be greater than 0") ;
        
        // Create a reference to the underlying asset contract, like DAI.
        ERC20 underlying = ERC20(_erc20Contract);
        emit MyLog("underlying", 0);

        // Create a reference to the corresponding cToken contract, like cDAI
        CErc20 cToken = CErc20(_cErc20Contract);
        emit MyLog("cToken", 0);
    
        // Amount of current exchange rate from cToken to underlying
        uint256 exchangeRateMantissa = cToken.exchangeRateCurrent();
        emit MyLog("Exchange Rate (scaled up by 1e18): ", exchangeRateMantissa);

        // Amount added to you supply balance this block
        uint256 supplyRateMantissa = cToken.supplyRatePerBlock();
        emit MyLog("Supply Rate: (scaled up by 1e18)", supplyRateMantissa);

        // Approve transfer on the ERC20 contract
        underlying.approve(_cErc20Contract, _numTokensToSupply);

        // Mint cTokens
        uint mintResult = cToken.mint(_numTokensToSupply);
        return mintResult;
    }
    
}