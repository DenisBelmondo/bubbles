extends Node


const GameChild := preload('res://scripts/game_child.gd')
const GAME_CHILD_SCENE := preload('res://scenes/game_child.tscn')

var _game_child: GameChild


func _ready() -> void:
	reset()


func reset() -> void:
	_game_child = GAME_CHILD_SCENE.instantiate()
	add_child(_game_child)
	_game_child.bubble_popped.connect(func () -> void:
			await get_tree().create_timer(2).timeout
			_game_child.free()
			reset())
