extends Control

@export var quiz_list : ItemList
@export var error_label : Label
@export var create_quiz_button : Button
@export var edit_button : Button
@export var delete_button : Button
@export var start_button : Button

var quiz_icon = preload("res://art/ui/quiz_icon.png")

var local_quizzes = []
var selected_quiz = ''
var label_tween

func _ready():
	StateManager.connect("network_state_changed", _on_network_state_changed)
	DataParser.connect("quiz_recieved", _on_quiz_recieved)
	start_button.connect("pressed", _on_start_button_pressed)
	create_quiz_button.connect("pressed", _on_create_quiz_button_pressed)
	delete_button.connect("pressed", _on_delete_button_pressed)
	quiz_list.connect("item_selected", _on_quiz_item_selected)
	
	edit_button.visible = false
	delete_button.visible = false
	start_button.visible = false
	
	if !StateManager.network_state == StateManager.NETWORK_STATE.DISCONNECTED:
		# ask for a list of participants from the server
		NetworkManager.get_participants()
		
		# get a list of quizzes
		NetworkManager.list_all_quizzes()
	else:
		error_label.text = 'loading quiz list...'
		quiz_list.visible = false

func _on_network_state_changed(state):
	if StateManager.NETWORK_STATE.CONNECTED:
		# ask for a list of participants from the server
		NetworkManager.list_all_quizzes()
		error_label.visible = false
	else:
		error_label.visible = true
		quiz_list.visible = false

func _on_quiz_recieved(quizzes):
	if quizzes.size() == 0:
		quiz_list.visible = false
		error_label.visible = true
		error_label.text = 'no quizzes created, create one!'
		start_button.visible = false
	else:
		quiz_list.visible = true

	for quiz in quizzes:
		local_quizzes.append(quiz)
		var icon = Texture2D.new()
		icon = quiz_icon
		quiz_list.add_item(quiz.quizTitle, icon)
	

func _on_quiz_item_selected(index):
	# show our edit / delete buttons
	edit_button.visible = true
	delete_button.visible = true
	start_button.visible = true
	
	selected_quiz = local_quizzes[index]
	edit_button.text = 'EDIT ' + selected_quiz.quizTitle.to_upper()
	delete_button.text = 'DELETE ' + selected_quiz.quizTitle.to_upper()

func _on_start_button_pressed():
	NetworkManager.start_quiz(selected_quiz)
	
	# change to quiz mode
	UIManager.change_scene(UIManager.faculty_quiz_mode)

func _on_create_quiz_button_pressed():
	UIManager.change_scene("res://scenes/faculty/quiz/create_quiz.tscn")

func _on_delete_button_pressed():
	if selected_quiz.quizTitle != '':
		NetworkManager.delete_quiz(selected_quiz)
		# clear all the items
		quiz_list.clear()
		# refresh the quiz list in 2 secs
		await get_tree().create_timer(2000).timeout
		NetworkManager.list_all_quizzes()
	else:
		error_label.text = 'please select a quiz to delete!'
		label_tween = create_tween()
		label_tween.tween_property(error_label, "visible", true, .1)
		label_tween.tween_property(error_label, "visible", false, 2)
		
	
