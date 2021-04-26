extends RigidBody2D

var crate: RigidBody2D;
var joint: DampedSpringJoint2D;
export (bool) var attached = false;
var nextLoss = 0.0;

func _ready():
	pass # Replace with function body.

#func _process(delta):
#	pass

func _input(event):
	if event.is_action_pressed("jump") && is_instance_valid(crate) && (crate.global_position - global_position).length() < 20:
		print("attach")
		joint = DampedSpringJoint2D.new()
		joint.node_a = self.get_path();
		joint.node_b = crate.get_path();
		joint.length = 10;
		joint.rest_length = 10;
		joint.stiffness = 64.0;
		add_child(joint);
		attached = true
		get_node("/root/UI/Panel2/CrateImage").visible = true
	elif event.is_action_pressed("jump") && is_instance_valid(joint):
		print("detach")
		joint.queue_free()
		attached = false
		get_node("/root/UI/Panel2/CrateImage").visible = false

func _physics_process(delta):
	nextLoss = clamp(nextLoss - delta, 0.0, 0.5)
	for b in get_colliding_bodies():
		if b.collision_mask & 4 > 0 && nextLoss <= 0.0:
			get_node("/root/Global").addPoints(-50)
			$Hit.play();
			nextLoss = 0.5

func _on_Anchor_body_entered(body):
	if body.collision_layer & 32 > 0:
		crate = body;
		print(crate);
