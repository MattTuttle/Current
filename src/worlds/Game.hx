package worlds;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.HXP;
import com.haxepunk.masks.Grid;
import com.haxepunk.masks.Pixelmask;
import com.haxepunk.tweens.misc.NumTween;
import com.haxepunk.utils.Input;
import com.haxepunk.World;
import com.haxepunk.Tween;
import base.Physics;
import entities.Checkpoint;
import entities.Fish;
import entities.Player;
import entities.Rock;
import entities.Sheol;
import entities.ThermalVent;
import flash.display.BitmapData;
import flash.utils.ByteArray;
import haxe.xml.Fast;
import hxmikmod.MikModPlayer;

class Game extends World
{
	
	public static var player:Player;
	public static var levelWidth:Int;
	public static var levelHeight:Int;
	public static var musicPlayer:MikModPlayer = new MikModPlayer();

	public function new()
	{
		super();
		
		_exits = new Hash<String>();
		
		_currentMusic = "";
		_music = new Hash<ByteArray>();
		_music.set("R01", new ModHome());
		_music.set("R02", new ModTheme());
		
		loadLevel("Boss");
		_alphaTween = new NumTween(alphaComplete, TweenType.Looping);
		addTween(_alphaTween, true);
		alphaComplete();
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
		var entities:Array<Entity> = new Array<Entity>();
		getAll(entities);
		for (entity in entities)
		{
			if (entity.type != "keep")
				remove(entity);
		}
		
		// change the music
		var music:ByteArray = _music.get(id);
		if (music != null && _currentMusic != id)
		{
			musicPlayer.stop();
//			musicPlayer.loadSong(music);
			_currentMusic = id;
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
			levelWidth = walls.width;
			levelHeight = walls.height;
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
			
			if (xml.hasNode.actors)
				loadObjects(xml.node.actors);
			if (xml.hasNode.world)
				loadWorld(xml.node.world);
			if (xml.hasNode.walls)
				loadWalls(xml.node.walls);
		}
	}
	
	private function loadWorld(group:Fast)
	{
		var size:Int = 50;
		var map:Tilemap = new Tilemap(GfxTileset, levelWidth, levelHeight, size, size);
		for (obj in group.nodes.tile)
		{
			map.setTile(Std.int(Std.parseInt(obj.att.x) / size),
				Std.int(Std.parseInt(obj.att.y) / size),
				map.getTile(Std.int(Std.parseInt(obj.att.tx) / size), Std.int(Std.parseInt(obj.att.ty) / size)));
		}
		addGraphic(map, 40);
	}
	
	private function loadWalls(group:Fast)
	{
		var size:Int = 10;
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
		var x:Float, y:Float;
		for (obj in group.elements)
		{
			x = Std.parseFloat(obj.att.x);
			y = Std.parseFloat(obj.att.y);
			switch (obj.name)
			{
				case "fish": add(new Fish(x, y));
				case "rock": add(new Rock(x, y, obj.name));
				case "smallrock": add(new Rock(x, y, obj.name));
				case "sheol": add(new Sheol(x, y));
				case "vent": add(new ThermalVent(x, y));
				case "checkpoint": add(new Checkpoint(x, y));
				case "player":
					// only add the player if we're starting the game
					if (player == null)
					{
						player = new Player(x, y);
						add(player);
					}
			}
		}
	}
	
	private function switchLevel(direction:String)
	{
		var level:String = _exits.get(direction);
		if (level == "")
		{
			trace("No level to switch to");
			return;
		}
		loadLevel(level);
		switch (direction)
		{
			case "left":
				player.x = levelWidth - 4;
			case "right":
				player.x = 4;
			case "top":
				player.y = levelHeight - 4;
			case "bottom":
				player.y = 4;
		}
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
		// check if player heads off screen
		if (player != null)
		{
			if (player.x < -player.width)
				switchLevel("left");
			else if (player.x > levelWidth)
				switchLevel("right");
			if (player.y < -player.height)
				switchLevel("top");
			else if (player.y > levelHeight)
				switchLevel("bottom");
		}
		
		// shift the alpha on the lighting layer, if it exists
		if (_lighting != null)
			_lighting.alpha = _alphaTween.value;
		
		super.update();
		
		clampCamera();
		
		if (Input.mousePressed)
		{
			_tossObject = null;
			if (player.bubbles > 0)
			{
				_tossObject = cast(collidePoint("grab", mouseX, mouseY), Physics);
				if (_tossObject != null)
				{
					_dragX = mouseX;
					_dragY = mouseY;
				}
			}
		}
		else if (Input.mouseReleased)
		{
			if (_tossObject != null)
			{
				player.removeBubble();
				_tossObject.toss(mouseX - _dragX, mouseY - _dragY);
			}
		}
	}
	
	// drag objects
	private var _dragX:Float;
	private var _dragY:Float;
	private var _dragTime:Float;
	private var _tossObject:Physics;
	
	// music
	private var _currentMusic:String;
	private var _music:Hash<ByteArray>;
	
	// exits
	private var _exits:Hash<String>;
	
	// lighting
	private var _alphaTween:NumTween;
	private var _lighting:Image;
	
}