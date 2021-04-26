extends RigidBody2D

export (int) var speedForward = 1500
export (int) var speedBack = 500
var nextPing = 3.0;

var velocity = Vector2()

func get_input():
	velocity = Vector2()
	if (get_node("/root/Global").gameOver):
		return;
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1

	#var anchor = get_node("Chain/Anchor");
	#if !(is_instance_valid(anchor) && anchor.attached):
	#	scale = Vector2(velocity.x if abs(velocity.x) > 0 else scale.x, 1)

	velocity = velocity.normalized() * speedForward

func _process(delta):
	var crates = get_node("../Level").crates;
	var dist = 10000.0;
	for crate in crates:
		dist = min(dist, abs(crate.position.x - position.x));
	var factor = clamp(5.0 - (dist/100.0), 1.0, 5.0)
	nextPing -= delta*factor
	if (nextPing < 0):
		nextPing = 3.0;
		$SonarPing.play()

func _physics_process(_delta):
	applied_force = Vector2();
	applied_torque = 0;
	#scale = Vector2(-1, 1);
	get_input()
	add_central_force(velocity);
	get_node("/root/UI/ViewportContainer/Viewport/MiniCamera").position = position;
