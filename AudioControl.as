package  {
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	public class AudioControl {
		
		private var sound:Sound = null;
		private var soundChannel:SoundChannel = null;
		private var intCurrentPosition:Number = 0;

		public function AudioControl(soundIn:Sound) {
			// constructor code
			sound = soundIn;
			soundChannel = new SoundChannel();
		}
		
		public function dispose() {
			soundChannel.stop();
			soundChannel = null;
			sound = null;
		}
		
		public function playSound() {
			soundChannel = sound.play(intCurrentPosition);
		}
		
		public function stopSound() {
			intCurrentPosition = soundChannel.position;
			soundChannel.stop();
		}
		
		public function resetAndPlaySound() {
			intCurrentPosition = 0;
			playSound();
		}

	}
	
}
