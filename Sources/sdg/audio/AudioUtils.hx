package sdg;

import kha.audio2.Audio;
import kha.audio2.AudioChannel;

class AudioUtils
{
	/**
	 * Gets current audio state
	 */
	public static function getChannelStatus(channel:AudioChannel):String
	{
		return "Position: ${channel.position}s, Volume: ${channel.volume}, Playing: ${!channel.finished}";
	}
}
