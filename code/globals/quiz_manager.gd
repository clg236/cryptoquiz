extends Node

var current_quiz
var quiz_info = {
	'stats' : {
		'correct_count' : 0,
		'incorrect_count' : 1,
	}
}

func _ready():
	DataParser.connect('quiz_recieved', _on_quiz_recieved)
	DataParser.connect('quiz_participant_recieved', update_participant)
	DataParser.connect('quiz_score_updated', update_score)

func _on_quiz_recieved(quiz):
	current_quiz = quiz

func update_participant(participant):

	# update our participants list
	quiz_info.participants = []
	quiz_info.participants.append(participant)

func update_score(participant, score):
	# find the participant and update their score
	pass
	
func update_stats(correct):
	print('updating stats...', correct)
	if correct:
		quiz_info.stats.correct_count += 1
	else:
		quiz_info.stats.correct_count -= 1


