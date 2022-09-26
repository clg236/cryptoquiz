using Godot;
using Nethereum.Web3;
using Nethereum.Util;
using System.Collections.Generic;
using System.Text;
using Nethereum.Signer;
using Nethereum.Hex.HexConvertors.Extensions;
using Nethereum.ABI.Encoders;

public partial class sign_message : Node
{

    public string signMessage(string message, string key) 
    {
        var playerManager = GetNode<Node>("/root/PlayerManager");
        var address = playerManager.Call("get_address");

        var privateKey = key;
        var signer = new EthereumMessageSigner();
        var signature = signer.EncodeUTF8AndSign(message, new EthECKey(privateKey));
        GD.Print(signature);
        return signature;
    }

}