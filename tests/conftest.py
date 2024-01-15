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


@pytest.fixture(scope="session")
def token_contract(owners, project, web3):
    constructor_args = [web3.to_wei(10, "ether")]
    return project.TestToken.deploy(*constructor_args, sender=owners[0])


@pytest.fixture(scope="session")
def issue_eth_transfer_transaction_request(owners, not_owner, wallet):
    return lambda account: wallet.issueETHTransferTransactionRequest(
        *[not_owner, "1 ether"], sender=account
    )


@pytest.fixture(scope="session")
def issue_token_transfer_transaction_request(
    not_owner, owners, wallet, token_contract, web3
):
    args = [token_contract, 0, not_owner, web3.to_wei(0.5, "ether")]
    return lambda account: wallet.issueTokenTransferTransactionRequest(
        *args, sender=account
    )
