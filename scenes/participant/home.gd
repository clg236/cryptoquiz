extends Control

@export var hand_button : TextureButton
@export var send_comment_button : TextureButton
@export var comment_text : TextEdit
@export var treasure_amount : Label
var hand_raised : bool = false

func _ready():
	WalletOperations.wallet_operations.getBalance(PlayerManager.player.eth_address)
	WalletOperations.connect("balance_updated", _on_balance_updated)
	hand_button.connect('pressed', _on_hand_button_pressed)
	send_comment_button.connect('pressed', _on_send_comment_button_pressed)
	hand_button.toggle_mode = true

func _on_hand_button_pressed():
	hand_raised = !hand_raised
	var facilitator
	for participant in ParticipantManager.participants.participants:
		if ParticipantManager.participants.participants[participant]['role'] == 'facilitator':
			facilitator = ParticipantManager.participants.participants[participant]['eth_address']
			NetworkManager.raise_hand(hand_raised, facilitator )

func _on_send_comment_button_pressed():
	var facilitator
	for participant in ParticipantManager.participants.participants:
		if ParticipantManager.participants.participants[participant]['role'] == 'facilitator':
			facilitator = ParticipantManager.participants.participants[participant]['eth_address']
			NetworkManager.send_comment(comment_text.text, facilitator)
			comment_text.text = ''

func _on_balance_updated(balance):
	treasure_amount.text = 'TREASURE: ' + str(balance) + ' ETH'
