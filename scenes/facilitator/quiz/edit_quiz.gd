extends Control

@export var save_quiz_button : Button
@export var cancel_buttion: Button
@export var quiz_title_field : LineEdit
@export var quiz_description_field : TextEdit
@export var question_container : VBoxContainer

var questions = []
var question_button
var question_count = 1


var question_scene = preload("res://scenes/components/question.tscn")
var add_question_button = preload("res://scenes/components/add_question_button.tscn")

# our quiz object
var quiz

func _ready():
	save_quiz_button.connect("pressed", _on_save_quiz_button_pressed)
	cancel_buttion.connect("pressed", _on_cancel_button_pressed)
	
	# populate our questions
	quiz = QuizManager.current_quiz

	quiz_title_field.text = quiz.quizTitle
	for question in quiz.questions:
		
		#spawn a question scene
		var q = question_scene.instantiate()
		question_container.add_child(q)
		q.question_title.text = question.title
		q.question_reward.text = question.reward
		q.question_time.text = question.time
		
		if question.answers[0]:
			q.choice_1.text = question.answers[0].title
			q.correct_1.button_pressed = question.answers[0].correct
		if question.answers[1]:
			q.choice_2.text = question.answers[1].title
			q.correct_2.button_pressed = question.answers[1].correct
		if question.answers[2]:
			q.choice_3.text = question.answers[2].title
			q.correct_3.button_pressed = question.answers[2].correct
		if question.answers[3]:
			q.choice_4.text = question.answers[3].title
			q.correct_4.button_pressed = question.answers[3].correct
			
			
	# add our question add button
	var b = add_question_button.instantiate()
	question_container.add_child(b)
	question_button = b
	question_button.connect('pressed', _on_add_question_button_pressed)

func _on_save_quiz_button_pressed():
	
	# construct our quiz from the UI
	var quiz_title = quiz_title_field.text
	var quiz_desctipion = quiz_description_field.text
	
	for child in question_container.get_children():
		if child.is_in_group('question'):
			var question_title = child.question_title.text
			var question_time = int(child.question_time.text)
			var question_reward = float(child.question_reward.text)
			
			var answers = []
			
			if child.choice_1.text != '':
				var answer = {
					'title' : child.choice_1.text,
					'correct' : child.correct_1.is_pressed()
					}
				answers.append(answer)
			
			if child.choice_2.text != '':
				var answer = {
					'title' : child.choice_2.text,
					'correct' : child.correct_2.is_pressed()
					}
				answers.append(answer)
			if child.choice_3.text != '':
				var answer = {
					'title' : child.choice_3.text,
					'correct' : child.correct_3.is_pressed()
					}
				answers.append(answer)
			if child.choice_4.text != '':
				var answer = {
					'title' : child.choice_4.text,
					'correct' : child.correct_4.is_pressed()
					}
				answers.append(answer)
				
			var question = {
				'title' : question_title,
				'time' : int(question_time),
				'reward' : float(question_reward),
				'answers' : answers
			}
			questions.append(question)

	quiz = {
		'title' : quiz_title,
		'description' : quiz_desctipion,
		'questions' : questions
	}
	
	# has the title been changed? if so, delete the old quiz
	if quiz_title != QuizManager.current_quiz.quizTitle:
		NetworkManager.delete_quiz(QuizManager.current_quiz.quizTitle)
	
	NetworkManager.save_quiz(quiz)
	UIManager.change_scene(UIManager.faculty_app)

func _on_add_question_button_pressed():
	question_button.queue_free()
	var next_slot = question_container.get_child_count()
	
	var q = question_scene.instantiate()
	question_container.add_child(q)
	q.question_number.text = 'QUESTION ' + str(question_count)
	q.delete_button.connect('pressed', _on_question_deleted)
	question_count += 1
	
	# re-add our question button
	var b = add_question_button.instantiate()
	question_container.add_child(b)
	question_button = b
	question_button.connect('pressed', _on_add_question_button_pressed)

func _on_question_deleted():
	# loop through our questions and update their question numbers
	pass

func _on_cancel_button_pressed():
	UIManager.change_scene(UIManager.faculty_app)
