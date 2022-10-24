extends Control


@export var wallet_list : ItemList
@export var balance : Label
@export var account : Label
@export var wallet_info : VBoxContainer

@export var to_address : LineEdit
@export var send_amount : LineEdit
@export var send_button : Button
var wallets
var selected_balance
var selected_index

# Called when the node enters the scene tree for the first time.
func _ready():
	WalletOperations.connect("balance_updated", _on_balance_updated)
	WalletOperations.connect("ether_sent", _on_ether_sent)
	#wallet_info.visible = false
	wallets = read_wallet_directory()
	for wallet in wallets:
		wallet_list.add_item(wallet.address)
	wallet_list.connect("item_selected",_on_wallet_selected)
	send_button.connect("pressed", _on_send_button_pressed)
	
func read_wallet_directory():
	var accounts = []
	var files = []
	var dir = DirAccess.open("res://Wallets/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			elif file_name.begins_with('Ethereum'):
				print("Found wallet file: " + file_name)
				var file = FileAccess.open('res://Wallets/' + file_name,FileAccess.READ)
				var text = file.get_as_text()
				var json = JSON.new()
				json.parse(text)
				var data = json.get_data()
				accounts.append(data)
				files.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
		return accounts
	else:
		print("An error occurred when trying to access the path.")

func _on_balance_updated(balance):
	selected_balance = balance
	_update_balance()
	
func _on_ether_sent():
	print('sent ether!')

func _update_balance():
	balance.text = selected_balance

func _on_wallet_selected(index):
	selected_index = index
	# show our wallet information screen
	balance.text = 'getting balance...'
	account.text = wallets[index].address
	wallet_info.visible = true
	WalletOperations.wallet_operations.getBalance(wallets[index].address)
	
func _on_send_button_pressed():
	WalletOperations.wallet_operations.sendEther(wallets[selected_index].privateKey, to_address.text)
