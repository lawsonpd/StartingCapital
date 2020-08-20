import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import Web3Service from '../../web3/web3.service';
//import { Test } from './Contract.styles';

class Contract extends PureComponent { 
  constructor(props) {
    super(props);

    this.state = {
      hasError: false,
      balance : 0
    };

    this.web3 = null;
    this.setBalance = this.setBalance.bind(this);
  }

  componentWillMount = () => {
     //constructing an instance of web 3 with preset config
     this.web3 = new Web3Service();
     this.setBalance()
  }

  setBalance(){
    this.web3.bal().then(bal => {
      console.log(bal)
      this.setState({ balance : bal })
    })
  }

  render () {
    if (this.state.hasError) {
      return <h1>Something went wrong.</h1>;
    }
    return (
      <div className="ContractWrapper">
        Balance : { this.state.balance }
      </div>
    );
  }
}

export default Contract;
