<!-- PROJECT SHIELDS -->

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]


<!-- PROJECT LOGO -->

<div align="center">
  <h3 align="center">Multi-Sig Wallet</h3>

  <p align="center">
    A multi-signature wallet implementation using the Eth-Ape framework in python
    <br />
    <a href="https://github.com/Sahil-Gujrati/multi-sig-wallet/blob/main/docs"><strong>Explore the docs »</strong></a>
    <br />
    <a href="https://github.com/Sahil-Gujrati/multi-sig-wallet/issues">Report Bug</a>
    ·
    <a href="https://github.com/Sahil-Gujrati/multi-sig-wallet/issues">Request Feature</a>
  </p>
</div>


<!-- TABLE OF CONTENTS -->

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#setup-and-deployment">Setup and Deployment</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>


<!-- ABOUT THE PROJECT -->

## About The Project

A multi-sig wallet, also known as a multi-signature wallet, is a crypto wallet which is held by multiple owners, and requires a predetermined minimum number of approvals to authorize and execute transactions.

The wallet owners and the minimum number of approvals required for transaction authorization are set during deployment of the smart contract. A transaction request can be issued by any one of the owners. Further, the transaction can be approved by other wallet owners, and then executed. This implementation of the multi-sig wallet supports ether, token, and NFT transactions.

To get a full list of multi-sig wallet functions and their descriptions, head over to `./docs/index.html`. Open the file in a web browser to view the documentation.

Additionally, you can view the most recent deployment of an example wallet contract [here](https://sepolia.etherscan.io/address/0xCdec20F79bd58A9A30870f632e3F928717cffa95).


### Built With

- ![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
- ![Eth-Ape](https://img.shields.io/badge/-ETH--APE-FFFFFF.svg?style=for-the-badge)
- ![Solidity](https://img.shields.io/badge/Solidity-%23363636.svg?style=for-the-badge&logo=solidity&logoColor=white)
- ![Ethereum](https://img.shields.io/badge/-ethereum-3C3C3D?logo=ethereum&logoColor=white&style=for-the-badge)


<!-- GETTING STARTED -->

## Getting Started

### Prerequisites

Make sure you have node.js, python3, pip3, python3-venv, and git installed and configured on your system. Also, you need to have a bunch of MetaMask accounts, with atleast one of them (the deployer) having about 1 ETH. If you are using the Sepolia testnet, you can get Sepolia testnet ETH from the [Alchemy faucet](https://sepoliafaucet.com/).

### Installation

Clone this repository

```shell
git clone https://github.com/mgnfy-view/multi-sig-wallet.git
```

Cd into the project folder and activate the virtual environment

```shell
cd multi-sig-wallet
python3 -m venv .venv
source .venv/bin/activate
```

Then install the dependencies

```shell
pip3 install -r requirements.txt
ape pm install .
npm install
```

Don't forget to install the plugins required by this project!

```shell
ape plugins install .
```

### Setup and Deployment

> [!WARNING]
> The multi-sig wallet contract hasn't undergone a security review yet. It is highy advisable to keep your deployments restricted to testnets only.

You need to bring your Metamask accounts into ape. One of these accounts will be used to deploy your wallet. The others, along with the deployer, will be joint owners of the multi-sig wallet. You can import as many accounts as you like with

```shell
ape accounts import <ALIAS>
```
Answer the prompts and your accounts will be registered with ape. You will need to provide an alias for each account, and a passphrase. Don't forget these! Ape will ask you for the passphrase to sign transactions.

If you would like to deploy to the Sepolia testnet, you'll need to get your api key from [Alchemy](https://www.alchemy.com/), and set it as an environment variable

```shell
export WEB3_ALCHEMY_API_KEY=<YOUR_API_KEY>
```

Additionally, you can get an api key from [Etherscan](https://docs.etherscan.io/getting-started/creating-an-account) to publish and verify your contracts. Once you have the api key, set it as an environment variable

```shell
export ETHERSCAN_API_KEY=<YOUR_API_KEY>
```

Then, go to `./scripts/deploy_multi_sig_wallet.py` and bring in your accounts using the account aliases you set before. Remember, account_1 is the deployer.

```python
account_1 = accounts.load("<ALIAS_1>")
account_2 = accounts.load("<ALIAS_2>")
...
account_n = accounts.load("<ALIAS_n>")
```

Set the minimum number of required approvals to authorize a transaction to a valid value (required_approvals <= number of wallet owners and required_approvals > 0).

```python
required_approvals = 2 # an example
```
> [!TIP]
> You can pass in only one owner, and set the required_approvals to 0 to use the multi-sig wallet as a conventional wallet!

Add all your accounts to the constructor arguments in order. These accounts will be registered as wallet owners during deployment.

```python
constructor_args = [[account_1, account_2,..., account_n], required_approvals]
```

Finally, deploy your wallet to your preferred network (I'm using the Sepolia testnet as an example here)

```shell
ape run scripts/deploy_multi_sig_wallet.py --network ethereum:sepolia:alchemy
```

This will prompt you to sign the transaction by entering your passphrase. Wait for some time as the deployment script deploys the contract and publishes the contract code on Etherscan.

And there you have it, your very own multi-sig wallet!

You can go to Etherscan, paste in your wallet's address, connect your Metamask account (which is one of the wallet owners), and start issuing, approving, and executing transactions!


<!-- ROADMAP -->

## Roadmap

- [x] Write the multi-sig wallet and factory smart contracts
- [x] Write deployment scripts
- [x] Conduct unit testing
- [x] Perform gas optimizations
- [x] Deploy the wallet on Sepolia testnet
- [x] Write Natspec documentation and generate docs
- [x] Write a good README.md

See the [open issues](https://github.com/Sahil-Gujrati/multi-sig-wallet/issues) for a full list of proposed features (and known issues).


<!-- CONTRIBUTING -->

## Contributing

Check out [CONTRIBUTING.md](./.github/CONTRIBUTING.md) for contribution guidelines. 


<!-- LICENSE -->

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.


<!-- CONTACT -->

## Contact

Sahil Gujrati - [@twitter_handle](https://twitter.com/Sahil__Gujrati) - sahilgujrati12@gmail.com

Project Link: [https://github.com/Sahil-Gujrati/multi-sig-wallet](https://github.com/Sahil-Gujrati/multi-sig-wallet)


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/Sahil-Gujrati/multi-sig-wallet.svg?style=for-the-badge
[contributors-url]: https://github.com/Sahil-Gujrati/multi-sig-wallet/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/Sahil-Gujrati/multi-sig-wallet.svg?style=for-the-badge
[forks-url]: https://github.com/Sahil-Gujrati/multi-sig-wallet/network/members
[stars-shield]: https://img.shields.io/github/stars/Sahil-Gujrati/multi-sig-wallet.svg?style=for-the-badge
[stars-url]: https://github.com/Sahil-Gujrati/multi-sig-wallet/stargazers
[issues-shield]: https://img.shields.io/github/issues/Sahil-Gujrati/multi-sig-wallet.svg?style=for-the-badge
[issues-url]: https://github.com/Sahil-Gujrati/multi-sig-wallet/issues
[license-shield]: https://img.shields.io/github/license/Sahil-Gujrati/multi-sig-wallet.svg?style=for-the-badge
[license-url]: https://github.com/Sahil-Gujrati/multi-sig-wallet/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/sahil-gujrati-125ab0284
