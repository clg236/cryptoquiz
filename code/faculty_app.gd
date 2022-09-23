extends Control

@export var home : Control
@export var classes : Control
@export var quizzes : Control
@export var participants : Control
@export var financials : Control

func _ready():
	Header.connect('menu_changed', _on_menu_changed)
	UIManager.current_scene = get_tree().get_current_scene()

	# show the header
	Header.show_header(true)
	Header.create_menu()
	
	# hide all of the screens
	home.visible = true
	classes.visible = false
	quizzes.visible = false
	participants.visible = false
	financials.visible = false

func _on_menu_changed(item):
	match item:
		'HOME':
			home.visible = true
			classes.visible = false
			quizzes.visible = false
			participants.visible = false
			financials.visible = false
		'CLASSES':
			home.visible = false
			classes.visible = true
			quizzes.visible = false
			participants.visible = false
			financials.visible = false
		'QUIZZES':
			home.visible = false
			classes.visible = false
			quizzes.visible = true
			participants.visible = false
			financials.visible = false
		'PARTICIPANTS':
			home.visible = false
			classes.visible = false
			quizzes.visible = false
			participants.visible = true
			financials.visible = false
		'FINANCIALS':
			home.visible = false
			classes.visible = false
			quizzes.visible = false
			participants.visible = false
			financials.visible = true

