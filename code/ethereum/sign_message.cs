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

    public string signMessage(string message) 
    {
        var playerManager = GetNode<Node>("/root/PlayerManager");
        var address = playerManager.Call("get_address");

        var privateKey = "0xd7acaa8b621eb2b27a5f5b9d4489c2cf84d3f60659ece30718e07baaaa532fce";
        var signer = new EthereumMessageSigner();
        var signature = signer.EncodeUTF8AndSign(message, new EthECKey(privateKey));
        return signature;
    }

}