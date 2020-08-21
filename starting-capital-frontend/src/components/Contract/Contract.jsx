import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import Web3Service from '../../web3/web3.service';
import * as Web3 from 'web3';
import abi from './abi';
import keys from "../../keys"


class Contract extends PureComponent { 
  constructor(props) {
    super(props);

    this.state = {
      hasError: false,
      balance : 0,
      sctSaleAddress : null
    };

    this.web3 = null;
    this.setBalance = this.setBalance.bind(this);
  }

  componentWillMount = () => {
     //constructing an instance of web 3 with preset config
    const web3 = new Web3(keys.rpcUrl);
    const contract = new web3.eth.Contract(abi, keys.address);
    //call the methods to get the sct_sale_address value adn set state to re render ui
    contract.methods.sct_sale_address().call().then(
        address => this.setState({sctSaleAddress:address})
      )
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
        SCT Sale Address : { this.state.sctSaleAddress }
      </div>
    );
  }
}

export default Contract;
