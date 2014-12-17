package  {
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenLite;
	import com.greensock.plugins.*;
	
	public class AudioControl extends EventDispatcher {
		
		public static const PLAY_END:String = "AudioControl.PLAY_END";
		
		private var sound:Sound = null;
		private var soundChannel:SoundChannel = null;
		private var intSoundStopPosition:Number = 0;
		private var bgSound:Sound = null;
		private var bgSoundChannel:SoundChannel = null;
		private var intCurrentBgSoundPosition:Number = 0;
		private var isFadeOut:Boolean = false;

		public function AudioControl(soundIn:Sound) {
			// constructor code
			sound = soundIn;
			var intBgSoundIndex:int = Math.floor(Math.random()*3) + 1;
			switch (intBgSoundIndex) {
				case 1:
					bgSound = new GuideBMG01();
				break;
				case 2:
					bgSound = new GuideBMG02();
				break;
				case 3:
					bgSound = new GuideBMG03();
				break;
			}
		}
		
		public function dispose() {
			isFadeOut = false;
			removeSoundChannel();
			removeBgSoundChannel();
			sound = null;
			bgSound = null;
		}
		
		public function playSound() {
			if (sound) {
				soundChannel = new SoundChannel();
				soundChannel = sound.play(intSoundStopPosition);
				soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundPlayEnd);
			}
//			if (soundChannel) {
//				TweenPlugin.activate([VolumePlugin]);
//				TweenLite.to(soundChannel, 0.2, {volume:0});
//			}
			bgSoundChannel = new SoundChannel();
			bgSoundChannel = bgSound.play(intCurrentBgSoundPosition, int.MAX_VALUE);
		}
		
		private function removeSoundChannel() {
			if (soundChannel) {
				soundChannel.stop();
				soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundPlayEnd);
			}
			soundChannel = null;
		}
		
		public function stopSound() {
			if (soundChannel) intSoundStopPosition = soundChannel.position;
			if (bgSoundChannel) intCurrentBgSoundPosition = bgSoundChannel.position;
			removeSoundChannel();
			removeBgSoundChannel();
		}
		
		public function resetAndPlaySound() {
			intSoundStopPosition = 0;
			playSound();
		}
		
		private function onSoundPlayEnd(e:Event) {
			removeSoundChannel();
			intSoundStopPosition = 0;
			intCurrentBgSoundPosition = 0;
			if (bgSoundChannel) {
				TweenPlugin.activate([VolumePlugin]);
				TweenLite.to(bgSoundChannel, 1, {volume:0, onComplete:removeBgSoundChannel});
			}
			this.dispatchEvent(new Event(AudioControl.PLAY_END));
		}
		
		private function removeBgSoundChannel() {
			if (!isFadeOut) {
				if (bgSoundChannel) bgSoundChannel.stop();
				bgSoundChannel = null;
				isFadeOut = false;
			}
		}
		
		public function getCurrentAudioPosition():Number {
			return soundChannel.position;
		}

	}
	
}
