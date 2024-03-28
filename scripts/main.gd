extends Node

const INITIAL_VIEWPORT_SIZE = Vector2(1152, 648)
const GAME_SIZE = 250000 # half of the width
const CHUNK_SIZE = 500
const ASTEROID_SPAWNING_CHUNK_SiZE = CHUNK_SIZE * 0.9
const ALIEN_SPAWNING_CHUNK_SiZE = CHUNK_SIZE
const ASTEROID_PROBABILITY = 0.5
const ALIEN_PROBABILITY = 0.8
const BORDER_DAMAGE = 2
const MOVED_TIMING = 60
const MAX_RENDER_AMOUNT = 4
const QUIT_TIME = 0.1

@export var ship_scene: PackedScene
@export var asteroid_scene: PackedScene
@export var alien_scene: PackedScene
@export var ui_scene: PackedScene

var WORLD_INSTANTIATED = false
var WORLD_CREATED = false
var LOADING_WORLD = false
var X = -GAME_SIZE
var Y = -GAME_SIZE
var PARTICLES = true
var MOVED_OBJECTS = []
var MOVED_TIMINGS = []
var MOVED_TYPES = []
var SHIP_DIED = false
var ALIEN_TEAMS = []

var ship
var quit = false
var quit_timer = 0
var exited_areas = []

var loaded_chunks = []

func _ready():
	var ui = ui_scene.instantiate()
	add_child(ui)

func _physics_process(delta):
	if quit:
		quit_timer += delta
		if quit_timer >= QUIT_TIME:
			reset()
	if Input.is_action_just_pressed("particles"):
		PARTICLES = !PARTICLES
		
	if WORLD_CREATED && !WORLD_INSTANTIATED:
		LOADING_WORLD = false
		respawn_ship()
		LOADING_WORLD = true
		WORLD_INSTANTIATED = true
	
#	if WORLD_CREATED && !WORLD_INSTANTIATED:
#		LOADING_WORLD = true
#
#		for i in range(0, MAX_RENDER_AMOUNT):
#			if X >= GAME_SIZE and Y >= GAME_SIZE:
#				WORLD_INSTANTIATED = true
#				LOADING_WORLD = false
#				respawn_ship()
#
#			if X < GAME_SIZE:
#				X += CHUNK_SIZE
#			else:
#				X = -GAME_SIZE
#				if Y < GAME_SIZE:
#					Y += CHUNK_SIZE
#				else:
#					Y = -GAME_SIZE
#			if !(X == 0 and Y == 0):
#				var asteroid = create_asteroid(X, Y)
#				if !asteroid:
#					create_alien(X, Y)
	
	if WORLD_CREATED:
		if is_instance_valid(ship):
			var current_chunk = floor((ship.position - Vector2.ONE * CHUNK_SIZE / 2) / CHUNK_SIZE) + Vector2.ONE
			for y in range(-MAX_RENDER_AMOUNT + current_chunk.y, MAX_RENDER_AMOUNT + current_chunk.y):
				for x in range(-MAX_RENDER_AMOUNT + current_chunk.x, MAX_RENDER_AMOUNT + current_chunk.x):
					if !(x == 0 and y == 0) and !loaded_chunks.has([x, y]):
						var asteroid = create_asteroid(x * CHUNK_SIZE, y * CHUNK_SIZE)
						if !asteroid:
							create_alien(x * CHUNK_SIZE, y * CHUNK_SIZE)
						loaded_chunks.append([x, y])
		
		for area in exited_areas:
			if is_instance_valid(area):
				if area.is_in_group("items"):
					area.queue_free()
				else:
					if area.is_in_group("aliens"):
						area.health -= area.STATS.max_health / BORDER_DAMAGE * delta
					else:
						area.health -= area.MAX_HEALTH / BORDER_DAMAGE * delta
		
		for i in range(0, MOVED_OBJECTS.size()):
			if MOVED_TIMINGS[i] > 0:
				MOVED_TIMINGS[i] -= delta
			else:
				if MOVED_TYPES[i] == 'asteroid':
					var asteroid = asteroid_scene.instantiate()
					asteroid.position = MOVED_OBJECTS[i]
					asteroid.rotation = randf_range(0, 360)
					add_child(asteroid)
				elif MOVED_TYPES[i] == 'alien':
					var alien = alien_scene.instantiate()
					alien.position = MOVED_OBJECTS[i]
					add_child(alien)
				MOVED_OBJECTS[i] = null
				MOVED_TIMINGS[i] = null
				MOVED_TYPES[i] = null
		
		MOVED_OBJECTS = MOVED_OBJECTS.filter(func(elem): return elem != null)
		MOVED_TIMINGS = MOVED_TIMINGS.filter(func(elem): return elem != null)

