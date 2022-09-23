extends Node

signal quiz_recieved(quiz)
signal start_quiz(quiz)
signal quiz_participant_recieved(participant)
signal quiz_score_updated(participant, score)
signal class_recieved(clazz)
signal class_created(clazz)

func parse_data(data):
	# print('parsing data: ', data)
	# ping action: client is connected to the server, keep our state as connected
	match data.action:
		
		# we receive a ping from the server, so we are connected
		'ping':
			StateManager.network_state = StateManager.NETWORK_STATE.CONNECTED
		'recieve_participants':
			ParticipantManager.participants.append(data.participant)
		'participant_joined':
			ParticipantManager.participant_join(data.participant)
			
		## CLASS FUNCTIONS ###
		'class-create':
			emit_signal("class_created", data.Attributes)
		'class-list-single':
			emit_signal("class_recieved", data.clazz)
			
		## QUIZ FUNCTIONS
		'quiz-list':
			emit_signal("quiz_recieved", data.Items)
		'quiz-list-single':
			emit_signal("quiz_recieved", data.Item)
		'start_quiz':
			StateManager.change_game_state(StateManager.GAME_STATE.QUIZ)
			emit_signal("start_quiz", data.quiz)
			
		'send_quiz_participant':
			emit_signal("quiz_participant_recieved", data.participant)
			
		'update_score':
			emit_signal("quiz_score_updated", data.participant, data.score)
	
