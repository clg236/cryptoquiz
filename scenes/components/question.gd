extends Control

@export var question_number : Label
@export var question_title : LineEdit
@export var question_reward : LineEdit
@export var question_time : LineEdit

@export var choice_1 : LineEdit
@export var choice_2 : LineEdit
@export var choice_3 : LineEdit
@export var choice_4 : LineEdit

@export var correct_1 : CheckBox
@export var correct_2 : CheckBox
@export var correct_3 : CheckBox
@export var correct_4 : CheckBox

var open_trash_icon = preload("res://art/ui/open_trash.png")
var closed_trash_icon = preload("res://art/ui/closed_trash.png")

@export var delete_button : Button

# Called when the node enters the scene tree for the first time.
func _ready():
	delete_button.connect('pressed', _on_delete_button_pressed)
	delete_button.connect('button_down', _on_delete_button_down)

func _on_delete_button_pressed():
	queue_free()

func _on_delete_button_down():
	delete_button.icon = open_trash_icon
