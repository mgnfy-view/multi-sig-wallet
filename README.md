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
    <li><a href="#usage">Usage</a></li>
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

To get the full list of multi-sig wallet functions and their descriptions, head over to `./docs/index.html`. Open the file in a web browser to view the documentation.

Additionally, you can view the most recent deployment of the contract [here]().

P.S: This project served as my submission for the python project for semester four of my Bachelor's in Computer Engineering. While everyone was leaning towards web development with Flask or Django, I decided to do something a bit unique.

### Built With

- ![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
- ![Eth-Ape](https://img.shields.io/badge/-ETH--APE-%23323330.svg?style=for-the-badge)
- ![Solidity](https://img.shields.io/badge/Solidity-%23363636.svg?style=for-the-badge&logo=solidity&logoColor=white)
- ![Ethereum](https://img.shields.io/badge/-ethereum-3C3C3D?logo=ethereum&logoColor=white&style=for-the-badge)


<!-- GETTING STARTED -->

## Getting Started

### Prerequisites

Make sure you have node.js, python3, pip3, and git installed and configured on your system. Also, you need to have a MetaMask account with sufficient ETH. If you are using the Sepolia testnet, you can get Sepolia testnet ETH from [Alchemy](https://sepoliafaucet.com/). Try to get about 3-4 ETH.```

### Installation

Clone this repository

```shell
git clone https://github.com/Sahil-Gujrati/multi-sig-wallet.git
```

Cd into the project folder and activate the virtual environment

```shell
cd multi-sig-wallet
python3 -m venv .venv
source .venv/bin/activate
```

Then install the project dependencies

```shell
pip3 install -r requirements.txt
npm install
```

### Setup and Deployment



<!-- USAGE EXAMPLES -->

## Usage


<!-- ROADMAP -->

## Roadmap

- [x] Write the multi-sig wallet smart contract
- [x] Write the deployment script
- [x] Conduct unit testing
- [ ] Deploy the wallet on the Sepolia testnet
- [ ] Write Natspec documentation and generate docs
- [ ] Write a good README.md

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