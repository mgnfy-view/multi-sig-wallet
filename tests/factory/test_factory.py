import pytest


@pytest.mark.test_factory
def test_factory_initialisation(factory):
    assert factory.getTotalNumberOfWalletsDeployed() == 0


@pytest.mark.test_factory
def test_wallet_deployment_using_factory(owners, factory):
    constructor_args = [[owners[0], owners[1]], 2]
    txn_receipt = factory.deployWallet(*constructor_args, sender=owners[0])
    logs = txn_receipt.decode_logs(factory.WalletDeployed)

    assert factory.getTotalNumberOfWalletsDeployed() == 1
    assert factory.getWalletAddress(owners[0]) == logs[0].walletAddress
    assert factory.getWalletAddress(owners[1]) == logs[0].walletAddress


@pytest.mark.test_factory
def test_wallet_deployment_using_factory_emits_wallet_deployed_event(owners, factory):
    constructor_args = [[owners[0], owners[1]], 2]
    txn_receipt = factory.deployWallet(*constructor_args, sender=owners[0])
    logs = txn_receipt.decode_logs(factory.WalletDeployed)

    assert len(logs) == 1
    assert logs[0].walletAddress > "0x0000000000000000000000000000000000000000"
