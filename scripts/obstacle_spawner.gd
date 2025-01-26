extends Node3D


var _current_obstacle: Node
@onready var _spawn_timer: Timer = $SpawnTimer


func _ready() -> void:
	_spawn_timer.timeout.connect(spawn_obstacle)


func spawn_obstacle() -> void:
	if _current_obstacle:
		_current_obstacle.queue_free()

	var obstacle: Node3D = preload('res://scenes/obstacle_1.tscn').instantiate()

	add_child.call_deferred(obstacle)

	await get_tree().process_frame

	obstacle.global_position.y += randf_range(-4, 4)
	_current_obstacle = obstacle
