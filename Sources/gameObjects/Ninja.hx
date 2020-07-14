package gameObjects;

import kha.Assets;
import kha.audio1.Audio;
import kha.Sound;
import kha.audio1.AudioChannel;
import com.framework.utils.LERP;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;

class Ninja extends Entity {
	public var display:Sprite;
	public var collision:CollisionBox;
	public var kunaiThrower:KunaiThrower;
	var isThrowing:Bool=false;
	var maxSpeed = 150;
	public var tripleShooter:Bool = false;
	public var canFly:Bool = false;
	var shootTime:Float = 0;
	var jumping:AudioChannel;
    var jumpSound:Sound;

	var scale = 0.18;

	public function new(x:Float,y:Float,layer:Layer, cape:Bool, triple:Bool) {
		super();
		display = new Sprite("ninja");
		layer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width()*scale*0.5;
		collision.height = display.height()*scale;
		display.pivotX=-collision.width*0.55;
		display.offsetY = 3;
		display.offsetX = 5;
		
		display.scaleX = display.scaleY = scale;
		collision.x=x;
		collision.y=y;
		collision.userData = this;

		collision.accelerationY = 2000;
		collision.maxVelocityX = 500;
		collision.maxVelocityY = 800;
		collision.dragX = 0.9;
		
		kunaiThrower = new KunaiThrower();
		addChild(kunaiThrower);

		canFly = cape;
		tripleShooter = triple;
	}

	override function update(dt:Float) {
		shootTime += dt;
		
		super.update(dt);
		
		collision.update(dt);
	}
	override function render() {
		display.x = collision.x;
		display.y = collision.y;
		if (collision.isTouching(Sides.BOTTOM) && collision.velocityX == 0) {
			display.timeline.playAnimation("idle");
		} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX != 0) {
			display.timeline.playAnimation("run");
		} else if (!collision.isTouching(Sides.BOTTOM) && collision.velocityY < 0) {
			display.timeline.playAnimation("jump");
		}else if (!collision.isTouching(Sides.BOTTOM) && canFly){
			display.timeline.playAnimation("glide");
		}else if(isThrowing){
			display.timeline.playAnimation("throw");
		}
		var s = Math.abs(collision.velocityX / collision.maxVelocityX);
		display.timeline.frameRate = (1 / 30) * s + (1 - s) * (1 / 10);
	}

	

	public function onButtonChange(id:Int, value:Float) {
		if (id == XboxJoystick.LEFT_DPAD) {
			if (value == 1) {
				collision.accelerationX = -maxSpeed * 4;
				display.rotation = -0.05;
				display.offsetX = 47;
				display.scaleX = -Math.abs(display.scaleX);
			} else {
				if (collision.accelerationX < 0) {
					collision.accelerationX = 0;
					display.rotation = 0;
				}
			}
		}
		if (id == XboxJoystick.RIGHT_DPAD) {
			if (value == 1) {
				collision.accelerationX = maxSpeed * 4;
				display.rotation = 0.05;
				display.offsetX = 5;
				display.scaleX = Math.abs(display.scaleX);
			} else {
				if (collision.accelerationX > 0) {
					collision.accelerationX = 0;
					display.rotation = 0;
				}
			}
		}
		if (id == XboxJoystick.UP_DPAD) {
			jumpSound = Assets.sounds.get("jumpSound");
			jumping = Audio.play(jumpSound);
			if (value == 1) {
				if (collision.isTouching(Sides.BOTTOM)) {
					collision.velocityY = -1000;
					
				}
			}
		}if (id == XboxJoystick.UP_DPAD) {
			if (value == 1) {
				if (canFly) {
					collision.velocityY = -750;
				}
			}
		}
		if (id == XboxJoystick.A){
			if(value == 1 && shootTime > 1){
				isThrowing = true;
				var y = collision.y+(collision.height*0.5);
				if(tripleShooter){
					kunaiThrower.shoot(collision.x, y, 1000, -500);
					kunaiThrower.shoot(collision.x, y, 1000, 0);
					kunaiThrower.shoot(collision.x, y, 1000, 500);
				}else{
					kunaiThrower.shoot(collision.x, y, 1000, 0);
				}
				isThrowing=false;
			}
		}
		
	}

	public function onAxisChange(id:Int, value:Float) {}
}
