extends Control

### STUDENT HOME PAGE 
# This scene is responsible for managing the student live class experience

var quiz = {
	'title' : 'test quiz'
}

@export var start_button : Button
@export var home : Control
@export var classes : Control
@export var wallet : Control
@export var get_quiz_button : Button
@export var start_quiz_button : Button

func _ready():
	
	# show the header
	Header.show_header(true)
	Header.create_menu()
	Header.connect('menu_changed', _on_menu_changed)
	
	# for testing purposes, pull the test quiz from the server
	DataParser.connect("start_quiz", _on_quiz_started)
	get_quiz_button.connect('pressed', _on_get_quiz_button_pressed)
	start_quiz_button.connect('pressed', _on_start_quiz_button_pressed)
	
	# if this is the first time we are here, register ourselves with the server and other clients
	# NetworkManager.participant_joined(PlayerManager.player)
	# NetworkManager.broadcast_to_individual('0x7e37Ddc63dF45172F22DFB9C08f0C41912F74d96', 'hello!')
	StateManager.connect("game_state_changed", _on_game_state_changed)
	StateManager.connect("network_state_changed", _on_network_state_changed)

func _on_menu_changed(item):
	match item:
		'HOME':
			home.visible = true
			classes.visible = false
			wallet.visible = false
		'CLASSES':
			home.visible = false
			classes.visible = true
			wallet.visible = false
		'WALLET':
			home.visible = false
			classes.visible = false
			wallet.visible = true
	
func _on_game_state_changed(state):
	pass
	#if state == StateManager.GAME_STATE.QUIZ:
		#UIManager.change_scene(UIManager.student_quiz_countdown)

func _on_network_state_changed(state):
	pass

func _on_start_quiz_button_pressed():
	NetworkManager.start_quiz('test quiz')
	print('current quiz: ', QuizManager.current_quiz)

func _on_get_quiz_button_pressed():
	NetworkManager.list_single_quiz(quiz)

func _on_quiz_started(quiz):
	QuizManager.current_quiz = quiz
	UIManager.change_scene(UIManager.student_quiz_countdown)
