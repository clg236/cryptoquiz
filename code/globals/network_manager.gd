extends Node
class_name WebSocketClient

@export var handshake_headers := PackedStringArray()
@export var supported_protocols := PackedStringArray()
@export var tls_trusted_certificate : X509Certificate = null
@export var tls_verify := true

var last_state = WebSocketPeer.STATE_CLOSED

var websocket_test_url
var _client = WebSocketPeer.new()
var event_code

var timeout_timer = Timer.new()
var is_connected : bool = false

signal connected_to_server()
signal connection_closed()
signal message_received(message: Variant)

# old signals
signal participant_entered(participant)
signal participant_exited(participant)
signal participant_updated(participant)
signal connected()
signal valid_class(result)

var searching_for_class : bool = false
var event_valid : bool = false

func connect_to_server(code):
	_client.supported_protocols = supported_protocols
	_client.handshake_headers = handshake_headers
	event_code = code
	websocket_test_url = 'wss://3uswb60jt4.execute-api.us-east-1.amazonaws.com/Prod?address=' + PlayerManager.player.eth_address + "&message=" + PlayerManager.player.name + "&signature=" + PlayerManager.player.signature + "&token=123456"
	var err = _client.connect_to_url(websocket_test_url, tls_verify, tls_trusted_certificate)

	if err != OK:
		print('unable to connect to server')
	last_state = _client.get_ready_state()
	return OK

func _on_connected():
	connected.emit()
	is_connected = true
	get_event(event_code)
	searching_for_class = true
	
func send(message) -> int:
	if typeof(message) == TYPE_STRING:
		return _client.send_text(message)
	print('sending data to server: ', message)
	return _client.send(var_to_bytes(message))

func get_message() -> Variant:
	if _client.get_available_packet_count() < 1:
		return null
	var pkt = _client.get_packet()
	if _client.was_string_packet():
		_on_data(pkt.get_string_from_utf8())
		return pkt.get_string_from_utf8()
	return bytes_to_var(pkt)

func close(code := 1000, reason := "") -> void:
	print('connecting closed: ', reason)
	PlayerManager.in_event = false
	is_connected = false
	_client.close(code, reason)
	last_state = _client.get_ready_state()

func clear() -> void:
	_client = WebSocketPeer.new()
	last_state = _client.get_ready_state()

func get_socket() -> WebSocketPeer:
	return _client

func poll() -> void:
	if _client.get_ready_state() != _client.STATE_CLOSED:
		_client.poll()
	var state = _client.get_ready_state()
	if last_state != state:
		last_state = state
		if state == _client.STATE_OPEN:
			_on_connected()
		elif state == _client.STATE_CLOSED:
			connection_closed.emit()
	while _client.get_ready_state() == _client.STATE_OPEN and _client.get_available_packet_count():
		message_received.emit(get_message())

func _process(delta):
	poll()


func _on_data(data):
	# convert the data to a json dictionary
	var json = JSON.new()
	#var data = _client.get_peer(1).get_packet().get_string_from_utf8()
	var parse_result = json.parse(data)
	if parse_result != OK:
		print("Error %s reading json file." % parse_result)
		return
	data = json.get_data()
	
	# print("server sent data: ", data)
	# has data
	
	if searching_for_class:
		if data.data == null:
			emit_signal("valid_class", false)
			return
		else:
			join_event(event_code)
			emit_signal("valid_class", true)
		searching_for_class = false

	if 'data' in data.keys() and data.data != null:
		DataParser.parse_data(data.data)

func _send_data(data):
	if is_connected:
		# print('sending data: ', data)
		send(data)
	
	
### PARTICIPANT NETWORK FUNCTIONS ###
func raise_hand(value, facilitator):
	var json = JSON.new()
	var data = json.stringify({
		"action" : "class",
		"op" : "broadcast",
		"payload" : {
			"data" : {
				"action" : "raise_hand",
				"value" : value,
				"participant" : PlayerManager.player
			},
		},
		"participants" : [facilitator]
	})
	_send_data(data)


func send_comment(comment, facilitator):
	var json = JSON.new()
	var data = json.stringify({
		"action" : "class",
		"op" : "broadcast",
		"payload" : {
			"data" : {
				"action" : "send_comment",
				"comment" : comment,
				"name" : PlayerManager.player.name
			},
		},
		"participants" : [facilitator]
	})
	_send_data(data)


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

