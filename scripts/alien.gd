extends Area2D

const MOVEMENT_RATE = 1
const LERP_CONSTANT = 0.1
const MIN_STROLL_SPEED = 1
var DEAD = false

# Shooter
const SHOOTER_STATS = {
	"stroll_pull_factor": 0.5,
	"target_pull_factor": 1.2,
	"move_speed": 5,
	"energy_regen": 2,
	"max_health": 45,
	"bullet_locations": [Vector2(64, 0), Vector2(35, -45), Vector2(35, 45)],
	"bullet_damages": [10, 7, 7],
	"bullet_speeds": [1000, 600, 600],
	"bullet_rotations": [deg_to_rad(0), deg_to_rad(-45), deg_to_rad(45)],
	"scale": 0.6,
	"probability": 1,
	"mass": 100,
	"drops": [5, 8],
	"calm": "shooter_calm",
	"angry": "shooter_angry",
	"recoil": false
}

# Racer
const RACER_STATS = {
	"stroll_pull_factor": 0.4,
	"target_pull_factor": 0.6,
	"move_speed": 5,
	"energy_regen": 2,
	"max_health": 100,
	"bullet_locations": [Vector2(-55, 0), Vector2(50, 15), Vector2(50, -15), Vector2(40, 30), Vector2(40, -30)],
	"bullet_damages": [20, 5, 5, 5, 5],
	"bullet_speeds": [1750, 1500, 1500, 1500, 1500],
	"bullet_rotations": [deg_to_rad(180), deg_to_rad(0), deg_to_rad(0), deg_to_rad(0), deg_to_rad(0)],
	"scale": 0.5,
	"probability": 0.8,
	"mass": 250,
	"drops": [0, 1, 2, 3],
	"calm": "racer_calm",
	"angry": "racer_angry",
	"recoil": true
}

# Spread
const SPREAD_STATS = {
	"stroll_pull_factor": 0.8,
	"target_pull_factor": 1,
	"move_speed": 5,
	"energy_regen": 2,
	"max_health": 100,
	"bullet_locations": [Vector2(64, 0), Vector2(32, -32), Vector2(0, -64), Vector2(-32, -32), Vector2(-64, 0), Vector2(-32, 32), Vector2(0, 64), Vector2(32, 32)],
	"bullet_damages": [10, 10, 10, 10, 10, 10, 10, 10],
	"bullet_speeds": [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000],
	"bullet_rotations": [deg_to_rad(0), deg_to_rad(-45), deg_to_rad(-90), deg_to_rad(-135), deg_to_rad(180), deg_to_rad(135), deg_to_rad(90), deg_to_rad(40)],
	"scale": 0.75,
	"probability": 0.6,
	"mass": 500,
	"drops": [0, 1, 2, 3],
	"calm": "spread_calm",
	"angry": "spread_angry",
	"recoil": false
}

