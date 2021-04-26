extends StaticBody2D

onready var crateTemplate = preload("res://Crate.tscn");
export (Array) var crates = Array()
var MAX_COUNT = 10;

func spawn():
	var crate = crateTemplate.instance();
	crate.position = Vector2(rand_range(150, 1750), 250);
	if (crate.position.x - get_node("../Player").position.x) < 400:
		return;
	add_child(crate);
	move_child(crate, 0);
	crate.connect("collect", self, "onCrateCollected");
	crates.append(crate)

func _process(delta):
	pass

func onCrateCollected(crate):
	crates.erase(crate)
	$CollectSound.play()
	get_node("/root/UI/Panel2/CrateImage").visible = false

func _on_Timer_timeout():
	if (crates.size() < MAX_COUNT):
		spawn();
