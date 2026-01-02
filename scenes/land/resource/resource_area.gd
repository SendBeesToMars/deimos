# should this class even exist????
class_name ResourceArea2D
extends Area2D

@export var res: ResourceNode
@export var resource_name: String = ""
@onready var sprite: = $CollisionShape2D/Sprite2D as Sprite2D
@export var growth_rate: float
@export var initial_val: float
@export var max_capacity: float
@export var can_deplete: bool = false
@export var is_found: bool = false


func _ready() -> void:
	res.resource_name = resource_name
	res.initial_val = initial_val
	res.resource_rate = growth_rate
	res.capacity = max_capacity
	res.can_deplete = can_deplete
	res.init_resource()
	sprite.rotate(randf() * 5)


func _on_resource_spawn_timeout() -> void:
	res.regen()


func _on_body_entered(body: Node2D) -> void:
	res.on_enter(body)


func _on_body_exited(body: Node2D) -> void:
	res.on_exit(body)


func harvest(inventory_cap: int) -> int:
	return res.harvest(inventory_cap)


func get_resource_name() -> String:
	return resource_name


func found():
	modulate = Color.AQUAMARINE
