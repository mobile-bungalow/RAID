extends KinematicBody2D

const speed = 110;
const attack_radius = 350;

var vel = Vector2.ZERO;
var dir = Vector2.ZERO;
var target_dir = Vector2.ZERO;
export var dash_offset = 0.0;
export var slice_width = 0.0;
var slice_slope = 1.0;

signal die

var state = Game.MookState.Hunting;
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("enemies")
	randomize();
	slice_slope = randf() - 0.5;
	hunt()

func add_points():
	$NoPos/Blood.points = [position, position, position];

func remove_points():
	$NoPos/Blood.points = [];
	
func shoot_off_frame():
	var dirs = [dir.dot(Vector2.UP), dir.dot(Vector2.DOWN), dir.dot(Vector2.RIGHT), dir.dot(Vector2.LEFT)];
	match dirs.find(dirs.max()):
		-1:
			pass;
		0:
			$AnimatedSprite.frame = 3;
		1:
			$AnimatedSprite.frame = 6;
		2, 3:
			$AnimatedSprite.frame = 1;


func shoot_on_frame():
	var dirs = [dir.dot(Vector2.UP), dir.dot(Vector2.DOWN), dir.dot(Vector2.RIGHT), dir.dot(Vector2.LEFT)];
	match dirs.find(dirs.max()):
		-1:
			pass;
		0:
			$AnimatedSprite.frame = 4;
		1:
			$AnimatedSprite.frame = 7;
		2, 3:
			$AnimatedSprite.frame = 0;

var last_change = 0.0;
func hunt():
	state = Game.MookState.Hunting
	var dirs = [dir.dot(Vector2.UP), dir.dot(Vector2.DOWN), dir.dot(Vector2.RIGHT), dir.dot(Vector2.LEFT)];
	match dirs.find(dirs.max()):
		-1:
			pass;
		0:
			$AnimationPlayer.play("run_cycle_u");
		1:
			$AnimationPlayer.play("run_cycle_d");
		2, 3:
			$AnimationPlayer.play("run_cycle");


func prime():
	state = Game.MookState.Priming

func wait_post_strike():
	state = Game.MookState.PostStrike

const arrow_scn = preload("res://scenes/gameplay/enemies/shoot_mook/arrow.tscn");
func attack():
	var player = Game.get_active_scene().get_node("Player");
	target_dir = (player.position - position)
	$AnimatedSprite.frame = set_attack_frame(target_dir);
	var arrow = arrow_scn.instance();
	arrow.direction = target_dir;
	arrow.position =  ( target_dir.normalized() * 5 ) + position;
	Game.get_active_scene().add_child(arrow);
	state = Game.MookState.Striking
	
func set_attack_frame(dir: Vector2):
	var dirs = [dir.dot(Vector2.UP), dir.dot(Vector2.DOWN), dir.dot(Vector2.RIGHT), dir.dot(Vector2.LEFT)];
	match dirs.find(dirs.max()):
		-1:
			return 3;
		0:
			return 5;
		1:
			return 8;
		2: 
			return 2;
		3:
			return 2;
	pass

func strike():
	$AnimationPlayer.play("die")
	emit_signal("die")
	remove_child($Area2D)
	remove_child($CollisionShape2D)
	state = Game.MookState.Dead

func is_lethal():
	return false;

func approx_unit_vec(dir: Vector2):
	var dirs = [dir.dot(Vector2.UP), dir.dot(Vector2.DOWN), dir.dot(Vector2.RIGHT), dir.dot(Vector2.LEFT)];
	match dirs.find(dirs.max()):
		-1:
			return Vector2.ZERO
		0:
			return Vector2.UP
		1:
			return Vector2.DOWN
		2: 
			$AnimatedSprite.flip_h = false;
			return Vector2.RIGHT
		3:
			$AnimatedSprite.flip_h = true;
			return Vector2.LEFT
	

func _process(delta):
	z_index = int(position.y);
	var player = Game.get_active_scene().get_node("Player");
	if player.state == Game.PlayerState.Dead:
		$AnimationPlayer.stop()
		return
	match state:
		Game.MookState.Dead:
			if len($NoPos/Blood.points) == 3:
				$NoPos/Blood.points[0] = $NoPos/Blood.points[1] + (Vector2(1, 1*slice_slope) * slice_width);
				$NoPos/Blood.points[2] = $NoPos/Blood.points[1] - (Vector2(1, 1*slice_slope) * slice_width);
			pass
		Game.MookState.Hunting:
			if player:
				last_change += delta;
				if last_change > 0.1:
					hunt()
					last_change = 0.0;
				dir = (player.position - position)
				var dom_dir = approx_unit_vec(dir);
				var modifier = speed  if dir.length() < 10 else 0;
				vel = (dir.normalized() + dom_dir * 0.80 ).normalized() * (speed - modifier);
				vel = move_and_slide(vel);	
				if dir.length() < attack_radius:
					$AnimationPlayer.play("attack")
		Game.MookState.Priming:
			pass
		Game.MookState.PostStrike:
			pass
		Game.MookState.Striking:
			pass




