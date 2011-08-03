package worlds;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import com.haxepunk.masks.Pixelmask;
import com.haxepunk.World;
import entities.Fish;
import entities.Player;
import flash.utils.ByteArray;
import haxe.xml.Fast;

class Game extends World
{
	
	public static var player:Player;

	public function new() 
	{
		super();
		var ent:Entity = new Entity(0, 0, new Image(GfxLevel), new Pixelmask(GfxMask));
		ent.type = "map";
		ent.layer = 20;
		add(ent);
		
		loadLevel("Underwater");
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
		switch (direction)
		{
			case "left":
			case "right":
			case "up":
			case "down":
		}
	}
	
	public override function update()
	{
		// check if player heads off screen
		if (player.x < -player.width)
			switchRoom("left");
		else if (player.x > HXP.screen.width)
			switchRoom("right");
		if (player.y < -player.height)
			switchRoom("up");
		else if (player.y > HXP.screen.height)
			switchRoom("down");
		
		super.update();
	}
	
	private var _spawnFish:Float;
	
}