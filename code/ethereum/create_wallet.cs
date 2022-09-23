using System.Net;
using Godot;
using System;
using static System.Console;
using System.Collections;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Nethereum.HdWallet;
using Nethereum.Web3;
using Nethereum.Web3.Accounts;
using Newtonsoft.Json;
using NBitcoin;
using Rijndael256;

namespace Wallets
    {
    public partial class create_wallet : Node
    {

        const string network = "https://ropsten.infura.io/v3/efcca7a01a1c4e0e9e28e8a311332a56";
        const string workingDirectory = @"wallets\"; // Path where you want to store the Wallets
        //Wallet wallet = new Wallet(Wordlist.English, WordCount.Twelve);
        Web3 web3 = new Web3(network);

        public string seed_words; 
        public string eth_account;

        public string createWallet(string password)
        {

            // Create brand-new wallet and get all the Words that were used.
            Wallet wallet = new Wallet(Wordlist.English, WordCount.Twelve);
            string words = string.Join(" ", wallet.Words);
            string fileName = string.Empty;

            // create our wallets directory. 
            System.IO.Directory.CreateDirectory(workingDirectory);

            // try to save the wallet to our directory
            try 
            {
                fileName = SaveWalletToJsonFile(wallet, password, workingDirectory);
            }
            catch (Exception e)
            {
                GD.Print("error saving wallet");
            }

            // set our seed words for the front end
            seed_words = words;

            // set our account for the front end
            eth_account = wallet.GetAccount(0).Address;



            return wallet.GetAccount(0).Address;
        }

        private static string SaveWalletToJsonFile(Wallet wallet, string password, string filepath)
        {
            string words = string.Join(" ", wallet.Words);
            string address = wallet.GetAccount(0).Address;
            var encryptedWords = Rijndael.Encrypt(words, password, KeySize.Aes256);
            string date = DateTime.Now.ToString();
            var walletJsonData = new { address, encryptedWords = encryptedWords, date = date };
            string json = JsonConvert.SerializeObject(walletJsonData);
            Random random = new Random();
            var fileName =
                "EthereumWallet_"
                + DateTime.Now.Year + "-"
                + DateTime.Now.Month + "-"
                + DateTime.Now.Day + "-"
                + DateTime.Now.Hour + "-"
                + DateTime.Now.Minute + "-"
                + DateTime.Now.Second + "-"
                + random.Next(0, 1000) + ".json";
            System.IO.File.WriteAllText(Path.Combine(filepath, fileName), json);
            GD.Print(fileName);
            return fileName;
        }
    }
}