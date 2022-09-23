extends Control

@export var quiz_title : Label
@export var num_questions : Label
@export var score : Label
@export var question_title : RichTextLabel
@export var question_time : ProgressBar
@export var question_reward : RichTextLabel
@export var choice_container : GridContainer
@export var submit_button : Button

@export var question_screen : Control
@export var answer_screen : Control
@export var answer_screen_text : Label

@export var quiz_timeout : int

var answer_scene = preload("res://scenes/student/quiz/answer.tscn")
var current_question 
var current_question_num = 1
var chosen_answer_index
var current_score = 0
var quiz

var question_timer

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# tell everyone that we are playing the quiz!
	NetworkManager.send_quiz_participant()
	
	submit_button.connect('pressed', _on_submit_button_pressed)
	quiz = QuizManager.current_quiz
	
	# set the quiz title (fix this!)
	quiz_title.text = quiz.quizTitle
	
	# number of questions
	num_questions.text = str(current_question_num) + ' OF ' + str(quiz.questions.size())
	
	
	submit_button.disabled = true
	# populate our question
	populate_question()
	
func populate_question():
	question_screen.visible = true
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
		a.connect("answer_chosen", _on_answer_chosen)
	# start the timer
	question_timer = Timer.new()
	add_child(question_timer)
	question_timer.wait_time = current_question.time
	question_time.max_value = current_question.time
	question_timer.start()
	question_timer.connect('timeout', _on_question_timer_timeout)

func _on_answer_chosen(index):
	chosen_answer_index = index
	submit_button.disabled = false
	for answer in choice_container.get_child_count():
		if choice_container.get_child(answer).get_index() != index:
			choice_container.get_child(answer).button.button_pressed = false

func _on_submit_button_pressed():
	# check what they chose
	check_answer()
		
func check_answer():
	current_question_num += 1
	# what did the player choose?
	if chosen_answer_index != null:
		if current_question.answers[chosen_answer_index].correct == true:
			# increase the score
			answer_screen_text.text = 'CORRECT!'
			
			# increase the player's session_eth by the reward
			PlayerManager.player.session_eth += current_question.reward
			
			# send an updated player list to connected clients
			NetworkManager.send_quiz_participant()
			
		else:
			answer_screen_text.text = 'INCORRECT!'
	else:
		answer_screen_text.text = 'DID NOT CHOOSE AN ANSWER :()'

	# pause everything and show the answer status to the player
	question_timer.stop()
	answer_screen.visible = true
	question_screen.visible = false
	await get_tree().create_timer(quiz_timeout).timeout
	answer_screen.visible = false
	
	# if we do not have any more questions, the quiz is over
	if current_question_num > quiz.questions.size():
		UIManager.change_scene(UIManager.student_quiz_complete)
	else:
		populate_question()
	
func _on_question_timer_timeout():
	check_answer()

func _process(_delta):
	question_time.value = question_timer.time_left

	



