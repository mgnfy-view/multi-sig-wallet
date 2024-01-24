import pytest
import ape


@pytest.mark.txn_execution
def test_eth_txn_execution_succeeds_if_conditions_have_been_met(
    owners, not_owner, wallet, issue_eth_txn, web3
):
    issue_eth_txn(owners[0])
    not_owner_initial_balance = web3.eth.get_balance(not_owner.address)
    wallet.approveTxn(0, 0, sender=owners[0])
    wallet.approveTxn(0, 0, sender=owners[1])
    owners[0].transfer(wallet.address, "2 ether")
    wallet.executeTxn(0, 0, sender=owners[0])
    not_owner_new_balance = web3.eth.get_balance(not_owner.address)

    assert not_owner_new_balance - not_owner_initial_balance == web3.to_wei(1, "ether")


@pytest.mark.txn_execution
def test_eth_txn_emits_txn_executed_event_on_success(owners, wallet, issue_eth_txn):
    issue_eth_txn(owners[0])
    wallet.approveTxn(0, 0, sender=owners[0])
    wallet.approveTxn(0, 0, sender=owners[1])
    owners[0].transfer(wallet.address, "2 ether")
    txn_receipt = wallet.executeTxn(0, 0, sender=owners[0])
    logs = txn_receipt.decode_logs(wallet.TxnExecuted)

    assert len(logs) == 1
    assert logs[0].txnType == 0
    assert logs[0].txnIndex == 0
    assert logs[0].by == owners[0]


@pytest.mark.txn_execution
def test_only_owners_can_execute_eth_txns(owners, not_owner, wallet, issue_eth_txn):
    issue_eth_txn(owners[0])
    wallet.approveTxn(0, 0, sender=owners[0])
    wallet.approveTxn(0, 0, sender=owners[1])

    with ape.reverts(wallet.MultiSigWallet__NotOneOfTheOwners):
        wallet.executeTxn(0, 0, sender=not_owner)


@pytest.mark.txn_execution
def test_passing_an_invalid_eth_txn_index_reverts(owners, wallet, issue_eth_txn):
    issue_eth_txn(owners[0])

    with ape.reverts(wallet.MultiSigWallet__InvalidIndex):
        wallet.executeTxn(0, 10, sender=owners[0])


@pytest.mark.txn_execution
def test_eth_txn_execution_reverts_if_not_enough_approvals_have_been_given(
    owners, wallet, issue_eth_txn
):
    issue_eth_txn(owners[0])
    wallet.approveTxn(0, 0, sender=owners[0])

    with ape.reverts(wallet.MultiSigWallet__NotEnoughApprovalsGiven):
        wallet.executeTxn(0, 0, sender=owners[0])


@pytest.mark.txn_execution
def test_eth_txns_can_only_be_executed_once(owners, wallet, issue_eth_txn):
    issue_eth_txn(owners[0])
    wallet.approveTxn(0, 0, sender=owners[0])
    wallet.approveTxn(0, 0, sender=owners[1])
    owners[0].transfer(wallet.address, "2 ether")
    wallet.executeTxn(0, 0, sender=owners[0])

    with ape.reverts(wallet.MultiSigWallet__TxnAlreadyExecuted):
        wallet.executeTxn(0, 0, sender=owners[0])


@pytest.mark.txn_execution
def test_eth_txn_execution_reverts_if_wallet_does_not_have_enough_balance(
    owners, wallet, issue_eth_txn
):
    issue_eth_txn(owners[0])
    wallet.approveTxn(0, 0, sender=owners[0])
    wallet.approveTxn(0, 0, sender=owners[1])

    with ape.reverts(wallet.MultiSigWallet__NotEnoughEtH):
        wallet.executeTxn(0, 0, sender=owners[0])
