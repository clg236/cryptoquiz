extends Control

@export var countdown_screen : Control
@export var quiz_screen : Control
@export var score_screen : Control
@export var countdown_time_label : Label

@export var quiz_title : Label
@export var num_questions : Label

@export var question_title : RichTextLabel
@export var question_time : ProgressBar
@export var question_reward : RichTextLabel
@export var choice_container : GridContainer
@export var answer_screen : Control

var countdown_timer
var countdown_time = 2
var quiz
var current_question_num = 1
var current_question
var answer_scene = preload("res://scenes/student/quiz/answer.tscn")
var question_timer
var chosen_answer_index
var in_quiz : bool = false

@export var question_pause_time : int = 1

func _ready():
	DataParser.connect("start_quiz", _on_quiz_started)
	Header.show_header(false)
	countdown_screen.visible = true
	quiz_screen.visible = false
	
	# set up our counter
	countdown_timer = Timer.new()
	add_child(countdown_timer)
	countdown_timer.start(countdown_time)
	countdown_timer.connect("timeout", _on_countdown_timer_timeout)
	
	quiz = QuizManager.current_quiz
	
	# set the quiz title
	quiz_title.text = quiz.quizTitle
	
	# number of questions
	num_questions.text = str(current_question_num) + ' OF ' + str(quiz.questions.size())

func _process(_delta):
	if !in_quiz:
		# TO DO: state machine so we don't do this all the time...
		countdown_time_label.text = str(floor(countdown_timer.time_left))
	else:
		question_time.value = question_timer.time_left
	
func _on_quiz_started(quiz):
	# star the countdown
	print('quiz has begun')

func _on_countdown_timer_timeout():
	countdown_timer.stop()
	countdown_screen.visible = false
	quiz_screen.visible = true
	
	# start the quiz...
	in_quiz = true
	populate_question()

func populate_question():

	# if we have answers, kill them off
	for answer in choice_container.get_children():
		answer.queue_free()
	current_question = quiz.questions[current_question_num - 1]
	question_title.text = current_question.title
	question_reward.text = 'REWARD: ' + str(current_question.reward)
	for answer in current_question.answers:
		var a = answer_scene.instantiate()
		choice_container.add_child(a)
		a.text = '[center]' + answer.title + '[/center]'
	# start the timer
	question_timer = Timer.new()
	add_child(question_timer)
	question_timer.wait_time = current_question.time
	question_time.max_value = current_question.time
	question_timer.start()
	question_timer.connect('timeout', _on_question_timer_timeout)
			
func _on_question_timer_timeout():
	# hightlight the correct answer for a bit
	
	for answer in current_question.answers.size():
		if !current_question.answers[answer].correct:
			choice_container.get_child(answer).get_child(0).disabled = true
		else:
			pass # highlight the correct answer
		
	#quiz_screen.visible = false
	await get_tree().create_timer(question_pause_time).timeout
	#score_screen.visible = true
