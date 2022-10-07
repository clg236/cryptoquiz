extends Node

var websocket_test_url
var _client = WebSocketClient.new()
var event_code

var timeout_timer = Timer.new()


# signals
signal participant_entered(participant)
signal participant_exited(participant)
signal participant_updated(participant)
signal connected()
signal valid_class(result)

var searching_for_class : bool = false
var event_valid : bool = false

func _ready():
	_client.connect("connection_closed", _closed)
	_client.connect("connection_error", _closed)
	_client.connect("connection_established", _connected)
	_client.connect("data_received", _on_data)
	_client.connect("server_close_request", _close_request)
	
func connect_to_server(code):
	event_code = code
	websocket_test_url = 'wss://3uswb60jt4.execute-api.us-east-1.amazonaws.com/Prod?address=' + PlayerManager.player.eth_address + "&message=" + PlayerManager.player.name + "&signature=" + PlayerManager.player.signature + "&token=123456"
	var err = _client.connect_to_url(websocket_test_url)

	if err != OK:
		print('unable to connect to server')
		set_process(false)

func disconnect_from_server():
	_client.disconnect_from_host()
	PlayerManager.in_event = false

func _close_request(code, reason):
	print("closed with code: ", code, " and reason: ", reason)
	StateManager.change_network_state(StateManager.NETWORK_STATE.CLOSED)

func _connected(proto):
	print('connected to server!', proto)
	_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	
	# start our timeout timer
	add_child(timeout_timer)
	timeout_timer.connect("timeout", _on_timeout_timer_timeout)

	# add a ping timer
	var ping_timer = Timer.new()
	add_child(ping_timer)
	ping_timer.start(3)
	ping_timer.connect("timeout", _on_ping_timer_timeout)
	
	# update our network state to connected
	StateManager.change_network_state(StateManager.NETWORK_STATE.CONNECTED)
	
	# get the class
	get_event(event_code)
	
	searching_for_class = true

func _closed(was_clean_close = false):
	print('connection closed', was_clean_close)
	StateManager.change_network_state(StateManager.NETWORK_STATE.CLOSED)
	
func _process(_delta):
	_client.poll()

func _on_data():
	
	# we want a timer that resets whenever we recieve some data (since we are pinging...)
	timeout_timer.stop()
	
	# convert the data to a json dictionary
	var json = JSON.new()
	var data = _client.get_peer(1).get_packet().get_string_from_utf8()
	var parse_result = json.parse(data)
	if parse_result != OK:
		print("Error %s reading json file." % parse_result)
		return
	data = json.get_data()
	
	print("server sent data: ", data)
	# has data
	
	if searching_for_class:
		if data.data == null:
			emit_signal("valid_class", false)
			return
		else:
			join_event(event_code)
			emit_signal("valid_class", true)
		searching_for_class = false
	
	emit_signal("connected")
			
	#if !data.success:
		#return
	
	if 'data' in data.keys() and data.data != null:
		DataParser.parse_data(data.data)

# ping function: ensures clients are connected. If they do not recieve a return ping within 15 seconds, they will switch to a disconnected state
func _on_ping_timer_timeout():
	
	# start our timeout timer, if it reaches zero, we'll set the status to disconnected
	timeout_timer.start(15)
	
	# send a ping to the server 
	var json = JSON.new()
	var data = json.stringify({
		"action" : "utilities",
		"op" : "ping",
	})
	_send_data(data)

func _on_timeout_timer_timeout():
	# set the state to disconnected
	StateManager.change_network_state(StateManager.NETWORK_STATE.DISCONNECTED)

func _send_data(data):
	# print('sending data: ', data)
	_client.get_peer(1).put_packet(data.to_ascii_buffer())
	
### CLASS NETWORK FUNCTIONS ###
func create_event(code, title):
	var json = JSON.new()
	var data = json.stringify({
		"action" : "class",
		"op" : "create",
		"class" : {
			'classCode' : code,
			'className' : title
		}
	})
	_send_data(data)

