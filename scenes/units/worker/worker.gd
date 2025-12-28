extends CharacterBody2D

class_name Worker

@onready var home: Home
@onready var resource: ResourceArea2D
@onready var destination: Area2D
@onready var inside_area_timer: Timer = $InsideAreaTimer

@export var speed: float = 50.0
const TOP_SPEED: float = 50
var ready_to_move: = false

const INVENTORY_CAP: int = 5
var inventory: Dictionary[String, int] = {
	"food": 0,
	"water": 0,
	"material": 0,
}


func _process(delta: float) -> void:
	home = find_closest(get_tree().get_nodes_in_group("home"))
	resource = find_closest(get_tree().get_nodes_in_group("resource"))
	destination = get_destination(destination)
	var target: Vector2 = destination.global_position - global_position
	velocity = velocity.move_toward(target, speed * delta)

	move_and_slide()


# should first look for resources. using a random walk?
# then walk back to base and report new location to all other workers (unless.... you dont want to ;) ).
func find_closest(locations: Array[Node]) -> Area2D:
	var closest: Area2D = locations[0]
	var distance = 9999999.0
	for location: Area2D in locations:
		var new_distance = location.global_position.distance_to(global_position)
		if new_distance < distance:
			closest = location
			distance = new_distance
	return closest


# if destination reached, switch destination
func get_destination(current_destination: Area2D = null) -> Area2D:
	if current_destination == null:
		return home
	if ready_to_move:
		inside_area_timer.stop()
		ready_to_move = false
		if current_destination == home:
			return resource
		else:
			return home
	else:
		return current_destination


func deposit(deposit_node: Home):
	ready_to_move = false
	inventory = deposit_node.deposit(inventory)
	inside_area_timer.wait_time = randi_range(1, 5)
	inside_area_timer.start()


func harvest(res: ResourceArea2D):
	ready_to_move = false
	var amount_harvested: int = res.harvest(INVENTORY_CAP)
	inventory[res.resource_name] += amount_harvested
	inside_area_timer.wait_time = randi_range(1, 5)
	inside_area_timer.start()


# check distance to destination, if close enough return true.
func destination_reached(dest: Vector2):
	return true if position.distance_to(dest) < 1 else false


# go to new destination after timer runs out
func _on_inside_area_timer_timeout() -> void:
	ready_to_move = true


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("home"):
		var home_node: = area as Home
		deposit(home_node)
	var res := area as ResourceArea2D
	if res:
		harvest(res)
