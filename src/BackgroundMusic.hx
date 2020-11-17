import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxepunk.HXP;
import haxepunk.assets.AssetCache;

#if (js && hxmod)

import js.html.audio.AudioContext;

class BackgroundMusic
{
	static var volume:Float = 1;
	@:const static var numChannels:Int = 2;
	@:const static var sampleRate:Int = 44100;
	static var context:AudioContext;
	static var player:xm.Player;
	static var startTime:Float = 0;
	static var bufferOffset:Float = 0;

	public static function play(path:String)
	{
		if (context == null) context = new AudioContext();
		var bytes = AssetCache.global.getBytes(path);
		var input = new BytesInput(bytes);
		var song = xm.Loader.load(input);
		player = new xm.Player(song, sampleRate);
		player.volume = Std.int(HXP.volume * 0x10);
		startTime = 0;
		createSource(0.5);
	}

    static function createSource(duration:Float) {
        var bufferLen = Std.int(sampleRate * duration);
        var source = context.createBufferSource();
        var buffer = context.createBuffer(numChannels, bufferLen, sampleRate);
        player.fillBuffer(buffer, Std.int(sampleRate * bufferOffset), bufferLen);
        source.buffer = buffer;
        source.connect(context.destination);
		source.start(startTime + bufferOffset);
		bufferOffset += duration;
    }

	public static function update()
	{
		if (context == null) return;
		player.volume = Std.int(HXP.volume * 0x10);
		var elapsed = context.currentTime - startTime;
		if (bufferOffset - elapsed < 0.1) {
			createSource(0.5);
		}
	}
}

#elseif audaxe

class BackgroundMusic
{
	public static var backgroundMusic:audaxe.Channel;

	public static function play(path:String)
	{
		if (backgroundMusic == null)
		{
			backgroundMusic = audaxe.Engine.createChannel();
		}

		backgroundMusic.sound = audaxe.Sound.loadTracker(path);
		backgroundMusic.sound.play();
	}

	public static function update()
	{
		audaxe.Engine.volume = HXP.volume;
	}
}

#else

// null player
class BackgroundMusic
{
	public static function play(path:String) {}
	public static function update() {}
}

#end
