extends KinematicBody2D

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 120 # allows for editor changss - easier for debugging
export var FRICTION = 500

enum {
	MOVE, # string value representations
	ATTACK, # automatic value 0,1,2
	IDLE,
	BLOCK,
	CHARGE
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var raise_animation = false
var raiseanim = null
var timer_state = false
var shield_attack = null

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback") #root animation node info
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var blockHitbox = $HitboxPivot/BlockHitbox


func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true # animation not constantly playing, only active when game starts
	swordHitbox.knockback_vector = roll_vector
	blockHitbox.knockback_vector = roll_vector


func _physics_process(delta): # waits until physics have been processed
	match state:  # switch statement in GODOT - no case
		MOVE: # if the state matches MOVE then  - move_state(delta)
			move_state(delta)
		ATTACK:
			attack_state(delta)
		IDLE:
			idle_state(delta)
		BLOCK:
			block_state(delta)
		CHARGE:
			congrats_state(delta)
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized() # removed diagonal speed > l or r , u or d
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector * 0.6 # code to store knockback movement as direction
		blockHitbox.knockback_vector = input_vector * 0.8 # IVE DEFINITLY FUCKED UP KNOCKBACK DELTA SOMEWHERE #
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)# stops moving attack animation mid attack
		animationTree.set("parameters/Block/blend_position", input_vector)
		animationTree.set("parameters/Congrats/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK # stops running move case - starts attack case
	
	if Input.is_action_just_pressed("Block"):
		if PlayerStats.shields > 0:
			$ShieldRegen.start()
			state = BLOCK
			shield_attack = true
			PlayerStats.shields -=1

	if Input.is_action_just_pressed("Emote"):
		if PlayerStats.shields == 3:
			$ShieldRegen.start()
			state = CHARGE
			PlayerStats.shields -=3


func idle_state(_delta):
	velocity = Vector2.ZERO

func attack_state(_delta):
	velocity = Vector2.ZERO # sets velocity to 0.
	animationState.travel("Attack")

func block_state(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Block")
	hurtbox.start_invincibility(0.2)

func congrats_state(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Congrats")

func move():
	velocity = move_and_slide(velocity)

func attack_animation_finished():
	state = MOVE

func block_animation_finished():
	state = MOVE
	shield_attack = false

func emote_animation_finished():
	state = MOVE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.7)
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)

func _on_Hurtbox_invincibility_started():
	if shield_attack != true:
		blinkAnimationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")

func _on_ShieldRegen_timeout():
	if PlayerStats.shields < PlayerStats.max_shields:
		PlayerStats.shields += 1
