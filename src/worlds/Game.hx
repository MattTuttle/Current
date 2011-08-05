package worlds;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import com.haxepunk.masks.Pixelmask;
import com.haxepunk.tweens.misc.NumTween;
import com.haxepunk.World;
import com.haxepunk.Tween;
import entities.Fish;
import entities.Player;
import flash.display.BitmapData;
import flash.utils.ByteArray;
import haxe.xml.Fast;

class Game extends World
{
	
	public static var player:Player;
	public static var levelWidth:Int;
	public static var levelHeight:Int;

	public function new()
	{
		super();
		
		loadLevel("Room01");
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
	
	private function getImageData(id:String):BitmapData
	{
		var c:Class<Dynamic> = Type.resolveClass("Gfx" + id);
		if (c != null)
			return Type.createInstance(c, []).bitmapData;
		return null;
	}
	
	private function getLevelData(id:String):ByteArray
	{
		var c:Class<Dynamic> = Type.resolveClass("Lvl" + id);
		if (c != null)
			return Type.createInstance(c, []);
		return null;
	}
	
	private function loadLevel(id:String)
	{
		removeAll();
		
		// background and lighting
		addGraphic(new Image(GfxOceanBackground)).layer = 110;
		addGraphic(new Image(getImageData(id + "Background"))).layer = 100;
		
		_lighting = new Image(getImageData(id + "Lighting"));
		if (_lighting != null)
			addGraphic(_lighting).layer = -10;
		
		// load up foreground and use it as a mask
		var image:BitmapData = getImageData(id + "Foreground");
		var mask:Pixelmask = new Pixelmask(image);
		mask.threshold = 250;
		var ent:Entity = new Entity(0, 0, new Image(image), mask);
		ent.type = "map";
		ent.layer = 20;
		add(ent);
		
		// set the level dimensions
		levelWidth = mask.width;
		levelHeight = mask.height;
		
		// load level specific data
		var data:ByteArray = getLevelData(id);
		if (data == null)
			throw "Level does not exist: " + id;
		var xml:Fast = new Fast(Xml.parse(data.toString()));
		xml = xml.node.level;
		
		if (xml.hasNode.actors)
			loadObjects(xml.node.actors);
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
					add(new Fish(x, y));
				case "player":
					player = new Player(x, y - 50);
					add(player);
			}
		}
	}
	
	private function switchRoom(direction:String)
	{
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
		if (player.x < -player.width)
			switchRoom("left");
		else if (player.x > levelWidth)
			switchRoom("right");
		if (player.y < -player.height)
			switchRoom("up");
		else if (player.y > levelHeight)
			switchRoom("down");
		
		_lighting.alpha = _alphaTween.value;
		
		super.update();
		
		clampCamera();
	}
	
	private var _alphaTween:NumTween;
	private var _lighting:Image;
	
}