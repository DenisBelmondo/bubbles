extends Node


const GameChild := preload('res://scripts/game_child.gd')
const Office := preload('res://scripts/office.gd')
const GAME_CHILD_SCENE := preload('res://scenes/game_child.tscn')

var _game_child: GameChild
@onready var _office: Office = %Office
@onready var _sub_viewport: SubViewport = %SubViewport


func _ready() -> void:
	var mat := StandardMaterial3D.new()

	_office.screen.set_surface_override_material(1, mat)
	mat.albedo_texture = _sub_viewport.get_texture()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	reset()


func reset() -> void:
	_game_child = GAME_CHILD_SCENE.instantiate()
	_sub_viewport.add_child(_game_child)
	_game_child.bubble_popped.connect(func () -> void:
			await get_tree().create_timer(2).timeout
			_game_child.free()
			reset())
