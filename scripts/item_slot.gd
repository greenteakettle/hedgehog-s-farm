# item_slot.gd
extends Control

@onready var icon = $Slot/ItemTexture
@onready var label = $CountLabel
@onready var selection_border = $SelectionBorder 

var my_crop_data: CropData = null 
var count = 0

func _ready():
	if my_crop_data == null:
		visible = false
		count = 0
	if selection_border:
		selection_border.visible = false

func update_slot_with_data(data: CropData, new_count: int):
	my_crop_data = data
	count = new_count
	
	if count == 0 or data == null:
		my_crop_data = null
		$CountLabel.visible = false
		label.text = str(count)
		icon.texture = null
		visible = true
	else:
		icon.texture = data.inventory_icon
		$CountLabel.visible = true
		label.text = str(count)
		visible = true
		
		if count > 1:
			label.visible = true  # Показываем, если 2, 3...
		else:
			label.visible = false # Прячем, если 1		

func set_selected(is_selected: bool):
	if selection_border:
		selection_border.visible = is_selected
