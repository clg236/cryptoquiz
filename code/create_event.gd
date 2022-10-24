extends Control

@export var name_field : LineEdit
@export var event_name : LineEdit
@export var event_code : LineEdit
@export var wallet_dropdown : OptionButton
@export var join_button : Button
@export var cancel_button : Button

@export var create_screen : CenterContainer
@export var connecting_screen : Control

var accounts = []
var connected : bool = false

# sign message script
var sign_message_script = load("res://code/ethereum/sign_message.cs")
var sign_message = sign_message_script.new()

var logo = preload("res://art/ui/logo_small.png")


func _ready():
	NetworkManager.connect("connected", _on_network_connected)
	cancel_button.connect('pressed', _on_cancel_button_pressed)
	join_button.connect('pressed', _on_join_button_pressed)
	connecting_screen.visible = false
	
	# does the client have a wallet present?
	var wallets = read_wallet_directory()
	if wallets.size() == 0:
		UIManager.change_scene(UIManager.registration)
		# PlayerManager.player.role = 'faculty'
		
	# populate the wallet dropdown
	accounts = wallets
	for wallet in wallets:
		var icon = Texture2D.new()
		icon = logo
		wallet_dropdown.add_icon_item(icon, wallet.address)
	add_child(sign_message)

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


func _on_join_button_pressed():
	
	PlayerManager.player.role = 'facilitator'
	
	# selected wallet
	var selected_wallet = wallet_dropdown.selected
	
	print('you selected ', selected_wallet)
	# update the player
	PlayerManager.player.name = name_field.text
	
	# set the players eth address to the selected address
	PlayerManager.player.eth_address = accounts[selected_wallet].address
	PlayerManager.private_key = accounts[selected_wallet].privateKey

	WalletOperations.set_address(PlayerManager.player.eth_address)
	WalletOperations.wallet_operations.getBalance(PlayerManager.player.eth_address)
	
	# sign a message from our account (use the name)
	PlayerManager.player.signature = sign_message.signMessage(PlayerManager.player.name, accounts[selected_wallet].privateKey)
	
	if event_code.text != '':
		
		NetworkManager.connect_to_server(event_code.text)

		# wait until we are connected
		create_screen.visible = false
		connecting_screen.visible = true

func _on_network_connected():
	# create the event
	PlayerManager.player.role = 'facilitator'
	NetworkManager.create_event(event_code.text, event_name.text)
	connected = true
	UIManager.change_scene(UIManager.faculty_app)
	PlayerManager.player.event_code = event_code.text
	
func _on_cancel_button_pressed():
	UIManager.change_scene(UIManager.home)
