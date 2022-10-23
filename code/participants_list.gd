extends Control

@export var item_list : ItemList

func _ready():
	# connect to our quiz participants list
	DataParser.connect('quiz_participant_recieved', _on_quiz_participants_recieved)

func _on_quiz_participants_recieved(participants):
	# refresh out participants list
	for participant in QuizManager.quiz_info.participants:
		if participant.name != '':
			item_list.add_item(participant.name) # add their avatar later too