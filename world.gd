extends Node2D

#@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
#@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
@onready var level_completed = $CanvasLayer/LevelCompleted
# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
#	polygon_2d.polygon = collision_polygon_2d.polygon
	Events.level_completed.connect(show_level_completed)

func show_level_completed():
	print('show')
	level_completed.show()
	get_tree().paused = true
