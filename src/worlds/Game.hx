package worlds;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.HXP;
import com.haxepunk.masks.Grid;
import com.haxepunk.masks.Pixelmask;
import com.haxepunk.tweens.misc.NumTween;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Data;
import com.haxepunk.World;
import com.haxepunk.Tween;
import base.Physics;
import flash.display.BitmapData;
import flash.utils.ByteArray;
import haxe.xml.Fast;
import hxmikmod.MikModPlayer;

class Game extends World
{
	
//	public var shader:WaterShader;
	public var player:Player;
	public static var levelWidth:Int;
	public static var levelHeight:Int;
	public static var musicPlayer:MikModPlayer = new MikModPlayer();

	public function new()
	{
		super();
		
//		shader = new WaterShader();
		_exits = new Hash<String>();
		
		_currentMusic = "";
		_music = new Hash<ByteArray>();
		_music.set("heartbeat", new ModHeartbeat());
		_music.set("boss", new ModBoss());
		_music.set("home", new ModHome());
		_music.set("city", new ModCity());
		_music.set("title", new ModTitle());
		_music.set("storm", new ModStorm());
	}
	
	private function fadeComplete()
	{
		if (_fadeTween.value == 1)
		{
			loadNextLevel();
			_fadeTween.tween(1, 0, 0.5);
		}
	}
	
	public override function begin()
	{
		load();
		
		// lighting alpha tween
		_alphaTween = new NumTween(alphaComplete, TweenType.Looping);
		addTween(_alphaTween, true);
		alphaComplete();
		
		// fade to black
		_fade = Image.createRect(HXP.screen.width, HXP.screen.height, 0);
		_fade.scrollX = _fade.scrollY = 0;
		addGraphic(_fade, -1000).type = "keep";
		_fadeTween = new NumTween(fadeComplete);
		addTween(_fadeTween);
		_fadeTween.tween(1, 0, 2);
	}
	
	public function restart()
	{
		player = null;
		_nextLevel = Data.readString("level", "R01");
		_direction = "none"; // fake direction
		_fadeTween.tween(0, 1, 1);
	}
	
