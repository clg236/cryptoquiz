extends Node

enum NETWORK_STATE {CONNECTING, CONNECTED, CLOSED, DISCONNECTED}
enum GAME_STATE { START, CLOSED, WAITING, IN_CLASS, POLL, QUIZ }
var network_state = NETWORK_STATE.DISCONNECTED
var game_state = GAME_STATE.START

### SIGNALS ###
signal network_state_changed(new_state)
signal game_state_changed(new_state)

func change_network_state(new_state):
	network_state = new_state
	emit_signal("network_state_changed", new_state)

func change_game_state(new_state):
	game_state = new_state
	emit_signal("game_state_changed", new_state)


	
	
