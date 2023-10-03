extends Node2D

@export var next_level: PackedScene
#@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
#@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
@onready var level_completed = $CanvasLayer/LevelCompleted
# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
#	polygon_2d.polygon = collision_polygon_2d.polygon
	Events.level_completed.connect(show_level_completed)

func show_level_completed():
	level_completed.show()
	get_tree().paused = true
	if not next_level is PackedScene: return
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	LevelTransition.fade_from_black()
	
