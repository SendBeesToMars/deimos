extends Node

class_name Location

var resources: Dictionary[String, Array] = { }
var depleted: Dictionary[String, Array] = { }


func _init() -> void:
	resources = { "food": [], "water": [], "material": [] }
	depleted = { "food": [], "water": [], "material": [] }
