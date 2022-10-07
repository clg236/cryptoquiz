extends Control

@export var waiting_screen : Control
@export var quiz_screen : Control
@export var score_screen : Control
@export var quiz_over_screen : Control

@export var ready_participant_container : VBoxContainer
@export var not_ready_participant_container : VBoxContainer

@export var quiz_title : Label
@export var num_questions : Label

@export var start_quiz_button : Button
@export var return_button : Button

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
var quiz_participant_row = preload("res://scenes/components/quiz_participant.tscn")
var question_timer
var chosen_answer_index
var in_quiz : bool = false
var ready_to_quiz : bool = false

@export var question_pause_time : int = 5

func _ready():
	DataParser.connect("participant_ready", _on_participant_ready)
	DataParser.connect('quiz_recieved', _on_quiz_recieved)
	start_quiz_button.connect("pressed", _on_start_quiz_pressed)
	return_button.connect('pressed', _on_return_button_pressed)
	Header.show_header(false)
	waiting_screen.visible = true
	quiz_screen.visible = false
	quiz_over_screen.visible = false
	
	# populate our not ready container with participants
	for participant in ParticipantManager.participants.participants:
		if ParticipantManager.participants.participants[participant].role != 'facilitator':
			var p = quiz_participant_row.instantiate()
			not_ready_participant_container.add_child(p)
			p.participant_name.text = ParticipantManager.participants.participants[participant].name
			p.participant_address.text = participant
			
	# send all participants the ready_quiz broadcast
	for participant in ParticipantManager.participants.participants:
		if ParticipantManager.participants.participants[participant].role != 'facilitator':
			var message = {
				'action' : 'ready_quiz',
				'quiz_title' : QuizManager.quiz_title
				}
			NetworkManager.broadcast_to_individual(participant, message)
	
	NetworkManager.list_single_quiz(QuizManager.quiz_title)

func _on_quiz_recieved(quiz):
	print('recieved a quiz: ', quiz)
	ready_to_quiz = true
	QuizManager.current_quiz = quiz
	
func _on_start_quiz_pressed():
	print('pressed!')
	if ready_to_quiz:
		# send all participants the start_quiz broadcast
		for participant in ParticipantManager.participants.participants:
			if ParticipantManager.participants.participants[participant].role != 'facilitator':
				var message = {
					'action' : 'start_quiz',
					}
				NetworkManager.broadcast_to_individual(participant, message)
		# hide the waiting screen
		in_quiz = true
		waiting_screen.visible = false
		quiz_screen.visible = true
		populate_question()
	
func _process(_delta):
	if in_quiz:
		question_time.value = question_timer.time_left
	
func _on_participant_ready(participant):
	for _participant in ParticipantManager.participants.participants:
		if _participant == participant:
			var p = quiz_participant_row.instantiate()
			ready_participant_container.add_child(p)
			p.participant_name.text = ParticipantManager.participants.participants[participant].name
			p.participant_address.text = participant
	print('a participanty is ready: ', participant)
	
	# remove the corresponding participant from our not ready container
	for not_ready in not_ready_participant_container.get_children():
		if not_ready.participant_address.text == participant:
			not_ready.queue_free()

func populate_question():
	quiz_screen.visible = true
	score_screen.visible = false
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
	# start the timer
	question_timer = Timer.new()
	add_child(question_timer)
	question_timer.wait_time = current_question.time
	question_time.max_value = current_question.time
	question_timer.start()
	question_timer.one_shot = true
	question_timer.connect('timeout', _on_question_timer_timeout)
			
func _on_question_timer_timeout():
	# hightlight the correct answer for a bit
	for answer in current_question.answers.size():
		if !current_question.answers[answer].correct:
			choice_container.get_child(answer).get_child(0).disabled = true
		else:
			choice_container.get_child(answer).modulate = Color("#ff0077")
	
	question_timer.stop()
	await get_tree().create_timer(question_pause_time).timeout
	#increase question number 
	current_question_num += 1
	
	# if we do not have any more questions, the quiz is over
	if current_question_num > QuizManager.current_quiz.questions.size():
		in_quiz = false
		quiz_screen.visible = false
		score_screen.visible = false
		quiz_over_screen.visible = true
	else:
		populate_question()

func _on_return_button_pressed():
	UIManager.change_scene(UIManager.faculty_app)
