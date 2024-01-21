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
def test_nft(owners, project):
    constructor_args = ["ipfs://test1234567890"]
    return project.TestNFT.deploy(*constructor_args, sender=owners[0])


@pytest.fixture(scope="session")
def issue_eth_txn(not_owner, wallet):
    args = [not_owner, "1 ether"]
    return lambda account: wallet.issueEthTxn(*args, sender=account)


@pytest.fixture(scope="session")
def issue_token_transfer_txn(not_owner, wallet, token_contract):
    args = [not_owner, "1 ether", token_contract]
    return lambda account: wallet.issueTokenTransferTxn(*args, sender=account)


@pytest.fixture(scope="session")
def issue_token_transfer_from_txn(not_owner, owners, wallet, token_contract):
    args = [not_owner, "1 ether", owners[0], token_contract]
    return lambda account: wallet.issueTokenTransferFromTxn(*args, sender=account)


@pytest.fixture(scope="session")
def issue_token_approval_txn(not_owner, wallet, token_contract):
    args = [not_owner, "1 ether", token_contract]
    return lambda account: wallet.issueTokenApprovalTxn(*args, sender=account)
