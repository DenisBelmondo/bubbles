extends Node3D


var _current_obstacle: Node
@onready var _spawn_timer: Timer = $SpawnTimer


func _ready() -> void:
	spawn_obstacle()
	_spawn_timer.timeout.connect(spawn_obstacle)


func spawn_obstacle() -> void:
	if _current_obstacle:
		_current_obstacle.queue_free()

	var obstacle := preload('res://scenes/obstacle_1.tscn').instantiate()

	add_child.call_deferred(obstacle)
	_current_obstacle = obstacle
