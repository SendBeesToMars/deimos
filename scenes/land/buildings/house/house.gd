extends Area2D

@export var construction_progress: float:
	get:
		return construction_progress
	set(new_value):
		construction_progress = new_value
		modulate = Color(1, 1, 1, clampf(construction_progress / 100, 0, 1))
