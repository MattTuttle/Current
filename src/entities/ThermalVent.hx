package entities;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;

class ThermalVent extends Entity
{

	public function new(x:Float, y:Float, angle:Float) 
	{
		super(x, y);
		graphic = _image = new Image(GfxThermalVent);
		_image.centerOO();
		_image.angle = angle;
		layer = 15;
		_spawnTime = 2;
		type = "scenery";
	}
	
	private function spawnBubble()
	{
		HXP.world.add(new Bubble(x + Math.random() * 16, y, 2));
		_spawnTime = Math.random();
	}
	
	public override function update()
	{
		_spawnTime -= HXP.elapsed;
		if (_spawnTime < 0)
			spawnBubble();
		
	}
	
	private var _image:Image;
	private var _spawnTime:Float;
	
}