extends VBoxContainer

@export var avatar_button : TextureButton
@export var name_label : Label
var participant

func _ready():
	avatar_button.connect('pressed', _on_avatar_button_pressed)
	
func _on_avatar_button_pressed():
	print('calling on ', participant.eth_address)
	queue_free()
