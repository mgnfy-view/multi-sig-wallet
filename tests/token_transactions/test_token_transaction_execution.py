import pytest
import ape


@pytest.mark.txn_execution
def test_token_txn_reverts_if_not_enough_approvals_given(
    owners, wallet, issue_token_transfer_txn
):
    issue_token_transfer_txn(owners[0])

    with ape.reverts(wallet.MultiSigWallet__NotEnoughApprovalsGiven):
        wallet.executeTxn(1, 0, sender=owners[0])


@pytest.mark.txn_execution
def test_token_txn_reverts_if_txn_already_executed(
    owners, wallet, token_contract, issue_token_transfer_txn
):
    issue_token_transfer_txn(owners[0])
    wallet.approveTxn(1, 0, sender=owners[0])
    wallet.approveTxn(1, 0, sender=owners[1])

    token_contract.transfer(wallet, "1 ether", sender=owners[0])
    wallet.executeTxn(1, 0, sender=owners[0])

    with ape.reverts(wallet.MultiSigWallet__TxnAlreadyExecuted):
        wallet.executeTxn(1, 0, sender=owners[0])


@pytest.mark.txn_execution
def test_token_transfer_execution_reverts_if_wallet_does_not_have_enough_tokens(
    owners, wallet, issue_token_transfer_txn
):
    issue_token_transfer_txn(owners[0])
    wallet.approveTxn(1, 0, sender=owners[0])
    wallet.approveTxn(1, 0, sender=owners[1])

    with ape.reverts(wallet.MultiSigWallet__NotEnoughTokens):
        wallet.executeTxn(1, 0, sender=owners[0])


@pytest.mark.txn_execution
def test_token_transfer_execution(
    owners, not_owner, wallet, token_contract, issue_token_transfer_txn, web3
):
    issue_token_transfer_txn(owners[0])
    wallet.approveTxn(1, 0, sender=owners[0])
    wallet.approveTxn(1, 0, sender=owners[1])

    token_contract.transfer(wallet, "1 ether", sender=owners[0])
    wallet.executeTxn(1, 0, sender=owners[0])

    assert token_contract.balanceOf(not_owner) == web3.to_wei(1, "ether")


@pytest.mark.txn_execution
def test_token_transfer_from_execution_reverts_if_wallet_does_not_have_enough_allowance(
    owners, wallet, issue_token_transfer_from_txn
):
    issue_token_transfer_from_txn(owners[0])
    wallet.approveTxn(1, 0, sender=owners[0])
    wallet.approveTxn(1, 0, sender=owners[1])

    with ape.reverts(wallet.MultiSigWallet__NotEnoughAllowance):
        wallet.executeTxn(1, 0, sender=owners[0])


@pytest.mark.txn_execution
def test_token_transfer_from_execution(
    owners, not_owner, wallet, token_contract, issue_token_transfer_from_txn, web3
):
    issue_token_transfer_from_txn(owners[0])
    wallet.approveTxn(1, 0, sender=owners[0])
    wallet.approveTxn(1, 0, sender=owners[1])

    token_contract.approve(wallet, web3.to_wei(1, "ether"), sender=owners[0])
    wallet.executeTxn(1, 0, sender=owners[0])

    assert token_contract.balanceOf(not_owner) == web3.to_wei(1, "ether")


@pytest.mark.txn_execution
def test_token_approval_execution_reverts_if_wallet_does_not_have_enough_tokens(
    owners, wallet, issue_token_approval_txn
):
    issue_token_approval_txn(owners[0])
    wallet.approveTxn(1, 0, sender=owners[0])
    wallet.approveTxn(1, 0, sender=owners[1])

    with ape.reverts(wallet.MultiSigWallet__NotEnoughTokens):
        wallet.executeTxn(1, 0, sender=owners[0])


@pytest.mark.txn_execution
def test_token_approval_execution(
    owners, not_owner, wallet, token_contract, issue_token_approval_txn, web3
):
    issue_token_approval_txn(owners[0])
    wallet.approveTxn(1, 0, sender=owners[0])
    wallet.approveTxn(1, 0, sender=owners[1])

    token_contract.transfer(wallet, web3.to_wei(1, "ether"), sender=owners[0])
    wallet.executeTxn(1, 0, sender=owners[0])

    assert token_contract.allowance(wallet, not_owner) == web3.to_wei(1, "ether")
