extends VBoxContainer



func _on_BombSlider_value_changed(value):
	get_node("BombOptions/numericalValue").text = String(int(value*100))+"%"


func _on_HeightSlider_value_changed(value):
	get_node("HeightOptions/numericalValue").text = String(value)


func _on_WidthSlider_value_changed(value):
	get_node("WidthOptions/numericalValue").text = String(value)
