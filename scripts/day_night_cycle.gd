extends ColorRect

@export var day_duration := 60.0      
@export var night_duration := 60.0    
@export var transition_time := 10.0    

var day_color := Color(0, 0, 0, 0)       
var night_color := Color(0, 0, 0, 0.7)    

var timer := 0.0
var phase := "day"  # puede ser: day, to_night, night, to_day

func _process(delta: float) -> void:
	timer += delta

	match phase:
		"day":
			color = day_color
			if timer >= day_duration:
				phase = "to_night"
				timer = 0

		"to_night":
			var alpha = lerp(day_color.a, night_color.a, timer / transition_time)
			color = Color(0, 0, 0, alpha)   # ← reasignamos el color completo
			if timer >= transition_time:
				phase = "night"
				timer = 0

		"night":
			color = night_color
			if timer >= night_duration:
				phase = "to_day"
				timer = 0

		"to_day":
			var alpha = lerp(night_color.a, day_color.a, timer / transition_time)
			color = Color(0, 0, 0, alpha)   # ← reasignamos el color completo
			if timer >= transition_time:
				phase = "day"
				timer = 0
