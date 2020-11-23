package scenes;

import haxepunk.Entity;
import haxepunk.graphics.Image;
import haxepunk.graphics.tile.Tilemap;
import haxepunk.HXP;
import haxepunk.masks.Grid;
import haxepunk.tweens.misc.NumTween;
import haxepunk.tweens.misc.VarTween;
import haxepunk.tweens.sound.Fader;
import haxepunk.assets.AssetCache;
import haxepunk.graphics.shader.SceneShader;
import haxepunk.input.Key;
import haxepunk.utils.Data;
import haxepunk.Scene;
import haxepunk.Tween;
import entities.Pickup;
import entities.Player;
import haxe.xml.Access;
import ui.Announce;

class Game extends Scene
{

	public var player:Player;
	public static var levelWidth:Int;
	public static var levelHeight:Int;

	@:const var defaultLevel = "R01";

	var ripple:SceneShader;
	var rippleTime:Float = 0;

	public function new()
	{
		super();

		_exits = new Map<String,String>();

		ripple = SceneShader.fromAsset("shaders/ripple.frag");
		ripple.setUniform("speed", 2.0);
		ripple.setUniform("density", 1.4);
		ripple.setUniform("scale", 2.5);
		shaders.push(ripple);

		shaders.push(SceneShader.fromAsset("shaders/blur.frag"));

		_currentMusic = "";

		_soundFader = new Fader();
		_soundFader.onComplete.bind(soundFadeComplete);
		addTween(_soundFader, false);
		_muted = false;
	}

	private function fadeComplete()
	{
		if (_fadeTween.value == 1)
		{
			// load next level
			loadLevel(_nextLevel);
			_fadeTween.tween(1, 0, 0.5);
			player.switchRoom(_direction);
		}
	}

	public override function begin()
	{
		load();

		// lighting alpha tween
		_alphaTween = new NumTween(TweenType.Looping);
		_alphaTween.onComplete.bind(alphaComplete);
		addTween(_alphaTween, true);
		alphaComplete();

		// fade to black
		_fade = Image.createRect(HXP.screen.width, HXP.screen.height, 0);
		_fade.scrollX = _fade.scrollY = 0;
		addGraphic(_fade, 0).type = "keep";
		_fadeTween = new NumTween();
		_fadeTween.onComplete.bind(fadeComplete);
		addTween(_fadeTween, true);
		_fadeTween.tween(1, 0, 2);

		_soundFader.start();
	}

	public function restart()
	{
		player = null;
		_doors = Data.read("doors", new Array<String>());
		_nextLevel = Data.readString("level", defaultLevel);
		_direction = "none"; // fake direction
		_fadeTween.tween(0, 1, 1);
	}

	public function load()
	{
		Data.load("Current");
		_doors = Data.read("doors", new Array<String>());

		loadLevel(Data.readString("level", defaultLevel));
	}

	public function save()
	{
		Data.write("doors", _doors);
		Data.write("level", _level);
		player.saveData();
		Data.save("Current");
	}

	public function openedDoor()
	{
		_doors.push(_level);
	}

	private function doorOpen():Bool
	{
		for (room in _doors)
		{
			if (room == _level)
				return true;
		}
		return false;
	}

	private function alphaComplete()
	{
		var rand:Float = Math.random() * 5 + 10;
		if (_alphaTween.value == 1)
		{
			_alphaTween.tween(1.0, 0.5, rand);
		}
		else
		{
			_alphaTween.tween(0.5, 1.0, rand);
		}
	}

	private function addImage(id:String, layer:Int):Null<Image>
	{
		var image:Image = new Image(id);
		addGraphic(image, layer);
		return image;
	}

	private function getLevelData(id:String):String
	{
		var level = AssetCache.global.getText("levels/" + id + "/level.oel");
		if (level == "")
			level = AssetCache.global.getText("levels/temple/" + id + ".oel");
		return level;
	}

	private inline function destroyImage(imagePath:String)
	{
		// var data = AtlasData.getAtlasDataByName(imagePath);
		// if (data != null) data.destroy();
	}

	private inline function unloadLevel()
	{
		if (_level != null) {
			destroyImage("levels/" + _level + "/immediatebg.png");
			destroyImage("levels/" + _level + "/walls.png");
			destroyImage("levels/" + _level + "/decor.png");
			destroyImage("levels/" + _level + "/front.png");
			destroyImage("levels/" + _level + "/lighting.png");
		}
		var entities:Array<Entity> = new Array<Entity>();
		getAll(entities);
		for (entity in entities)
		{
			if (entity.type != "keep")
				remove(entity);
		}
	}

