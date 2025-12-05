extends ResourceNode

func _ready() -> void:
	init_resource()


func _on_resource_spawn_timeout() -> void:
	resource_spawn()


func _on_body_entered(body: Node2D) -> void:
	resource_entered(body)
