extends KinematicBody2D

var state = Game.PlayerState.Alive;
export var dash_offset = 0.0;
var direction: Vector2 = Vector2.ZERO;
const speed: int = 3000;
var velocity: Vector2 = Vector2.ZERO;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func attack():
	$AnimatedSprite.frame = set_attack_frame(direction);
	state = Game.PlayerState.Dashing;

func stop_attacking():
	state = Game.PlayerState.Alive;
	can_dash = false;
	dash_cd = 0.25

func set_attack_frame(dir: Vector2):
	var dirs = [dir.dot(Vector2.UP), dir.dot(Vector2.DOWN), dir.dot(Vector2.RIGHT), dir.dot(Vector2.LEFT)];
	match dirs.find(dirs.max()):
		-1:
			return 8;
		0:
			return 3;
		1:
			return 21;
		2: 
			$AnimatedSprite.flip_h = false;
			return 1;
		3:
			$AnimatedSprite.flip_h = true;
			return 1;
	pass

func set_run_animation(dir: Vector2):
	if direction.length() < 0.03:
		$AnimatedSprite.frame = 6;
		return;
	var dirs = [dir.dot(Vector2.UP), dir.dot(Vector2.DOWN), dir.dot(Vector2.RIGHT), dir.dot(Vector2.LEFT)];
	match dirs.find(dirs.max()):
		-1:
			pass
		0:
			$AnimationPlayer.play("run_cycle_v")
		1:
			$AnimationPlayer.play("run_cycle_d")
		2: 
			$AnimatedSprite.flip_h = false;
			$AnimationPlayer.play("run_cycle_h")
			pass
		3:
			$AnimatedSprite.flip_h = true;
			$AnimationPlayer.play("run_cycle_h")
			pass

func input():
	if state == Game.PlayerState.Dead:
		return
	if state == Game.PlayerState.Dashing:
		return

	if ((get_viewport().get_mouse_position() - position).length() > 50):
		direction = (get_viewport().get_mouse_position() - position).normalized()
	else:
		direction = Vector2.ZERO	

	if Input.is_action_just_pressed("dash") && can_dash:
		dash_target = get_viewport().get_mouse_position()
		direction = (dash_target - position);
		attack()
		$AnimationPlayer.play("strike")
		$NoPos/StrikePlayer.play("strike")

func die():
	z_index = position.y
	$AnimationPlayer.play("die")
	state = Game.PlayerState.Dead

var inertia = 1.20;
var can_dash = true;
var dash_time = 0.0;
var dash_cd = 0.0;
var dash_target = Vector2.ZERO;
var game_stopped = false;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if 	$NoPos/StrikeTrail.default_color.a == 0.0: 
		$NoPos/StrikeTrail.clear_points();
	match state:
		Game.PlayerState.Dead:
				get_parent().game_over()
		Game.PlayerState.Alive:
			set_run_animation(direction);
			velocity += direction.normalized() * speed * delta; 
			velocity = move_and_slide(velocity)
			velocity /= inertia;
			velocity.x = clamp(velocity.x, -450, 450);
			velocity.y = clamp(velocity.y, -450, 450);
			if dash_cd > 0:
				dash_cd -= delta;
			else:
				can_dash = true;
				dash_cd = 0;
		Game.PlayerState.Dashing:
			$NoPos/StrikeTrail.add_point(global_position)
			move_and_slide(direction.normalized() * dash_offset)


func _on_Area2D_area_entered(area):
	if state == Game.PlayerState.Dead:
		return;
	var collision_node = area.get_parent()
	if state == Game.PlayerState.Dashing:
		collision_node.strike()
	elif collision_node.is_lethal():
		die()



