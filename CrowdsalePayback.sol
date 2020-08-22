pragma solidity ^0.5.0;
// SPDX-License-Identifier: UNLICENSED
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol";
contract CrowdsaleGiveBack {
    using SafeMath for uint;
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
    uint send_amount;
    //constructor
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
    function balance() public view returns(uint) {
        return address(this).balance;
    }
    function deposit() public payable {
        uint tmp_amt = msg.value;
        uint amount = tmp_amt.div(10);
        crowdsale_one.call.value(amount);
        crowdsale_two.call.value(amount);
        crowdsale_three.call.value(amount);
        crowdsale_four.call.value(amount);
        crowdsale_five.call.value(amount);
        crowdsale_six.call.value(amount);
        crowdsale_seven.call.value(amount);
        crowdsale_eight.call.value(amount);
        crowdsale_nine.call.value(amount);
        crowdsale_ten.call.value(amount);
        uint remainder = tmp_amt.sub(amount);
        remainder = remainder.mul(10);
        msg.sender.call.value(remainder);
    }
    function() external payable {
        deposit();
    }
}