import React, { PureComponent } from 'react';
import * as Web3 from 'web3';
import abi from './abi';
import startingCapitalAbi from './startingCapitalAbi';
import keys from "../../keys"
import TextField from '@material-ui/core/TextField';
import { Button, FormControl, InputLabel, OutlinedInput, InputAdornment, IconButton } from '@material-ui/core';

//TEST CONTRACT ADDRESS, ADD TO keys.js file
//0x2BBBea5fA645865Fc61B3E09691DFC6157C5d9eF
class Contract extends PureComponent {
  constructor(props) {
    super(props);

    this.state = {
      error: { exists: false, msg: '' },
      balance: 0,
      sctSaleAddress: null,
      loading: true
    };

    this.web3 = new Web3(keys.rpcUrl);
    this.getContracts = this.getContracts.bind(this);
    this.startingCapitalContract = null;
  }

  componentWillMount = () => {
    //getting contracts when app component starts
    this.getContracts()
  }

  async getContracts() {
    const salesDeployerContract = new this.web3.eth.Contract(abi, keys.address);
    console.log(salesDeployerContract)
    let nextContractAddress = await salesDeployerContract.methods.sct_sale_address().call();
    console.log(nextContractAddress)
    if (nextContractAddress) {
      const startingCapitalContract = new this.web3.eth.Contract(startingCapitalAbi, nextContractAddress);
      this.startingCapitalContract = startingCapitalContract;
      this.setState({ loading: false, sctSaleAddress: nextContractAddress });
    } else {
      this.setState({ error: { exists: true, msg: 'No Address Found!' } })
    }
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
          <h2>CAP Token</h2>
        </div>
        <div>
          <b>SCT Sale Address</b> : {this.state.sctSaleAddress}
        </div>
        <div className="form">
          {/* <TextField 
            id="outlined-search" 
            label="Amount" 
            type="number" 
            variant="outlined" />
            <div className="buy">
              <Button variant="contained">Buy</Button>
            </div> */}
          <FormControl variant="outlined">
            <InputLabel htmlFor="outlined-adornment-amount">Amount</InputLabel>
            <OutlinedInput
              id="outlined-adornment-amount"
              type={'text'}
              //value={values.password}
              //onChange={handleChange('password')}
              endAdornment={
                <InputAdornment position="end">
                  <IconButton
                    color="primary"
                    aria-label="buy tokens"
                    // onClick={handleClickShowPassword}
                    // onMouseDown={handleMouseDownPassword}
                    edge="end"
                    >
                    $Buy
                  </IconButton>
                </InputAdornment>
              }
              labelWidth={80}
            />
          </FormControl>
        </div>
      </div>
    );
  }
}

export default Contract;
