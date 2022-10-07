extends Control

@export var home_screen : Control
@export var create_wallet_screen : Control
@export var wallet_created_screen : Control

# buttons
@export var participant_button : Button
@export var new_wallet_button : Button
@export var create_wallet_button : Button
@export var import_wallet_button : Button
@export var home_button : Button

@export var wallet_password_field : LineEdit
@export var confirm_password_field : LineEdit
@export var wallet_address_field : Label
@export var word_list : RichTextLabel
@export var reminder : Label

# create wallet script
var create_wallet_script = load("res://code/ethereum/create_wallet.cs")
var create_wallet = create_wallet_script.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	home_screen.visible = true
	
	create_wallet_screen.visible = false
	wallet_created_screen.visible = false
	create_wallet_button.disabled = true
	new_wallet_button.connect('pressed', _new_wallet_button_pressed)
	create_wallet_button.connect('pressed', _create_wallet_button_pressed)
	home_button.connect("pressed", _on_home_button_pressed)
	confirm_password_field.connect('text_changed', _on_confirm_password_text_changed)

func _on_confirm_password_text_changed(text):
	if confirm_password_field.text == wallet_password_field.text and confirm_password_field.text != null:
		create_wallet_button.disabled = false
	else:
		create_wallet_button.disabled = true

func _on_home_button_pressed():
	if PlayerManager.player.role == 'student':
		UIManager.change_scene(UIManager.join_event)
	else: 
		UIManager.change_scene(UIManager.create_event)

func _on_participant_button_pressed():
	create_wallet_screen.visible = true

func _on_facilitator_button_pressed():
	pass

func _new_wallet_button_pressed():
	home_screen.visible = false
	create_wallet_screen.visible = true

func _create_wallet_button_pressed():
	# create a wallet
	var result = await(create_wallet.createWallet(wallet_password_field.text))
	# print(result)
	
	create_wallet_screen.visible = false
	wallet_created_screen.visible = true
	
	#flash our reminder
	var reminder_tween = create_tween().set_loops()
	reminder_tween.tween_property(reminder, "theme_override_colors/font_color", Color("#8dffd0"), .1)
	reminder_tween.tween_property(reminder, "theme_override_colors/font_color", Color("#7361ff"), .1)
	
	#print out the seed words
	word_list.text = create_wallet.seed_words
	wallet_address_field.text = result
	PlayerManager.player.eth_address = result
