package sdg.audio;

import kha.Sound;
import kha.Assets;
import kha.audio1.Audio;

class SoundBank
{
	/**
	 * Name of the bank (e.g., "fx", "music", "sfx")
	 */
	public var name:String;
	
	/**
	 * Map of sound names to Sound objects
	 */
	public var sounds:Map<String, Sound>;
	
	/**
	 * Base volume for sounds in this bank (1.0 = full volume)
	 */
	public var volume:Float = 1.0;
	
	/**
	 * Whether sounds in this bank should loop
	 */
	public var loop:Bool = false;
	
	public function new(name:String):Void
	{
		this.name = name;
		sounds = new Map<String, Sound>();
	}
	
	/**
	 * Adds a sound to the bank
	 */
	public function addSound(soundName:String, loadCallback:Sound->Void):Void
	{
		var sound = Assets.sounds.get(soundName);
		if (sound != null)
		{
			sounds.set(soundName, sound);
			loadCallback(sound);
		}
		else
		{
			// Load from path if available
			Assets.loadSoundFromPath('sounds/' + soundName + '.ogg', function(sound:Sound):Void {
				sounds.set(soundName, sound);
				loadCallback(sound);
			});
		}
	}
	
	/**
	 * Plays a sound from this bank
	 */
	public function play(soundName:String):Void
	{
		var sound = sounds.get(soundName);
		if (sound != null)
		{
			var channel = Audio.play(sound, loop);
			channel.volume = volume;
		}
	}
	
	/**
	 * Loads all sounds in the bank
	 */
	public function loadAll():Void
	{
		// Load each sound
		for (soundName in sounds.keys())
		{
			Assets.loadSound(soundName, function(sound:Sound):Void {
				// Called after all sounds loaded
			});
		}
	}
}
