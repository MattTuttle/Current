package ui;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.text.TextLineMetrics;

class Announce extends Entity
{
	
	public var displaySpeed:Float;
	public var displayHold:Float;

	public function new(x:Float, y:Float, text:String, ?complete:Void->Void)
	{
		super(x, y);
		
		_field = new TextField();
		_field.embedFonts = true;
		_field.multiline = true;
		_field.defaultTextFormat = _format = new TextFormat("FontBubble", 24, 0xFFFFFF);
		_field.text = "";
		_field.autoSize = TextFieldAutoSize.LEFT;
		
		_drawable = new Sprite();
		_drawable.blendMode = BlendMode.LAYER;
		_drawable.addChild(_field);
		
		_complete = complete;
		
		_text = text;
		_index = 0;
		_angle = 0;
		originX = originY = 0;
		_waitTime = 0;
		_matrix = HXP.matrix;
		layer = -500;
		
		displaySpeed = 1 / text.length;
		displayHold = (1 - displaySpeed) * 5;
	}
	
	public var centered(getCentered, setCentered):Bool;
	private function getCentered():Bool { return _centered; }
	private function setCentered(value:Bool):Bool
	{
		_centered = value;
		if (_centered)
			_format.align = TextFormatAlign.CENTER;
		else
			_format.align = TextFormatAlign.LEFT;
		_field.setTextFormat(_format);
		return value;
	}
	
	public var color(getColor, setColor):Int;
	private function getColor():Int { return _format.color; }
	private function setColor(value:Int):Int
	{
		_format.color = value;
		_field.setTextFormat(_format);
		return value;
	}
	
	public var size(getSize, setSize):Float;
	private function getSize():Float { return _format.size; }
	private function setSize(value:Float):Float
	{
		_format.size = value;
		_field.setTextFormat(_format);
		return value;
	}
	
	public override function update()
	{
		_waitTime -= HXP.elapsed;
		if (_waitTime < 0)
		{
			if (_index < _text.length)
			{
				_field.text += _text.charAt(_index);
				_field.setTextFormat(_format);
				if (_centered)
				{
					originX = Std.int(_field.width / 2);
					originY = Std.int(_field.height / 2);
				}
				_index += 1;
				// fully shown text, wait a few seconds
				if (_index == _text.length)
					_waitTime = displayHold;
				else
					_waitTime = displaySpeed;
			}
			else
			{
				_field.alpha -= 0.01;
				if (_field.alpha < 0)
				{
					if (_complete != null)
						_complete();
					HXP.world.remove(this);
				}
			}
		}
		super.update();
	}
	
	public override function render()
	{
		_matrix.identity();
//		_matrix.translate(_camera.x, _camera.y);
		_matrix.translate(x - originX, y - originY);
		HXP.buffer.draw(_drawable, _matrix);
		super.render();
	}
	
	private var _complete:Void->Void;
	private var _centered:Bool;
	private var _angle:Float;
	private var _matrix:Matrix;
	private var _waitTime:Float;
	private var _index:Int;
	private var _text:String;
	private var _field:TextField;
	private var _drawable:Sprite;
	private var _format:TextFormat;
	
}