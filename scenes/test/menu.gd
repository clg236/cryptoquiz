extends Control

@export var menu_button : TextureButton
@export var close_button : Button
@export var menu_container : MarginContainer


func _ready():
	menu_container.visible = false
	menu_button.connect('pressed',_on_menu_button_pressed)
	close_button.connect('pressed', _on_close_button_pressed)
	# hide the status overlap
	StatusOverlay.show_status(false)
	
	# hide the header
	Header.show_header(false)
	
	# clear the header too
	Header.remove_items()
	
func _on_menu_button_pressed():
	menu_container.visible = true
	var menu_tween = create_tween().set_trans(Tween.TRANS_BACK).set_parallel()
	menu_tween.tween_property(menu_button, "position:x", -200, .5).as_relative()
	menu_tween.tween_property(menu_container, "position:x", 500, .7).as_relative()

func _on_close_button_pressed():
	var menu_tween = create_tween().set_trans(Tween.TRANS_BACK).set_parallel()
	menu_tween.tween_property(menu_button, "position:x", 200, .5).as_relative()
	menu_tween.tween_property(menu_container, "position:x", -500, .7).as_relative()

