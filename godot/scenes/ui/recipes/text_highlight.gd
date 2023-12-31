extends ColorRect

var has_mouse:bool = false
var enabled:bool = true:
	set(val):
		enabled=val
		mouse_default_cursor_shape=Control.CURSOR_ARROW if not val else Control.CURSOR_POINTING_HAND
		$crossed.visible = not val
@export var ingridient:Ingridient
var panel:TextureRect 

		


func _ready():
	
#	crossed_out = not enabled
	panel = TextureRect.new()
	panel.texture = ingridient.written_board_png
	panel.visible = false
	panel.z_index=10
	add_child(panel)
	Events.pot_updated.connect(_on_pot_updated)
	_on_pot_updated()
	
func _on_pot_updated():
	enabled = not Global.is_ingridient_found(ingridient)		

func _on_mouse_entered():
	has_mouse = true


func _on_mouse_exited():
	has_mouse = true
	
	


func _on_gui_input(event):
	if panel.visible: 
		if event is InputEventMouseButton and event.pressed:
			close_haiku()
			Events.haiku_hidden.emit()
	else:
		if not has_mouse or not enabled:
			return
		if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
				open_haiku()
				Events.haiku_displayed.emit()

func is_open():
	return panel.visible

func close_haiku():
	panel.visible=false
	
func open_haiku():
	var size = panel.texture.get_size()
	panel.global_position = get_global_mouse_position()-size/2.0
	panel.visible=true
	
	
	
	
