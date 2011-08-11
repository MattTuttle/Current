package entities;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;

class ThermalVent extends Entity
{

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		graphic = new Image(GfxThermalVent);
		layer = 15;
		_spawnTime = 2;
		type = "scenery";
	}
	
	private function spawnBubble()
	{
		HXP.world.add(new Bubble(x + 16 + Math.random() * 16, y + 8, 2));
		_spawnTime = HXP.random * 2;
	}
	
	public override function update()
	{
		_spawnTime -= HXP.elapsed;
		if (_spawnTime < 0)
			spawnBubble();
		
	}
	
	private var _spawnTime:Float;
	
}