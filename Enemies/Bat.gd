extends KinematicBody2D

const heartcontainer = preload("res://Items/HeartContainer.tscn")
var mini_enemy = load("res://Enemies/MiniSlime.tscn") as PackedScene
const heart_entity = preload("res://Items/Heart.tscn")
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
	if stats.mini_slime == true:
		hurtbox.start_invincibility(0.2)
	
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
				MAX_SPEED = 60
				$Hitbox.damage += 10
				$AnimatedSprite.play("Slime_2")
				hurtbox.start_invincibility(8)
				$boss_timer.start()
				spawn_slime()
				spawn_slime()
				spawn_slime()
				stats.boss_state = true
			else:
				pass

func spawn_slime():
	var slime = mini_enemy.instance()
	get_parent().call_deferred("add_child",slime)
	slime.global_position = $EntityPosition.global_position

func heart_container():
	if stats.boss == true:
		var container = heartcontainer.instance()
		get_parent().call_deferred("add_child",container)
		container.global_position = $EntityPosition.global_position


func _on_stats_no_health():
	if stats.mini_slime == true:
		heart_spawn()
		heart_container()
		queue_free()
	else:
		var enemyDeathEffect = EnemyDeathEffect.instance()
		get_parent().add_child(enemyDeathEffect)
		enemyDeathEffect.global_position = global_position
		heart_spawn()
		heart_container()
		queue_free()
	

func heart_spawn():
	var chance  = range(1,11)[randi()%range(1,11).size()] # in range 1-10
	if chance <=2: # 20% chance to spawn a heart
		var heart = heart_entity.instance()
		get_parent().call_deferred("add_child",heart)
		heart.global_position = $EntityPosition.global_position
	else:
		pass
	
func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")

func _on_boss_timer_timeout():
	state = CHASE
