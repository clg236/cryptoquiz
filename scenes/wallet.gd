extends Control

@export var create_wallet_button : Button
@export var create_wallet_dialogue : Panel

var create_wallet_script = load("res://code/ethereum/create_wallet.cs")
var create_wallet = create_wallet_script.new()

func _ready():
	create_wallet_dialogue.visible = false
	create_wallet_button.connect('pressed', _create_wallet)

func _create_wallet():
	
	# show our create wallet dialogue
	create_wallet_dialogue.visible = true
	var result = create_wallet.createWallet('password')
	# print(result)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
