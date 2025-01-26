extends Node


enum State {
	INVALID,
	PLAYING,
}


class Player:
	var offshore_account: float


const GROUP_OBSTACLE := &'obstacle'


var state: State
var players: Array[Player]


func _init() -> void:
	players.resize(2)
