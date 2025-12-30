class_name Home
extends Area2D

@export var worker_scene: PackedScene
@export var max_workers: int = 5

@onready var food_text: = $Food as RichTextLabel
@onready var water_text: = $Water as RichTextLabel
@onready var material_text: = $Material as RichTextLabel

@onready var spawner: = $Spawner as Marker2D

@onready var workers: Array = []

var text_template: = "[font_size=5][color=#000000]{label}[/color][/font_size]"

var storage: Dictionary[String, ResourceInfo] = {
	"food": ResourceInfo.new(),
	"water": ResourceInfo.new(),
	"material": ResourceInfo.new(),
}

var known_locations: Dictionary[String, Array] = { "resources": [], "depleted": [] }


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


func deposit(worker_inventory: Dictionary[String, int]) -> Dictionary[String, int]:
	for key in worker_inventory.keys():
		if storage.has(key):
			storage[key].value += worker_inventory[key]
			worker_inventory[key] = 0
			var key_str: String = str(key)
			update_text(storage, key_str)
	return worker_inventory


func add_new_location(new_location: Area2D):
	if not is_instance_valid(new_location):
		return
	if new_location.is_in_group("resource"):
		known_locations.resources.append(new_location)


func get_resource_locations() -> Array[Area2D]:
	return format_resource_array(known_locations.resources)


func get_depleted_locations() -> Array[Area2D]:
	return format_resource_array(known_locations.depleted)


# valid format for worker
func format_resource_array(res_array: Array) -> Array[Area2D]:
	var ret: Array[Area2D] = []
	for item in res_array:
		if item is Area2D:
			ret.append(item)
	return ret


func _on_spawn_timer_timeout() -> void:
	if not is_instance_valid(worker_scene):
		return
	if workers.size() <= max_workers:
		var worker: Worker = worker_scene.instantiate() as Worker
		workers.append(worker)
		var offset := Vector2(-20, 0).rotated(randf_range(-20, 0))
		worker.global_position = spawner.global_position + offset - global_position
		worker.home = self as Area2D # set this home as workers home.
		worker.resource_locations = get_resource_locations()
		add_child(worker)
