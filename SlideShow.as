package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;

	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import com.greensock.TweenLite;
	
	import Language;
	import AudioControl;
	
	public class SlideShow extends MovieClip {
		
		private var dicExhibitData:Object = null;
		private var lstPhoto:Array = null;
		private var soundAudio:Sound = null;
		private var audioControl:AudioControl = null;

		public function SlideShow(dicExhibitDataIn:Object, lstPhotoIn:Array, soundAudioIn:Sound) {
			// constructor code
			dicExhibitData = dicExhibitDataIn;
			lstPhoto = lstPhotoIn;
			soundAudio = soundAudioIn;
			
			audioControl = new AudioControl(soundAudio);
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			audioControl.dispose();
			audioControl = null;
			dicExhibitData = null;
			lstPhoto = null;
			soundAudio = null;
		}

		public function playSlideShow() {
			audioControl.playSound();
		}
		
		public function stopSlideShow() {
			audioControl.stopSound();
		}
		
		public function resetAndPlay() {
			audioControl.resetAndPlaySound();
		}
	}
	
}
