extends Control

# UI Manager
# This script is responsible for maintaining the UI state for the player (loading scenes mainly)

### SCENES ###
@export var start_page: String = "res://scenes/start_screen.tscn"
@export var faculty_app: String = "res://scenes/facilitator/faculty_app.tscn"
@export var student_app: String = "res://scenes/participant/student_app.tscn"
@export var faculty_quiz_mode : String = "res://scenes/facilitator/quiz/faculty_quiz_mode.tscn"
@export var student_quiz_countdown : String = "res://scenes/participant/quiz/student_quiz_countdown.tscn"
@export var student_quiz_mode : String = "res://scenes/participant/quiz/student_quiz_mode.tscn"
@export var student_quiz_complete : String = "res://scenes/participant/quiz/student_quiz_complete.tscn"
@export var registration : String = "res://scenes/registration.tscn"
@export var home : String = "res://scenes/start_screen.tscn"
@export var create_event : String = "res://scenes/create_event.tscn"
@export var join_event : String = "res://scenes/join_event.tscn"
@export var edit_quiz : String = "res://scenes/facilitator/quiz/edit_quiz.tscn"
@export var payout_scene : String = "res://scenes/facilitator/payout.tscn"

var logged_in : bool = false
var current_scene

func _ready():
	# are we logged in?
	if !logged_in:
		return
	else:
		if PlayerManager.player.role == 'faculty':
			get_tree().change_scene(faculty_app)
		else:
			get_tree().change_scene(student_app)

func change_scene(scene):
	get_tree().change_scene_to_file(scene)


	
