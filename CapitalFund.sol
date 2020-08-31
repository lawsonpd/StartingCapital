pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20Detailed.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20Mintable.sol";


contract Capital is ERC20, ERC20Detailed, ERC20Mintable {
    
    constructor (string memory name, string memory symbol, uint initial_supply)
        ERC20Detailed (name, symbol, 18)
        public
        {
            //constructor can stay empty
        }

}

contract StartingCapital is Crowdsale, MintedCrowdsale {
    
    constructor (uint rate, address payable wallet, IERC20 token) 
        MintedCrowdsale()
        Crowdsale(rate, wallet, token)
        public
        {
            //constructor can stay empty
        }
    
}

contract CapitalTokenSaleDeployer {
    
    constructor (string memory name, string memory symbol) public {
            
            ERC20Mintable token = new Capital(name, symbol, 100);
            
            Crowdsale sct_sale = new StartingCapital(1000000000000000000, msg.sender, token); // 1 token == 1 eth
            
            token.addMinter(address(sct_sale));
            token.renounceMinter();
            
        }
}

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
    
    address cEtherAddress = address(0x41B5844f4680a8C38fBb695b7F9CFd1F64474a72);
    address comptrollerAddress = address(0x5eAe89DC1C671724A672ff0630122ee834098657);
    address priceOracleAddress = address(0xbBdE93962Ca9fe39537eeA7380550ca6845F8db7);
    address cUSDCAddress = address(0x4a92E71227D294F041BD82dd8f78591B75140d63);
    address usdcAddress = address(0xb7a4F3E9097C08dA09517b5aB877F7a917224ede);
    
    constructor () 
    public
        {
            owner = msg.sender;
        }
    
    event MyLog(string, uint256);


    /* 
        Convert ETH to cETH
    */
    function supplyEthToCompound()
        public
        payable
        returns (bool)
    {
        // Create a reference to the corresponding cToken contract
        CEth cToken = CEth(cEtherAddress);

        // Amount of current exchange rate from cToken to underlying
        uint256 exchangeRateMantissa = cToken.exchangeRateCurrent();
        emit MyLog("Exchange Rate (scaled up by 1e18): ", exchangeRateMantissa);

        // Amount added to you supply balance this block
        uint256 supplyRateMantissa = cToken.supplyRatePerBlock();
        emit MyLog("Supply Rate: (scaled up by 1e18)", supplyRateMantissa);

        cToken.mint.value(msg.value).gas(250000)();
        return true;
    }

    /*
        Redeem cETH for ETH
    */
    function redeemCEth(
        uint256 amount,
        bool redeemType
    ) public returns (bool) {
        
        require (msg.sender == owner, "You must be owner to do redeem.");
        // Create a reference to the corresponding cToken contract
        CEth cToken = CEth(cEtherAddress);

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

    /*
        Borrow USDC using cETH
    */
    function borrowUSDC(
    ) public payable returns (uint256) {
        CEth cEth = CEth(cEtherAddress);
        Comptroller comptroller = Comptroller(comptrollerAddress);
        PriceOracle priceOracle = PriceOracle(priceOracleAddress);
        CErc20 cUSDC = CErc20(cUSDCAddress);

        // Supply ETH as collateral, get cETH in return
        cEth.mint.value(msg.value)();

        // Enter the ETH market so you can borrow another type of asset
        address[] memory cTokens = new address[](1);
        cTokens[0] = cEtherAddress;
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
        uint256 USDCPriceInWei = priceOracle.getUnderlyingPrice(cUSDCAddress);
        uint256 maxBorrowUSDCInWei = liquidity / USDCPriceInWei;

        // Borrowing near the max amount will result
        // in your account being liquidated instantly
        emit MyLog("Maximum USDC Borrow (borrow far less!)", maxBorrowUSDCInWei);

        // Borrow USDC
        uint256 numUSDCToBorrow = 400;

        // Borrow USDC, check the USDC balance for this contract's address
        cUSDC.borrow(numUSDCToBorrow * 1e6);

        // Get the borrow balance
        uint256 borrows = cUSDC.borrowBalanceCurrent(address(this));
        emit MyLog("Current USDC borrow amount", borrows);

        // Transfer USDC tokens to contract owner
        Erc20 USDC = Erc20(usdcAddress);
        USDC.transfer(owner, borrows);
        
        return borrows;
    }

    /*
        Pay back USDC loan to Compound.
    */
    function usdcRepayBorrow(
        uint256 amount
    ) public returns (bool) {
        Erc20 USDC = Erc20(usdcAddress);
        CErc20 cUSDC = CErc20(cUSDCAddress);

        USDC.approve(cUSDCAddress, amount);
        uint256 error = cUSDC.repayBorrow(amount);

        require(error == 0, "CErc20.repayBorrow Error");
        return true;
    }

    // Need this to receive ETH when `borrowEthExample` executes
    function() external payable {}
}

contract CrowdsaleGiveBack {
    address payable crowdsale_one;
    address payable crowdsale_two;
    address payable crowdsale_three;
    address payable crowdsale_four;
    address payable crowdsale_five;
    address payable crowdsale_six;
    address payable crowdsale_seven;
    address payable crowdsale_eight;
    address payable crowdsale_nine;
    address payable crowdsale_ten;
    
    constructor(address payable _one, address payable _two, address payable _three, 
        address payable _four, address payable _five, address payable _six,
        address payable _seven, address payable _eight, address payable _nine,
        address payable _ten) public {
            crowdsale_one = _one;
            crowdsale_two = _two;
            crowdsale_three = _three;
            crowdsale_four = _four;
            crowdsale_five = _five;
            crowdsale_six = _six;
            crowdsale_seven = _seven;
            crowdsale_eight = _eight;
            crowdsale_nine = _nine;
            crowdsale_ten = _ten;
    }

    function distribute() public payable {
        uint amount = msg.value / 10;
        crowdsale_one.transfer(amount);
        crowdsale_two.transfer(amount);
        crowdsale_three.transfer(amount);
        crowdsale_four.transfer(amount);
        crowdsale_five.transfer(amount);
        crowdsale_six.transfer(amount);
        crowdsale_seven.transfer(amount);
        crowdsale_eight.transfer(amount);
        crowdsale_nine.transfer(amount);
        crowdsale_ten.transfer(amount);
        uint remainder = msg.value - amount * 10;
        msg.sender.transfer(remainder);
    }
    function() external payable {
        distribute();
    }
}
