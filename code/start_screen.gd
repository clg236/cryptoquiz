extends Control

@export var title_text : Label
@export var body_text : Label
@export var name_field : TextEdit
@export var faculty_checkbox : CheckBox
@export var enter_button : Button
@export var sign_up_button : Button
@export var accounts_list : ItemList

var logo = preload("res://art/ui/logo_small.png")

# sign message script
var sign_message_script = load("res://code/ethereum/sign_message.cs")
var sign_message = sign_message_script.new()

func _ready():
	add_child(sign_message)
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
	for wallet in wallets:
		var icon = Texture2D.new()
		icon = logo
		accounts_list.add_item(wallet, icon )
	
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
			accounts.append(data.address)
			account.close()
			files.append(file)
	dir.list_dir_end()
	
	return accounts

func _on_name_text_changed():
	body_text.text = 'welcome ' + name_field.text

func _on_enter_button_pressed():
	# update the player
	PlayerManager.player.name = name_field.text
	
	# sign a message from our account (use the name)
	PlayerManager.player.signature = sign_message.signMessage(PlayerManager.player.name)
	print(PlayerManager.player.signature)
	print(NetworkManager.websocket_test_url)
	# attempt to log in to the server
	NetworkManager.connect_to_server()
	
	if faculty_checkbox.button_pressed:
		UIManager.change_scene(UIManager.faculty_app)
	else:
		UIManager.change_scene(UIManager.student_app)
		PlayerManager.player.role = 'student'

func _on_sign_up_button_pressed():
	UIManager.change_scene(UIManager.registration)
