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

enum Action { MOVING, IDLE, HARVESTING, DEPOSITING, WANDERING, SEARCHING }
var action = Action.SEARCHING

var found_area: Area2D = null
var resource_locations: Array[Area2D] = []


func _process(delta: float) -> void:
	if not is_instance_valid(home):
		var homes: Array[Area2D] = []
		for node in get_tree().get_nodes_in_group("home"):
			if node is Area2D:
				homes.append(node)
		home = find_closest(homes)

	match action:
		Action.IDLE:
			return
		Action.MOVING:
			walk_to_destination(delta)
		Action.HARVESTING:
			return
		Action.DEPOSITING:
			return
		# could set to wander when no resources to gather/ waiting for resources to replenish
		Action.WANDERING, Action.SEARCHING:
			random_walk_around_base(5000, delta)
			if resource_locations.size() > 0:
				action = Action.MOVING
				ready_to_move = true
				destination = set_destination(destination)
	move_and_slide()


func set_destination(new_dest: Area2D):
	destination = new_dest


func walk_to_destination(delta: float):
	destination = get_destination(destination)
	var target: Vector2 = destination.global_position - global_position
	velocity = velocity.move_toward(target, speed * delta)


func random_walk_around_base(wander_distance: float, delta: float):
	var distance_to_home = home.global_position.distance_squared_to(global_position)
	var random_accel = Vector2.ZERO
	var accel_to_home = Vector2.ZERO
	var accel = Vector2.ZERO
	if distance_to_home > wander_distance:
		accel_to_home = global_position.direction_to(home.global_position) / 20
		random_accel = Vector2((randf() - 0.5), (randf() - 0.5))
		accel = (accel_to_home + random_accel) / 2
	else:
		accel = Vector2(randf() - 0.5, randf() - 0.5)
	velocity += accel * speed * delta


# should first look for resources. using a random walk?
# then walk back to base and report new location to all other workers (unless.... you dont want to ;) ).
func find_closest(locations: Array[Area2D]) -> Area2D:
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
			resource = find_closest(resource_locations)
			return resource
		else:
			return home
	else:
		return current_destination


func deposit(deposit_node: Home):
	ready_to_move = false
	inventory = deposit_node.deposit(inventory)
	if deposit_node.is_in_group("home"):
		if is_instance_valid(found_area):
			deposit_node.add_new_location(found_area)
			found_area = null
		resource_locations = deposit_node.get_resource_locations() # check if its the same?
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
	if action == Action.SEARCHING:
		if area.is_in_group("resource"):
			set_destination(area)
			found_area = area
			action = Action.MOVING
			get_tree().create_timer(randi_range(2, 5))
			set_destination(home)
		elif area is Home:
			var area_home: Home = area
			resource_locations = area_home.get_resource_locations()
	if action == Action.MOVING:
		if destination == home:
			if area.is_in_group("home"):
				var home_node: = area as Home
				deposit(home_node)
		elif destination == resource:
			if area.is_in_group("resource"):
				var res := area as ResourceArea2D
				if res:
					harvest(res)
