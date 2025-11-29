extends Area2D

@export var production_text: RichTextLabel
@export var resources_text: RichTextLabel
@export var workers_text: RichTextLabel

var text_template: = "[font_size=5][color=#000000]{label}[/color][/font_size]"

var node_info: Dictionary[String, Dictionary] = { }


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	node_info = {
		"production": { "value": 0, "node": production_text },
		"food": { "value": 2, "node": resources_text },
		"workers": { "value": 0, "node": workers_text },
	}
	init_text(node_info)


func init_text(items: Dictionary[String, Dictionary]):
	for key: String in items.keys() as Array[String]:
		var item: Dictionary = items[key]
		if item == null || item.value == null || item.node == null:
			printt({ "1": item, "2": item.value, "3": item.node })
			continue
		if item.node is RichTextLabel and item.value is int:
			update_text(items, key)


func update_text(dict: Dictionary[String, Dictionary], key: String):
	var bbcode: String = text_template.format(
		{ "label": key.capitalize() + ": " + str(dict[key].value) },
	)
	dict[key].node.text = bbcode


func _on_body_entered(body: Node2D) -> void:
	if body is Worker:
		var worker: Worker = body as Worker
		printt(worker.name + " entered farm plot")
		worker.harvest(node_info, update_text)
