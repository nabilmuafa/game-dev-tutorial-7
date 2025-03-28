extends Area3D

@export var sceneName := "Level 1"

func _on_body_entered(body: Node3D) -> void:
	if body.get_name() == "Player":
		if sceneName == "Level 1":
			$"../AudioStreamPlayer3D".play()
			await $"../AudioStreamPlayer3D".finished  # Wait for sound to finish before transitioning
		call_deferred("change_scene")  # Defer the scene change

func change_scene():
	get_tree().change_scene_to_file("res://scenes/" + sceneName + ".tscn")
