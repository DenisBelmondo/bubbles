extends Node


enum State {
	INVALID,
	QUARTER,
	PLAYER_ROTATE,
	OFFSHORE_ACCOUNT_TALLY,
	PLAYING,
	POPPED,
	END,
}

enum Quarter {
	NONE,
	ONE,
	TWO,
	THREE,
	FOUR,
	COUNT,
}


const GameChild := preload('res://scripts/game_child.gd')
const Office := preload('res://scripts/office.gd')
const GAME_CHILD_SCENE := preload('res://scenes/game_child.tscn')

var _quarter: Quarter
var _game_child: GameChild
var _state: State
var _seconds_left: float = 30.0

@onready var _quarter_label: Label = $QuarterLabel
@onready var _quarter_top_left: Control = $QuarterTopLeft
@onready var _quarter_center: Control = $QuarterCenter
@onready var _office: Office = %Office
@onready var _sub_viewport: SubViewport = %SubViewport
@onready var _time_label: Label = %TimeLabel
@onready var _quarter_tally_root: Control = $QuarterTallyRoot
@onready var _offshore_account_label: Label = _quarter_tally_root.find_child('OffshoreAccountLabel', true, false)


func _ready() -> void:
	var mat := StandardMaterial3D.new()

	_office.screen.set_surface_override_material(1, mat)
	mat.albedo_texture = _sub_viewport.get_texture()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_quarter_label.pivot_offset = _quarter_label.size / 2

	set_state(State.QUARTER)


func _process(delta: float) -> void:
	if _state == State.PLAYING:
		var should_do_tally := false

		_seconds_left -= delta

		if _seconds_left < 0.0:
			should_do_tally = true

		_seconds_left = maxf(_seconds_left, 0)
		_time_label.text = str(int(_seconds_left))

		if should_do_tally:
			set_state(State.OFFSHORE_ACCOUNT_TALLY)


func set_state(new_state: State) -> void:
	var qtween := func (to: Control) -> Tweener:
			return (get_tree().create_tween()
				.tween_property(_quarter_label, ^'global_position', to.global_position, 1.0)
				.set_ease(Tween.EASE_IN_OUT)
				.set_trans(Tween.TRANS_CUBIC))

	if new_state == _state:
		return

	_state = new_state

	if _state == State.QUARTER:
		await qtween.call(_quarter_center).finished

		if _quarter >= Quarter.FOUR:
			await get_tree().create_timer(2.0).timeout
			set_state(State.END)
			return

		_quarter += 1
		_quarter %= Quarter.COUNT
		_quarter_label.text = 'Q%d' % _quarter
		_quarter_label.scale = Vector2.ONE * 2
		get_tree().create_tween().tween_property(_quarter_label, ^'scale', Vector2.ONE, 0.25)
		await get_tree().create_timer(1.0).timeout
		await qtween.call(_quarter_top_left).finished
		set_state(State.PLAYING)
	elif _state == State.PLAYING:
		reset()
	elif _state == State.OFFSHORE_ACCOUNT_TALLY:
		var deposit_amt := _game_child._asset_price_amount * 100.0

		_game_child.process_mode = Node.PROCESS_MODE_DISABLED
		Game.players[0].offshore_account += deposit_amt
		_offshore_account_label.text = 'Funds deposited into offshore account: $%.2f' % deposit_amt
		await get_tree().create_timer(1).timeout
		await get_tree().create_tween().tween_property(_quarter_tally_root, ^'modulate:a', 1.0, 1.0).finished
		await get_tree().create_timer(2).timeout
		await get_tree().create_tween().tween_property(_quarter_tally_root, ^'modulate:a', 0.0, 1.0).finished
		set_state(State.QUARTER)
	elif _state == State.END:
		get_tree().quit()


func reset() -> void:
	if is_instance_valid(_game_child):
		_game_child.queue_free()

	_seconds_left = 30
	_game_child = GAME_CHILD_SCENE.instantiate()
	_sub_viewport.add_child(_game_child)
	_game_child.bubble_popped.connect(func () -> void:
			await set_state(State.POPPED)
			await get_tree().create_timer(2).timeout
			_game_child.set_process(false)
			await set_state(State.QUARTER)
			reset())
	set_state(State.PLAYING)
