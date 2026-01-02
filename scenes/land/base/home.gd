class_name Home
extends Area2D

@export var worker_scene: PackedScene
@export var max_workers: int = 5

@onready var food_text: = $Food as RichTextLabel
@onready var water_text: = $Water as RichTextLabel
@onready var material_text: = $Material as RichTextLabel

@onready var spawner: = $Spawner as Marker2D

@onready var workers: Array = []

const MAX_INT: float = Vector3i.MAX.x

var text_template: = "[font_size=5][color=#000000]{label}[/color][/font_size]"

var storage: Dictionary[String, ResourceInfo] = {
	"food": ResourceInfo.new(),
	"water": ResourceInfo.new(),
	"material": ResourceInfo.new(),
}

var known_locations: Location = Location.new()

enum Job { SEARCH, GATHER, BUILD }


func _ready() -> void:
	init_text(storage)


func get_required_resource_name() -> String:
	var lowest_resource: = MAX_INT
	var resource_name: String
	for key in storage:
		if storage[key].value < lowest_resource:
			lowest_resource = storage[key].value
			resource_name = key
	return resource_name


# this should be in the worker class? should home tell workers what to do? or should they choose for themselves? ;)))))
func get_required_resource() -> Array:
	var low_resource: = get_required_resource_name()
	var known_resources: = get_all_resource_locations()
	return known_resources.get(low_resource, [])


func get_closest_required_resource() -> Area2D:
	var resources: Array = get_required_resource()
	return _find_closest(resources)


func _find_closest(locations: Array) -> Area2D:
	if locations.size() == 0:
		return
	var closest: Area2D = locations[0]
	var distance := MAX_INT
	for location: Area2D in locations:
		var new_distance = location.global_position.distance_squared_to(global_position)
		if new_distance < distance:
			closest = location
			distance = new_distance
	return closest


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


func add_new_location(location: Area2D):
	if not is_instance_valid(location):
		return
	if location is not ResourceArea2D:
		return
	var new_location: = location as ResourceArea2D
	new_location.found()
	var resource_name = new_location.get_resource_name()
	if new_location not in known_locations.resources[resource_name]:
		known_locations.resources[resource_name].append(new_location)


func get_all_resource_locations() -> Dictionary:
	return known_locations.resources


func get_resource_locations(resource_type: String) -> Array[Area2D]:
	return format_resource_array(known_locations.resources[resource_type])


func get_depleted_locations(resource_type: String) -> Array[Area2D]:
	return format_resource_array(known_locations.depleted[resource_type])


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
		worker.destination = get_closest_required_resource()
		add_child(worker)
