package entities;

import base.Physics;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.masks.Pixelmask;
import com.haxepunk.Sfx;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import flash.geom.Point;
import worlds.Game;

enum Gesture
{
	DOWN;
	DOWNLEFT;
	DOWNRIGHT;
	LEFT;
	RIGHT;
	UP;
	UPLEFT;
	UPRIGHT;
}

class Player extends Physics
{
	
	private static inline var bubbleLayers:Array<Int> = [6, 12, 18, 24];
	private static var maxBubbles:Int = 0;
	
	public var following:Int; // bubbles following

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		var image:Image = new Image(GfxBubble);
		image.centerOO();
		graphic = image;
		mask = new Pixelmask(GfxBubble, -8, -8);
		
		following = 0;
		bounce = 2;
		
		_bubbles = new Array<Bubble>();
		_bubbleAngle = 0;
		maxBubbles = 0;
		for (i in 0 ... bubbleLayers.length)
		{
			maxBubbles += bubbleLayers[i];
		}
		
		type = "keep";
		
		Input.define("up", [Key.W, Key.UP]);
		Input.define("down", [Key.S, Key.DOWN]);
		Input.define("left", [Key.A, Key.LEFT]);
		Input.define("right", [Key.D, Key.RIGHT]);
		Input.define("grab", [Key.SPACE, Key.SHIFT]);
	}
	
	private function kill()
	{
		if (dead) return;
		
		HXP.world.remove(this);
		var pop:Sfx = new Sfx(new SfxBubblePop());
		pop.play();
		dead = true;
	}
	
	public var bubbles(getBubbleCount, null):Int;
	private function getBubbleCount():Int { return _bubbles.length; }
	
	public function lastBubble():Bubble { return (_bubbles.length == 0) ? null : _bubbles[_bubbles.length - 1]; }
	
	public override function update()
	{
		handleInput();
		
		// move camera
		HXP.camera.x = x - HXP.screen.width / 2;
		HXP.camera.y = y - HXP.screen.height / 2;
		
		super.update();
		
		if (collide("enemy", x, y) != null && _bubbles.length == 0)
		{
			kill();
		}
		else
		{
			var checkpoint:Checkpoint = cast(collide("checkpoint", x, y), Checkpoint);
			if (checkpoint != null)
			{
				checkpoint.save(this);
			}
		}
		
		// check if player heads off screen
		var game:Game = cast(HXP.world, Game);
		if (dead)
		{
			game.restart();
		}
		else
		{
			if (x < -width)
				game.switchLevel("left");
			else if (x > Game.levelWidth)
				game.switchLevel("right");
			if (y < -height)
				game.switchLevel("top");
			else if (y > Game.levelHeight)
				game.switchLevel("bottom");
			
			// rotate bubbles
			_bubbleAngle += 1;
			for (i in 0 ... _bubbles.length)
			{
				moveBubble(i);
			}
			
			var bubble:Bubble = cast(collide("bubble", x, y), Bubble);
			if (bubble != null)
			{
				addBubble(bubble);
			}
		}
	}
	
	public function resetBubbles()
	{
		for (i in 0 ... _bubbles.length)
		{
			moveBubble(i);
			_bubbles[i].reset = true;
		}
	}
	
	private function moveBubble(index:Int)
	{
		var layer:Int = -1;
		var numOnLayer:Int = 0;
		var angleIndex:Int = index;
		
		var total:Int = 0;
		for (i in 0 ... bubbleLayers.length)
		{
			total += bubbleLayers[i];
			if (index < total)
			{
				numOnLayer = bubbleLayers[i];
				layer = i;
				break;
			}
			angleIndex -= bubbleLayers[i];
		}
		
		// this bubble is on an undefined layer
		if (layer == -1) return;
		
		var offsetAngle:Float = (angleIndex % numOnLayer) * 360 / numOnLayer;
		var offsetRadius:Float = layer * 12 + width;
		var angle:Float = (_bubbleAngle + offsetAngle) * HXP.RAD;
		
		_bubbles[index].targetX = Math.cos(angle) * offsetRadius + x;
		_bubbles[index].targetY = Math.sin(angle) * offsetRadius + y;
	}
	
	public function removeBubble(?bubble:Bubble)
	{
		if (bubble == null)
		{
			if (_bubbles.length > 0)
				_bubbles.pop().kill();
		}
		else
		{
			_bubbles.remove(bubble);
		}
	}
	
	private function addBubble(bubble:Bubble)
	{
		if (bubble.owned || _bubbles.length >= maxBubbles) return;
		_bubbles.push(bubble);
		bubble.owner = this;
		moveBubble(_bubbles.length - 1);
	}
	
	private function handleInput()
	{
		// Horizontal movement
		if (Input.check("left"))
		{
			acceleration.x = -speed;
		}
		else if (Input.check("right"))
		{
			acceleration.x = speed;
		}
		else
		{
			// Horizontal drag (rest at zero)
			if (velocity.x < 0)
			{
				velocity.x += drag;
				if (velocity.x > 0)
					velocity.x = 0;
			}
			else if (velocity.x > 0)
			{
				velocity.x -= drag;
				if (velocity.x < 0)
					velocity.x = 0;
			}
		}
		
		// Vertical movement
		if (Input.check("up"))
		{
			acceleration.y = -speed;
		}
		else if (Input.check("down"))
		{
			acceleration.y = speed;
		}
		else
		{
			// Vertical drag (rest at zero)
			if (velocity.y < 0)
			{
				velocity.y += drag;
				if (velocity.y > 0)
					velocity.y = 0;
			}
			else if (velocity.y > 0)
			{
				velocity.y -= drag;
				if (velocity.y < 0)
					velocity.y = 0;
			}
		}
		
		if (Input.check("grab") && _bubbles.length > 0)
		{
			if (_grabObject == null)
			{
				_grabObject = cast(HXP.world.nearestToEntity("grab", this), Physics);
				_grabTime = 1;
				if (HXP.distance(_grabObject.x, _grabObject.y, x, y) > 100)
					_grabObject = null;
			}
			else
			{
				_grabTime -= HXP.elapsed;
				if (_grabTime < 0)
				{
					removeBubble();
					_grabTime = 1;
				}
				_point.x = x - _grabObject.x;
				_point.y = y - _grabObject.y;
				if (_point.length > 30)
				{
					_point.normalize(8);
					_grabObject.velocity.x += _point.x;
					_grabObject.velocity.y += _point.y;
				}
			}
		}
		else
		{
			_grabObject = null;
		}
	}
	
	private var _grabTime:Float;
	private var _grabObject:Physics;
	
	private var _bubbles:Array<Bubble>;
	private var _bubbleAngle:Float;
	
}