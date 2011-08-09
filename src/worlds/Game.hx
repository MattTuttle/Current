package worlds;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import com.haxepunk.masks.Grid;
import com.haxepunk.masks.Pixelmask;
import com.haxepunk.tweens.misc.NumTween;
import com.haxepunk.World;
import com.haxepunk.Tween;
import entities.Fish;
import entities.Player;
import flash.display.BitmapData;
import flash.utils.ByteArray;
import haxe.xml.Fast;
import hxmikmod.MikModPlayer;

class Game extends World
{
	
	public static var player:Player;
	public static var levelWidth:Int;
	public static var levelHeight:Int;
//	public static var musicPlayer:MikModPlayer = new MikModPlayer();

	public function new()
	{
		super();
		
		_exits = new Hash<String>();
		
		_currentMusic = "";
		_music = new Hash<ByteArray>();
		_music.set("R01", new ModHome());
		_music.set("R02", new ModTheme());
		
		loadLevel("R01");
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
	
	private function addImage(id:String, layer:Int, scroll:Float = 1):Image
	{
		var c:Class<Dynamic> = Type.resolveClass("Gfx" + id);
		if (c != null)
		{
			var image:Image = new Image(HXP.getBitmap(c));
			image.scrollX = image.scrollY = scroll;
			var ent:Entity = new Entity(0, 0, image);
			ent.layer = layer;
			_entities.push(ent);
			return image;
		}
		return null;
	}
	
	private function loadForeground(id:String):BitmapData
	{
		var c:Class<Dynamic> = Type.resolveClass("Gfx" + id);
		if (c != null)
		{
			var image:BitmapData = HXP.getBitmap(c);
//			var mask:Pixelmask = new Pixelmask(image);
//			mask.threshold = 250; // pass through shadows
			var ent:Entity = new Entity(0, 0, new Image(image));
//			ent.type = "map";
			ent.layer = 20;
			_entities.push(ent);
			
			// set the level dimensions
			levelWidth = image.width;
			levelHeight = image.height;
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
		if (_entities != null) removeList(_entities);
		_entities = new Array<Entity>();
		
		// change the music
		var music:ByteArray = _music.get(id);
		if (music != null && _currentMusic != id)
		{
//			musicPlayer.stop();
//			musicPlayer.loadSong(music);
			_currentMusic = id;
		}
		
		// background and lighting
		addImage("Parallax", 100, 0);
		addImage(id + "Background", 90);
		addImage(id + "Decor", 80);
		
		// load up wall image and use it as a mask
		loadForeground(id + "Walls");
		
		addImage(id + "Front", -10);
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
			
			if (xml.hasNode.actors)
				loadObjects(xml.node.actors);
			if (xml.hasNode.walls)
				loadWalls(xml.node.walls);
		}
		
		// add the level specific entities
		addList(_entities);
	}
	
	private function loadWalls(group:Fast)
	{
		var grid:Grid = new Grid(levelWidth, levelHeight, 16, 16);
		for (obj in group.nodes.rect)
		{
			grid.setRect(Std.int(Std.parseInt(obj.att.x) / 16),
				Std.int(Std.parseInt(obj.att.y) / 16),
				Std.int(Std.parseInt(obj.att.w) / 16),
				Std.int(Std.parseInt(obj.att.h) / 16),
				true);
		}
		var ent:Entity = new Entity(0, 0);
		ent.mask = grid;
		ent.type = "map";
		_entities.push(ent);
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
				case "fish":
					_entities.push(new Fish(x, y));
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
	}
	
	private var _currentMusic:String;
	private var _music:Hash<ByteArray>;
	private var _entities:Array<Entity>;
	private var _exits:Hash<String>;
	private var _alphaTween:NumTween;
	private var _lighting:Image;
	
}