## Normal Alien
#const NORMAL_STROLL_PULL_FACTOR = 0.1
#const NORMAL_TARGET_PULL_FACTOR = 0.25
#const NORMAL_MOVE_SPEED = 5
#const NORMAL_ENERGY_REGEN = 2
#const NORMAL_MAX_HEALTH = 45
#const NORMAL_BULLET_LOCATIONS = [Vector2(8, 8), Vector2(-8, 8), Vector2(-8, -8), Vector2(8, -8)]
#const NORMAL_BULLET_DAMAGES = [7.5, 7.5, 7.5, 7.5]
#const NORMAL_BULLET_SPEEDS = [600, 600, 600, 600]
#const NORMAL_BULLET_ROTATIONS = [deg_to_rad(45), deg_to_rad(135), deg_to_rad(225), deg_to_rad(315)]
#const NORMAL_SCALE = 2.5
#const NORMAL_PROBABILITY = 0.8
#const NORMAL_MASS = 100
#const NORMAL_DROPS = [5, 8]
## Small Boss
#const SMALL_BOSS_STROLL_PULL_FACTOR = 0.25
#const SMALL_BOSS_TARGET_PULL_FACTOR = 2
#const SMALL_BOSS_MOVE_SPEED = 10
#const SMALL_BOSS_ENERGY_REGEN = 5
#const SMALL_BOSS_MAX_HEALTH = 75
#const SMALL_BOSS_BULLET_LOCATIONS = [Vector2(8, 8), Vector2(-8, 8), Vector2(-8, -8), Vector2(8, -8)]
#const SMALL_BOSS_BULLET_DAMAGES = [5, 5, 5, 5]
#const SMALL_BOSS_BULLET_SPEEDS = [1200, 1200, 1200, 1200]
#const SMALL_BOSS_BULLET_ROTATIONS = [deg_to_rad(45), deg_to_rad(135), deg_to_rad(225), deg_to_rad(315)]
#const SMALL_BOSS_SCALE = 2
#const SMALL_BOSS_PROBABILITY = 0.1
#const SMALL_BOSS_MASS = 50
#const SMALL_BOSS_DROPS = [0, 1, 2, 3]
## Medium Boss
#const MEDIUM_BOSS_STROLL_PULL_FACTOR = 0.05
#const MEDIUM_BOSS_TARGET_PULL_FACTOR = 0.2
#const MEDIUM_BOSS_MOVE_SPEED = 4
#const MEDIUM_BOSS_ENERGY_REGEN = 5
#const MEDIUM_BOSS_MAX_HEALTH = 1500
#const MEDIUM_BOSS_BULLET_LOCATIONS = [Vector2(8, 8), Vector2(-8, 8), Vector2(-8, -8), Vector2(8, -8)]
#const MEDIUM_BOSS_BULLET_DAMAGES = [20, 20, 20, 20]
#const MEDIUM_BOSS_BULLET_SPEEDS = [2400, 2400, 2400, 2400]
#const MEDIUM_BOSS_BULLET_ROTATIONS = [deg_to_rad(45), deg_to_rad(135), deg_to_rad(225), deg_to_rad(315)]
#const MEDIUM_BOSS_SCALE = 7.5
#const MEDIUM_BOSS_PROBABILITY = 0.075
#const MEDIUM_BOSS_MASS = 500
#const MEDIUM_BOSS_DROPS = [6, 9, 10, 11]
## Large Boss
#const LARGE_BOSS_STROLL_PULL_FACTOR = 0.01
#const LARGE_BOSS_TARGET_PULL_FACTOR = 0.1
#const LARGE_BOSS_MOVE_SPEED = 2
#const LARGE_BOSS_ENERGY_REGEN = 2
#const LARGE_BOSS_MAX_HEALTH = 5000
#const LARGE_BOSS_BULLET_LOCATIONS = [Vector2(8, 0), Vector2(8, 8), Vector2(0, 8), Vector2(-8, 8), Vector2(-8, 0), Vector2(-8, -8), Vector2(0, -8), Vector2(8, -8)]
#const LARGE_BOSS_BULLET_DAMAGES = [80, 40, 80, 40, 80, 40, 80, 40]
#const LARGE_BOSS_BULLET_SPEEDS = [1800, 600, 1800, 600, 1800, 600, 1800, 600]
#const LARGE_BOSS_BULLET_ROTATIONS = [deg_to_rad(0), deg_to_rad(45), deg_to_rad(90), deg_to_rad(135), deg_to_rad(180), deg_to_rad(225), deg_to_rad(270), deg_to_rad(315)]
#const LARGE_BOSS_SCALE = 17.5
#const LARGE_BOSS_PROBABILITY = 0.025
#const LARGE_BOSS_MASS = 1000
#const LARGE_BOSS_DROPS = [4, 7, 12]

