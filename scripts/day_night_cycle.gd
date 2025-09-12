extends ColorRect

signal day_started
signal night_started

@export var cycle_time := 24.0   # duración del ciclo completo en segundos

# Colores que simulan 24h (24 pasos = 1 "hora" por paso)
var colors := [
	Color(0.2,0.2,0.4,0.5),   # 0h - medianoche
	Color(0.25,0.2,0.35,0.45),
	Color(0.3,0.25,0.3,0.4),
	Color(0.35,0.3,0.25,0.3),
	Color(0.4,0.35,0.25,0.25),
	Color(0.5,0.45,0.3,0.2),
	Color(0.7,0.6,0.3,0.1),
	Color(0.9,0.75,0.4,0.05), # 7h - amanecer
	Color(1.0,0.9,0.6,0.0),   # 8h
	Color(1.0,1.0,0.9,0.0),   # 9h - mañana clara
	Color(1.0,1.0,1.0,0.0),   # 10h - día pleno
	Color(1.0,1.0,1.0,0.0),   # 11h
	Color(1.0,1.0,1.0,0.0),   # 12h
	Color(1.0,0.95,0.85,0.05),# 13h
	Color(0.95,0.8,0.7,0.1),  # 14h
	Color(0.85,0.65,0.55,0.15), # 15h
	Color(0.7,0.5,0.4,0.2),   # 16h - atardecer
	Color(0.5,0.35,0.3,0.3),  # 17h
	Color(0.35,0.25,0.3,0.4), # 18h
	Color(0.25,0.2,0.35,0.45),# 19h - anochecer
	Color(0.2,0.2,0.4,0.5),   # 20h
	Color(0.2,0.2,0.45,0.55), # 21h
	Color(0.2,0.2,0.5,0.6),   # 22h
	Color(0.2,0.2,0.55,0.65)  # 23h
]

var tween: Tween

func _ready() -> void:
	color = colors[0]
	_start_cycle()


func _start_cycle() -> void:
	tween = create_tween().set_loops()

	for i in range(colors.size() - 1):
		var duration := cycle_time / (colors.size() - 1)

		# cuando pasamos a ciertas "horas", disparamos señales
		if i == 7:   # amanecer
			tween.tween_callback(func(): emit_signal("day_started"))
		if i == 19:  # anochecer
			tween.tween_callback(func(): emit_signal("night_started"))

		tween.tween_property(self, "color", colors[i + 1], duration)
