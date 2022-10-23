extends Control

@export var home : Control
@export var classes : Control
@export var quizzes : Control
@export var participants : Control
@export var financials : Control

@export var get_participants_button : Button

func _ready():
	
	# we are faculty, so set it
	PlayerManager.player.role = 'facilitator'
	Header.connect('menu_changed', _on_menu_changed)
	Header.connect('end_class', _on_class_ended)

	# join our event one time and tell everyone we did. hax
	if !PlayerManager.in_event:
		print('joining event')
		NetworkManager.join_event(PlayerManager.player.event_code)
		NetworkManager.participant_joined(PlayerManager.player)
		
	# show the header
	Header.show_header(true)
	Header.create_menu()
	StatusOverlay.show_status(true)
	
	# hide all of the screens
	home.visible = true
	classes.visible = false
	quizzes.visible = false
	participants.visible = false
	financials.visible = false

func _get_participants():
	# this is a test function to see if we can grab participants
	NetworkManager.get_event(PlayerManager.player.event_code)

func _on_menu_changed(item):
	match item:
		'HOME':
			home.visible = true
			classes.visible = false
			quizzes.visible = false
			participants.visible = false

		'CLASSES':
			home.visible = false
			classes.visible = true
			quizzes.visible = false
			participants.visible = false

		'QUIZZES':
			home.visible = false
			classes.visible = false
			quizzes.visible = true
			participants.visible = false

		'PARTICIPANTS':
			home.visible = false
			classes.visible = false
			quizzes.visible = false
			participants.visible = true

func _on_class_ended():
	home.visible = false
	classes.visible = false
	quizzes.visible = false
	participants.visible = true
