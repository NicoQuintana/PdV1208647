package states;

import kha.audio1.Audio;
import kha.Sound;
import kha.audio1.AudioChannel;
import com.gEngine.GEngine;
import com.gEngine.display.Text;
import com.gEngine.display.StaticLayer;
import com.loading.basicResources.FontLoader;
import gameObjects.Interactible;
import com.collision.platformer.ICollider;
import com.collision.platformer.CollisionBox;
import com.loading.basicResources.ImageLoader;
import com.collision.platformer.CollisionGroup;
import com.gEngine.display.Sprite;
import com.gEngine.shaders.ShRetro;
import com.gEngine.display.Blend;
import com.gEngine.shaders.ShRgbSplit;
import com.gEngine.display.Camera;
import kha.Assets;
import helpers.Tray;
import com.gEngine.display.extra.TileMapDisplay;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.framework.utils.VirtualGamepad;
import format.tmx.Data.TmxObject;
import kha.input.KeyCode;
import com.framework.utils.Input;
import com.collision.platformer.CollisionEngine;
import gameObjects.Ninja;
import gameObjects.Kunai;
import gameObjects.Fruit;
import gameObjects.FinalBoss;
import com.loading.basicResources.TilesheetLoader;
import com.loading.basicResources.SpriteSheetLoader;
import com.gEngine.display.Layer;
import com.loading.basicResources.DataLoader;
import com.collision.platformer.Tilemap;
import com.loading.basicResources.JoinAtlas;
import com.loading.Resources;
import com.framework.utils.State;
import GlobalGameData.GGD;

class GameState extends State {
	var worldMap:Tilemap;
	var ninja:Ninja;
	var fruit:Fruit;
	var finalBoss:FinalBoss;
	var simulationLayer:Layer;
	var touchJoystick:VirtualGamepad;
	var tray:helpers.Tray;
	var enemyCollisions:CollisionGroup;
	var level:String = "level1_tmx";
	var fromLevel:String = "first";
	var doorCollision:CollisionGroup;
	var capeCollision:CollisionGroup;
	var tripleCollision:CollisionGroup;
	var cape:Bool = false;
	var triple:Bool = false;
	var bossHealth:Float = 3;
	var hudLayer:StaticLayer;
	var scoreDisplay:Text;
	var weapon:Sprite;
	var weaponAmmo:Text;
	var life:Sprite;
	var ambient:AudioChannel;
    var ambientSound:Sound;

	public function new(room:String, fromRoom:String, cape:Bool, triple:Bool) {
		super();
		if(fromRoom == "first" || fromRoom == "second"){
			level = room;
		}
		this.cape = cape;
		this.triple = triple;
	}

