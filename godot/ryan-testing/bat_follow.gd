extends Sprite3D

@export var follow_object:Node3D
@export var follow_offset:Vector3
@export var follow_offset_local:bool

@export var target_object:Node3D
@export var target_offset:Vector3
@export var target_offset_local:bool

enum states {FOLLOWING = 0, TARGETING = 1}
var state:states = states.FOLLOWING

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous physics tic.
func _physics_process(delta:float):
	match state:
		states.FOLLOWING:
			move_towards(follow_object.get_position() + (
				(follow_object.quaternion if follow_offset_local else Quaternion.IDENTITY) * follow_offset
				))
		states.TARGETING:
			move_towards(target_object.get_position() + (target_offset))
	
func move_towards(location:Vector3):
	set_position(location)

func switch_to_follow():
	state = states.FOLLOWING
	
func switch_to_target():
	state = states.TARGETING
