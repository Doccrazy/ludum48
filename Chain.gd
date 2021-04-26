extends Node2D

var velocity = 0
var length = 0
var speed = 50
var bodies = Array()
var anchor: Node2D = null;
var linkRadius = 5;

onready var linkTemplate: PackedScene = preload("res://ChainLink.tscn")
onready var anchorTemplate: PackedScene = preload("res://ChainAnchor.tscn")
onready var anim: AnimationPlayer = get_node("/root/UI/AnimationPlayer")

func get_input():
	velocity = 0
	if (get_node("/root/Global").gameOver):
		return;
	if Input.is_action_pressed("down"):
		velocity += 1
	if Input.is_action_pressed("up"):
		velocity -= 1

func _physics_process(delta):
	get_input();
	length = max(0, length + velocity*delta*speed);
	updateBodies();
	
func _process(_delta):
	if (is_instance_valid(anchor)):
		get_node("../Camera2D").position = anchor.position;
		get_node("../../Level/BackgroundNoise").volume_db = -25
	else:
		get_node("../Camera2D").position = Vector2(0, 50);
		get_node("../../Level/BackgroundNoise").volume_db = -15

func updateBodies():
	var num = floor(length / (linkRadius*2));
	#var rest = length - num * linkRadius*2;
	while (bodies.size() < num):
		var body = linkTemplate.instance()
		var parentBody = get_parent();
		var p0 = Vector2(0, 0);
		body.position = Vector2(p0.x, p0.y + linkRadius*2)
		body.visible = true
		bodies.push_front(body)
		add_child(body)

		var joint = PinJoint2D.new()
		joint.softness = 0.1;
		joint.node_a = parentBody.get_path()
		joint.node_b = body.get_path();
		body.add_child(joint);
		
		if (bodies.size() > 1):
			var j1 = bodies[1].get_child(2);
			j1.queue_free();
			bodies[1].position = Vector2(bodies[1].position.x, bodies[1].position.y + linkRadius*2)
			j1 = PinJoint2D.new()
			j1.softness = 0.1;
			j1.node_a = body.get_path()
			j1.node_b = bodies[1].get_path();
			bodies[1].add_child(j1);
		else:
			anchor = anchorTemplate.instance();
			anchor.position = Vector2(p0.x, p0.y + linkRadius*5)
			add_child(anchor);
			var j2 = PinJoint2D.new()
			j2.position = Vector2(0, -3)
			j2.softness = 0.1;
			j2.node_a = body.get_path()
			j2.node_b = anchor.get_path();
			anchor.add_child(j2);
			anim.play("In")
	while (bodies.size() > num):
		bodies.pop_front().queue_free();
		if (bodies.size() > 0):
			var j1 = bodies[0].get_child(2);
			j1.queue_free();
			bodies[0].position = Vector2(0, linkRadius*2)
			j1 = PinJoint2D.new()
			j1.softness = 0.1;
			j1.node_a = get_parent().get_path();
			j1.node_b = bodies[0].get_path();
			bodies[0].add_child(j1);
		else:
			anchor.queue_free()
			anim.play("Out")

