using Godot;
using Nethereum.Signer;

public partial class sign_message : Node
{

    public string signMessage(string message, string key) 
    {
        var playerManager = GetNode<Node>("/root/PlayerManager");
        var address = playerManager.Call("get_address");

        var privateKey = key;
        var signer = new EthereumMessageSigner();
        var signature = signer.EncodeUTF8AndSign(message, new EthECKey(privateKey));
        return signature;
    }

}