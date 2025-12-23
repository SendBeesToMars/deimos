extends Node2D

class_name ResourceNode

@export var production_text: RichTextLabel
@export var resources_text: RichTextLabel
@export var workers_text: RichTextLabel

var text_template: = "[font_size=5][color=#000000]{label}[/color][/font_size]"

var node_info: Dictionary[String, Dictionary] = { }
@export var resource: String
@export var resource_rate: float
@export var initial_val: float

signal has_supplies


func init_resource() -> void:
	node_info = {
		"production": { "value": resource_rate, "node": production_text },
		resource: { "value": initial_val, "node": resources_text },
		"workers": { "value": 0.0, "node": workers_text },
	}
	init_text(node_info)


func init_text(items: Dictionary[String, Dictionary]):
	for key: String in items.keys() as Array[String]:
		var item: Dictionary = items[key]
		if item == null || item.value == null || item.node == null:
			continue
		if item.node is RichTextLabel and item.value is float:
			update_text(items, key)


func update_text(dict: Dictionary[String, Dictionary], key: String):
	var bbcode: String = text_template.format(
		{ "label": key.capitalize() + ": " + str(dict[key].value) },
	)
	dict[key].node.text = bbcode


func on_enter(body: Node2D) -> void:
	if body is Worker:
		var worker: Worker = body as Worker
		node_info.workers.value += 1
		update_text(node_info, "workers")
		worker.harvest(node_info, update_text)


func on_exit(body: Node2D) -> void:
	if body is Worker:
		node_info.workers.value -= 1
		update_text(node_info, "workers")


func produce() -> void:
	regen()


func regen() -> void:
	node_info[resource].value += node_info.production.value
	update_text(node_info, resource)
	if node_info[resource].value > 1:
		has_supplies.emit()
