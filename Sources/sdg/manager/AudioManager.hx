package sdg.manager;

import sdg.audio.SoundBank;
import kha.Sound;
import kha.Assets;
import kha.audio1.Audio;
import kha.audio1.AudioChannel;
import sdg.manager.Manager;

class AudioManager extends Manager
{
	/**
	 * Master volume (0.0 = silent, 1.0 = full volume)
	 */
	public var masterVolume(default, set):Float;
	
	/**
	 * Sound banks for organized audio management
	 * Banks help you group sounds (e.g., "fx", "music", "sfx")
	 */
	public var banks(default, set):Map<String, SoundBank>;
	
	/**
	 * Current music playing
	 */
	public var currentMusic(default, set):Music;
	
	/**
	 * Queue of pending sound effects
	 */
	public var effectQueue:Array<AudioEffect>;
	
	/**
	 * Whether to loop music when it ends
	 */
	public var musicLoop:Bool;
	
	/**
	 * active audio Channels
	 */
	public var channels:Array<AudioChannel>;

	public static var manager:AudioManager;
	
	public function new():Void
	{
		super();
		
		banks = new Map<String, SoundBank>();
		effectQueue = new Array<AudioEffect>();
		musicLoop = false;
		channels = new Array<AudioChannel>();
		masterVolume = 1.0;
		manager = this;
	}
	
	/**
	 * Plays a sound effect
	 */
	public function playSound(soundName:String, ?bankName:String):Void
	{
		var sound = getSound(bankName, soundName);
		if (sound == null) return;
		
		var channel = Audio.play(sound, false);
		if (channel != null)
		{
			// Apply master volume
			channel.volume = masterVolume;
			// Apply bank-specific volume if set
			var bank = banks.get(bankName);
			if (bank != null)
			{
				channel.volume *= bank.volume;
			}

            channels.push(channel);
		}
	}
	
	/**
	 * Plays a looping music track
	 */
	public function playMusic(soundName:String, ?bankName:String):Void
	{
		var sound = getSound(bankName, soundName);
		if (sound == null) return;
		var channel = Audio.play(sound, true); // Loop = true
		if (channel != null)
		{
			// Apply master volume
			channel.volume = masterVolume;
			// Apply bank-specific volume if set
			var bank = banks.get(bankName);
			if (bank != null)
			{
				channel.volume *= bank.volume;
			}
			else if (bankName != null)
			{
				banks.set(bankName,new SoundBank(bankName));
			}
			
			currentMusic = {
				channel: channel,
				soundName: soundName,
				bankName: bankName,
				startTime: Sdg.time(),
                paused: false
			};

            channels.push(channel);
		}
	}
	
	/**
	 * Stops current music
	 */
	public function stopMusic():Void
	{
		if (currentMusic != null)
		{
			currentMusic.channel.stop();
			currentMusic = null;
		}
	}
	
	/**
	 * Pauses/resumes music
	 */
	public function pauseMusic(pause:Bool):Void
	{
		if (currentMusic != null)
		{
			currentMusic.channel.pause();
			currentMusic.paused = pause;
		}
	}
	
	/**
	 * Queues a sound effect to play after others finish
	 */
	public function queueSound(soundName:String, ?bankName:String):Void
	{
		effectQueue.push({
			soundName: soundName,
			bankName: bankName
		});
	}
	
	/**
	 * Gets sound from bank or directly from assets
	 */
	private function getSound(?bankName:String, soundName:String):Sound
	{
		if (bankName != null && banks.exists(bankName))
		{
			var bank = banks.get(bankName);
			if (bank != null && bank.sounds.exists(soundName))
			{
				return bank.sounds.get(soundName);
			}
		}
		
		return Assets.sounds.get(soundName);
	}
	
	/**
	 * Updates music state based on time
	 */
	public override function update():Void
	{
		if (effectQueue.length > 0)
		{
			// Play queued sounds
			for (effect in effectQueue)
			{
				playSound(effect.soundName, effect.bankName);
			}
			effectQueue = [];
		}
		
		// Handle music
		if (currentMusic != null && !currentMusic.paused)
		{
			var elapsed = Sdg.time() - currentMusic.startTime;
			var sound = currentMusic.channel;
			
			if (sound.finished)
			{
				if (musicLoop)
				{
					playMusic(currentMusic.soundName, currentMusic.bankName);
				}
				else
				{
					stopMusic();
				}
			}
		}
        for (channel in channels)
        {
            if (channel != null && channel.finished)
            {
                channels.remove(channel);
            }
        }
	}

	function set_masterVolume(value:Float):Float
	{
		masterVolume = Sdg.clamp(value, 0.0, 1.0);
		// Update all active channels
		for (channel in channels)
		{
			if (channel != null && !channel.finished)
			{
				channel.volume = masterVolume;
			}
		}
		
		return masterVolume;
	}
	
	function set_banks(value:Map<String, SoundBank>):Map<String, SoundBank>
	{
		banks = value;
		return value;
	}
	
	function set_currentMusic(value:Music):Music
	{
		currentMusic = value;
		return value;
	}

	public function addBank(name:String)
	{
		if(banks.get(name) == null)
		{
			banks.set(name, new SoundBank(name));
		}
	}
}

typedef AudioEffect = {
	var soundName:String;
	var bankName:Null<String>;
}

typedef Music = {
	var channel:AudioChannel;
	var soundName:String;
	var bankName:Null<String>;
	var startTime:Float;
	var paused:Bool;
};
