extends RigidBody2D

signal collect;
var player: RigidBody2D;
var maxDepth = 0;

var COLLECT_DIST = 75;

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("/root/UI/ViewportContainerMain/Viewport/Game/Player");

func collect():
	get_node("/root/Global").addPoints(floor(maxDepth/75.0)*50);
	emit_signal("collect", self)
	queue_free();

func _physics_process(delta):
	maxDepth = max(maxDepth, position.y)
	if (player.global_position - global_position).length() < COLLECT_DIST:
		collect();
