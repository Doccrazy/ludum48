extends Node2D

export (int) var points = 0;
var time = 5*60.0;
export (bool) var gameOver = false;

func addPoints(amount: int):
	points += amount;
	get_node("/root/UI/Panel/ScoreLabel").text = "Score: %d" % [points]

func _process(delta):
	time = max(time - delta, 0.0);
	if (time <= 5*60.0-5):
		get_node("/root/UI/IntroScreen").visible = false;
	if (time <= 0):
		gameOver = true;
		get_node("/root/UI/GameOverScreen/Label").text = "Thank You For Playing!\n\nYour Score: %d" % [points];
		get_node("/root/UI/GameOverScreen").visible = true;
	get_node("/root/UI/Panel3/TimeLabel").text = "Time: %d:%02d" % [floor(time/60.0), int(floor(time)) % 60]
