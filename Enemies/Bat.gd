extends KinematicBody2D

#bad.gd should be renamed to enemy as it falls under all / most enemy types now

const heartcontainer = preload("res://Items/HeartContainer.tscn") # Preloading all tscn's that are called and used under bat.gd 
const heart_entity = preload("res://Items/Heart.tscn")
const EnemyDeathEffect = preload ("res://Effects/EnemyDeathEffect.tscn")

#var mini_enemy = load("res://Enemies/MiniSlime.tscn") as PackedScene # allowing multiple tscn's to pass under one entity crash free
var velocity = Vector2.ZERO # setting values based on predetermines values.
var knockback =  Vector2.ZERO
var state = CHASE # Setting base state to chace, whenever player comes into contact - CHASE

export var ACCELERATION = 300 # Next 3 lines set enemy parameters to limit movement speed -- ALL EXPORTED - CHANGEABLE OUTSIDE OF CODE
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 4 # Set value in which the enemy can roam wihtin it's wander state.

onready var sprite = $AnimatedSprite # calling children of the parent node into variables for neater code.
onready var stats = $stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

enum {
	IDLE, # The states in which the nemy call fall under. Neater more concise management of movement
	WANDER,
	CHASE,
	STILL,
}

func _ready():
	state = pick_random_state([IDLE, WANDER]) # When the game starts the enemies will pick a random state
	if stats.mini_slime == true:
		hurtbox.start_invincibility(0.4) # Since these enemies are called during a script to be added, add invincibility to ensure they dont collide with an active hurtbox on spawn
	
func _physics_process(delta): # called every frame of the game
	knockback = knockback.move_toward(Vector2.ZERO , 200 * delta)
	knockback = move_and_slide(knockback)
	
	match state: # Creating values for the STATE machine
		STILL: # NO MOVEMENT
			alert_inactive()
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)

		IDLE: # NO MOVEMENT - LOOKING FOR PLAYER CONSTANTLY
			alert_inactive()
			seek_player()
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			if wanderController.get_time_left() == 0:
				update_wander()
		
		WANDER: # MOVING, STILL LOOKING FOR PLAYER UNDER A WANDER RANGE DETERMINES BY EXPORT VARIRABLE
			seek_player()
			alert_inactive()
			if wanderController.get_time_left() == 0:
				update_wander()
			
			accelerate_towards_point(wanderController.target_position, delta) # take x,y from player and subtract from x,y from enemy - normalizing removes vectors allowing multiplication
			
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
			
		CHASE: # MOVING TOWARDS PLAYER IF INSIDE PLAYER DETECTIVE ZONE
			var player = playerDetectionZone.player
			alert_active()
			if player != null:
				accelerate_towards_point(player.global_position, delta) # take x,y from player and subtract from x,y from enemy - normalizing removes vectors allowing multiplication
			else:
				state = IDLE # when player moves out of detection zone. switch to IDLE

	if softCollision.is_colliding(): # If colliding with another entity push off, avoiding an overlap
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func update_wander(): # Once player leaves the PDZ, reset state and at 1-3 seconds from removalm pick a state to be in.
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1,2))

func accelerate_towards_point(point, delta): # Accelerate towards players location.
	var direction = global_position.direction_to(point) # take x,y from player and subtract from x,y from enemy - normalizing removes vectors allowing multiplication
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0 # If on the other side of the player flip sprite to other direction.

func seek_player():# Look for player, if the player is wihtin the PDZ change state to CHASE
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list): # Shuffling list of given values on a stack and then popping the value on top
	state_list.shuffle()
	return state_list.pop_front()


func _on_Hurtbox_area_entered(area): # When the the hurtbox of the enemy is entered by the players sword.
	stats.health -= area.damage # Enemy health - the players swords exported var damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect() 
	state = STILL
	hurtbox.start_invincibility(0.3)
	$CD.start()


func heart_container():
	pass

func alert_active():
	pass


func alert_inactive():
	pass

func _on_stats_no_health():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	heart_spawn()
	heart_container()
	queue_free()

func heart_spawn():
	var chance  = range(1,11)[randi()%range(1,11).size()] # in range 1-10
	if chance <=2: # 20% chance to spawn a heart
		var heart = heart_entity.instance() # bring the tscn into the scene under a variable
		get_parent().call_deferred("add_child",heart)
		heart.global_position = $EntityPosition.global_position # STILL BROKEN relative fix with position 2D
	else:
		pass
	
func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")
 #  both set an animation for being invincible
func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")

func _on_CD_timeout():
	state = IDLE
