package states;

import kha.input.KeyCode;
import com.framework.utils.Input;
import kha.Color;
import com.gEngine.GEngine;
import com.gEngine.display.Text;
import kha.math.FastVector2;
import com.gEngine.display.Sprite;
import kha.Assets;
import com.loading.basicResources.FontLoader;
import com.gEngine.display.IAnimation;
import com.loading.Resources;
import com.loading.basicResources.JoinAtlas;
import com.framework.utils.State;

class GameOver extends State {
    var score:String;
    var time:Float = 0;
    var targetPosition:FastVector2;
    var win:Bool;

    public function new(win:Bool) {
        super();
        this.win = win;
    }

    override function load(resources:Resources) {
        var atlas:JoinAtlas = new JoinAtlas(2048, 2048);
        atlas.add(new FontLoader(Assets.fonts.Kenney_ThickName, 30));
        resources.add(atlas);
    }

    override function init() {
        var scoreDisplay = new Text(Assets.fonts.Kenney_ThickName);
        if(win){
            scoreDisplay.text = "Vives un dia mas";
        }else{
            scoreDisplay.text="Has muerto";
        }
        scoreDisplay.x=GEngine.virtualWidth/2-150;
        scoreDisplay.y=GEngine.virtualHeight/2;
        scoreDisplay.color=Color.Red;
        stage.addChild(scoreDisplay);
    }

    override function update(dt:Float) {
        super.update(dt);
        if(Input.i.isKeyCodePressed(KeyCode.Space)){
            changeState(new GameState("","", false, false));
        }
    }
}