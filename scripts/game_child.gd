extends Node


signal bubble_popped

const Bubble := preload('res://scripts/bubble.gd')
const DELTA_MULTIPLIER := 30.0

var _asset_price_amount: float = 1.0
var _offshore_account_amount: float = 0.0
var _bubble_velocity: Vector2
var _axis: Vector2

@onready var _bubble: Bubble = %Bubble
@onready var _asset_price_label: RichTextLabel = %AssetPriceLabel
@onready var _offshore_account_label: RichTextLabel = %OffshoreAccountLabel


func _ready() -> void:
	_asset_price_label.pivot_offset = _asset_price_label.size / 2
	_offshore_account_label.pivot_offset = _offshore_account_label.size / 2
	update_asset_price_label()
	update_offshore_account_label()
	_bubble.popped.connect(bubble_popped.emit)


func _process(delta: float) -> void:
	_axis.x = Input.get_axis(&'move_left', &'move_right')
	_axis.y = Input.get_axis(&'move_down', &'move_up')


func _physics_process(delta: float) -> void:
	var dt := delta * DELTA_MULTIPLIER
	var move := _axis

	if _bubble._state == Bubble.State.POPPING:
		return

	move = move.normalized()
	move *= 0.05
	move *= dt
	_bubble_velocity += move
	_bubble.global_position += Vector3(_bubble_velocity.x, _bubble_velocity.y, 0)
	_bubble_velocity.x *= float(absf(_bubble.global_position.x) < 8)
	_bubble_velocity.y *= float(absf(_bubble.global_position.y) < 5)
	_bubble.global_position.x = clampf(_bubble.global_position.x, -8, 5)
	_bubble.global_position.y = clampf(_bubble.global_position.y, -8, 5)
	_bubble_velocity = _bubble_velocity.lerp(Vector2.ZERO, delta * 2.0)


func _unhandled_input(event: InputEvent) -> void:
	if _bubble._state != Bubble.State.READY:
		return

	if event.is_pressed() and not event.is_echo():
		if event.is_action(&'inflate'):
			increase_asset_price()
			await _bubble.try_inflate()
		elif event.is_action(&'deflate'):
			decrease_asset_price()
			await _bubble.try_deflate()


func _punch(label: Control) -> void:
	await (get_tree().create_tween()
				.set_trans(Tween.TRANS_BOUNCE)
				.tween_property(label, ^'scale', Vector2.ONE * 1.1, 0.05)
				.finished)
	await (get_tree().create_tween()
			.tween_property(label, ^'scale', Vector2.ONE, 0.05)
			.finished)


func calculate_random_cents() -> float:
	return fmod(randf_range(0.0, 0.99), 1.0)


func increase_asset_price() -> void:
	_asset_price_amount *= 1.1
	_asset_price_amount += calculate_random_cents()
	update_asset_price_label()
	_punch(_asset_price_label)


func decrease_asset_price() -> void:
	_asset_price_amount /= 2.0
	_asset_price_amount += calculate_random_cents()
	update_asset_price_label()


func update_asset_price_label() -> void:
	_asset_price_label.text = 'Asset Price: $%.2f' % _asset_price_amount


func update_offshore_account_label() -> void:
	_offshore_account_label.text = 'Offshore Account: $%.2f' % Game.players[0].offshore_account
