extends Area2D

@onready var resource_node: ResourceNode = $ResourceNode


func _ready() -> void:
	resource_node.init_resource()


func _on_resource_spawn_timeout() -> void:
	resource_node.regen()


func _on_body_entered(body: Node2D) -> void:
	resource_node.on_enter(body)


func _on_body_exited(body: Node2D) -> void:
	resource_node.on_exit(body)
