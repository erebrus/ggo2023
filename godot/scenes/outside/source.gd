extends Node3D
class_name Source
signal collection_complete

var has_ingridient:= true:
	set(val):
		has_ingridient = val
		$sprite_on.visible = val
		$sprite_off.visible = not val
@export var ingridient:Ingridient

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(ingridient)
	has_ingridient=true
	$Timer.wait_time = ingridient.collect_time



func _on_collect_area_body_entered(body):
	if body.is_in_group("Player"):
		body.register_source(self)

func _on_collect_area_body_exited(body):
	if body.is_in_group("Player"):
		body.unregister_source(self)
		
func start_collecting():
	$Timer.start()
	
func stop_collecting():
	$Timer.cancel()

func _on_timer_timeout():
	has_ingridient=false
	collection_complete.emit()
