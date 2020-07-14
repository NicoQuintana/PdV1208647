package gameObjects;

import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;

class Interactible extends Entity {

	public var collider:CollisionBox;

	public function new(x:Float, y:Float, width:Float, height:Float) {
		super();
		collider = new CollisionBox();
		collider.x = x;
		collider.y = y-height;
		collider.userData = this;
		collider.width = width;
		collider.height = height;
    }
    override function update(dt:Float) {
        super.update(dt);
    }

	function beenTaken(){
		collider.removeFromParent();
	}
}
