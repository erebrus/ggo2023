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

func _process(_delta):

	if visible:
		if Input.is_action_just_pressed("ui_accept"):
			_on_button_pressed()
		if Input.is_action_just_pressed("ui_cancel"):
			close()
			
func _on_button_pressed():
	match Global.prep_table_items.size():
		1:
			prepare_ingridient(Global.prep_table_items[0])
		2:
			mix_ingridients(Global.prep_table_items[0],Global.prep_table_items[1])	
		_:
			close()
	
func mix_ingridients(i1:Ingridient, i2:Ingridient):
	var prep_i = Global.find_mix_ingridient([i1,i2])
	Global.prep_table_items.clear()
	if prep_i != null:
		Global.prep_table_items.append(prep_i)	
	else:
		Global.show_message("Wrong ingridients")
	close()
	
func prepare_ingridient(i:Ingridient):
	if i.prepared_ingridient!=null:
		Global.prep_table_items=[i.prepared_ingridient]
		Global.show_message("prepared %s" % Global.prep_table_items[0].name)
	else:
		Global.prep_table_items.clear()
		Global.show_message("wrong ingridient")
	close()
		
func close():
	visible = false
	Events.prep_table_close_requested.emit()
