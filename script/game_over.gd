extends CanvasLayer

signal restart_requested

@onready var score_label: Label = $Overlay/CenterContainer/Panel/Buttons/ScoreLabel
@onready var high_score_label: Label = $Overlay/CenterContainer/Panel/Buttons/HighScoreLabel
@onready var restart_button: Button = $Overlay/CenterContainer/Panel/Buttons/RestartButton


func _ensure_nodes() -> void:
	if score_label == null and has_node("Overlay/CenterContainer/Panel/Buttons/ScoreLabel"):
		score_label = $Overlay/CenterContainer/Panel/Buttons/ScoreLabel
	if high_score_label == null and has_node("Overlay/CenterContainer/Panel/Buttons/HighScoreLabel"):
		high_score_label = $Overlay/CenterContainer/Panel/Buttons/HighScoreLabel
	if restart_button == null and has_node("Overlay/CenterContainer/Panel/Buttons/RestartButton"):
		restart_button = $Overlay/CenterContainer/Panel/Buttons/RestartButton


func set_score(score: int, high_score: int = -1) -> void:
	_ensure_nodes()
	if score_label != null:
		score_label.text = "Final Score: %d" % score
	if high_score_label != null and high_score >= 0:
		high_score_label.text = "High Score: %d" % high_score


func show_game_over(score: int, high_score: int = -1) -> void:
	set_score(score, high_score)
	show()
	if restart_button != null:
		restart_button.grab_focus()


func hide_game_over() -> void:
	hide()


func _on_restart_button_pressed() -> void:
	restart_requested.emit()
