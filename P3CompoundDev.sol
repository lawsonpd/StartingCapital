pragma solidity ^0.5.12;

interface Erc20 {
    function approve(address, uint256) external returns (bool);

    function transfer(address, uint256) external returns (bool);
}


interface CErc20 {
    function mint(uint256) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function redeem(uint) external returns (uint);

    function redeemUnderlying(uint) external returns (uint);
    
    function borrow(uint256) external returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function borrowBalanceCurrent(address) external returns (uint256);

    function repayBorrow(uint256) external returns (uint256);
}


interface CEth {
    function mint() external payable;

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function redeem(uint) external returns (uint);

    function redeemUnderlying(uint) external returns (uint);
    
    function borrow(uint256) external returns (uint256);

    function repayBorrow() external payable;

    function borrowBalanceCurrent(address) external returns (uint256);
}


interface Comptroller {
    function markets(address) external returns (bool, uint256);

    function enterMarkets(address[] calldata)
        external
        returns (uint256[] memory);

    function getAccountLiquidity(address)
        external
        view
        returns (uint256, uint256, uint256);
}


interface PriceOracle {
    function getUnderlyingPrice(address) external view returns (uint256);
}

contract Compound {
    
    address payable private owner;
    uint256 balance;
    
    constructor () 
    public
        {
            owner = msg.sender;
        }
    
    event MyLog(string, uint256);

    function supplyEthToCompound(address payable _cEtherContract)
        public
        payable
        returns (bool)
    {
        // Create a reference to the corresponding cToken contract
        CEth cToken = CEth(_cEtherContract);

        // Amount of current exchange rate from cToken to underlying
        uint256 exchangeRateMantissa = cToken.exchangeRateCurrent();
        emit MyLog("Exchange Rate (scaled up by 1e18): ", exchangeRateMantissa);

        // Amount added to you supply balance this block
        uint256 supplyRateMantissa = cToken.supplyRatePerBlock();
        emit MyLog("Supply Rate: (scaled up by 1e18)", supplyRateMantissa);

        cToken.mint.value(msg.value).gas(250000)();
        return true;
    }

    function redeemCEth(
        uint256 amount,
        bool redeemType,
        address _cEtherContract
    ) public returns (bool) {
        require (msg.sender == owner, "You must be owner to do redeem.");
        // Create a reference to the corresponding cToken contract
        CEth cToken = CEth(_cEtherContract);

        // `amount` is scaled up by 1e18 to avoid decimals

        uint256 redeemResult;

        if (redeemType == true) {
            // Retrieve your asset based on a cToken amount
            redeemResult = cToken.redeem(amount);
        } else {
            // Retrieve your asset based on an amount of the asset
            redeemResult = cToken.redeemUnderlying(amount);
        }
        
        balance = address(this).balance;
        owner.transfer(balance);

        // Error codes are listed here:
        // https://compound.finance/docs/ctokens#ctoken-error-codes
        emit MyLog("If this is not 0, there was an error", redeemResult);

        return true;
    }

    function borrowErc20Example(
        address payable _cEtherAddress,
        address _comptrollerAddress,
        address _priceOracleAddress,
        address _cUSDCAddress
    ) public payable returns (uint256) {
        CEth cEth = CEth(_cEtherAddress);
        Comptroller comptroller = Comptroller(_comptrollerAddress);
        PriceOracle priceOracle = PriceOracle(_priceOracleAddress);
        CErc20 cUSDC = CErc20(_cUSDCAddress);

        // Supply ETH as collateral, get cETH in return
        cEth.mint.value(msg.value)();

        // Enter the ETH market so you can borrow another type of asset
        address[] memory cTokens = new address[](1);
        cTokens[0] = _cEtherAddress;
        uint256[] memory errors = comptroller.enterMarkets(cTokens);
        if (errors[0] != 0) {
            revert("Comptroller.enterMarkets failed.");
        }

        // Get my account's total liquidity value in Compound
        (uint256 error, uint256 liquidity, uint256 shortfall) = comptroller
            .getAccountLiquidity(address(this));
        if (error != 0) {
            revert("Comptroller.getAccountLiquidity failed.");
        }
        require(shortfall == 0, "account underwater");
        require(liquidity > 0, "account has excess collateral");

        // Get the collateral factor for our collateral
        // (
        //   bool isListed,
        //   uint collateralFactorMantissa
        // ) = comptroller.markets(_cEthAddress);
        // emit MyLog('ETH Collateral Factor', collateralFactorMantissa);

        // Get the amount of USDC added to your borrow each block
        // uint borrowRateMantissa = cUSDC.borrowRatePerBlock();
        // emit MyLog('Current USDC Borrow Rate', borrowRateMantissa);

        // Get the USDC price in ETH from the Price Oracle,
        // so we can find out the maximum amount of USDC we can borrow.
        uint256 USDCPriceInWei = priceOracle.getUnderlyingPrice(_cUSDCAddress);
        uint256 maxBorrowUSDCInWei = liquidity / USDCPriceInWei;

        // Borrowing near the max amount will result
        // in your account being liquidated instantly
        emit MyLog("Maximum USDC Borrow (borrow far less!)", maxBorrowUSDCInWei);

        // Borrow USDC
        uint256 numUSDCToBorrow = 10;

        // Borrow USDC, check the USDC balance for this contract's address
        cUSDC.borrow(numUSDCToBorrow * 1e6);

        // Get the borrow balance
        uint256 borrows = cUSDC.borrowBalanceCurrent(address(this));
        emit MyLog("Current USDC borrow amount", borrows);

        return borrows;
    }

    function myEthRepayBorrow(address _cEtherAddress, uint256 amount)
        public
        returns (bool)
    {
        CEth cEth = CEth(_cEtherAddress);
        cEth.repayBorrow.value(amount)();
        return true;
    }

    function myErc20RepayBorrow(
        address _erc20Address,
        address _cErc20Address,
        uint256 amount
    ) public returns (bool) {
        Erc20 USDC = Erc20(_erc20Address);
        CErc20 cUSDC = CErc20(_cErc20Address);

        USDC.approve(_cErc20Address, amount);
        uint256 error = cUSDC.repayBorrow(amount);

        require(error == 0, "CErc20.repayBorrow Error");
        return true;
    }

    function borrowEthExample(
        address payable _cEtherAddress,
        address _comptrollerAddress,
        address _cUSDCAddress,
        address _USDCAddress,
        uint256 _USDCToSupplyAsCollateral
    ) public returns (uint) {
        CEth cEth = CEth(_cEtherAddress);
        Comptroller comptroller = Comptroller(_comptrollerAddress);
        CErc20 cUSDC = CErc20(_cUSDCAddress);
        Erc20 USDC = Erc20(_USDCAddress);

        // Approve transfer of USDC
        USDC.approve(_cUSDCAddress, _USDCToSupplyAsCollateral);

        // Supply USDC as collateral, get cUSDC in return
        uint256 error = cUSDC.mint(_USDCToSupplyAsCollateral);
        require(error == 0, "CErc20.mint Error");

        // Enter the USDC market so you can borrow another type of asset
        address[] memory cTokens = new address[](1);
        cTokens[0] = _cUSDCAddress;
        uint256[] memory errors = comptroller.enterMarkets(cTokens);
        if (errors[0] != 0) {
            revert("Comptroller.enterMarkets failed.");
        }

        // Get my account's total liquidity value in Compound
        (uint256 error2, uint256 liquidity, uint256 shortfall) = comptroller
            .getAccountLiquidity(address(this));
        if (error2 != 0) {
            revert("Comptroller.getAccountLiquidity failed.");
        }
        require(shortfall == 0, "account underwater");
        require(liquidity > 0, "account has excess collateral");

        // Borrowing near the max amount will result
        // in your account being liquidated instantly
        emit MyLog("Maximum ETH Borrow (borrow far less!)", liquidity);

        // Get the collateral factor for our collateral
        // (
        //   bool isListed,
        //   uint collateralFactorMantissa
        // ) = comptroller.markets(_cUSDCAddress);
        // emit MyLog('USDC Collateral Factor', collateralFactorMantissa);

        // Get the amount of ETH added to your borrow each block
        // uint borrowRateMantissa = cEth.borrowRatePerBlock();
        // emit MyLog('Current ETH Borrow Rate', borrowRateMantissa);

        // Borrow a fixed amount of ETH below our maximum borrow amount
        uint256 numWeiToBorrow = 20000000000000000; // 0.02 ETH

        // Borrow USDC, check the USDC balance for this contract's address
        cEth.borrow(numWeiToBorrow);

        uint256 borrows = cEth.borrowBalanceCurrent(address(this));
        emit MyLog("Current ETH borrow amount", borrows);

        return borrows;
    }

    // Need this to receive ETH when `borrowEthExample` executes
    function() external payable {}
}



