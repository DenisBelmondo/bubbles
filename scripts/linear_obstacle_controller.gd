extends Node


@onready var _parent_node_3d: Node3D = get_parent()


func _physics_process(delta: float) -> void:
	_parent_node_3d.global_position.x -= 0.5
