package gameObjects;

import com.loading.basicResources.SoundLoader;
import kha.audio1.AudioChannel;
import kha.audio1.Audio;
import kha.Assets;
import kha.Sound;
import com.collision.platformer.CollisionGroup;
import com.framework.utils.Entity;

class KunaiThrower extends Entity{
    public var kunaisCollision:CollisionGroup;
    var shooting:AudioChannel;
    var shootSound:Sound;

    public function new() {
        super();
        pool = true;
        kunaisCollision = new CollisionGroup();
    }

    public function shoot(X:Float, Y:Float, dirX:Float, dirY:Float):Void {
        var kunai:Kunai = cast recycle(Kunai);
        kunai.shoot(X,Y, dirX, dirY, kunaisCollision);
        shootSound = Assets.sounds.get("shootSound");
        shooting = Audio.play(shootSound);
    }

}