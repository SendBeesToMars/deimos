extends CharacterBody2D

class_name Worker

@onready var text: RichTextLabel = $Text
var text_template: = "[font_size=4][color=#550000]{label}[/color][/font_size]"

const house_scene = preload("uid://dnwnw6scp355m")

enum Action { MOVING, IDLE, HARVESTING, DEPOSITING, SCOUTING, PROSPECTING, BUILDING }
var action: Action = Action.SCOUTING
var home_base_location: Vector2
var destination: Vector2
var found_area: Area2D = null # new found area when searching.
var resource_locations: Dictionary[String, Array] = Location.new().resources # all personally known locations. updated when base

@export var speed: float = 50.0
const TOP_SPEED: float = 50
const MAX_INT: float = Vector3i.MAX.x

const INVENTORY_CAP: int = 5
var inventory: Dictionary[String, int] = {
	"food": 0,
	"water": 0,
	"material": 0,
}
var amount_harvested: int = 0

# TODO: have actual dedicated jobs list that needs to be done


func _process(delta: float) -> void:
	#  if not set; find closes base
	if not home_base_location:
		var bases: Array[Area2D] = []
		for node in get_tree().get_nodes_in_group("base"):
			if node is Area2D:
				bases.append(node)
		home_base_location = find_closest(bases).global_position

	if destination.is_zero_approx():
		destination = home_base_location

	match action:
		Action.IDLE:
			pass
			#base.get_new_worker_action(action)
		Action.MOVING:
			walk_to_destination(delta)
		Action.HARVESTING:
			walk_to_destination(delta)
		Action.DEPOSITING:
			walk_to_destination(delta)
			#base.get_new_worker_action(action)
		# could set to wander when no resources to gather/ waiting for resources to replenish
		Action.PROSPECTING:
			random_walk_around_base(5000, delta)
		Action.SCOUTING: # scout for new locations to build on.
			scout(delta)
		Action.BUILDING:
			pass
			#build(delta)
	move_and_slide()
	update_text(text, str(Action.find_key(action)))


func scout(delta: float):
	# check if still need to scout
	if destination_reached():
		if can_place_circle(position, 10):
			build_site(position)
			go_home()
		else:
			destination = get_scout_location(40, home_base_location) # this should be set to homes radius
	draw_crumb(position, 1)
	walk_to_destination(delta)


func build(delta: float, home_base: Base):
	var building_locaiton = home_base.get_building_request_location()
	if is_instance_valid(building_locaiton):
		destination = building_locaiton.position
	else:
		action = Action.MOVING
	walk_to_destination(delta)


func update_text(txt: RichTextLabel, string: String):
	var bbcode: String = text_template.format(
		{ "label": string },
	)
	txt.text = bbcode


func go_home():
	destination = home_base_location


func set_destination(new_dest: Vector2):
	destination = new_dest


func walk_to_destination(delta: float):
	if destination.is_equal_approx(position):
		return
	var target: Vector2 = destination - global_position
	velocity = velocity.move_toward(target, speed * delta)


# if destination reached, switch destination
func get_destination() -> Vector2:
	return destination
	#if not is_instance_valid(destination):
	#return home_base_location
	#if ready_to_move:
	#ready_to_move = false
	#if destination.is_equal_approx(home_base_location):
	#var resource: Area2D = base.get_closest_required_resource()
	#return resource.global_position
	#else:
	#return base.global_position
	#else:
	#return destination


# after all resource nodes are depleted increase the wander distance
func random_walk_around_base(wander_distance: float, delta: float):
	var distance_to_home = home_base_location.distance_squared_to(global_position)
	var random_accel = Vector2.ZERO
	var accel_to_home = Vector2.ZERO
	var accel = Vector2.ZERO
	if distance_to_home > wander_distance:
		accel_to_home = global_position.direction_to(home_base_location) / 20
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


func deposit(deposit_node: Base) -> int:
	# if worker has found a new location, add it to Base resource dict
	var amount_deposited: int = 0
	if is_instance_valid(found_area):
		deposit_node.add_found_location(found_area)
		found_area = null
	if amount_harvested != 0:
		amount_deposited = amount_harvested
		inventory = deposit_node.deposit(inventory)
		amount_harvested = 0
	return amount_deposited


