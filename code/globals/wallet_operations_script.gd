extends Node

# sign message script
var wallet_operations_script = load("res://code/ethereum/wallet_operations.cs")
var wallet_operations = wallet_operations_script.new()

signal balance_updated(balance)
signal ether_sent()
signal address_updated(address)

var last_balance

func _ready():
	var wallet_timer = Timer.new()
	add_child(wallet_timer)
	wallet_timer.start(5)
	wallet_timer.connect("timeout", _on_wallet_timer_timeout)
	add_child(wallet_operations)

func set_address(address):
	emit_signal("address_updated", address)
	
func set_balance(balance):
	emit_signal("balance_updated", balance)
	PlayerManager.player.total_eth = balance
	
func send_ether():
	emit_signal("ether_sent")
	
func _on_wallet_timer_timeout():
	pass
	# print('getting balance')
	# wallet_operations.getBalance(PlayerManager.player.eth_address)
