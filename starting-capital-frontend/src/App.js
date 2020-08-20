import React from 'react';
import './App.css';
import AppBar from '@material-ui/core/AppBar';
import Main from './components/Main/Main';

function App() {
  const title = 'Starting Capital'
  return (
    <div className="App">
     <AppBar position="static" className="app-bar" color="primary">
        <h1>
          { title }
        </h1>
     </AppBar>
     <Main />
    </div>
  );
}

export default App;
