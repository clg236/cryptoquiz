extends Node

# sign message script
var wallet_operations_script = load("res://code/ethereum/wallet_operations.cs")
var wallet_operations = wallet_operations_script.new()

signal balance_updated(balance)
signal ether_sent()
signal address_updated(address)

func _ready():
	add_child(wallet_operations)

func set_address(address):
	emit_signal("address_updated", address)
	
func set_balance(balance):
	emit_signal("balance_updated", balance)

func send_ether():
	emit_signal("ether_sent")
	
