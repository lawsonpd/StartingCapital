import * as Web3 from 'web3';
import settings from '../enums/settings.enum';

class Web3Service {

    constructor(){
        this.web3 = new Web3(settings.rpcUrl)
    }

    /**
     * wrapper around getBalance
     * gets balance of a wallet
     */
    bal(){
        return new Promise((resolve, reject) => {
            this.web3.eth.getBalance(settings.address, (err, wei) => {
                resolve(wei)
            });
        })
        
    }

}

export default Web3Service;