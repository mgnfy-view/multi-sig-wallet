import pytest
import ape


@pytest.fixture
def issue_eth_transaction_request(wallet):
    return lambda args, account: wallet.issueTransactionRequest(*args, sender=account)


@pytest.mark.transaction_execution
def test_only_owners_can_execute_transaction(
    not_owner, owners, wallet, issue_eth_transaction_request
):
    args = [0, 0, not_owner, "1 ether"]
    issue_eth_transaction_request(args, owners[0])

    with ape.reverts(wallet.MultiSigWallet__NotOneOfTheOwners):
        wallet.executeTransaction(0, sender=not_owner)


@pytest.mark.transaction_execution
def test_passing_an_invalid_transaction_index_reverts(
    not_owner, owners, wallet, issue_eth_transaction_request
):
    args = [0, 0, not_owner, "1 ether"]
    issue_eth_transaction_request(args, owners[0])

    with ape.reverts(wallet.MultiSigWallet__InvalidTransactionIndex):
        wallet.executeTransaction(100, sender=owners[0])


@pytest.mark.transaction_execution
def test_execution_reverts_if_wallet_does_not_have_enough_balance(
    not_owner, owners, wallet, issue_eth_transaction_request
):
    args = [0, 0, not_owner, "1 ether"]
    issue_eth_transaction_request(args, owners[0])

    wallet.approveTransaction(0, sender=owners[0])
    wallet.approveTransaction(0, sender=owners[1])

    with ape.reverts(wallet.MultiSigWallet__NotEnoughEtH):
        wallet.executeTransaction(0, sender=owners[0])


@pytest.mark.transaction_execution
def test_transaction_succeeds_if_wallet_has_enough_eth(
    not_owner, owners, wallet, web3, issue_eth_transaction_request
):
    args = [0, 0, not_owner, "1 ether"]
    issue_eth_transaction_request(args, owners[0])

    wallet.approveTransaction(0, sender=owners[0])
    wallet.approveTransaction(0, sender=owners[1])

    not_owner_initial_balance = web3.eth.get_balance(not_owner.address)

    owners[0].transfer(wallet, "2 ether")
    wallet.executeTransaction(0, sender=owners[0])

    assert web3.eth.get_balance(
        not_owner.address
    ) - not_owner_initial_balance == web3.to_wei(1, "ether")


@pytest.mark.transaction_execution
def test_transaction_emits_transaction_executed_event_on_success(
    not_owner, owners, wallet, web3, issue_eth_transaction_request
):
    args = [0, 0, not_owner, "1 ether"]
    issue_eth_transaction_request(args, owners[0])

    wallet.approveTransaction(0, sender=owners[0])
    wallet.approveTransaction(0, sender=owners[1])

    owners[0].transfer(wallet, "2 ether")
    transaction_receipt = wallet.executeTransaction(0, sender=owners[0])

    logs = list(transaction_receipt.decode_logs(wallet.TransactionExecuted))

    assert len(logs) == 1
    assert logs[0].transactionIndex == 0
    assert logs[0].transactionType == 0
    assert logs[0].transactionAction == 0