	private function loadLevel(id:String)
	{
		unloadLevel();
		_level = StringTools.replace(id, "R", "room");

		addImage("levels/" + _level + "/immediatebg.png", 90);
		var walls:Image = addImage("levels/" + _level + "/walls.png", 30);
		addImage("levels/" + _level + "/decor.png", 20);

		// parallax image, only for hand drawn levels
		if (walls != null)
		{
			var parallax:Image;
			parallax = addImage("gfx/FarParallax.png", 110);
			parallax.scrollX = 0.8;
			parallax.scrollY = 0.6;
			parallax.x -= 200;
			parallax = addImage("gfx/Parallax.png", 100);
			parallax.scrollX = 0.9;
			parallax.scrollY = 0.7;
		}

		addImage("levels/" + _level + "/front.png", 1);
		_lighting = addImage("levels/" + _level + "/lighting.png", 0);

		// load level specific data
		var data:String = getLevelData(_level);
		if (data == null)
		{
			trace("Level data does not exist for " + _level);
		}
		else
		{
			var xml:Access = new Access(Xml.parse(data));
			xml = xml.node.level;

			_vignette = false;
			if (xml.has.vignette && xml.att.vignette == "true")
			{
				_vignette = true;
				var image:Image = addImage("gfx/black_background.png", 100);
				image.x = HXP.halfWidth - image.width / 2;
				image.y = HXP.halfHeight - image.height / 2;
				image.scrollX = image.scrollY = 0;

				image = addImage("gfx/current_vignette.png", 0);
				image.y -= 40;
				image.scrollX = image.scrollY = 0;
			}

			if (xml.has.left)   _exits.set("left", xml.att.left);
			if (xml.has.right)  _exits.set("right", xml.att.right);
			if (xml.has.top)    _exits.set("top", xml.att.top);
			if (xml.has.bottom) _exits.set("bottom", xml.att.bottom);

			// set the level dimensions
			levelWidth = Std.parseInt(xml.node.width.innerData);
			levelHeight = Std.parseInt(xml.node.height.innerData);

			// change music
			if (xml.has.music)
				changeMusic(xml.att.music);

			// load objects
			if (xml.hasNode.actors)
				loadObjects(xml.node.actors);
			// load tilemaps
			if (xml.hasNode.background)
				loadTilemap(xml.node.background, 80);
			if (xml.hasNode.world)
				loadTilemap(xml.node.world, 75);
			if (xml.hasNode.foreground)
				loadTilemap(xml.node.foreground, 6);
			if (xml.hasNode.walls)
				loadWalls(xml.node.walls);
		}
	}

	private function soundFadeComplete()
	{
		if (HXP.volume == 0 && _currentMusic != "")
		{
			BackgroundMusic.play("music/" + _currentMusic + ".xm");
			if (!_muted)
				_soundFader.fadeTo(1, 4);
		}
	}

	private function changeMusic(id:String)
	{
		if (_currentMusic != id)
		{
			_soundFader.fadeTo(0, 1);
			_currentMusic = id;
		}
	}

	private function loadTilemap(group:Access, layer:Int)
	{
		var size:Int = 32;
		var tilesInRow = 13; // TODO: make it so this isn't hard coded for tileset
		var map:Tilemap = new Tilemap("levels/tileset.png", levelWidth, levelHeight, size, size);
		map.usePositions = true;
		for (obj in group.elements)
		{
			// TODO: verify this is right
			var x = Std.int(Std.parseInt(obj.att.tx) / size);
			var y = Std.int(Std.parseInt(obj.att.ty) / size);
			var index = y * tilesInRow + x;
			switch(obj.name)
			{
				case "tile":
					map.setTile(Std.parseInt(obj.att.x),
						Std.parseInt(obj.att.y),
						index);
				case "rect":
					map.setRect(Std.parseInt(obj.att.x),
						Std.parseInt(obj.att.y),
						Std.parseInt(obj.att.w),
						Std.parseInt(obj.att.h),
						index);
			}
		}
		addGraphic(map, layer);
	}

	private function loadWalls(group:Access)
	{
		var size:Int = 8;
		var grid:Grid = new Grid(levelWidth, levelHeight, size, size);
		for (obj in group.nodes.rect)
		{
			grid.setRect(Std.int(Std.parseInt(obj.att.x) / size),
				Std.int(Std.parseInt(obj.att.y) / size),
				Std.int(Std.parseInt(obj.att.w) / size),
				Std.int(Std.parseInt(obj.att.h) / size),
				true);
		}
		addMask(grid, "map");
	}

