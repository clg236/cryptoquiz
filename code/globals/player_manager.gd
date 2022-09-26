extends Node

var player = {
	'id' : '',
	'role' : '',
	'name' : '',
	'total_eth' : 0,
	'session_eth' : 0,
	'eth_address' : '',
	'signature' : '',
	'avatar' : {
		'color' : '#FE00E7',
	}
}

func get_address():
	return player.eth_address
	
func _test():
	print('test')