func join_event(code):
	var json = JSON.new()
	var data = json.stringify({
		"action" : "class",
		"op" : "join",
		"class" : {
			'classCode' : code,
			'participant' : PlayerManager.player
		}
	})
	_send_data(data)
	
func update_participant(code):
	var json = JSON.new()
	var data = json.stringify({
		"action" : "class",
		"op" : "join",
		"class" : {
			'classCode' : code,
			'participant' : PlayerManager.player
		}
	})
	_send_data(data)

func get_event(code):
	var json = JSON.new()
	var data = json.stringify({
		"action" : "class",
		"op" : "get",
		"class" : {
			'classCode' : code,
		}
	})
	_send_data(data)
	

### QUIZ NETWORK FUNCTIONS ###
func start_quiz(quiz):
	var json = JSON.new()
	var data = json.stringify({
		"action" : "class",
		"op" : "broadcast",
		"payload" : {
			"data" : {
				"action" : "start_quiz",
				"quiz" : quiz
			}
		}
	})
	_send_data(data)

func save_quiz(quiz):
	var json = JSON.new()
	var data = json.stringify({
		"action" : "quiz",
		"op" : "create",
		"quiz" : {
			'title' : quiz.title,
			'description' : quiz.description,
			'questions' : quiz.questions
		}
	})
	_send_data(data)

func list_single_quiz(quiz_title):
	var json = JSON.new()
	var data = json.stringify({
		"action" : "quiz",
		"op" : "get",
		"quiz" : {
			'title' : quiz_title,
		}
	})
	_send_data(data)

func list_all_quizzes():
	var json = JSON.new()
	var data = json.stringify({
		"action" : "quiz",
		"op" : "list",
		"quiz" : { }
	})
	_send_data(data)

func delete_quiz(quiz):
	var json = JSON.new()
	var data = json.stringify({
		"action" : "quiz",
		"op" : "delete",
		"quiz" : { 
			'title' : quiz
		}
	})
	_send_data(data)
	
func send_quiz_participant():
	var json = JSON.new()
	var data = json.stringify({
		"action" : "class",
		"op" : "broadcast",
		"payload" : {
			"data" : {
				"action" : "send_quiz_participant",
				"participant" : PlayerManager.player
			}
		}
	})
	_send_data(data)

func ready_for_quiz():
	var json = JSON.new()
	var data = json.stringify({
		"action" : "class",
		"op" : "broadcast",
		"payload" : {
			"data" : {
				"action" : "send_quiz_participant",
				"participant" : PlayerManager.player
			}
		}
	})
	_send_data(data)

func update_score(score):
	var json = JSON.new()
	var data = json.stringify({
		"action" : "class",
		"op" : "broadcast",
		"payload" : {
			"data" : {
				"action" : "update_score",
				"participant" : PlayerManager.player,
				"score" : score
			}
		}
	})
	_send_data(data)
	
### PARTICIPANT NETWORK FUNCTIONS
func participant_joined(participant):
	var json = JSON.new()
	var data = json.stringify({
		"action" : "class",
		"op" : "broadcast",
		"payload" : {
			"data" : {
				"action" : "participant_joined",
			}
		}
	})
	_send_data(data)

func participant_left(participant):
	emit_signal("participant_exited", participant)

func participant_changed(participant):
	emit_signal("participant_updated", participant)

# returns all clients that send a message back
func get_participants():
	# REPLACE BY GET_CLASS
	var json = JSON.new()
	var data = json.stringify({
		"action" : "class",
		"op" : "get",
	})
	_send_data(data)
	
### BROADCAST TO INDIVIDUAL ID ##
func broadcast_to_individual(id, message): #id is the user's address
	var json = JSON.new()
	var data = json.stringify({
		"action" : "class",
		"op" : "broadcast",
		"payload" : {
			"data" : message
		},
		"participants" : [id]
	})
	_send_data(data)

