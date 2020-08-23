# Frontend for Starting Capital Project

## Getting started

## Keys

Create a keys.js file in this folder to add your keys. This file is ignored and not committed so your information will not be on github.
Add the content below with your infura url and contract address inside the quotes. This will automatically create a web3 instance with this information.
The address that is in ther is the contract address that has been used for testing so far, but can be updated.

```
const keys = {
    rpcUrl : 'https://kovan.infura.io/v3/{YOUR KEY}',
    address : '0x40F4eff644694c818B56844AcaFb0D14E5bC6339',
}

export default keys;
```

### Commands
*you must have node installed bed be able to run these commands

Run the command below to install packages when you pull or clone from the repo. You must be in the starting-capital-frontend directory
```
npm install
```

After installing packages, you can fire up the app by running the command below
```
npm run start
```

### Documenation

This app was created using react. Read their docs for more information
<a href="https://reactjs.org/docs/getting-started.html">React Docs</a>