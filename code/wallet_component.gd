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
	var dir = Directory.new()
	dir.open("res://Wallets/")
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == '':
			break
		elif not file.begins_with('.'):
			# read the file
			var account = File.new()
			#print(file)
			var error = account.open('res://Wallets/' + file,File.READ)
			if error != OK:
				printerr("Couldn't open file for read: %s, error code: %s." % [file, error])
				break
			var text = account.get_as_text()
			var json = JSON.new()
			json.parse(text)
			var data = json.get_data()
			accounts.append(data)
			account.close()
			files.append(file)
	dir.list_dir_end()
	return accounts

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
