extends MeshInstance3D


signal popped


enum State {
	INTRO,
	READY,
	INFLATING,
	DEFLATING,
	POPPING,
}


@export_range(0, 100.0) var inflation_addend: float = 0.1
@export_range(0, 100.0) var deflation_subtrahend: float = 0.8
var _state: State
var _audio: AudioStreamPlaybackPolyphonic
@onready var _area: Area3D = $Area3D


func _ready() -> void:
	var on_something_entered := func (what: Node) -> void:
			if what.is_in_group(Game.GROUP_OBSTACLE):
				_state = State.POPPING
				_area.queue_free()
				popped.emit()
				_audio.play_stream(preload('res://sounds/pop.ogg'), 0, -10)
				material_override.albedo_texture = preload('res://textures/pop.png')
				(get_tree().create_tween()
						.set_ease(Tween.EASE_OUT)
						.set_trans(Tween.TRANS_ELASTIC)
						.tween_property(self, ^'scale', Vector3.ONE * 20, 0.25))
				await get_tree().create_timer(0.5).timeout
				visible = false

	_area.area_entered.connect(on_something_entered)
	_area.body_entered.connect(on_something_entered)
	_audio = $AudioStreamPlayer.get_stream_playback()
	_state = State.INTRO
	_audio.play_stream(preload('res://sounds/blow_1.ogg'), 0, -10)
	scale *= 0.01
	await get_tree().create_tween().tween_property(self, ^'scale', Vector3.ONE  * 2.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).finished
	await get_tree().create_timer(0.5).timeout
	_audio.play_stream(preload('res://sounds/bubble_1.ogg'), 0, -5)
	await get_tree().create_tween().tween_property(self, ^'scale', Vector3.ONE  * 1.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).finished

	if _state != State.POPPING:
		_state = State.READY


func _make_inflation_tween(target_uniform_scale: float) -> Tweener:
	return get_tree().create_tween().tween_property(self, ^'scale', scale + Vector3.ONE * target_uniform_scale, 0.125)


func _can_change_size() -> bool:
	var scale_len_2 := scale.length_squared()

	return _state == State.READY and scale_len_2 >= 0.5 and scale_len_2 <= 10.0


func try_inflate() -> void:
	if _state != State.READY:
		return

	_state = State.INFLATING
	_audio.play_stream(preload('res://sounds/blow_2.ogg'), 0, -15)

	await _make_inflation_tween(inflation_addend).finished

	if _state != State.POPPING:
		_state = State.READY


func try_deflate() -> void:
	if _state != State.READY:
		return

	_state = State.DEFLATING
	_audio.play_stream(preload('res://sounds/deflate_1.ogg'), 0, -10)

	await _make_inflation_tween(-deflation_subtrahend).finished

	if _state != State.POPPING:
		_state = State.READY
