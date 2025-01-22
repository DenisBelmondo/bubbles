extends Node3D


signal ready_again


enum State {
	READY,
	INFLATING,
	DEFLATING,
}


@export_range(0, 100.0) var inflation_addend: float = 0.1
@export_range(0, 100.0) var deflation_subtrahend: float = 0.8
var _state: State


func _make_inflation_tween(target_uniform_scale: float) -> Tweener:
	return get_tree().create_tween().tween_property(self, ^'scale', scale + Vector3.ONE * target_uniform_scale, 0.125)


func _can_change_size() -> bool:
	var scale_len_2 := scale.length_squared()

	return _state == State.READY and scale_len_2 >= 0.1 and scale_len_2 <= 10.0


func try_inflate() -> void:
	if _state != State.READY:
		return

	_state = State.INFLATING

	await _make_inflation_tween(inflation_addend).finished

	_state = State.READY
	ready_again.emit()


func try_deflate() -> void:
	if _state != State.READY:
		return

	_state = State.DEFLATING

	await _make_inflation_tween(-deflation_subtrahend).finished

	_state = State.READY
	ready_again.emit()
