extends Node


var _selected_button_idx: int
@onready var _buttons: Control = $Buttons
@onready var _button_children: Array[Control]
@onready var _fade: ColorRect = $Fade
@onready var _logo: TextureRect = $Logo


func _ready() -> void:
	_buttons.pivot_offset = _buttons.size / 2
	_button_children.assign(_buttons.get_children())
	_logo.pivot_offset = _logo.size / 2
	_fade.visible = true
	await get_tree().create_timer(1).timeout
	await get_tree().create_tween().tween_property(_fade, ^'color:a', 0.0, 1.0).finished
	_logo.scale = Vector2.ONE * 0.01
	_logo.visible = true
	await get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC).tween_property(_logo, ^'scale', Vector2.ONE, 1.0).finished
	_buttons.scale = Vector2.ONE * 0.01
	_buttons.visible = true
	get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC).tween_property(_buttons, ^'scale', Vector2.ONE, 1.0)


func _process(delta: float) -> void:
	_button_children[_selected_button_idx].scale = Vector2.ONE + Vector2.ONE * sin(Time.get_ticks_msec() / 100.0) * delta


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&'ui_down'):
		_selected_button_idx += 1
		_selected_button_idx %= _buttons.get_child_count()
	elif event.is_action_pressed(&'ui_up'):
		_selected_button_idx -= 1
		_selected_button_idx %= _buttons.get_child_count()
	elif event.is_action_pressed(&'ui_accept'):
		var selected := _buttons.get_child(_selected_button_idx)

		if selected.name == 'Start':
			await get_tree().create_tween().tween_property(_fade, ^'color:a', 1.0, 1.0).finished
			get_tree().change_scene_to_file('res://scenes/game_root.tscn')
		elif selected.name == 'Quit':
			get_tree().quit()
