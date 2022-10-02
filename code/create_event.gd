extends Control

@export var name_field : TextEdit
@export var event_name : TextEdit
@export var event_code : TextEdit
@export var wallet_dropdown : OptionButton
@export var join_button : Button
@export var cancel_button : Button

@export var create_screen : CenterContainer
@export var connecting_screen : CenterContainer

@export var connecting_label : Label

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
		PlayerManager.player.role = 'faculty'
		
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
			print(file)
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

func _on_join_button_pressed():
	
	# selected wallet
	var selected_wallet = wallet_dropdown.selected - 1
	# update the player
	PlayerManager.player.name = name_field.text
	
	# set the players eth address to the selected address
	PlayerManager.player.eth_address = accounts[selected_wallet].address
	WalletOperations.set_address(PlayerManager.player.eth_address)
	WalletOperations.wallet_operations.getBalance(PlayerManager.player.eth_address)
	
	# sign a message from our account (use the name)
	PlayerManager.player.signature = sign_message.signMessage(PlayerManager.player.name, accounts[selected_wallet].privateKey)
	
	if event_code.text != '':
		
		# attempt to log in to the server
		NetworkManager.connect_to_server(event_code.text)
		
		# create the event
		NetworkManager.create_event(event_code.text, event_name.text)
		
		# wait until we are connected
		create_screen.visible = false
		connecting_screen.visible = true
		var connecting_tween = create_tween().set_loops()
		connecting_tween.tween_property(connecting_label, "text", "CONNECTING", .1)
		connecting_tween.tween_property(connecting_label, "text", "CONNECTING.", .1)
		connecting_tween.tween_property(connecting_label, "text", "CONNECTING..", .1)
		connecting_tween.tween_property(connecting_label, "text", "CONNECTING...", .1)
		
func _on_network_connected():
	connected = true
	UIManager.change_scene(UIManager.faculty_app)
	
func _on_cancel_button_pressed():
	UIManager.change_scene(UIManager.home)