func create_asteroid(x, y):
	var asteroid_probability = randf_range(0, 1) < ASTEROID_PROBABILITY
	if asteroid_probability:
		var asteroid = asteroid_scene.instantiate()
		var x1_clamp = clamp(x - ASTEROID_SPAWNING_CHUNK_SiZE / 2, -GAME_SIZE, GAME_SIZE)
		var x2_clamp = clamp(x + ASTEROID_SPAWNING_CHUNK_SiZE / 2, -GAME_SIZE, GAME_SIZE)
		var y1_clamp = clamp(y - ASTEROID_SPAWNING_CHUNK_SiZE / 2, -GAME_SIZE, GAME_SIZE)
		var y2_clamp = clamp(y + ASTEROID_SPAWNING_CHUNK_SiZE / 2, -GAME_SIZE, GAME_SIZE)
		var x1 = x - ASTEROID_SPAWNING_CHUNK_SiZE / 2
		var x2 = x + ASTEROID_SPAWNING_CHUNK_SiZE / 2
		var y1 = y - ASTEROID_SPAWNING_CHUNK_SiZE / 2
		var y2 = y + ASTEROID_SPAWNING_CHUNK_SiZE / 2
		var randX = randf_range(x1, x2)
		var randY = randf_range(y1, y2)
		asteroid.position = Vector2(randX, randY)
		asteroid.rotation = randf_range(0, 360)
		add_child(asteroid)
		if x1 != x1_clamp or x2 != x2_clamp or y1 != y1_clamp or y2 != y2_clamp:
			asteroid.queue_free()
			return null
		return asteroid
	return null

func create_alien(x, y):
	var alien_probability = randf_range(0, 1) < ALIEN_PROBABILITY
	if alien_probability:
		var alien = alien_scene.instantiate()
		ALIEN_TEAMS.append(alien)
		var x1_clamp = clamp(x - ALIEN_SPAWNING_CHUNK_SiZE / 2, -GAME_SIZE, GAME_SIZE)
		var x2_clamp = clamp(x + ALIEN_SPAWNING_CHUNK_SiZE / 2, -GAME_SIZE, GAME_SIZE)
		var y1_clamp = clamp(y - ALIEN_SPAWNING_CHUNK_SiZE / 2, -GAME_SIZE, GAME_SIZE)
		var y2_clamp = clamp(y + ALIEN_SPAWNING_CHUNK_SiZE / 2, -GAME_SIZE, GAME_SIZE)
		var x1 = x - ALIEN_SPAWNING_CHUNK_SiZE / 2
		var x2 = x + ALIEN_SPAWNING_CHUNK_SiZE / 2
		var y1 = y - ALIEN_SPAWNING_CHUNK_SiZE / 2
		var y2 = y + ALIEN_SPAWNING_CHUNK_SiZE / 2
		var randX = randf_range(x1, x2)
		var randY = randf_range(y1, y2)
		alien.position = Vector2(randX, randY)
		alien.rotation = randf_range(0, 360)
		alien.ORIGINAL_POSITION = alien.position
		add_child(alien)
		if x1 != x1_clamp or x2 != x2_clamp or y1 != y1_clamp or y2 != y2_clamp:
			alien.queue_free()
			return null
		return alien
	return null

func reset():
	get_tree().reload_current_scene()
	
func create_new_world():
	WORLD_CREATED = true

func respawn_ship():
	if is_instance_valid(ship):
		ship.queue_free()
	
	SHIP_DIED = false
	
	ship = ship_scene.instantiate()
	add_child(ship)

func _on_game_border_area_entered(area):
	if area.is_in_group("asteroids") or area.is_in_group("ships") or area.is_in_group("aliens") or area.is_in_group("items"):
		exited_areas.erase(area)

func _on_game_border_area_exited(area):
	if area.is_in_group("asteroids") or area.is_in_group("ships") or area.is_in_group("aliens") or area.is_in_group("items"):
		exited_areas.append(area)
