require('@nomiclabs/hardhat-waffle');

const INFURA_API_KEY = process.env.INFURA_API_KEY;

// Replace this private key with your Ropsten account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Be aware of NEVER putting real Ether into testing accounts
const KOVAN_PRIVATE_KEY = process.env.KOVAN_PRIVATE_KEY;

module.exports = {
	solidity: '0.8.3',
	networks: {
		kovan: {
			url: `https://kovan.infura.io/v3/${INFURA_API_KEY}`,
			accounts: [`0x${KOVAN_PRIVATE_KEY}`],
		},
	},
};
