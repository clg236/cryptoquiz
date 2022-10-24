extends CanvasLayer

### LABELS ###
@export var status_label : Control
@export var balance_label : Label
@export var account_label : Label
@export var balance_change_label : Label
@export var wallet_popup : Control
@export var balance_updated_screen : Control

@export var treasure_button : TextureButton
@export var chest : AnimatedSprite2D

var participant_count = 0

var dot_tween
var selected_balance

var emtpy_treasure = preload("res://art/ui/chest_open_empty.png")
var full_treasure = preload("res://art/ui/chest_open_full.png")

var wallet_timer

var last_balance

func _ready():
	# signal connectsion
	NetworkManager.connect('connected', _on_connected)
	WalletOperations.connect("address_updated", _on_address_updated)
	WalletOperations.connect("balance_updated", _on_balance_updated)
	
	treasure_button.connect('pressed', _on_treasure_button_pressed)
	chest.connect("animation_finished", _on_animation_finished)

	# dot tween
	dot_tween = create_tween().set_loops()
	dot_tween.tween_property(status_label, "text", "CONNECTING ", .1)
	dot_tween.tween_property(status_label, "text", "CONNECTING .", .1)
	dot_tween.tween_property(status_label, "text", "CONNECTING ..", .1)
	dot_tween.tween_property(status_label, "text", "CONNECTING ...", .1)
	
	balance_updated_screen.visible = false
	last_balance = PlayerManager.player.total_eth

func _on_treasure_button_pressed():
	if PlayerManager.player.total_eth < 0:
		treasure_button.texture_pressed = emtpy_treasure
	else:
		treasure_button.texture_pressed = full_treasure
	var popup_tween = create_tween()
	wallet_popup.visible = !wallet_popup.visible
	popup_tween.tween_property(wallet_popup, "position:y", -25, .1).as_relative()
	popup_tween.tween_property(wallet_popup, "position:y", 25, .1).as_relative()
	

func _on_address_updated(address):
	account_label.text = address

func _on_balance_updated(balance):
	selected_balance = balance
	_update_balance()

#why do I have to do this, ugh...
func _update_balance():
	if last_balance != PlayerManager.player.total_eth:
		last_balance = PlayerManager.player.total_eth
		balance_updated_screen.visible = true
		chest.play('open')
		var balance_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		balance_tween.tween_property(balance_updated_screen, "modulate:a", 1, .75)
		balance_tween.tween_property(balance_updated_screen, "position:y", -25, .75).as_relative()
		balance_tween.tween_property(balance_updated_screen, "position:y", 25, .75).as_relative()
		balance_tween.tween_property(balance_updated_screen, "modulate:a", 0, .75).set_delay(3)
		balance_label.text = str(selected_balance) + " ETH"
		
		balance_change_label.text = "+ " + str(selected_balance) + " ETH"
		var balance_timer = Timer.new()
		add_child(balance_timer)
		balance_timer.connect('timeout', _on_balance_timer_timeout)
		balance_timer.start(3)
	else:
		return

func _on_balance_timer_timeout():
	balance_updated_screen.visible = false
	
func _on_animation_finished():
	chest.stop()
	
# when we are connected
func _on_connected():
	# stop the dot tween if we are not connecting
	dot_tween.stop()
	status_label.text = 'CONNECTION STATUS: CONNECTED'


func show_status(status):
	if status:
		visible = true
	else:
		visible = false
	
