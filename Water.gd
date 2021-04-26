extends Area2D

export (Texture) var texture;
export (Color) var color;
export (Texture) var currents;

var t = 0;
var intensity = 2.0;
var currentStrength = 100.0;
var player: RigidBody2D;
var anchor: RigidBody2D;
var points: PoolVector2Array;
var uvs: PoolVector2Array;
var affectedByCurrents = Array();

onready var collider = $CollisionShape2D;
var currentsImage: Image;

func _ready():
	$Particles2D.process_material.set_shader_param("width", $CollisionShape2D.shape.extents.x);
	$Particles2D.process_material.set_shader_param("height", $CollisionShape2D.shape.extents.y);
	$Particles2D.visibility_rect = Rect2(-$CollisionShape2D.shape.extents, $CollisionShape2D.shape.extents*2)
	yield(currents, "changed");
	currentsImage = currents.get_data();
	points = PoolVector2Array()
	points.resize(collider.shape.extents.x * 2 + 4)
	uvs = PoolVector2Array()
	uvs.resize(collider.shape.extents.x * 2 + 4)
	for i in range(points.size()):
		points[i] = Vector2()
		uvs[i] = Vector2()

func updatePoly(start, end):
	var height = end.y - start.y;
	var width = end.x - start.x;
	points[0] = start
	uvs[0] = Vector2(0, 0)

	for i in range(width + 1):
		var dist = 0.9*i/width + 0.1;
		var wave1 = sin(t*2 + i/10.0)*3*dist*intensity;
		var wave2 = sin(t*5 + i/7.0)*1*dist*intensity;
		var wave3 = sin(t*3 + i/2.0)*0.5*dist*intensity;
		var wave4 = sin(-t*7 + i/1.5)*0.25*dist*intensity;
		var wave = wave1 + wave2 + wave3 + wave4;
		points[i+1].x = start.x + i
		points[i+1].y = start.y + wave
		uvs[i+1].x = i/width
		uvs[i+1].y = wave/height
	points[width+2] = end
	uvs[width+2] = Vector2(1, 1)
	points[width+3] = Vector2(start.x, end.y)
	uvs[width+3] = Vector2(0, 1)

func drawPoly(fillColor):
	var colors = PoolColorArray([fillColor])
	draw_polygon(points, colors, uvs, texture)
	
func _draw():
	drawPoly(color)

func _process(delta):
	t += delta;
	updatePoly(collider.position - collider.shape.extents, collider.position + collider.shape.extents)
	update();

func _physics_process(delta):
	if (player != null):
		floatPlayer(delta);
	applyCurrents(delta);
		
func getCurrentAt(p: Vector2):
	var pos = collider.to_local(p);
	var uv = Vector2(clamp((1.0 + pos.x / collider.shape.extents.x) / 2.0, 0.0, 1.0),
		clamp((1.0 + pos.y / collider.shape.extents.y) / 2.0, 0.0, 1.0))
	currentsImage.lock();
	var col = currentsImage.get_pixelv(uv * currentsImage.get_size());
	currentsImage.unlock();
	return col.r * 2.0 - 1.0;

func applyCurrents(delta):
	for body in affectedByCurrents:
		var bodyCurrent = getCurrentAt(body.global_position);
		body.apply_impulse(Vector2(), Vector2(bodyCurrent*delta*currentStrength*body.mass, 0));
	
	#var playerCurrent = getCurrentAt(player.global_position);
	#player.apply_impulse(Vector2(), Vector2(playerCurrent*delta*200.0, 0));
	#if (anchor):
	#	var anchorCurrent = getCurrentAt(anchor.global_position);
	#	print(anchorCurrent);
	#	anchor.apply_impulse(Vector2(), Vector2(anchorCurrent*delta*100.0, 0));

func floatPlayer(delta):
	for p in points:
		if abs(p.x - player.position.x) < 15:
			var depth = p.y - player.position.y - 10;
			var dx = (p.x - player.position.x)*sin(player.rotation)*7.0;
			if (depth < 0):
				player.apply_impulse(player.position - p, Vector2(0, depth + dx)*delta*20)

func _on_Area2D_body_entered(body):
	if (body.collision_layer & 512 > 0):
		player = body;
	if (body.collision_layer & 1024 > 0):
		affectedByCurrents.append(body);

func _on_Area2D_body_exited(body):
	if (body.collision_layer & 512 > 0):
		player = null;
	if (body.collision_layer & 1024 > 0):
		affectedByCurrents.erase(body);
