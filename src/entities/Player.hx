package entities;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.masks.Pixelmask;
import com.haxepunk.Sfx;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import flash.geom.Point;

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

class Player extends Entity
{
	
	private static inline var bubbleLayers:Array<Int> = [6, 12, 18];
	private static var maxBubbles:Int = 0;
	
	public var dead:Bool;
	public var following:Int; // bubbles following
	
	public var velocity:Point;
	public var acceleration:Point;
	public var maxSpeed:Float;
	public var drag:Float;
	public var speed:Float;

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		var image:Image = new Image(GfxBubble);
		image.centerOO();
		graphic = image;
		mask = new Pixelmask(GfxBubble, -8, -8);
		
		following = 0;
		dead = false;
		
		_bubbles = new Array<Bubble>();
		_bubbleAngle = 0;
		maxBubbles = 0;
		for (i in 0 ... bubbleLayers.length)
		{
			maxBubbles += bubbleLayers[i];
		}
		
		velocity = new Point();
		acceleration = new Point();
		maxSpeed = 140;
		drag = 8;
		speed = 6;
		
		Input.define("up", [Key.W, Key.UP]);
		Input.define("down", [Key.S, Key.DOWN]);
		Input.define("left", [Key.A, Key.LEFT]);
		Input.define("right", [Key.D, Key.RIGHT]);
	}
	
	private function kill()
	{
		if (dead) return;
		
		HXP.world.remove(this);
		var pop:Sfx = new Sfx(new SfxBubblePop());
		pop.play();
		dead = true;
	}
	
	private function move()
	{
		var change:Float, delta:Int;
		velocity.x += acceleration.x;
		velocity.y += acceleration.y;
		if (Math.abs(velocity.x) > maxSpeed)
			velocity.x = maxSpeed * HXP.sign(velocity.x);
		if (Math.abs(velocity.y) > maxSpeed)
			velocity.y = maxSpeed * HXP.sign(velocity.y);
		
		// change in horizontal
		change = (velocity.x + Math.random() * 0.2) * HXP.elapsed; // adds wiggle
		if (collide("map", x + change, y) == null)
		{
			x += change;
		}
		else
		{
			delta = Math.floor(change);
			for (i in 0...delta)
			{
				if (collide("map", x + HXP.sign(delta), y) == null)
				{
					x += HXP.sign(delta);
				}
				else
				{
					velocity.x = 0;
					break;
				}
			}
		}
		
		// change in vertical
		change = (velocity.y + Math.random() * 1 - 0.5) * HXP.elapsed; // adds wiggle
		if (collide("map", x, y + change) == null)
		{
			y += change;
		}
		else
		{
			delta = Math.floor(change);
			for (i in 0...delta)
			{
				if (collide("map", x, y + HXP.sign(delta)) == null)
				{
					y += HXP.sign(delta);
				}
				else
				{
					velocity.y = 0;
					break;
				}
			}
		}
	}
	
	public override function update()
	{
		handleInput();
		
		// move camera
		HXP.camera.x = x - HXP.screen.width / 2;
		HXP.camera.y = y - HXP.screen.height / 2;
		
		mouseGesture(Input.mouseX, Input.mouseY);
		move();
		
		super.update();
		
		if (collide("enemy", x, y) != null)
		{
			if (_bubbles.length == 0)
				kill();
		}
		
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
	
	public function removeBubble(bubble:Bubble)
	{
		_bubbles.remove(bubble);
	}
	
	private function addBubble(bubble:Bubble)
	{
		if (bubble.owned || _bubbles.length >= maxBubbles) return;
		
		_bubbles.push(bubble);
		bubble.owner = this;
		moveBubble(_bubbles.length - 1);
	}
	
	private function mouseGesture(mouseX:Float, mouseY:Float)
	{
		if (Input.mousePressed)
		{
			_lastMouseX = mouseX;
			_lastMouseY = mouseY;
			_gestures = new Array<Gesture>();
		}
		else if (Input.mouseDown)
		{
			var dx:Float = mouseX - _lastMouseX;
			var dy:Float = mouseY - _lastMouseY;
			if (dx * dx + dy * dy > 400) // len > 20
			{
				var angle:Float = Math.atan2(dy, dx) * HXP.DEG;
				// LEFT = -22 to 22
				var gesture:Gesture = LEFT;
				
				// determine approx angle
				if (angle > 112)
					gesture = UPLEFT;
				else if (angle > 67)
					gesture = UP;
				else if (angle > 22)
					gesture = UPRIGHT;
				else if (angle > -22)
					gesture = RIGHT;
				else if (angle > -67)
					gesture = DOWNRIGHT;
				else if (angle > -112)
					gesture = DOWN;
				else if (angle > -157)
					gesture = DOWNLEFT;
				
				if (_gestures.length == 0 || gesture != _lastGesture)
				{
					_gestures.push(gesture);
					_lastGesture = gesture;
				}
				_lastMouseX = mouseX;
				_lastMouseY = mouseY;
			}
		}
		else if (Input.mouseReleased)
		{
			// Process gesture
		}
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
	}
	
	private var _bubbles:Array<Bubble>;
	private var _bubbleAngle:Float;
	
	private var _lastGesture:Gesture;
	private var _gestures:Array<Gesture>;
	private var _lastMouseX:Float;
	private var _lastMouseY:Float;
	
}