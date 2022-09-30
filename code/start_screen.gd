extends Control

@export var title_text : Label
@export var body_text : Label
@export var name_field : TextEdit
@export var faculty_checkbox : CheckBox
@export var enter_button : Button
@export var sign_up_button : Button
@export var accounts_list : ItemList
@export var account_container : VBoxContainer

var logo = preload("res://art/ui/logo_small.png")

# sign message script
var sign_message_script = load("res://code/ethereum/sign_message.cs")
var sign_message = sign_message_script.new()

var accounts = []
var selected_account

func _ready():
	account_container.visible = false
	enter_button.connect("pressed", _on_enter_button_pressed)
	sign_up_button.connect("pressed", _on_sign_up_button_pressed)
	name_field.connect("text_changed", _on_name_text_changed)
	
	UIManager.current_scene = get_tree().get_current_scene()
	
	# hide the status overlap
	StatusOverlay.show_status(true)
	
	# hide the header
	Header.show_header(false)
	
	# clear the header too
	Header.remove_items()
	
	# read the wallet directory if it exists
	var wallets = read_wallet_directory()
	accounts = wallets
	for wallet in wallets:
		var icon = Texture2D.new()
		icon = logo
		accounts_list.add_item(wallet.address, icon )
	if wallets:
		account_container.visible = true
		# what account do we have selected?
		accounts_list.connect("item_selected", _on_account_selected)
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

func _on_account_selected(index):
	selected_account = index
	
	# set the players eth address to the selected address
	PlayerManager.player.eth_address = accounts[selected_account].address
	WalletOperations.set_address(PlayerManager.player.eth_address)
	WalletOperations.wallet_operations.getBalance(PlayerManager.player.eth_address)

func _on_name_text_changed():
	body_text.text = 'welcome ' + name_field.text

func _on_enter_button_pressed():

	# update the player
	PlayerManager.player.name = name_field.text
	
	# sign a message from our account (use the name)
	PlayerManager.player.signature = sign_message.signMessage(PlayerManager.player.name, accounts[selected_account].privateKey)

	# attempt to log in to the server
	NetworkManager.connect_to_server()
	
	if faculty_checkbox.button_pressed:
		UIManager.change_scene(UIManager.faculty_app)
	else:
		UIManager.change_scene(UIManager.student_app)
		PlayerManager.player.role = 'student'

func _on_sign_up_button_pressed():
	UIManager.change_scene(UIManager.registration)
