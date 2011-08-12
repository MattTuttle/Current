package base;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import entities.Player;

class Interactable extends Entity
{

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		type = "interact";
	}
	
	public function activate(player:Player)
	{
		trace("You are supposed to override me!");
	}
	
}