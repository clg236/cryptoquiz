extends Node

var player = {
	'role' : '',
	'name' : '',
	'total_eth' : 0,
	'treasure' : 0,
	'eth_address' : '',
	'event_code' : null,
	'avatar' : {
		'color' : '#FE00E7',
	}
}

var private_key

var in_event : bool = false

var current_faculty = {
	'name' : '',
	'address' : ''
}

func get_address() -> String:
	return player.eth_address

func set_address(balance):
	print('here is our balance:', balance) 
	
func _test():
	print('test')
