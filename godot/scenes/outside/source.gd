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
		print("player next to %s" % name)

func _on_collect_area_body_exited(body):
	if body.is_in_group("Player"):
		body.unregister_source(self)
		
func start_collecting():
	$Timer.start()
	print("starting collection")
	
func stop_collecting():
	if not $Timer.is_stopped():
		$Timer.stop()
		print(" collection cancelled")

func _on_timer_timeout():
	has_ingridient=false
#	print("%s %s" % [$sprite_on.visible, $sprite_off.visible])
	collection_complete.emit()
	print("collection done")
