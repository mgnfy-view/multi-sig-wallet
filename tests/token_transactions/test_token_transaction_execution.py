import pytest
import ape

# test token transfer execution


@pytest.mark.transaction_execution
def test_token_transfer_execution_succeeds(
    owners, not_owner, wallet, token_contract, issue_token_transfer_request, web3
):
    issue_token_transfer_request(owners[0])
    wallet.approveTransaction(0, sender=owners[0])
    wallet.approveTransaction(0, sender=owners[1])

    token_contract.transfer(wallet, web3.to_wei(1, "ether"), sender=owners[0])
    wallet.executeTransaction(0, sender=owners[0])

    assert token_contract.balanceOf(not_owner) == web3.to_wei(0.5, "ether")


@pytest.mark.transaction_execution
def test_token_transfer_from_succeeds(
    owners, not_owner, wallet, token_contract, issue_token_transfer_from_request, web3
):
    issue_token_transfer_from_request(owners[0])
    wallet.approveTransaction(0, sender=owners[0])
    wallet.approveTransaction(0, sender=owners[1])

    token_contract.approve(wallet, web3.to_wei(1, "ether"), sender=owners[0])
    wallet.executeTransaction(0, sender=owners[0])

    assert token_contract.balanceOf(owners[0]) == web3.to_wei(9.5, "ether")
    assert token_contract.balanceOf(not_owner) == web3.to_wei(0.5, "ether")


@pytest.mark.transaction_execution
def test_token_approval_succeeds(
    owners, not_owner, wallet, token_contract, issue_token_approval_request, web3
):
    issue_token_approval_request(owners[0])
    wallet.approveTransaction(0, sender=owners[0])
    wallet.approveTransaction(0, sender=owners[1])

    token_contract.transfer(wallet, web3.to_wei(1, "ether"), sender=owners[0])
    wallet.executeTransaction(0, sender=owners[0])

    assert token_contract.allowance(wallet, not_owner) == web3.to_wei(0.5, "ether")


@pytest.mark.transaction_execution
def test_only_owners_can_execute_transaction(
    owners, not_owner, wallet, issue_token_transfer_request
):
    issue_token_transfer_request(owners[0])

    with ape.reverts(wallet.MultiSigWallet__NotOneOfTheOwners):
        wallet.executeTransaction(0, sender=not_owner)


@pytest.mark.transaction_execution
def test_passing_an_invalid_transaction_index_reverts(
    owners, wallet, issue_token_transfer_request
):
    issue_token_transfer_request(owners[0])

    with ape.reverts(wallet.MultiSigWallet__InvalidTransactionIndex):
        wallet.executeTransaction(100, sender=owners[0])


@pytest.mark.transaction_execution
def test_transfer_reverts_if_wallet_does_not_have_enough_tokens(
    owners, wallet, issue_token_transfer_request
):
    issue_token_transfer_request(owners[0])
    wallet.approveTransaction(0, sender=owners[0])
    wallet.approveTransaction(0, sender=owners[1])

    with ape.reverts(wallet.MultiSigWallet__NotEnoughTokens):
        wallet.executeTransaction(0, sender=owners[0])


@pytest.mark.transaction_execution
def test_transfer_from_reverts_if_wallet_does_not_have_enough_token_allowance(
    owners, wallet, issue_token_transfer_from_request
):
    issue_token_transfer_from_request(owners[0])
    wallet.approveTransaction(0, sender=owners[0])
    wallet.approveTransaction(0, sender=owners[1])

    with ape.reverts(wallet.MultiSigWallet__NotEnoughAllowance):
        wallet.executeTransaction(0, sender=owners[0])


@pytest.mark.transaction_execution
def test_approval_reverts_if_wallet_does_not_have_enough_token_balance(
    owners, wallet, issue_token_approval_request
):
    issue_token_approval_request(owners[0])
    wallet.approveTransaction(0, sender=owners[0])
    wallet.approveTransaction(0, sender=owners[1])

    with ape.reverts(wallet.MultiSigWallet__NotEnoughTokens):
        wallet.executeTransaction(0, sender=owners[0])
