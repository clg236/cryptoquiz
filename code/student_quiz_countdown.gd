extends Control

@export var countdown_time_label : Label
@export var countdown_label : Label
@export var retry_button : Button
@export var cancel_button : Button

var countdown_timer
var countdown_time = 2

func _ready():
	print('countdown entered with quiz: ', QuizManager.current_quiz)
	DataParser.connect("start_quiz", _on_quiz_started)
	retry_button.visible = false
	cancel_button.visible = false
	retry_button.connect('pressed', _on_retry_button_pressed)
	cancel_button.connect('pressed', _on_cancel_button_pressed)
	# start the quiz countdown
	countdown_timer = Timer.new()
	add_child(countdown_timer)
	countdown_timer.start(countdown_time)
	countdown_timer.connect("timeout", _on_countdown_timer_timeout)

func _process(_delta):
	countdown_time_label.text = str(floor(countdown_timer.time_left))

func _on_countdown_timer_timeout():
	countdown_timer.stop()
	# check that we have a quiz, if so, go to the quiz scene
	if QuizManager.current_quiz == null:
		countdown_label.text = 'UNABLE TO FIND A QUIZ OH NO!'
		countdown_time_label.visible = false
		retry_button.visible = true
		return

	UIManager.change_scene(UIManager.student_quiz_mode)

func _on_retry_button_pressed():
	countdown_label.text = 'RETRYING...'
	retry_button.visible = false
	cancel_button.visible = true

func _on_cancel_button_pressed():
	UIManager.change_scene(UIManager.student_app)
	
func _on_quiz_started(quiz):
	QuizManager.current_quiz = quiz
