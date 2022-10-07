extends Control

@export var quiz_title : Label
@export var num_questions : Label
@export var score : Label
@export var question_title : RichTextLabel
@export var question_time : ProgressBar
@export var question_reward : RichTextLabel
@export var choice_container : GridContainer
@export var submit_button : Button
@export var return_button : Button

@export var waiting_screen : Control
@export var question_screen : Control
@export var quiz_over_screen : Control
@export var answer_screen : Control
@export var answer_screen_text : Label

@export var quiz_timeout : int = 5

var answer_scene = preload("res://scenes/student/quiz/answer.tscn")
var current_question 
var current_question_num = 1
var chosen_answer_index
var current_score = 0
var quiz
var in_quiz : bool = false

var question_timer

func _ready():
	DataParser.connect('quiz_recieved', _on_quiz_recieved)
	DataParser.connect("start_quiz", _on_start_quiz_recieved)
	submit_button.connect('pressed', _on_submit_button_pressed)
	return_button.connect('pressed', _on_return_button_pressed)
	
	# hide screens
	waiting_screen.visible = true
	question_screen.visible = false
	answer_screen.visible = false
	
	# hide the header
	Header.show_header(false)
	
	# disabling our submit button
	submit_button.disabled = true
	
	# download our quiz
	NetworkManager.list_single_quiz(QuizManager.quiz_title)

func _on_quiz_recieved(quiz):
	print('recieved a quiz!!!!', quiz)
	# tell the faculty that we're ready for the quiz
	for participant in ParticipantManager.participants.participants:
		if ParticipantManager.participants.participants[participant].role == 'facilitator':
			var message = {
				'action' : 'ready_to_be_quizzed',
				'participant' : PlayerManager.player.eth_address
				}
			NetworkManager.broadcast_to_individual(participant, message)
	QuizManager.current_quiz = quiz

func _on_start_quiz_recieved():
	in_quiz = true
	waiting_screen.visible = false
	question_screen.visible = true
	populate_question()

func populate_question():
	question_screen.visible = true
	# if we have answers, kill them off
	for answer in choice_container.get_children():
		answer.queue_free()
	current_question = QuizManager.current_quiz.questions[current_question_num - 1]
	question_title.text = current_question.title
	question_reward.text = 'REWARD: ' + str(current_question.reward)
	for answer in current_question.answers:
		print('answer in current answers: ', answer)
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
	question_timer.one_shot = true
	question_timer.connect('timeout', _on_question_timer_timeout)

func _on_answer_chosen(index):
	chosen_answer_index = index
	submit_button.disabled = false
	for answer in choice_container.get_child_count():
		if choice_container.get_child(answer).get_index() != index:
			choice_container.get_child(answer).button.button_pressed = false

func _on_submit_button_pressed():
	# disable the button
	submit_button.disabled = true
		
func check_answer():
	current_question_num += 1
	# what did the player choose?
	if chosen_answer_index != null:
		if current_question.answers[chosen_answer_index].correct == true:
			# increase the score
			answer_screen_text.text = 'CORRECT!'
			
			# increase the player's session_eth by the reward
			PlayerManager.player.treasure += current_question.reward
			
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
	if current_question_num > QuizManager.current_quiz.questions.size():
		in_quiz = false
		question_screen.visible = false
		answer_screen.visible = false
		quiz_over_screen.visible = true
	else:
		populate_question()
	
func _on_question_timer_timeout():
	check_answer()

func _process(_delta):
	if in_quiz:
		question_time.value = question_timer.time_left

func _on_return_button_pressed():
	NetworkManager.update_participant(PlayerManager.player.event_code)
	UIManager.change_scene(UIManager.student_app)



