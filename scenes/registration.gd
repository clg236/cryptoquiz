extends Control

@export var role_select_panel : Panel
@export var create_wallet_panel : Panel
@export var wallet_created_panel : Panel

# buttons
@export var participant_button : Button
@export var facilitator_button : Button
@export var create_wallet_button : Button

@export var wallet_password_field : LineEdit
@export var confirm_password_field : LineEdit
@export var wallet_address_field : Label
@export var word_list : RichTextLabel

# create wallet script
var create_wallet_script = load("res://code/ethereum/create_wallet.cs")
var create_wallet = create_wallet_script.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	role_select_panel.visible = true
	create_wallet_panel.visible = false
	wallet_created_panel.visible = false
	create_wallet_button.disabled = true
	participant_button.connect('pressed', _on_participant_button_pressed)
	facilitator_button.connect('pressed', _on_facilitator_button_pressed)
	create_wallet_button.connect('pressed', _create_wallet_button_pressed)
	confirm_password_field.connect('text_changed', _on_confirm_password_text_changed)

func _on_confirm_password_text_changed(text):
	if confirm_password_field.text == wallet_password_field.text and confirm_password_field.text != null:
		create_wallet_button.disabled = false
	else:
		create_wallet_button.disabled = true
		

func _on_participant_button_pressed():
	role_select_panel.visible = false
	create_wallet_panel.visible = true

func _on_facilitator_button_pressed():
	pass

func _create_wallet_button_pressed():
	# create a wallet
	var result = await(create_wallet.createWallet(wallet_password_field.text))
	# print(result)
	
	create_wallet_panel.visible = false
	wallet_created_panel.visible = true
	
	#print out the seed words
	word_list.text = create_wallet.seed_words
	wallet_address_field.text = result
	PlayerManager.player.eth_address = result
