import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import Web3Service from '../../web3/web3.service';
//import { Test } from './Contract.styles';
import keys from "../../keys"
import * as web3 from "web3"
const Web3EthContract = require('web3-eth-contract');

class Contract extends PureComponent { 
  constructor(props) {
    super(props);

    this.state = {
      hasError: false,
      balance : 0
    };

    this.web3 = null;
    this.setBalance = this.setBalance.bind(this);
    this.abi = [
      {
          "inputs": [
              {
                  "internalType": "string",
                  "name": "name",
                  "type": "string"
              },
              {
                  "internalType": "string",
                  "name": "symbol",
                  "type": "string"
              },
              {
                  "internalType": "address payable",
                  "name": "wallet",
                  "type": "address"
              }
          ],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "constructor"
      },
      {
          "constant": true,
          "inputs": [],
          "name": "sct_sale_address",
          "outputs": [
              {
                  "internalType": "address",
                  "name": "",
                  "type": "address"
              }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
      },
      {
          "constant": true,
          "inputs": [],
          "name": "token_address",
          "outputs": [
              {
                  "internalType": "address",
                  "name": "",
                  "type": "address"
              }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
      }
  ]
  
  
  

  }

  componentWillMount = () => {
     //constructing an instance of web 3 with preset config
     this.web3 = new Web3Service();
     const contract = new Web3EthContract(this.abi, keys.address)
     console.log(contract)
     let address = contract.methods.sct_sale_address().call()
     console.log(address)
  }

  setBalance(){
    this.web3.bal().then(bal => {
      this.setState({ balance : bal });
    })
  }

  render () {
    if (this.state.hasError) {
      return <h1>Something went wrong.</h1>;
    }
    return (
      <div className="ContractWrapper">
        {/* Balance : { this.state.balance } */}
      </div>
    );
  }
}

export default Contract;
