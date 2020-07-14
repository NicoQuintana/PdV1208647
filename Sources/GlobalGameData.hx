import com.gEngine.display.Camera;
import com.gEngine.display.Layer;
import gameObjects.Ninja;

typedef GGD = GlobalGameData;
class GlobalGameData {
    public static var ninja:Ninja;
    public static var backgroundLayer:Layer;
    public static var camera:Camera;

    public static function destroy(){
        ninja = null;
        backgroundLayer = null;
        camera = null;
    }
}