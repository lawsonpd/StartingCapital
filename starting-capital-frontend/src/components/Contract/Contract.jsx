import React, { PureComponent } from 'react';
import * as Web3 from 'web3';
import abi from './abi';
import startingCapitalAbi from './startingCapitalAbi';
import keys from "../../keys"
import TextField from '@material-ui/core/TextField';
import { Button, FormControl, InputLabel, Select, MenuItem } from '@material-ui/core';

class Contract extends PureComponent {
  constructor(props) {
    super(props);

    this.state = {
      error: { exists: false, msg: '' },
      balance: 0,
      sctSaleAddress: null,
      loading: true,

      buy: {
        type: 'wei',
        amount: 1,
        address: ''
      },

      transactionOnKovan: null
    };

    this.web3 = new Web3(keys.rpcUrl);
    this.startingCapitalContract = null;

    this.setBuyField = this.setBuyField.bind(this);
    this.getContracts = this.getContracts.bind(this);
    this.handleAmountType = this.handleAmountType.bind(this);
    this.buy = this.buy.bind(this);
  }

  componentWillMount = () => {
    //getting contracts when app component starts
    this.getContracts()
    this.enableEth()
  }

  enableEth() {
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum);
      window.ethereum.enable()
    }
  }

  async getContracts() {
    //get initial contract to get sct sales address
    const salesDeployerContract = new this.web3.eth.Contract(abi, keys.address);
    let nextContractAddress = await salesDeployerContract.methods.sct_sale_address().call();
    //if we get an address after the call, fetch second contract
    if (nextContractAddress) {
      const startingCapitalContract = new this.web3.eth.Contract(startingCapitalAbi, nextContractAddress);
      //store contract in state variable for use outsise of this function
      this.startingCapitalContract = startingCapitalContract;
      this.setState({ loading: false, sctSaleAddress: nextContractAddress });
    } else {
      this.setState({ error: { exists: true, msg: 'No Address Found!' } })
    }
  }

  setBuyField({ target }, field) {
    let buy = { ...this.state.buy }
    buy[field] = target.value;
    this.setState({ buy });
  }

  handleAmountType() {
    if (this.state.buy.type === 'ether') {
      let buy = { ...this.state.buy }
      let wei = Web3.utils.toWei(this.state.buy.amount, 'ether');
      buy.amount = wei;
      return buy;
    }
    return this.state.buy;
  }

  async buy() {
    let request = this.handleAmountType();
    //use meta mask client to do transaction
    window.ethereum
      .request({
        method: 'eth_sendTransaction',
        params: [
          {
            from: request.address, //the address the user puts in the beneficiary address input
            to: this.state.sctSaleAddress, //address we get from the first contract on line: 56
            nonce: '0x00', // ignored by MetaMask
            gasPrice: Web3.utils.toHex(Web3.utils.toWei('9', 'gwei')),// customizable by user during MetaMask confirmation.
            gas: Web3.utils.toHex(3000000), // customizable by user during MetaMask confirmation.
            value: Web3.utils.toHex(request.amount), // Only required to send ether to the recipient from the initiating external account.
            chainId: 3,
            data: `0xec8ac4d8000000000000000000000000${request.address.replace('0x', '')}` //spefic data hex so meta mask knows this is for buying tokens
          }
        ]
      }).then(
        txHash => {
          if (txHash) {
            //if hash returns successful, show user link to view on etherscan
            this.setState({ transactionOnKovan: `https://kovan.etherscan.io/tx/${txHash}` })
          }
        })
  }

  render() {
    if (this.state.error.exists) {
      return <h1 className="error-text">{this.state.error.msg}</h1>;
    }

    if (this.state.loading) {
      return <h1 className="primary-text">Loading ... </h1>;
    }

    return (
      <div className="contract-wrapper">
        <div>
          <h2>SCAP Token</h2>
        </div>
        <div>
          <b>SCT Sale Address</b> : {this.state.sctSaleAddress}
        </div>
        <div className="form">
          <div className="form-input">
            <TextField
              id="outlined-amount-field"
              label="Amount"
              type="number"
              variant="outlined"
              value={this.state.buy.amount}
              onChange={event => this.setBuyField(event, 'amount')} />
            <FormControl variant="outlined" className="type-form-select">
              <InputLabel id="demo-simple-select-outlined-label">Type</InputLabel>
              <Select
                labelId="demo-simple-select-outlined-label"
                id="demo-simple-select-outlined"
                onChange={event => this.setBuyField(event, 'type')}
                label="Type"
                value={this.state.buy.type}
              >
                <MenuItem value={'wei'}>wei</MenuItem>
                <MenuItem value={'ether'}>ether</MenuItem>
              </Select>
            </FormControl>
          </div>

          <div className="form-input">
            <TextField
              id="outlined-address-field"
              label="Beneficiary Address"
              type="text"
              variant="outlined"
              value={this.state.buy.address}
              onChange={event => this.setBuyField(event, 'address')}
              fullWidth={true} />
          </div>
          {
            this.state.transactionOnKovan ?
              <p>
                <a href={this.state.transactionOnKovan}
                  target="_blank"
                  rel="noopener noreferrer">View Transaction on Kovan</a>
              </p> : null
          }
          <div className="buy">
            <Button variant="contained" color="primary" onClick={this.buy}>Buy</Button>
          </div>
        </div>
      </div>
    );
  }
}

export default Contract;
