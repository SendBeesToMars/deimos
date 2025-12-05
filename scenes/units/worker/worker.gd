extends CharacterBody2D

class_name Worker

@onready var base: Area2D = get_tree().get_nodes_in_group("base")[0]
@onready var farm: Area2D = get_tree().get_nodes_in_group("well")[0]
@onready var destination: Area2D
@onready var inside_area_timer: Timer = $InsideAreaTimer

@export var speed: float = 50.0
const TOP_SPEED: float = 50
var is_ready: = false

const INVENTORY_CAP: int = 5
var inventory: Dictionary[String, int] = {
	"food": 0,
	"water": 0,
	"material": 0,
}


func _process(delta: float) -> void:
	destination = get_destination(destination)
	var target: Vector2 = destination.global_position - global_position
	velocity = velocity.move_toward(target, speed * delta)

	move_and_slide()


# if destination reached, switch destination
func get_destination(current_destination: Area2D = null) -> Area2D:
	if current_destination == null:
		return base
	if destination_reached(current_destination.position) || is_ready:
		inside_area_timer.stop()
		is_ready = false
		if current_destination == base:
			return farm
		else:
			return base
	else:
		return current_destination


func drop_off_supplies(resources: Dictionary[String, ResourceInfo], update_text: Callable):
	is_ready = false
	for key in resources.keys():
		resources[key].value += inventory[key]
		inventory[key] = 0
		update_text.call(resources, key)
	printt("starting drop_off_supplies timer")
	inside_area_timer.wait_time = randi_range(1, 5)
	inside_area_timer.start()


func harvest(harvest_node_info: Dictionary[String, Dictionary], update_text: Callable):
	is_ready = false
	for key: String in harvest_node_info.keys():
		if key in inventory.keys():
			var gatherable: float = min(harvest_node_info[key].value, INVENTORY_CAP) #
			inventory[key] += floori(gatherable) # add item to worker inventory
			harvest_node_info[key].value -= floori(gatherable)
			update_text.call(harvest_node_info, key)
	printt("starting harvest_node_info timer")
	inside_area_timer.wait_time = randi_range(1, 5)
	inside_area_timer.start()


# check distance to destination, if close enough return true.
func destination_reached(dest: Vector2):
	return true if position.distance_to(dest) < 1 else false


func _on_inside_area_timer_timeout() -> void:
	printt("inside area timer ended")
	is_ready = true