	private function loadObjects(group:Access)
	{
		var x:Float, y:Float, angle:Float;

		// only add the player if we're starting the game
		if (player == null)
		{
			if (group.hasNode.player)
			{
				var obj = group.node.player;
				x = Std.parseFloat(obj.att.x);
				y = Std.parseFloat(obj.att.y);
			}
			else
			{
				x = levelWidth / 2;
				y = levelHeight / 2;
				trace("No player spawn found, you should think about adding one...");
			}
			player = new Player(x, y);
			player.loadData();
			add(player);
		}

		for (obj in group.elements)
		{
			x = Std.parseFloat(obj.att.x);
			y = Std.parseFloat(obj.att.y);
			angle = (obj.has.angle) ? -Std.parseFloat(obj.att.angle) : 0;
			switch (obj.name)
			{
				// enemies
				case "snapper": add(new entities.enemies.Snapper(x, y));
				case "piranha": add(new entities.enemies.Piranha(x, y, angle, player));
				case "coral": add(new entities.enemies.Coral(x, y, angle));
				case "urchin": add(new entities.enemies.Urchin(x, y));
				case "sheol": add(new entities.enemies.Sheol(x, y, player));

				// gem panel
				case "gem": if (!doorOpen()) add(new entities.puzzle.Gem(x, y));
				case "door": if (!doorOpen()) add(new entities.puzzle.GemDoor(x, y));
				case "panel": add(new entities.puzzle.GemPanel(x, y, doorOpen()));
				case "coloredDoor":
					if (obj.has.color)
						add(new entities.puzzle.LockedDoor(x, y, obj.att.color, player));
					else
						trace("door needs a color");

				// objects
				case "checkpoint": add(new entities.Checkpoint(x, y));
				case "vent": add(new entities.ThermalVent(x, y, angle));
				case "breakableWall": add(new entities.BreakableWall(x, y));
				case "rock": add(new entities.Rock(x, y, obj.name));
				case "smallrock": add(new entities.Rock(x, y, obj.name));

				case "exit": //add(new entities.Exit(x, y, Std.parseInt(obj.att.width), Std.parseInt(obj.att.height)));
				case "player": // do nothing

				//powerups
				default:
					if (!player.hasPickup(obj.name, _level))
						add(new Pickup(x, y, obj.name, _level));
			}
		}
	}

	public function finishGame()
	{
		unloadLevel();
		var white:Image = Image.createRect(HXP.screen.width, HXP.screen.height);
		white.alpha = white.scrollX = white.scrollY = 0;
		addGraphic(white, 1);
		var whiteout:VarTween = new VarTween(TweenType.OneShot);
		whiteout.onComplete.bind(finalWhiteOut);
		whiteout.tween(white, "alpha", 1, 2);
		addTween(whiteout, true);

		_currentMusic = ""; // clear out music
		_soundFader.fadeTo(0, 1);
	}

	private function finalWhiteOut()
	{
		var text:String = "The path of life leads upward\nfor the prudent, that he may turn\naway from Sheol beneath.\n\nProverbs 15:24";
		var a:Announce = new Announce(HXP.screen.width / 2, HXP.screen.height / 2, text, 0xFF000000, function() {
			HXP.scene = new MainMenu();
		});
		a.displaySpeed = 0.05;
		a.displayHold = 8;
		add(a);
	}

	public function switchLevel(direction:String)
	{
		 _direction = direction;
		_nextLevel = _exits.get(direction);
		player.frozen = true; // don't let player move
		if (_nextLevel == "")
		{
			finishGame();
			return;
		}
		_fadeTween.tween(0, 1, 0.3);
	}

	private function clampCamera()
	{
		// move camera with player
		if (player != null)
		{
			camera.x = player.x - HXP.screen.width / 2;
			camera.y = player.y - HXP.screen.height / 2;
		}

		// Vignette needs to follow the player exactly
		if (!_vignette)
		{
			if (camera.x < 0)
				camera.x = 0;
			else if (camera.x > levelWidth - HXP.screen.width)
				camera.x = levelWidth - HXP.screen.width;

			if (camera.y < 0)
				camera.y = 0;
			else if (camera.y > levelHeight - HXP.screen.height)
				camera.y = levelHeight - HXP.screen.height;
		}
	}

	public override function update()
	{
		rippleTime += HXP.elapsed;
		ripple.setUniform("uTime", rippleTime);
		if (_fadeTween != null)
			_fade.alpha = _fadeTween.value;

		// shift the alpha on the lighting layer, if it exists
		if (_lighting != null)
			_lighting.alpha = _alphaTween.value;

		if (Key.pressed(Key.M))
		{
			_muted = !_muted;
			if (_muted)
				HXP.volume = 0;
			else
				HXP.volume = 1;
		}

		super.update();
		clampCamera();
//		shader.update();
	}

	// music
	private var _currentMusic:String;
	private var _soundFader:Fader;
	private var _muted:Bool;

	// level info
	private var _doors:Array<String>;
	private var _level:String;
	// switch level
	private var _exits:Map<String,String>;
	private var _nextLevel:String;
	private var _direction:String;

	// lighting
	private var _alphaTween:NumTween;
	private var _lighting:Image;
	private var _vignette:Bool;

	// fade to black
	private var _fadeTween:NumTween;
	private var _fade:Image;

}