	public function load()
	{
		Data.load("Current");
		_doors = Data.read("doors", new Array<String>());
		
		_level = Data.readString("level", "R01");
		loadLevel(_level);
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
	
	private function addImage(id:String, layer:Int):Image
	{
		var c:Class<Dynamic> = Type.resolveClass("Gfx" + id);
		if (c != null)
		{
			var image:Image = new Image(HXP.getBitmap(c));
			addGraphic(image).layer = layer;
			return image;
		}
		return null;
	}
	
	private function addForeground(id:String, layer:Int):Image
	{
		var c:Class<Dynamic> = Type.resolveClass("Gfx" + id);
		if (c != null)
		{
			var image:BitmapData = HXP.getBitmap(c);
			var mask:Pixelmask = new Pixelmask(image);
			mask.threshold = 250; // pass through shadows
			var ent:Entity = new Entity(0, 0, new Image(image), mask);
			ent.type = "map";
			ent.layer = layer;
			add(ent);
			return cast(ent.graphic, Image);
		}
		return null;
	}
	
	private function getLevelData(id:String):ByteArray
	{
		var c:Class<Dynamic> = Type.resolveClass("Lvl" + id + "Data");
		if (c != null)
			return Type.createInstance(c, []);
		return null;
	}
	
	private function loadLevel(id:String)
	{
		_level = id;
		var entities:Array<Entity> = new Array<Entity>();
		getAll(entities);
		for (entity in entities)
		{
			if (entity.type != "keep")
				remove(entity);
		}
		
		// parallax image
		var parallax:Image;
		parallax = addImage("FarParallax", 110);
		parallax.scrollX = 0.8;
		parallax.scrollY = 0.6;
		parallax.x -= 200;
		parallax = addImage("Parallax", 100);
		parallax.scrollX = 0.9;
		parallax.scrollY = 0.7;
		
		addImage(id + "Background", 90);
		var walls:Image = addImage(id + "Walls", 30);
		addImage(id + "Decor", 20);
		
		addImage(id + "Front", -90);
		_lighting = addImage(id + "Lighting", -100);
		
		// load level specific data
		var data:ByteArray = getLevelData(id);
		if (data == null)
		{
			trace("Level data does not exist for " + id);
		}
		else
		{
			var xml:Fast = new Fast(Xml.parse(data.toString()));
			xml = xml.node.level;
			
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
				loadTilemap(xml.node.foreground, -30);
			if (xml.hasNode.walls)
				loadWalls(xml.node.walls);
		}
	}
	
	private function changeMusic(id:String)
	{
		var music:ByteArray = _music.get(id);
		if (music != null && _currentMusic != id)
		{
			musicPlayer.stop();
			musicPlayer.loadSong(music);
			_currentMusic = id;
		}
	}
	
	private function loadTilemap(group:Fast, layer:Int)
	{
		var size:Int = 32;
		var map:Tilemap = new Tilemap(GfxTileset, levelWidth, levelHeight, size, size);
		map.usePositions = true;
		for (obj in group.elements)
		{
			switch(obj.name)
			{
				case "tile":
					map.setTile(Std.parseInt(obj.att.x),
						Std.parseInt(obj.att.y),
						map.getIndex(Std.int(Std.parseInt(obj.att.tx) / size), Std.int(Std.parseInt(obj.att.ty) / size)));
				case "rect":
					map.setRect(Std.parseInt(obj.att.x),
						Std.parseInt(obj.att.y),
						Std.parseInt(obj.att.w),
						Std.parseInt(obj.att.h),
						map.getIndex(Std.int(Std.parseInt(obj.att.tx) / size), Std.int(Std.parseInt(obj.att.ty) / size)));
			}
		}
		addGraphic(map, layer);
	}
	
	private function loadWalls(group:Fast)
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
	
	private function loadObjects(group:Fast)
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
				case "gem": if (!doorOpen()) add(new entities.Gem(x, y));
				case "door": if (!doorOpen()) add(new entities.Door(x, y));
				case "panel": add(new entities.GemPanel(x, y, doorOpen()));
				
				// objects
				case "scroll": add(new entities.Scroll(x, y));
				case "checkpoint": add(new entities.Checkpoint(x, y));
				case "vent": add(new entities.ThermalVent(x, y, angle));
				case "rock": add(new entities.Rock(x, y, obj.name));
				case "smallrock": add(new entities.Rock(x, y, obj.name));
				
				//powerups
				default:
					if (!player.hasPickup(obj.name, _level) && obj.name != "player")
						add(new Powerup(x, y, obj.name, _level));
			}
		}
	}
	
	public function switchLevel(direction:String)
	{
		_direction = direction;
		_nextLevel = _exits.get(direction);
		if (_nextLevel == "")
		{
			trace("No level to switch to");
			return;
		}
		player.frozen = true; // don't let player move
		_fadeTween.tween(0, 1, 0.3);
	}
	
	private function loadNextLevel()
	{
		loadLevel(_nextLevel);
		switch (_direction)
		{
			case "left":
				player.x = levelWidth - 8;
			case "right":
				player.x = 8;
			case "top":
				player.y = levelHeight - 8;
			case "bottom":
				player.y = 8;
		}
		player.frozen = false;
		player.velocity.x = player.velocity.y = 0;
		player.resetBubbles();
	}
	
	private function clampCamera()
	{
		if (HXP.camera.x < 0)
			HXP.camera.x = 0;
		else if (HXP.camera.x > levelWidth - HXP.screen.width)
			HXP.camera.x = levelWidth - HXP.screen.width;
			
		if (HXP.camera.y < 0)
			HXP.camera.y = 0;
		else if (HXP.camera.y > levelHeight - HXP.screen.height)
			HXP.camera.y = levelHeight - HXP.screen.height;
	}
	
	public override function update()
	{
		_fade.alpha = _fadeTween.value;
		
		// shift the alpha on the lighting layer, if it exists
		if (_lighting != null)
			_lighting.alpha = _alphaTween.value;
		
		super.update();
		clampCamera();
//		shader.update();
	}
	
	// music
	private var _currentMusic:String;
	private var _music:Hash<ByteArray>;
	
	// level info
	private var _doors:Array<String>;
	private var _level:String;
	// switch level
	private var _exits:Hash<String>;
	private var _nextLevel:String;
	private var _direction:String;
	
	// lighting
	private var _alphaTween:NumTween;
	private var _lighting:Image;
	
	// fade to black
	private var _fadeTween:NumTween;
	private var _fade:Image;
	
}