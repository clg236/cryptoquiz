extends Control

@export var title_text : Label
@export var home_screen : Control
@export var transition : ColorRect

# BUTTONS
@export var join_event_button : Button
@export var create_event_button : Button

func _ready():
	
	home_screen.visible = true
	join_event_button.connect('pressed', _on_join_event_button_pressed)
	create_event_button.connect('pressed', _on_create_event_button_pressed)
	
	UIManager.current_scene = get_tree().get_current_scene()
	
	# hide the status overlap
	StatusOverlay.show_status(false)
	
	# hide the header
	Header.show_header(false)
	
	# clear the header too
	Header.remove_items()
	
func _on_join_event_button_pressed():
	# show our transition
	var transition_tween = create_tween()
	transition_tween.tween_property(transition, "material:shader_parameter/position", -1.5, 1)
	transition_tween.connect("finished", _on_join_transition_finished)

func _on_create_event_button_pressed():
	var transition_tween = create_tween()
	transition_tween.tween_property(transition, "material:shader_parameter/position", -1.5, 1)
	transition_tween.connect("finished", _on_create_transition_finished)
	
func _on_join_transition_finished():
	UIManager.change_scene(UIManager.join_event)

func _on_create_transition_finished():
	UIManager.change_scene(UIManager.create_event)

func  _on_cancel_button_pressed():
	UIManager.change_scene(UIManager.home)

