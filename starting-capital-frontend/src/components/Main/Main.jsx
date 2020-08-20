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
        Possible description explaining what this app is about and some instructions?
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