#var STROLL_PULL_FACTOR = 0
#var TARGET_PULL_FACTOR = 0
#var MOVE_SPEED = 0
#var ENERGY_REGEN = 0
#var MAX_HEALTH = 0
#var BULLET_LOCATIONS = []
#var BULLET_DAMAGES = []
#var BULLET_SPEEDS = []
#var BULLET_ROTATIONS = []
#var SCALE = 0
#var NORMAL = ""
#var ANGRY = ""
#var MASS = 0
#var DROPS = []

var STATS = SHOOTER_STATS # shooter code in case something goes wrong

@export var bullet_scene: PackedScene
@export var item_scene: PackedScene

var SPRITE: AnimatedSprite2D
var EXPLOSION_PARTICLE_EMITTER: GPUParticles2D
var SHIELD: Node2D
var SHIELD_BAR_CONTAINER: AnimatedSprite2D
var SHIELD_BAR: AnimatedSprite2D
var SHIELD_ICON: AnimatedSprite2D
var COLLISION_SHAPE: CollisionShape2D

var ORIGINAL_POSITION: Vector2

var areas_inside = []

var move_direction = Vector2.ONE
var speed = Vector2.ZERO
var health = 1000
var animation_time = 0.2
var particle_time = 1
var energy = 0
var boost = 1 # prevent wild spinning
var shoot = false
var shoot_area: Area2D
var spawned_item = false

func _ready():
	SPRITE = $AnimatedSprite2D
	EXPLOSION_PARTICLE_EMITTER = $ExplosionParticleEmitter
	SHIELD = $Shield
	SHIELD_BAR_CONTAINER = $Shield/ShieldBarContainer
	SHIELD_BAR = $Shield/ShieldBar
	SHIELD_ICON = $Shield/ShieldIcon
	COLLISION_SHAPE = $CollisionShape2D
	
	var probability = randf_range(0, 1)
	if probability <= SPREAD_STATS.probability:
		STATS = SPREAD_STATS
	elif probability <= RACER_STATS.probability:
		STATS = RACER_STATS
	elif probability <= SHOOTER_STATS.probability:
		STATS = SHOOTER_STATS
		
	
