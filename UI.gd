extends Control

func _ready():
	var world = $ViewportContainerMain/Viewport.find_world_2d()
	$ViewportContainer/Viewport.world_2d = world
