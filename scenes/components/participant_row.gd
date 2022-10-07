extends HBoxContainer

@export var participant_name : Label
@export var participant_address : Label
@export var treasure_label : Label
@export var details_button : Button
@export var reward_button : Button

var reward_address

# Called when the node enters the scene tree for the first time.
func _ready():
	reward_button.connect('pressed', _on_reward_button_pressed)

func _on_reward_button_pressed():
	print(PlayerManager.private_key)
	WalletOperations.wallet_operations.sendEther(PlayerManager.private_key, participant_address.text)
