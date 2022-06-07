extends Node

var elapsed = 0
var mookspawner: spawner = spawner.new()
var basic_mook_scene = preload("res://scenes/gameplay/enemies/mook/mook.tscn");
var shoot_mook_scene = preload("res://scenes/gameplay/enemies/shoot_mook/shoot_mook.tscn");
var game_over_screen = preload("res://scenes/gameplay/death_screen/death_overlay.tscn");
var smoke = preload("res://scenes/gameplay/smoku.tscn");
var elapsed_since_last_kill = 0.0;
var kill_count = 0;
var combo_count = 0;
var score = 0;
var max_combo = 0;

func spawn():
	var size = get_viewport().size;
	var pos = { x = randf()  * size.x, y = randf() * size.y };
	var instance =  basic_mook_scene.instance() if randf() < 0.85 else shoot_mook_scene.instance()
	instance.connect("die", self, "kill_mook");
	instance.position.x = pos.x;
	instance.position.y = pos.y;
	var smoku = smoke.instance();
	smoku.position = instance.position;
	self.add_child(smoku);
	self.add_child(instance);
	mookspawner.inc_alive();

func update_score():
	kill_count += 1;
	combo_count += 1;
	score += 100 * combo_count;
	$Control/ScoreLabel.set_text(str("Score   ", score));
	$Control/ComboLabel.set_text(str("Combo    ", combo_count, "X"));
	max_combo = max(max_combo, combo_count);
	

func kill_mook():
	elapsed_since_last_kill = 0.0;
	update_score();
	mookspawner.kill_one();
	

class spawner:
	var is_new: bool = false;
	var max_alive: int = 5;
	var max_spawn_rate: float = 2.0; # one every few seconds
	var last_spawn: float = 0.0;
	var next_spawn: float = 3.0;
	var num_alive: int = 0; 
	var challenge_ramp: float = 8.0; # every 8 seconds ramp till level 10
	
	func _init():
		randomize();
		pass
	
	func inc_alive():
		num_alive += 1;
	
	func kill_one():
		num_alive -= 1	
	
	func time_to_spawn(delta: float, game: SceneTree):
		last_spawn += delta;
		challenge_ramp -= delta;
		if challenge_ramp <= 0.0:
			max_alive = min(max_alive + 1, 18);
			challenge_ramp = 8.0
			max_spawn_rate = max(0.5, max_spawn_rate - 0.3)
		if num_alive < max_alive && last_spawn > next_spawn:
			last_spawn = 0;
			next_spawn = max_spawn_rate * randf();
			return true;
		return false

# `pre_start()` is called when a scene is loaded.
# Use this function to receive params from `Game.change_scene(params)`.
func pre_start(params):
	$Player.position = Game.size / 2
	set_process(false)

func reset():
	mookspawner = spawner.new()
	var size = get_viewport().size;
	$Player.state = Game.PlayerState.Alive;
	$Player.position = size / 2.0;
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free();
	for overlay in get_tree().get_nodes_in_group("overlay"):
		overlay.queue_free();
# `start()` is called when the graphic transition ends.
func start():
	print("\ngameplay.gd:start() called")
	var active_scene: Node = Game.get_active_scene()
	print("\nCurrent active scene is: ",
		active_scene.name, " (", active_scene.filename, ")")
	set_process(true)

func game_over():
	var cf = game_over_screen.instance();
	add_child(cf);
	move_child(cf, 0);

func _process(delta):
	$Player.input()
	elapsed_since_last_kill += delta;
	if elapsed_since_last_kill > 1.5:
		$Control/ComboLabel.set_text(str("Combo   ", combo_count, "X"));
		combo_count = 0;
	if $Player.state != Game.PlayerState.Dead && mookspawner.time_to_spawn(delta, get_tree()):
		spawn()
	
