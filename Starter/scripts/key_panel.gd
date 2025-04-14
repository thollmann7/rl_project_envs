extends Panel

func _ready():
	var style_box = StyleBoxFlat.new()
	style_box.set_border_width_all(2)
	style_box.border_color = Color(255, 255, 0, 255)
	style_box.bg_color = Color(255, 255, 0, 0)
	add_theme_stylebox_override("panel", style_box)

func set_filled(b):
	var style_box = get_theme_stylebox("panel") as StyleBoxFlat

	if b: # if filled
		style_box.bg_color = Color(255, 255, 0, 255)
	else:
		style_box.bg_color = Color(255, 255, 0, 0)
