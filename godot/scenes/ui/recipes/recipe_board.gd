extends Control

var recipe_tex:Texture = preload("res://assets/gfx/ui/written_boards/recipe.png")
var recipe_blurred_tex:Texture = preload("res://assets/gfx/ui/written_boards/recipe_blurred.png")

func _ready():
	Events.haiku_displayed.connect(_on_haiku_displayed)
	Events.haiku_hidden.connect(_on_haiku_hidden)

func _on_haiku_displayed():
	$Recipe.texture = recipe_blurred_tex
	
func _on_haiku_hidden():
	$Recipe.texture = recipe_tex
	
func _on_recipe_gui_input(event):
	if event is InputEventMouseButton and event.pressed:		
		for h in $Recipe.get_children():
			h.close_haiku()
		Events.haiku_hidden.emit()
