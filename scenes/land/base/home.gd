extends Area2D

@export var food_text: RichTextLabel
@export var water_text: RichTextLabel
@export var material_text: RichTextLabel

var text_template: = "[font_size=5][color=#000000]{label}[/color][/font_size]"

var storage: Dictionary[String, ResourceInfo] = {
	"food": ResourceInfo.new(),
	"water": ResourceInfo.new(),
	"material": ResourceInfo.new(),
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_text(storage)


func init_text(items: Dictionary[String, ResourceInfo]):
	items.food.node = food_text
	items.water.node = water_text
	items.material.node = material_text
	for key: String in items.keys() as Array[String]:
		var item: ResourceInfo = items[key]
		if item == null || item.value == null || item.node == null:
			continue
		if item.node is RichTextLabel:
			update_text(storage, key)


func update_text(dict: Dictionary[String, ResourceInfo], key: String):
	var bbcode: String = text_template.format(
		{ "label": key.capitalize() + ": " + str(dict[key].value) },
	)
	dict[key].node.text = bbcode


# update storage and ui text
func _on_body_entered(body: Node2D) -> void:
	if body is Worker:
		var worker: Worker = body as Worker
		printt(worker.name + " entered home base")
		worker.drop_off_supplies(storage, update_text)
