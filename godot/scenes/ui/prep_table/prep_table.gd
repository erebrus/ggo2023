extends Control

const itemScene:PackedScene = preload("res://scenes/ui/inventory/inventory_item.tscn")


var hbox:HBoxContainer
var button:Button
func _ready():	
	hbox = $panel/margin/vbox/margin/hbox
	button = $panel/margin/vbox/button
	
	Events.prep_table_updated.connect(update_view)
	update_view()
	
func update_view():
	while hbox.get_child_count() > 0:
		hbox.remove_child(hbox.get_child(0))
	for i in Global.prep_table_items:
		var it:InventoryItem = itemScene.instantiate()
		it.ingridient = i
		hbox.add_child(it)
	match Global.prep_table_items.size():
		1:
			button.text = Global.prep_table_items[0].prepare_action
		2:
			button.text = "Mix"
		_:
			button.text = "Cancel"


func _on_button_pressed():
	Input.action_press("ui_cancel")