#	var n_s_m_l = randf_range(0, 1)
#	if n_s_m_l <= NORMAL_PROBABILITY:
#		STROLL_PULL_FACTOR = NORMAL_STROLL_PULL_FACTOR
#		TARGET_PULL_FACTOR = NORMAL_TARGET_PULL_FACTOR
#		MOVE_SPEED = NORMAL_MOVE_SPEED
#		ENERGY_REGEN = NORMAL_ENERGY_REGEN
#		MAX_HEALTH = NORMAL_MAX_HEALTH
#		BULLET_LOCATIONS = NORMAL_BULLET_LOCATIONS
#		BULLET_DAMAGES = NORMAL_BULLET_DAMAGES
#		BULLET_SPEEDS = NORMAL_BULLET_SPEEDS
#		BULLET_ROTATIONS = NORMAL_BULLET_ROTATIONS
#		SCALE = NORMAL_SCALE
#		NORMAL = "normal"
#		ANGRY = "normal_angry"
#		MASS = NORMAL_MASS
#		DROPS = NORMAL_DROPS
#	elif n_s_m_l <= NORMAL_PROBABILITY + SMALL_BOSS_PROBABILITY:
#		STROLL_PULL_FACTOR = SMALL_BOSS_STROLL_PULL_FACTOR
#		TARGET_PULL_FACTOR = SMALL_BOSS_TARGET_PULL_FACTOR
#		MOVE_SPEED = SMALL_BOSS_MOVE_SPEED
#		ENERGY_REGEN = SMALL_BOSS_ENERGY_REGEN
#		MAX_HEALTH = SMALL_BOSS_MAX_HEALTH
#		BULLET_LOCATIONS = SMALL_BOSS_BULLET_LOCATIONS
#		BULLET_DAMAGES = SMALL_BOSS_BULLET_DAMAGES
#		BULLET_SPEEDS = SMALL_BOSS_BULLET_SPEEDS
#		BULLET_ROTATIONS = SMALL_BOSS_BULLET_ROTATIONS
#		SCALE = SMALL_BOSS_SCALE
#		NORMAL = "small_boss"
#		ANGRY = "small_boss_angry"
#		MASS = SMALL_BOSS_MASS
#		DROPS = SMALL_BOSS_DROPS
#	elif n_s_m_l <= NORMAL_PROBABILITY + SMALL_BOSS_PROBABILITY + MEDIUM_BOSS_PROBABILITY:
#		STROLL_PULL_FACTOR = MEDIUM_BOSS_STROLL_PULL_FACTOR
#		TARGET_PULL_FACTOR = MEDIUM_BOSS_TARGET_PULL_FACTOR
#		MOVE_SPEED = MEDIUM_BOSS_MOVE_SPEED
#		ENERGY_REGEN = MEDIUM_BOSS_ENERGY_REGEN
#		MAX_HEALTH = MEDIUM_BOSS_MAX_HEALTH
#		BULLET_LOCATIONS = MEDIUM_BOSS_BULLET_LOCATIONS
#		BULLET_DAMAGES = MEDIUM_BOSS_BULLET_DAMAGES
#		BULLET_SPEEDS = MEDIUM_BOSS_BULLET_SPEEDS
#		BULLET_ROTATIONS = MEDIUM_BOSS_BULLET_ROTATIONS
#		SCALE = MEDIUM_BOSS_SCALE
#		NORMAL = "medium_boss"
#		ANGRY = "medium_boss_angry"
#		MASS = MEDIUM_BOSS_MASS
#		DROPS = MEDIUM_BOSS_DROPS
#	elif n_s_m_l <= NORMAL_PROBABILITY + SMALL_BOSS_PROBABILITY + MEDIUM_BOSS_PROBABILITY + LARGE_BOSS_PROBABILITY:
#		STROLL_PULL_FACTOR = LARGE_BOSS_STROLL_PULL_FACTOR
#		TARGET_PULL_FACTOR = LARGE_BOSS_TARGET_PULL_FACTOR
#		MOVE_SPEED = LARGE_BOSS_MOVE_SPEED
#		ENERGY_REGEN = LARGE_BOSS_ENERGY_REGEN
#		MAX_HEALTH = LARGE_BOSS_MAX_HEALTH
#		BULLET_LOCATIONS = LARGE_BOSS_BULLET_LOCATIONS
#		BULLET_DAMAGES = LARGE_BOSS_BULLET_DAMAGES
#		BULLET_SPEEDS = LARGE_BOSS_BULLET_SPEEDS
#		BULLET_ROTATIONS = LARGE_BOSS_BULLET_ROTATIONS
#		SCALE = LARGE_BOSS_SCALE
#		NORMAL = "large_boss"
#		ANGRY = "large_boss_angry"
#		MASS = LARGE_BOSS_MASS
#		DROPS = LARGE_BOSS_DROPS
#
	scale = Vector2.ONE * STATS.scale
	health = STATS.max_health
	SPRITE.play(STATS.calm)
	SHIELD.scale = Vector2.ONE / STATS.scale * 5
	hide()
	set_physics_process(false)
	
func _physics_process(delta):
	position += speed
	var flipped = round(randf()) == 0
	var multiplier = 1
	if flipped:
		multiplier = -1
	boost += MOVEMENT_RATE * delta
	if boost >= 1:
		var x_rand = round(randf())
		if x_rand == 0:
			x_rand = -1
		var y_rand = round(randf())
		if y_rand == 0:
			y_rand = -1
		if !shoot:
			move_direction = Vector2(x_rand * randf_range(MIN_STROLL_SPEED, STATS.move_speed), y_rand * randf_range(MIN_STROLL_SPEED, STATS.move_speed))
		else:
			move_direction = Vector2(x_rand * randf_range(MIN_STROLL_SPEED, STATS.move_speed), y_rand * randf_range(MIN_STROLL_SPEED, STATS.move_speed)) * 0.1
		boost = 0
	
	var aim_position = ORIGINAL_POSITION
	var pull_factor = STATS.stroll_pull_factor
	if shoot:
		aim_position = shoot_area.position
		pull_factor = STATS.target_pull_factor
