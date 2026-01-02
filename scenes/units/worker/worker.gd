extends CharacterBody2D

class_name Worker

@onready var inside_area_timer: Timer = $InsideAreaTimer

enum Action { MOVING, IDLE, HARVESTING, DEPOSITING, SEARCHING }
var action: Action = Action.SEARCHING
var home: Home
var destination: Area2D
var found_area: Area2D = null # new found area when searching.
var resource_locations: Dictionary[String, Array] = Location.new().resources # all personally known locations. updated when home
var ready_to_move: = false # should the enums be enough to get rid of this?

@export var speed: float = 50.0
const TOP_SPEED: float = 50
const MAX_INT: float = Vector3i.MAX.x

const INVENTORY_CAP: int = 5
var inventory: Dictionary[String, int] = {
	"food": 0,
	"water": 0,
	"material": 0,
}


func _process(delta: float) -> void:
	#  if not set; find closes home
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
		Action.SEARCHING:
			random_walk_around_base(5000, delta)
			# when resource found
			#if resource_locations.size() > 0:
			#action = Action.MOVING
			#ready_to_move = true

	move_and_slide()


func set_destination(new_dest: Area2D):
	destination = new_dest


func walk_to_destination(delta: float):
	if not is_instance_valid(destination):
		return
	var target: Vector2 = destination.global_position - global_position
	velocity = velocity.move_toward(target, speed * delta)


# if destination reached, switch destination
func get_destination() -> Area2D:
	if not is_instance_valid(destination):
		return home
	if ready_to_move:
		ready_to_move = false
		inside_area_timer.stop()
		if destination == home:
			var resource: Area2D = home.get_closest_required_resource()
			return resource
		else:
			return home
	else:
		return destination


# after all resource nodes are depleted increase the wander distance
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
	velocity += accel * speed * delta * 2


# should first look for resources. using a random walk?
# then walk back to base and report new location to all other workers (unless.... you dont want to ;) ).
func find_closest(locations: Array) -> Area2D:
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


# does a ton of things - maybe too much
func deposit(deposit_node: Home):
	ready_to_move = false
	inventory = deposit_node.deposit(inventory)
	if is_instance_valid(found_area):
		deposit_node.add_new_location(found_area)
		found_area = null
	inside_area_timer.wait_time = randi_range(1, 5)
	inside_area_timer.start()


func harvest(res: ResourceArea2D):
	printt("harvesting")
	ready_to_move = false
	var amount_harvested: int = res.harvest(INVENTORY_CAP)
	inventory[res.resource_name] += amount_harvested
	destination = home


# check distance to destination, if close enough return true.
func destination_reached(dest: Vector2):
	return true if position.distance_to(dest) < 1 else false


func random_wait(start: int = 2, end: int = 5):
	return get_tree().create_timer(randi_range(start, end)).timeout


# go to new destination after timer runs out
func _on_inside_area_timer_timeout() -> void:
	ready_to_move = true


func _on_area_2d_area_entered(area: Area2D) -> void:
	if action == Action.SEARCHING:
		if area is ResourceArea2D:
			var found_resource = area as ResourceArea2D
			# ignore the area if it has already been found by another worker.
			if found_resource.is_found:
				return
			set_destination(area)
			found_area = found_resource
			action = Action.MOVING
			await random_wait()
			set_destination(home)
		elif area is Home:
			var area_home: Home = area
			resource_locations = area_home.get_all_resource_locations()
			await random_wait()
			destination = area_home.get_closest_required_resource()
	if action == Action.MOVING:
		# moving to home checklist:
		# deposit inventory
		# get new destination
		if destination == home:
			if area is Home:
				var home_node: = area as Home
				deposit(home_node)
				await random_wait()
				destination = home_node.get_closest_required_resource()
		else:
			if area is ResourceArea2D:
				var res := area as ResourceArea2D
				await random_wait()
				harvest(res)
