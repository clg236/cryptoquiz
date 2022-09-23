using System.Net;
using Godot;
using System.Threading.Tasks;
using Nethereum.Web3;
using Nethereum.BlockchainProcessing;
using Nethereum.Hex.HexTypes;

public partial class blockchain_manager : Node
{

	private Web3 web3;
	BlockchainProcessor processor;
	private Task<HexBigInteger> task;
	private bool taskCompleted = false;


	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		var player = GetNode<Node>("/root/PlayerManager");
		player.Call("get_address");
		ServicePointManager.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => true;
      	web3 = new Web3("https://ropsten.infura.io/v3/efcca7a01a1c4e0e9e28e8a311332a56");
      	processor = web3.Processing.Logs.CreateProcessor(log => GD.Print(log.ToString()));
		//task = web3.Eth.GetBalance.SendRequestAsync(player);
      	task = web3.Eth.GetBalance.SendRequestAsync("0x556E1fE6491036be98023B714390f1d4940Aaf45");
      	GD.Print(player);
	}

	public string create_wallet()
	{
		return "gotcha!";
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		 if (task.IsCompleted && taskCompleted == false)
		 {
			var amount = Web3.Convert.FromWei(task.Result);
			GD.Print($"Amount is {amount}.");
			taskCompleted = true;
     	}
  	}
}
