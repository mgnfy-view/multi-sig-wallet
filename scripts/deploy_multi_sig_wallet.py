from ape import accounts, networks, project


def main():
    """
    This functions is able to deploy the multi-sig wallet
    smart contract on both local and live chains, provided
    the constructor arguments are set correctly for a given
    network. However, please use the factory contract to
    deploy your wallets since it keeps track of the deployed
    wallets.
    """

    account_1 = None
    account_2 = None
    publish_source_code = True

    # use test accounts if we are on a local chain such
    # as hardhat
    print("Getting accounts")
    if networks.active_provider.chain_id in (1337, 31337):
        account_1 = accounts.test_accounts[0]
        account_2 = accounts.test_accounts[1]
        publish_source_code = False
    else:
        # here, use the aliases of the accounts that you have
        # imported with ape
        account_1 = accounts.load("Crosstalk")
        account_2 = accounts.load("Terrap0b")

    # set a valid value for the number of approvals
    # required for a wallet transaction to pass
    required_approvals = 2

    constructor_args = [[account_1, account_2], required_approvals]

    print("Deploying the wallet...")
    multi_sig_wallet = project.MultiSigWallet.deploy(
        *constructor_args, sender=account_1, publish=publish_source_code
    )

    # print the receipt after deployment
    print("Here's the receipt:")
    for key, value in multi_sig_wallet.receipt:
        print(key, value)
