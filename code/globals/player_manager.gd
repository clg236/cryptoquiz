extends Node

var player = {
	'id' : 'clg236',
	'role' : 'faculty',
	'name' : 'Christian Grewell',
	'total_eth' : 10,
	'session_eth' : 0,
	'eth_address' : '0x1bAFE96A7c853359cA5e73243D3742935a4250b9',
	'private_key' : '',
	'signature' : '',
	'secret' : 'hello!',
	'avatar' : {
		'color' : '#FE00E7',
	}
}

func get_address():
	return player.eth_address
	
func _test():
	print('test')