# TODO: if worker harvests nothing go back to wandering around.
func harvest(res: ResourceArea2D):
	amount_harvested = res.harvest(INVENTORY_CAP)
	inventory[res.resource_name] += amount_harvested
	printt("amount_harvested: ", amount_harvested)
	destination = res.global_position
	await random_wait()
	set_destination(home_base_location)
	action = Action.DEPOSITING


# check distance to destination, if close enough return true.
func destination_reached(dest: Vector2 = destination):
	return position.distance_squared_to(dest) < 5


func scout_area():
	var offset := Vector2(40, 0).rotated(randf() * TAU)
	var pos: Vector2 = position + offset
	return can_place_circle(pos, 10)


func get_scout_location(radius: float = 40, search_from: Vector2 = position):
	var offset := Vector2(radius, 0).rotated(randf() * TAU)
	var pos: Vector2 = search_from + offset
	return pos


# scout the area around starting_location for a free plot to build on.
func can_place_circle(location: Vector2, radius: int) -> bool:
	var shape := CircleShape2D.new()
	shape.radius = radius

	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, location)
	params.collide_with_areas = true
	params.collide_with_bodies = false

	var space := get_world_2d().direct_space_state
	return space.intersect_shape(params).is_empty()


func draw_crumb(location: Vector2, radius: float):
	var sprite := Sprite2D.new()
	sprite.texture = preload("uid://krjhtiqa6l")

	var tex_radius := sprite.texture.get_size().x * 0.5
	var scale_factor := radius / tex_radius
	sprite.scale = Vector2.ONE * scale_factor
	sprite.z_index = 5
	sprite.position = location
	sprite.modulate = Color(0, .5, 1, 0.05)
	get_parent().add_child(sprite)


func build_site(location: Vector2):
	var house: Area2D = house_scene.instantiate()
	house.position = location
	house.modulate = Color(1, 1, 1, 0.1)
	get_parent().add_child(house)


func random_wait(start: int = 2, end: int = 5):
	return get_tree().create_timer(randi_range(start, end)).timeout


func _on_area_2d_area_entered(area: Area2D) -> void:
	if action == Action.HARVESTING:
		if area is ResourceArea2D:
			var resource: ResourceArea2D = area
			harvest(resource)
	if action == Action.PROSPECTING:
		if area is ResourceArea2D:
			var found_resource: ResourceArea2D = area
			# ignore the area if it has already been found by another worker.
			if found_resource.is_found:
				return
			set_destination(found_resource.global_position)
			found_area = found_resource
			action = Action.MOVING
			harvest(found_resource)
		elif area is Base:
			var area_base: Base = area
			resource_locations = area_base.get_all_resource_locations()
			await random_wait()
			var new_dest = area_base.get_closest_required_resource()
			if is_instance_valid(new_dest):
				action = Action.HARVESTING
				destination = new_dest.global_position
	if action == Action.DEPOSITING:
		if area is Base:
			printt(1)
			await random_wait()
			printt(2)
			var base_node: Base = area
			var amount_depoed = 0
			amount_depoed = deposit(base_node)
			if amount_depoed > 0:
				action = Action.HARVESTING
				set_destination(base_node.get_closest_required_resource().global_position)
			else:
				action = Action.PROSPECTING
	if action == Action.MOVING:
		# moving to home checklist:
		# deposit inventory
		# get new destination
		if destination.is_equal_approx(home_base_location):
			if area is Base:
				var home_node: Base = area
				deposit(home_node)
				await random_wait()
				var required_resource = home_node.get_closest_required_resource()
				if is_instance_valid(required_resource):
					destination = required_resource.global_position
		else:
			if area is ResourceArea2D:
				var res: ResourceArea2D = area
				await random_wait()
				harvest(res)
	if action == Action.SCOUTING:
		pass
		#if area is Base:
		#var home_base: Base = area
		#action = home_base.get_new_worker_action(action)
