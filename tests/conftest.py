import pytest
from web3 import Web3


@pytest.fixture(scope="session")
def web3():
    return Web3(Web3.HTTPProvider("http://localhost:8545"))


@pytest.fixture(scope="session")
def owners(accounts):
    return accounts[0:3]


@pytest.fixture(scope="session")
def not_owner(accounts):
    return accounts[3]


@pytest.fixture(scope="session")
def wallet(owners, project):
    constructor_args = [owners, 2]
    return project.MultiSigWallet.deploy(*constructor_args, sender=owners[0])
