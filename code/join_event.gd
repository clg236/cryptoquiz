extends Control

@export var name_field : LineEdit
@export var event_code : LineEdit
@export var wallet_dropdown : OptionButton
@export var join_button : Button
@export var cancel_button : Button

@export var join_screen : CenterContainer
@export var connecting_screen : Control
@export var error_screen : Control
@export var connecting_label : Label
@export var bark_label : Label
@export var retry_button : Button

# sign message script
var sign_message_script = load("res://code/ethereum/sign_message.cs")
var sign_message = sign_message_script.new()

var logo = preload("res://art/ui/logo_small.png")

var accounts = []
var connected : bool = false

var barks = ['you can do this!', 'Opportunities don\'t happen, you create them.','Love your family, work super hard, live your passion.'  ]

func _ready():
	NetworkManager.connect("valid_class", _on_valid_class)
	DataParser.connect("joined_class", _on_class_joined)
	cancel_button.connect('pressed', _on_cancel_button_pressed)
	join_button.connect('pressed', _on_join_button_pressed)
	retry_button.connect('pressed', _on_retry_button_pressed)
	
	connecting_screen.visible = false
	join_screen.visible = true
	error_screen.visible = false
	
	# does the client have a wallet present?
	var wallets = read_wallet_directory()
	if wallets.size() == 0:
		UIManager.change_scene(UIManager.registration)
		PlayerManager.player.role = 'student'
		
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
	
	# selected wallet
	var selected_wallet = wallet_dropdown.selected
	# update the player
	PlayerManager.player.name = name_field.text
	
	PlayerManager.player.role = 'participant'
	
	# set the players eth address to the selected address
	PlayerManager.player.eth_address = accounts[selected_wallet].address
	PlayerManager.private_key = accounts[selected_wallet].privateKey
	WalletOperations.set_address(PlayerManager.player.eth_address)
	WalletOperations.wallet_operations.getBalance(PlayerManager.player.eth_address)
	
	# sign a message from our account (use the name)
	PlayerManager.player.signature = sign_message.signMessage(PlayerManager.player.name, accounts[selected_wallet].privateKey)
	
	if event_code.text != '':
		# attempt to log in to the server
		NetworkManager.connect_to_server(event_code.text)
		
		# wait until we are connected
		join_screen.visible = false
		connecting_screen.visible = true
		
		# show some motivational barks
		var bark_timer = Timer.new()
		add_child(bark_timer)
		bark_timer.connect('timeout', _on_bark_timer_timeout)
		bark_timer.start(2)

func _on_retry_button_pressed():
	error_screen.visible = false
	join_screen.visible = true

func _on_bark_timer_timeout():
	randomize()
	var random_bark = randi() % barks.size()
	bark_label.visible = true
	bark_label.text = barks[random_bark]
	
func _on_valid_class(result):
	if !result:
		error_screen.visible = true
		join_screen.visible = false
		connecting_screen.visible = false
		NetworkManager.disconnect_from_server()
	
func _on_class_joined():
	connected = true
	PlayerManager.in_event = true
	PlayerManager.player.role = 'participant'
	print('setting participant')
	NetworkManager.update_participant(event_code.text)
	UIManager.change_scene(UIManager.student_app)
	
func _on_cancel_button_pressed():
	UIManager.change_scene(UIManager.home)
