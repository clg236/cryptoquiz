extends CanvasLayer

### LABELS ###
@export var status_label : Control
@export var balance_label : Label
@export var account_label : Label

var participant_count = 0

var dot_tween
var selected_balance

func _ready():
	# signal connectsion
	StateManager.connect("network_state_changed", _on_network_state_changed)
	WalletOperations.connect("address_updated", _on_address_updated)
	WalletOperations.connect("balance_updated", _on_balance_updated)

	# dot tween
	dot_tween = create_tween().set_loops()
	dot_tween.tween_property(status_label, "text", "CONNECTING ", .1)
	dot_tween.tween_property(status_label, "text", "CONNECTING .", .1)
	dot_tween.tween_property(status_label, "text", "CONNECTING ..", .1)
	dot_tween.tween_property(status_label, "text", "CONNECTING ...", .1)

func _on_address_updated(address):
	account_label.text = address

func _on_balance_updated(balance):
	selected_balance = balance
	_update_balance()

#why do I have to do this, ugh...
func _update_balance():
	balance_label.text = "MY BALANCE: " + str(selected_balance) + " ETH"
	
# state handlers
func _on_network_state_changed(new_state):
	# stop the dot tween if we are not connecting
	if new_state != StateManager.NETWORK_STATE.CONNECTING:
		dot_tween.stop()
	status_label.text = 'CONNECTION STATUS: ' + StateManager.NETWORK_STATE.keys()[new_state]

func show_status(status):
	if status:
		visible = true
	else:
		visible = false
	
