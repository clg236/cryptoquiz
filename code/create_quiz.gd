extends Control

@export var save_quiz_button : Button
@export var cancel_buttion: Button
@export var quiz_title_field : TextEdit
@export var quiz_description_field : TextEdit

var test_quiz = {
	'title' : 'test quiz',
	'description' : 'a test quiz',
	'questions' : [
		{
			'title' : 'what is my name?',
			'time' : 10,
			'reward' : 1.1,
			'answers' : [
				{
					'title' : 'Christian',
					'correct' : true
				},
				{
					'title' : 'Bob',
					'correct' : false
				},
				{
					'title' : 'Amy',
					'correct' : false
				},
				{
					'title' : 'Xu',
					'correct' : false
				}
			]
		},
		{
			'title' : 'what is the same?',
			'time' : 5,
			'reward' : 0.1,
			'answers' : [
				{
					'title' : 'a rock',
					'correct' : false
				},
				{
					'title' : 'a stone',
					'correct' : false
				},
				{
					'title' : 'a twin',
					'correct' : true
				},
				{
					'title' : 'a keyboard',
					'correct' : false
				}
			]
		}
	]
}

func _ready():
	save_quiz_button.connect("pressed", _on_save_quiz_button_pressed)
	cancel_buttion.connect("pressed", _on_cancel_button_pressed)

func _on_save_quiz_button_pressed():
	NetworkManager.save_quiz(test_quiz)

func _on_cancel_button_pressed():
	UIManager.change_scene(UIManager.faculty_app)


