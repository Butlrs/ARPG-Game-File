extends KinematicBody2D

const EnemyDeathEffect = preload ("res://Effects/EnemyDeathEffect.tscn")
export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 4

enum {
	IDLE,
	WANDER,
	CHASE,
	STILL
}


var velocity = Vector2.ZERO
var knockback =  Vector2.ZERO

var state = CHASE

onready var sprite = $AnimatedSprite
onready var stats = $stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

func _ready():
	state = pick_random_state([IDLE, WANDER])
	add_to_group("enemies")

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO , 200 * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		STILL:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(wanderController.target_position, delta) # take x,y from player and subtract from x,y from enemy - normalizing removes vectors allowing multiplication
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta) # take x,y from player and subtract from x,y from enemy - normalizing removes vectors allowing multiplication
				
			else:
				state = IDLE # when player moves out of detection zone. switch to idle == apply friction
			

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1,3))

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point) # take x,y from player and subtract from x,y from enemy - normalizing removes vectors allowing multiplication
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle() #shuffles list
	return state_list.pop_front() # grab first from randomised list


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage # exported var damage on hitbox
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)
	if stats.boss == true:
		if stats.health <= 10:
			if stats.boss_state == false:
				state = STILL
				MAX_SPEED = 70
				$Hitbox.damage += 10
				hurtbox.start_invincibility(3.5)
				$AnimatedSprite.modulate = Color(0, 0, 0) # blue shade
				$boss_timer.start()
				stats.boss_state = true


func _on_stats_no_health():
	queue_free() # at 0 health remove entity
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")

func _on_boss_timer_timeout():
	state = CHASE
