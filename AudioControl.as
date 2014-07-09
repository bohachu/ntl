package  {
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class AudioControl extends EventDispatcher {
		
		public static const PLAY_END:String = "AudioControl.PLAY_END";
		
		private var sound:Sound = null;
		private var soundChannel:SoundChannel = null;
		private var intCurrentPosition:Number = 0;

		public function AudioControl(soundIn:Sound) {
			// constructor code
			sound = soundIn;
		}
		
		public function dispose() {
			removeSoundChannel();
			sound = null;
		}
		
		public function playSound() {
			soundChannel = new SoundChannel();
			soundChannel = sound.play(intCurrentPosition);
			soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundPlayEnd);
		}
		
		private function removeSoundChannel() {
			if (soundChannel) {
				soundChannel.stop();
				soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundPlayEnd);
			}
			soundChannel = null;
		}
		
		public function stopSound() {
			intCurrentPosition = soundChannel.position;
			removeSoundChannel();
		}
		
		public function resetAndPlaySound() {
			intCurrentPosition = 0;
			playSound();
		}
		
		private function onSoundPlayEnd(e:Event) {
			removeSoundChannel();
			intCurrentPosition = 0;
			this.dispatchEvent(new Event(AudioControl.PLAY_END));
		}

	}
	
}
