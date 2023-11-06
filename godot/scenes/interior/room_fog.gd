class_name RoomFog extends FogVolume

func on_room_entered(player: Node3D):
	visible = false

func on_room_exited():
	visible = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
