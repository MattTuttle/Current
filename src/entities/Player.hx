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
	
	public var dead:Bool;
	public var following:Int; // bubbles following
	
	public var velocity:Point;
	public var maxVelocity:Point;

	public function new(x:Float, y:Float) 
	{
		super(x, y);
		graphic = new Image(GfxBubble);
		mask = new Pixelmask(GfxBubble);
		
		following = 0;
		dead = false;
		
		velocity = new Point();
		maxVelocity = new Point(5, 5);
		
		Input.define("up", [Key.W, Key.UP]);
		Input.define("down", [Key.S, Key.DOWN]);
		Input.define("left", [Key.A, Key.LEFT]);
		Input.define("right", [Key.D, Key.RIGHT]);
	}
	
	private function clampCamera()
	{
		if (x < HXP.camera.x)
		{
			x = HXP.camera.x;
		}
		else if (x > HXP.camera.x + HXP.screen.width - 16)
		{
			x = HXP.camera.x + HXP.screen.width - 16;
		}
		
		if (y < HXP.camera.y)
			y = HXP.camera.y;
		else if (y > HXP.camera.y + HXP.screen.height - 16)
			y = HXP.camera.y + HXP.screen.height - 16;
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
		if (velocity.x > maxVelocity.x)
			velocity.x = maxVelocity.x;
		if (velocity.y > maxVelocity.y)
			velocity.y = maxVelocity.y;
		
		// change in horizontal
		change = velocity.x + Math.random() * 0.2; // adds wiggle
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
		change = velocity.y + Math.random() * 1 - 0.5; // adds wiggle
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
		
		clampCamera();
		mouseGesture(Input.mouseX, Input.mouseY);
		move();
		
		super.update();
		
		if (collide("enemy", x, y) != null)
		{
			kill();
		}
	}
	
	private function mouseGesture(mouseX:Float, mouseY:Float)
	{
		if (Input.mousePressed)
		{
			lastMouseX = mouseX;
			lastMouseY = mouseY;
			gestures = new Array<Gesture>();
		}
		else if (Input.mouseDown)
		{
			var dx:Float = mouseX - lastMouseX;
			var dy:Float = mouseY - lastMouseY;
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
				
				if (gestures.length == 0 || gesture != lastGesture)
				{
					gestures.push(gesture);
					lastGesture = gesture;
				}
				lastMouseX = mouseX;
				lastMouseY = mouseY;
			}
		}
		else if (Input.mouseReleased)
		{
			// Process gesture
		}
	}
	private var lastGesture:Gesture;
	private var gestures:Array<Gesture>;
	private var lastMouseX:Float;
	private var lastMouseY:Float;
	
	private function handleInput()
	{
		// Horizontal movement
		if (Input.check("left"))
		{
			velocity.x -= 0.1;
		}
		else if (Input.check("right"))
		{
			velocity.x += 0.1;
		}
		else
		{
			// Horizontal drag (rest at zero)
			if (velocity.x < 0)
			{
				velocity.x += 0.2;
				if (velocity.x > 0)
					velocity.x = 0;
			}
			else if (velocity.x > 0)
			{
				velocity.x -= 0.2;
				if (velocity.x < 0)
					velocity.x = 0;
			}
		}
		
		// Vertical movement
		if (Input.check("up"))
			velocity.y -= 0.1;
		else if (Input.check("down"))
			velocity.y += 0.1;
		else
		{
			// Vertical drag (rest at zero)
			if (velocity.y < 0)
			{
				velocity.y += 0.2;
				if (velocity.y > 0)
					velocity.y = 0;
			}
			else if (velocity.y > 0)
			{
				velocity.y -= 0.2;
				if (velocity.y < 0)
					velocity.y = 0;
			}
		}
	}
	
}