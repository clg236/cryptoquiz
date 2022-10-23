extends Control

var participant_row = preload("res://scenes/components/participant_row.tscn")
@export var participant_container : VBoxContainer
@export var payout_all_button : Button
@export var confirm_pay_button : Button
@export var confirmation_panel : Panel
@export var wallet_listing : OptionButton

@export var confirmed_amount : Label
@export var wallet_balance : Label

var wallets
var selected_index

var payment_list : Array

func _ready():
	# ask for a class list
	NetworkManager.get_event(PlayerManager.player.event_code)
	# connect to our data parser to get participant lists
	DataParser.connect("class_recieved", _on_class_list_recieved)
	DataParser.connect("participant_joined", _on_participant_joined)
	WalletOperations.connect("ether_sent", _on_ether_sent)
	WalletOperations.connect("balance_updated", _on_balance_updated)
	
	payout_all_button.connect('pressed', _on_payout_all_button_pressed)
	confirm_pay_button.connect('pressed', _on_confirm_pay_button_pressed)
	wallet_listing.connect("item_selected",_on_wallet_selected)
	
	confirmation_panel.visible = false
	
	wallets = read_wallet_directory()
	for wallet in wallets:
		wallet_listing.add_item(wallet.address)
	
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
	
func _on_class_list_recieved(data):
	
	# clear our current list
	for child in participant_container.get_children():
		child.queue_free()

	for participant in data.participants:
		var p = participant_row.instantiate()
		participant_container.add_child(p)
		p.participant_name.text = data.participants[participant]["name"]
		p.participant_address.text = data.participants[participant]["eth_address"]
		p.treasure_label.text = str(data.participants[participant]["treasure"])

func _on_participant_joined():
	#print('new participant!')
	NetworkManager.get_event(PlayerManager.player.event_code)

func _on_payout_all_button_pressed():
	confirmation_panel.visible = true
	for participant in ParticipantManager.participants.participants:
		if ParticipantManager.participants.participants[participant]['role'] != 'facilitator':
			var address = ParticipantManager.participants.participants[participant]['eth_address']
			var amount = ParticipantManager.participants.participants[participant]['treasure']
			var payment = { 
				'address' : address,
				'amount' : amount
			}
		
			payment_list.append(payment)
			#print('payment list: ', payment_list)
			var total_payment = 0
			for index in payment_list.size():
				total_payment += payment_list[index]["amount"]
			confirmed_amount.text = 'TOTAL PAYMENT: ' + str(total_payment)
		
func _on_confirm_pay_button_pressed():
	for payee in payment_list:
		WalletOperations.wallet_operations.sendEther(wallets[selected_index].privateKey, payee.address, payee.amount)

func _on_wallet_selected(index):
	selected_index = index
	WalletOperations.wallet_operations.getBalance(wallets[selected_index].address)
	
func _on_balance_updated(balance):
	update_balance(balance)
	
func update_balance(balance):
	wallet_balance.text = 'BALANCE: ' + str(balance)

func _on_ether_sent():
	print('amount sent')
