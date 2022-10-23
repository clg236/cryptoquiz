extends Control

var quiz = {
	'title' : 'test quiz'
}

@export var home : Control
@export var classes : Control
@export var wallet : Control

func _ready():
	
	# set our role
	PlayerManager.player.role = 'participant'
	
	# show the header
	Header.show_header(true)
	Header.create_menu()
	Header.connect('menu_changed', _on_menu_changed)
	StatusOverlay.show_status(true)
	
	# for testing purposes, pull the test quiz from the server
	DataParser.connect("start_quiz", _on_quiz_started)
	
	# when we recieve the ready_quiz broadcast, we'll switch to quiz mode
	DataParser.connect("ready_quiz", _on_ready_quiz_recieved)
	
	StateManager.connect("game_state_changed", _on_game_state_changed)
	StateManager.connect("network_state_changed", _on_network_state_changed)
	
	NetworkManager.participant_joined(PlayerManager.player)

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

func _on_network_state_changed(state):
	pass

func _on_ready_quiz_recieved(quiz_title): 
	QuizManager.quiz_title = quiz_title
	UIManager.change_scene(UIManager.student_quiz_mode)
	
func _on_start_quiz_button_pressed():
	NetworkManager.start_quiz('test quiz')
	print('current quiz: ', QuizManager.current_quiz)

func _on_get_quiz_button_pressed():
	NetworkManager.list_single_quiz(quiz)

func _on_quiz_started(quiz):
	QuizManager.current_quiz = quiz
	UIManager.change_scene(UIManager.student_quiz_countdown)
