import haxepunk.HXP;

#if audaxe

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
