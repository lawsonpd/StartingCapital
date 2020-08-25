import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import { Container } from '@material-ui/core';
import Contract from '../Contract/Contract';
//import { Test } from './Main.styles';

class Main extends PureComponent { 
  constructor(props) {
    super(props);
    this.state = {
      hasError: false,
    };
  }

  componentDidMount(){
   
  }

  render () {
    if (this.state.hasError) {
      return <h1>Something went wrong.</h1>;
    }
    return (
      <Container maxWidth="md" className="app-container">
        Thanks for participating in Harold's Crowdsale! Below you will find a box to input the amount to contribute, a box where you select "wei" or "ether" - select "ether", and another where you input an Ethereum address you own the private keys for (beneficiary address). The Ethereum address you input will be the location at which you receive your Starting Capital ERC20 tokens and can be easily accessed through the Metamask extension on your browser. Limt 1 "ether" per participant.
        <Contract />
      </Container>
    );
  }
}

Main.propTypes = {
  // bla: PropTypes.string,
};

Main.defaultProps = {
  // bla: 'test',
};

export default Main;