	override function load(resources:Resources) {
		resources.add(new DataLoader(Assets.blobs.level1_tmxName));
		resources.add(new DataLoader(Assets.blobs.level2_tmxName));
		resources.add(new DataLoader(Assets.blobs.level3_tmxName));
		var atlas = new JoinAtlas(4096, 4096);

		atlas.add(new TilesheetLoader("castleTiles", 32, 32, 0));
		atlas.add(new SpriteSheetLoader("ninja", 280, 291, 0, [
			new Sequence("jump", [12, 13, 14, 15, 16, 17, 18, 19, 20, 21]),
			new Sequence("run", [22, 23, 24, 25, 26, 27, 28, 29, 30, 31]),
			new Sequence("idle", [11]),
			new Sequence("dead", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
			new Sequence("glide", [10]),
			new Sequence("throw", [32, 33, 34, 35, 36, 37, 38, 39, 40, 41])
		]));
		atlas.add(new ImageLoader("fruta"));
		atlas.add(new ImageLoader("Kunai"));
		atlas.add(new ImageLoader("cape"));
		atlas.add(new ImageLoader("x3"));
		atlas.add(new ImageLoader("heart"));
        atlas.add(new FontLoader(Assets.fonts.Kenney_ThickName,30));
		resources.add(atlas);
	}

	override function init() {
		stageColor(0.5, .5, 0.5);		
		enemyCollisions = new CollisionGroup();
		doorCollision = new CollisionGroup();
		capeCollision = new CollisionGroup();
		tripleCollision = new CollisionGroup();
		simulationLayer = new Layer();
		stage.addChild(simulationLayer);
		hudLayer = new StaticLayer();
		stage.addChild(hudLayer);

		ambientSound = Assets.sounds.get("ambientSound");
		ambient = Audio.play(ambientSound);

		var levelMap:TileMapDisplay;
		worldMap = new Tilemap(level , 1);
		worldMap.init(function(layerTilemap, tileLayer) {
			if (tileLayer.name == "tiles-solid") {
				layerTilemap.createCollisions(tileLayer);
			}
			simulationLayer.addChild(layerTilemap.createDisplay(tileLayer,new Sprite("castleTiles")));
			levelMap = layerTilemap.createDisplay(tileLayer,new Sprite("castleTiles"));
			simulationLayer.addChild(levelMap);
		}, parseMapObjects);
		
		tray = new Tray(levelMap);


		stage.defaultCamera().limits(0, 0, worldMap.widthIntTiles * 32 , worldMap.heightInTiles * 32);
		ninja = new Ninja(20,400,simulationLayer, cape, triple);
		addChild(ninja);

		createTouchJoystick();

		stage.defaultCamera().postProcess=new ShRetro(Blend.blendDefault());

		GGD.ninja = ninja;
		GGD.backgroundLayer = simulationLayer;
		GGD.camera = stage.defaultCamera();

		createHud();

		if(level == "level3_tmx"){
			finalBoss = new FinalBoss(300, 300, simulationLayer, enemyCollisions);
			addChild(finalBoss);
		}else{
			fruit = new Fruit(850, 400, simulationLayer, enemyCollisions);
			addChild(fruit);
		}

	}

	function createHud(){
		life = new Sprite("heart");
		life.scaleX = life.scaleY = 0.3;
		life.x = 30;
		life.y = 30;
		hudLayer.addChild(life);

		weapon = new Sprite("Kunai");
		weapon.scaleX = weapon.scaleY = 0.5;
		weapon.x = 30;
		weapon.y = GEngine.virtualHeight - 120;
		hudLayer.addChild(weapon);

		weaponAmmo=new Text(Assets.fonts.Kenney_ThickName);
       	weaponAmmo.x = 60;
       	weaponAmmo.y = GEngine.virtualHeight - 90;
       	hudLayer.addChild(weaponAmmo);
		weaponAmmo.text = "x999";
		   
		if(level == "level3_tmx"){
			scoreDisplay=new Text(Assets.fonts.Kenney_ThickName);
       		scoreDisplay.x = GEngine.virtualWidth/2;
       		scoreDisplay.y = 30;
       		hudLayer.addChild(scoreDisplay);
       		scoreDisplay.text = "" + bossHealth;
		}
	}

	function createTouchJoystick() {
		touchJoystick = new VirtualGamepad();
		touchJoystick.addKeyButton(XboxJoystick.LEFT_DPAD, KeyCode.Left);
		touchJoystick.addKeyButton(XboxJoystick.RIGHT_DPAD, KeyCode.Right);
		touchJoystick.addKeyButton(XboxJoystick.UP_DPAD, KeyCode.Up);
		touchJoystick.addKeyButton(XboxJoystick.A, KeyCode.Space);
		touchJoystick.addKeyButton(XboxJoystick.X, KeyCode.X);
		touchJoystick.notify(ninja.onAxisChange, ninja.onButtonChange);

		var gamepad = Input.i.getGamepad(0);
		gamepad.notify(ninja.onAxisChange, ninja.onButtonChange);
		
	}

	function parseMapObjects(layerTilemap:Tilemap, object:TmxObject) {
		switch(object.objectType){
			case OTTile(gid):
				if(level == "level1_tmx"){
					var cape = new Sprite("cape");
					cape.x = object.x;
					cape.y = object.y - cape.height();
					cape.pivotY = cape.height();
					simulationLayer.addChild(cape);
					var capePU = new Interactible(object.x, object.y, object.width, object.height);
					capeCollision.add(capePU.collider);
					addChild(capePU);
				}else{
					var triple = new Sprite("x3");
					triple.x = object.x;
					triple.y = object.y - triple.height();
					triple.pivotY = triple.height();
					simulationLayer.addChild(triple);	
					var triplePU = new Interactible(object.x, object.y, object.width, object.height);
					tripleCollision.add(triplePU.collider);
					addChild(triplePU);
				}
			case OTRectangle:
				if(object.type == "door"){
					var door = new Interactible(object.x, object.y+object.height, object.width, object.height);
					doorCollision.add(door.collider);
					addChild(door);
				}
			default:
		}
	}


	override function update(dt:Float) {
		super.update(dt);
		stage.defaultCamera().scale=2;
	
		CollisionEngine.collide(ninja.collision,worldMap.collision);
		stage.defaultCamera().setTarget(ninja.collision.x, ninja.collision.y);

        tray.setContactPosition(ninja.collision.x + ninja.collision.width / 2, ninja.collision.y + ninja.collision.height + 1, Sides.BOTTOM);
		tray.setContactPosition(ninja.collision.x + ninja.collision.width + 1, ninja.collision.y + ninja.collision.height / 2, Sides.RIGHT);
		tray.setContactPosition(ninja.collision.x-1, ninja.collision.y+ninja.collision.height/2, Sides.LEFT);


		CollisionEngine.overlap(ninja.collision, enemyCollisions, ninjaVsFruit);
		if(level == "level3_tmx"){
			CollisionEngine.collide(finalBoss.collision, worldMap.collision);
			CollisionEngine.overlap(ninja.collision, finalBoss.kunaiThrower.kunaisCollision, ninjaVsKunai);
			CollisionEngine.overlap(ninja.kunaiThrower.kunaisCollision, enemyCollisions, kunaiVsBoss);
		}else {
			CollisionEngine.collide(fruit.collision,worldMap.collision);
			CollisionEngine.overlap(ninja.collision, fruit.kunaiThrower.kunaisCollision, ninjaVsKunai);
			CollisionEngine.overlap(ninja.kunaiThrower.kunaisCollision, enemyCollisions, kunaiVsFruit);
		}
		CollisionEngine.overlap(doorCollision, ninja.collision, nextLevel);
		CollisionEngine.overlap(capeCollision, ninja.collision, capePU);
		CollisionEngine.overlap(tripleCollision, ninja.collision, triplePU);
		//1280 y 640 son valores sacados de la cantidad de tiles del mapa y el tamaño de estos
		if(ninja.collision.x > 1280 || ninja.collision.x < 0 || ninja.collision.y > 640 || ninja.collision.y < 0){
			changeState(new GameOver(false));
		}
	}
	
	function nextLevel(doorCollision:ICollider, ninjaCollision:ICollider){
		if(level == "level1_tmx"){
			changeState(new GameState("level2_tmx", fromLevel, cape, triple));
		}else{
			changeState(new GameState("level3_tmx", "second", cape, triple));
		}
	}

	function capePU(powerUpCollision:ICollider, ninjaCollision:ICollider){
		ninja.canFly = true;
		cape = true;
	}
	
	function triplePU(powerUpCollision:ICollider, ninjaCollision:ICollider){
		ninja.tripleShooter = true;
		triple = true;
	}
	function ninjaVsFruit(ninjaCollision:ICollider, fruitCollision:ICollider){
		changeState(new GameOver(false));
	}
	function kunaiVsFruit(kunaiCollision:ICollider, fruitCollision:ICollider){
		var fruit:Fruit = cast fruitCollision.userData;
		fruit.kunaiThrower.die();
		fruit.damage();
		var kunai:Kunai = cast kunaiCollision.userData;
		kunai.die();
	}
	function ninjaVsKunai(ninjaCollision:ICollider, enemyKunaiCollision:ICollider){
		changeState(new GameOver(false));
	}
	function kunaiVsBoss(kunaiCollision:ICollider, finalBossCollision:ICollider){
		if(bossHealth == 1){
			changeState(new GameOver(true));
		}else{
			bossHealth--;
		}
	}
	
	#if DEBUGDRAW
	override function draw(framebuffer:kha.Canvas) {
		super.draw(framebuffer);
		var camera=stage.defaultCamera();
		CollisionEngine.renderDebug(framebuffer,camera);
	}
	#end
	override function destroy() {
		super.destroy();
		touchJoystick.destroy();
		GGD.destroy();
	}

}
