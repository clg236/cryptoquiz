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

    public string signMessage() 
    {
        var player = GetNode<Node>("/root/PlayerManager");
        //var address = player.Call("get_address");
        GD.Print("have an address");
        GD.Print(player);
        return "signed";
    }

}