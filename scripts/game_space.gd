extends Node


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
	update_asset_price_label()
	update_offshore_account_label()


func _process(delta: float) -> void:
	_axis.x = Input.get_axis(&'move_left', &'move_right')
	_axis.y = Input.get_axis(&'move_down', &'move_up')


func _physics_process(delta: float) -> void:
	var dt := delta * DELTA_MULTIPLIER
	var move := _axis

	move = move.normalized()
	move *= 0.05
	move *= dt
	_bubble_velocity += move
	_bubble.global_position += Vector3(_bubble_velocity.x, _bubble_velocity.y, 0)
	_bubble_velocity = _bubble_velocity.lerp(Vector2.ZERO, delta * 2.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo():
		if event.is_action(&'inflate'):
			_bubble.try_inflate()
			await _bubble.ready_again
			increase_asset_price()
		elif event.is_action(&'deflate'):
			_bubble.try_deflate()
			await _bubble.ready_again
			decrease_asset_price()


func calculate_random_cents() -> float:
	return fmod(randf_range(0.0, 0.99), 1.0)


func increase_asset_price() -> void:
	_asset_price_amount *= 1.1
	_asset_price_amount += calculate_random_cents()
	update_asset_price_label()


func decrease_asset_price() -> void:
	_asset_price_amount /= 2.0
	_asset_price_amount += calculate_random_cents()
	update_asset_price_label()


func update_asset_price_label() -> void:
	_asset_price_label.text = 'Asset Price: $%.2f' % _asset_price_amount


func update_offshore_account_label() -> void:
	_offshore_account_label.text = 'Offshore Account: $%.2f' % _offshore_account_amount
