extends Area2D

const LERP_CONSTANT = 0.5
const KN_LERP = 0.5
const RECOIL_CONSTANT = 0.01
const KNOCKBACK_CONSTANT = 0.1
const MIN_SIZE = 1
const MAX_SIZE = 60
const DAMAGE_DIVIDER = 1500
const DAMAGE_MULTIPLIER = 3
const SIZE_MULTIPLIER = 0.025
var DEAD = false

var SPRITE: AnimatedSprite2D
var COLLISION_SHAPE: CollisionShape2D

var TEAMS = []
var SHOOTER: Area2D = null
var DAMAGE = 0
var RECOIL = true

@export var asteroid_scene: PackedScene

var speed = Vector2.ZERO
var life_time = 1
var animation_time = 0.2
var area_hit: Area2D = null

func _ready():	
	SPRITE = $AnimatedSprite2D
	COLLISION_SHAPE = $CollisionShape2D
	
	if SHOOTER.is_in_group("ships"):
		SPRITE.play("ally_bullet")
	else:
		SPRITE.play("alien_bullet")
	if RECOIL:
		var s = SHOOTER.speed - speed * DAMAGE * RECOIL_CONSTANT
		SHOOTER.speed = lerp(SHOOTER.speed, s, KN_LERP)
	hide()
	# _physics_process is not false since bullets cannot like un-fly, and they don't last long

func _physics_process(delta):
	# Prevents chunk loading / unloading from disturbing motion of bullets
	position += speed * delta
	var targeted_scale = clamp(DAMAGE, MIN_SIZE, MAX_SIZE)
	scale = Vector2.ONE * targeted_scale * SIZE_MULTIPLIER
	life_time -= delta
	if life_time <= 0:
		speed = Vector2.ZERO
		if DAMAGE == 0:
			scale = Vector2.ONE
		SPRITE.play("explode")
		animation_time -= delta
		if animation_time <= 0:
			queue_free()

# remember, go to node tab then signals, then connect to the method needed
func _on_area_entered(area: Area2D):
	if area.is_in_group("asteroids") or area.is_in_group("ships") or area.is_in_group("aliens"):
		if area != SHOOTER:
			if !area.is_in_group("ships") && area.DEAD:
				return
			area_hit = area
			var dmg = DAMAGE * speed.length() / DAMAGE_DIVIDER
			if area_hit not in TEAMS:
				dmg = DAMAGE * speed.length() / DAMAGE_DIVIDER * DAMAGE_MULTIPLIER
			area_hit.health -= dmg
			if area.is_in_group("ships"):
				area.speed += speed * DAMAGE * KNOCKBACK_CONSTANT / area.MASS
			elif area.is_in_group("aliens"):
				area.speed += speed * DAMAGE * KNOCKBACK_CONSTANT / area.STATS.mass
			speed = Vector2.ZERO
			life_time = 0
	elif area.is_in_group("bullets"):
		if area.TEAMS != TEAMS:
			if DAMAGE >= area.DAMAGE:
				DAMAGE -= area.DAMAGE
				area.life_time = 0
				if DAMAGE <= 0:
					life_time = 0
					DAMAGE = 0
				else:
					var s_area = area.speed + speed * DAMAGE * KNOCKBACK_CONSTANT / area.DAMAGE
					var s = speed + area.speed * DAMAGE * KNOCKBACK_CONSTANT / DAMAGE
					area.speed = lerp(area.speed, s_area, KN_LERP)
					speed = lerp(speed, s, KN_LERP)
