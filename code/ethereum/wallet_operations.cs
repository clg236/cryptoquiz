using System.Net;
using Godot;
using System.Threading.Tasks;
using Nethereum.Web3;
using Nethereum.BlockchainProcessing;
using Nethereum.Hex.HexTypes;
using System;
using Nethereum.Web3.Accounts;
using Nethereum.Web3.Accounts.Managed;


public partial class wallet_operations : Node
{


    public void getBalance(string address) //TODO: pass in node, so we can return our value (signal maybe?)
    {

    var walletOperations = GetNode<Node>("/root/WalletOperations");

    Task.Run(async () => {
      	var web3 = new Web3("https://goerli.infura.io/v3/efcca7a01a1c4e0e9e28e8a311332a56");
      	var balance = await web3.Eth.GetBalance.SendRequestAsync(address);
        var etherAmount = Web3.Convert.FromWei(balance.Value);
        walletOperations.Call("set_balance", (double)etherAmount);
    });

    }

    // send ether
    public void sendEther(string key, string to, float amount)
    {
        var walletOperations = GetNode<Node>("/root/WalletOperations");
        var convertedAmount = (decimal)amount;
        GD.Print("sending eth");
        
        Task.Run(async () => {
            GD.Print("sending...");
            var network = "https://goerli.infura.io/v3/efcca7a01a1c4e0e9e28e8a311332a56";
            var privateKey = key;
            var account = new Account(privateKey);
            var web3 = new Web3(account, network);
            var toAddress = to;
            var transaction = await web3.Eth.GetEtherTransferService()
                .TransferEtherAndWaitForReceiptAsync(to, convertedAmount); //amount: .1m
            walletOperations.Call("send_ether");
            GD.Print(transaction);
    });

    }

    // call a smart contract function

}

