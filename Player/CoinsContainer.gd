extends HBoxContainer

const HIDDEN_Y_POS := -100
const DISPLAY_Y_POS := 20

@onready var display_timer: Timer = $Timer
@onready var coins_label: Label = $CoinsLabel


func _ready() -> void:
	display_timer.timeout.connect(_on_timeout)


func update_coins_amount(amount: int) -> void:
	if display_timer.is_stopped():
		var tween := create_tween()
		tween.tween_property(self, "position:y", DISPLAY_Y_POS, 0.5)
	display_timer.start()
	coins_label.text = "%d" % amount


func _on_timeout() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:y", HIDDEN_Y_POS, 0.5)