#		rotation = lerp_angle(rotation, aim_position.angle_to(position), LERP_CONSTANT)]]
#		rotation = aim_position.angle_to(position)
	var to_original = aim_position - position
	
	var new_speed = Vector2.ZERO
	if !shoot:
		new_speed += move_direction
	new_speed += to_original.normalized() * pull_factor * STATS.move_speed
	speed = lerp(speed, new_speed, LERP_CONSTANT)
	var s = move_direction
	if shoot:
		s = to_original.normalized()
	rotation = lerp_angle(rotation, atan2(s.y, s.x), LERP_CONSTANT)
	
#
#	speed.x = clamp(speed.x, -STATS.move_speed, STATS.move_speed)
#	speed.y = clamp(speed.y, -STATS.move_speed, STATS.move_speed)
	
	if health <= 0:
		speed = Vector2.ZERO
		if !spawned_item:
			get_parent().MOVED_OBJECTS.append(ORIGINAL_POSITION)
			get_parent().MOVED_TIMINGS.append(get_parent().MOVED_TIMING)
			get_parent().MOVED_TYPES.append("alien")
			spawned_item = true
			var item = item_scene.instantiate()
			get_parent().add_child(item)
			item.global_position = position
			item.TYPE = item.WEAPON_TYPES[STATS.drops[randi() % STATS.drops.size()]] # modulus gives us the number between 0 and the length - 1
			item.IS_WEAPON = true
			item.speed = Vector2(randf_range(-item.SPEED, item.SPEED), randf_range(-item.SPEED, item.SPEED))
		SPRITE.play("explode")
		if get_parent().PARTICLES:
			EXPLOSION_PARTICLE_EMITTER.emitting = true
		animation_time -= delta
		if animation_time <= 0:
			particle_time -= delta
			EXPLOSION_PARTICLE_EMITTER.emitting = false
			SPRITE.hide()
			SHIELD_BAR.hide()
			SHIELD_BAR_CONTAINER.hide()
			SHIELD_ICON.hide()

			DEAD = true
			if particle_time <= 0:
				queue_free()
	else:
		SHIELD_BAR.scale.x = 0.1 * health / STATS.max_health
		energy += STATS.energy_regen * delta
		if energy >= 1 and shoot:
			for order_loc in range(0, STATS.bullet_damages.size()):
				var bullet = bullet_scene.instantiate()		
				bullet.SHOOTER = self
				bullet.TEAMS = get_parent().ALIEN_TEAMS
				bullet.DAMAGE = STATS.bullet_damages[order_loc]
				bullet.RECOIL = STATS.recoil
				bullet.rotation = rotation + STATS.bullet_rotations[order_loc]
				bullet.position = position + (STATS.scale * STATS.bullet_locations[order_loc]).rotated(rotation)
				bullet.speed = speed.normalized().rotated(STATS.bullet_rotations[order_loc]) * STATS.bullet_speeds[order_loc] + speed
				get_parent().add_child(bullet)
			energy = 0
			
	SHIELD_BAR.global_rotation = 0
	SHIELD_BAR_CONTAINER.global_rotation = 0
	SHIELD_ICON.global_rotation = 0

func _on_firing_range_area_entered(area: Area2D):
	if area.is_in_group("ships"):
		areas_inside.append(area)
		shoot = true
		SPRITE.play(STATS.angry)
		shoot_area = area

func _on_firing_range_area_exited(area: Area2D):
	if area.is_in_group("ships"):
		areas_inside.erase(area)
		if (areas_inside.size() == 0):
			shoot = false
			SPRITE.play(STATS.calm)
