extends Control

var recipe_tex:Texture = preload("res://assets/gfx/ui/written_boards/recipe.png")
var recipe_blurred_tex:Texture = preload("res://assets/gfx/ui/written_boards/recipe_blurred.png")

func _ready():
	Events.haiku_displayed.connect(_on_haiku_displayed)
	Events.haiku_hidden.connect(_on_haiku_hidden)

func _process(_delta):
	if not visible and Input.is_action_just_pressed("recipe"):
		visible=true
		
	elif visible and Input.is_action_just_pressed("ui_cancel"):
		if _is_haiku_visible():
			close_haikus()
		else:
			visible=false

func _on_haiku_displayed():
	$Recipe.texture = recipe_blurred_tex
	
func _on_haiku_hidden():
	$Recipe.texture = recipe_tex

func _is_haiku_visible()->bool:
	for h in $Recipe.get_children():
		if h.is_open():
			return true
	return false	
	
func close_haikus():	
	for h in $Recipe.get_children():
		h.close_haiku()
	Events.haiku_hidden.emit()		

func _on_recipe_gui_input(event):
	if event is InputEventMouseButton and event.pressed:		
		close_haikus()
		

		
