extends Node

signal quiz_recieved(quiz)
signal start_quiz(quiz)
signal quiz_participant_recieved(participant)
signal quiz_score_updated(participant, score)
signal class_recieved(clazz)
signal class_created(clazz)
signal joined_class()
signal participant_joined()
signal ready_quiz(quiz)
signal participant_ready(participant)

func parse_data(data):
	#var data_size = data.values()
	#if data_size.size() == 0:
		#return
	match data.action:
		
		# we receive a ping from the server, so we are connected
		'ping':
			StateManager.network_state = StateManager.NETWORK_STATE.CONNECTED

		'participant_joined':
			emit_signal("participant_joined")
			
		## CLASS FUNCTIONS ###
		'join-class':
			print('we joined a class!')
			emit_signal("joined_class")
		'class-create':
			emit_signal("class_created", data.Attributes)
		'class-list-single':
			emit_signal("class_recieved", data)
			# keep our participant data in sync
			ParticipantManager.participants = data
			
		## QUIZ FUNCTIONS
		'quiz-list':
			emit_signal("quiz_recieved", data.Items)
		'quiz-list-single':
			emit_signal("quiz_recieved", data.Item)
		'ready_quiz':
			emit_signal("ready_quiz", data.quiz_title)
		'ready_to_be_quizzed':
			emit_signal("participant_ready", data.participant)
		'start_quiz':
			StateManager.change_game_state(StateManager.GAME_STATE.QUIZ)
			emit_signal("start_quiz")
			
		'send_quiz_participant':
			emit_signal("quiz_participant_recieved", data.participant)
			
		'update_score':
			emit_signal("quiz_score_updated", data.participant, data.score)
	
