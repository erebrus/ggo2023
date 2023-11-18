extends Node3D

@export var target_scene: String 

func travel_to_scene():
	print('travel?')
	get_tree().change_scene_to_file(target_scene)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		travel_to_scene()
