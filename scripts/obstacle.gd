extends Node


func _ready() -> void:
	for c in find_children('*', 'Area3D', true, false):
		c.add_to_group(&'obstacle')
