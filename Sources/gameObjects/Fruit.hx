package gameObjects;

import com.collision.platformer.Sides;
import com.gEngine.display.Layer;
import com.gEngine.display.Sprite;
import com.collision.platformer.CollisionGroup;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;

class Fruit extends Entity{
    public var display:Sprite;
    public var collision:CollisionBox;
    var collisionGroup:CollisionGroup;
    public var kunaiThrower:KunaiThrower;
    var time:Float=0;

    public function new(x:Float, y:Float, layer:Layer, collisions:CollisionGroup) {
        super();
        collisionGroup = collisions;
        display = new Sprite("fruta");
        layer.addChild(display);

        collision = new CollisionBox();
        collision.x = x;
        collision.y = y;
        collision.userData = this;
        
        var scale = 0.15;
        display.scaleX = display.scaleY = scale;

        collision.width = display.width()*scale;
        collision.height = display.height()*scale;
        collision.accelerationY = 2000;
        
        display.offsetX = -0*1.5;
        display.offsetY = -0*1.5;

        collisionGroup.add(collision);

        kunaiThrower = new KunaiThrower();
		addChild(kunaiThrower);

    }

    override public function update(dt:Float) {

        if(collision.isTouching(Sides.BOTTOM)){
            collision.velocityY = -550;
        }
        time += dt;
        if(time > 1){
            kunaiThrower.shoot(collision.x, collision.y, -1000, 0);
            time = 0;
        }
        collision.update(dt);
        super.update(dt);
    }

    override function render() {
        display.x = collision.x;
        display.y = collision.y;

        super.render();
    }

    public function damage():Void{
        collision.removeFromParent();
        collisionGroup.remove(collision);
        display.removeFromParent();
    }
}