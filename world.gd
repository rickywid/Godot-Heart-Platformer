extends Node2D

@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D

# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	polygon_2d.polygon = collision_polygon_2d.polygon

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
