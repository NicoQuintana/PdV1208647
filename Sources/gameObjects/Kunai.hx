package gameObjects;

import com.collision.platformer.CollisionGroup;
import com.framework.utils.Entity;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import GlobalGameData.GGD;


class Kunai extends Entity
{
    public var collision:CollisionBox;
    var display:Sprite;
    var lifeTime:Float = 0;
    var totalLifeTime:Float = 3;

    public function new(){
        super();
        display = new Sprite("Kunai");
        display.rotation = 1.5;
        collision = new CollisionBox();
        collision.width = display.width();
        collision.height = display.height()*0.1;
        collision.userData = this;

        display.scaleX = display.scaleY = 0.18;

    }

    override function limboStart() {
        display.removeFromParent();
        collision.removeFromParent();
    }

    override function update(dt:Float) {
        lifeTime += dt;
        if(lifeTime > totalLifeTime){
            die();
        }
        collision.update(dt);
        display.x = collision.x;
        display.y = collision.y;

        super.update(dt);
    }

    public function shoot(x:Float, y:Float,dirX:Float, dirY:Float, kunaisCollision:CollisionGroup):Void {
        lifeTime = 0;
        collision.x = x;
        collision.y = y;
        collision.velocityX = dirX;
        collision.velocityY = dirY;
        kunaisCollision.add(collision);
        GGD.backgroundLayer.addChild(display);
    }

}