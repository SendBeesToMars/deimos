class_name ResourceNode
extends Node2D

@export var production_text: RichTextLabel
@export var resources_text: RichTextLabel
@export var workers_text: RichTextLabel

var text_template: = "[font_size=5][color=#000000]{label}[/color][/font_size]"

var node_info: Dictionary[String, Dictionary] = { }
@export var resource_name: String
@export var capacity: float
@export var resource_rate: float
@export var initial_val: float
@export var can_deplete: bool = false


func init_resource() -> void:
	node_info = {
		"production": { "value": resource_rate, "node": production_text },
		resource_name: { "value": initial_val, "node": resources_text },
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


# tracks how many workers are present in the area
func on_enter(body: Node2D) -> void:
	if body is Worker:
		node_info.workers.value += 1
		update_text(node_info, "workers")


func on_exit(body: Node2D) -> void:
	if body is Worker:
		node_info.workers.value -= 1
		update_text(node_info, "workers")


# respawn resource over time
func regen() -> void:
	if can_deplete and node_info[resource_name].value <= 1:
		node_info[resource_name].value = 0
		return
	if node_info[resource_name].value >= capacity:
		return
	var prod_rate: float = node_info.production.value
	node_info[resource_name].value += prod_rate
	if node_info[resource_name].value >= capacity:
		node_info[resource_name].value = capacity
	update_text(node_info, resource_name)


func harvest(inventory_cap: int) -> int:
	var res := str(node_info[resource_name].value).to_float() # TODO: fix this? ignore variant to float cast error?
	var gatherable_amount: int = min(floori(res), inventory_cap)
	gatherable_amount = floori(gatherable_amount) # only work with fu
	node_info[resource_name].value -= gatherable_amount # remove number from resource inventory
	update_text(node_info, resource_name) # update ui
	return gatherable_amount
