package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.media.Sound;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;

	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import com.greensock.TweenLite;
	
	import Language;
	import AudioControl;
	
	public class SlideShow extends MovieClip {
		
		public static const PLAY_END:String = "SlideShow.PLAY_END";
		
		private var language:Language = Language.getInstance();
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = (LayoutManager.useIphone5Layout()) ? LayoutSettings.intDefaultHeightForIphone5 : LayoutSettings.intDefaultHeight;
		
		private var strLanguageType:String = language.getLanguageType();
		private var dicExhibitData:Object = null;
		private var lstImageInfo:Array = null;
		private var lstPhotoShowTime:Array = null;
		private var lstPhoto:Array = null;
		private var soundAudio:Sound = null;
		private var intAudioLength:Number = 0;
		private var audioControl:AudioControl = null;
		private var intCurrentPhotoIndex:int = 0;
		private var intPhotoTransformSec:int = 1.5;
		private var intPhotoShowTime:int = 3500;
		private var photoShowTimer:Timer = null;
		private var photoContainer:Sprite = null;

		public function SlideShow(dicExhibitDataIn:Object, lstPhotoIn:Array, soundAudioIn:Sound) {
			// constructor code
			dicExhibitData = dicExhibitDataIn;
			lstImageInfo = dicExhibitData["lstImageInfo"];
			lstPhoto = lstPhotoIn;
			soundAudio = soundAudioIn;
			intAudioLength = soundAudio.length;
			
			cloneLstImageInfoToLstPhotoShowTime();
			adjustPhoto();
			initSlideShow();
			
			audioControl = new AudioControl(soundAudio);
			audioControl.addEventListener(AudioControl.PLAY_END, onSoundPlayEnd);
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function cloneLstImageInfoToLstPhotoShowTime() {
			lstPhotoShowTime = lstImageInfo.concat();
			lstPhotoShowTime.shift();
			
			if (lstPhotoShowTime[i]["ENU"] != "") return;
			intPhotoShowTime = intAudioLength / lstPhoto.length;
			for (var i:int = 0; i<lstPhotoShowTime.length; i++) {
				lstPhotoShowTime[i]["ENU"] = intPhotoShowTime * (i+1);
				lstPhotoShowTime[i]["JPN"] = intPhotoShowTime * (i+1);
			}
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removePhotoShowTimer();
			removePhotoContainer();
			audioControl.removeEventListener(AudioControl.PLAY_END, onSoundPlayEnd);
			audioControl.dispose();
			audioControl = null;
			dicExhibitData = null;
			lstPhotoShowTime = null;
			lstImageInfo = null;
			lstPhoto = null;
			soundAudio = null;
		}
		
		private function adjustPhoto() {
			for (var i:int = 0; i<lstPhoto.length; i++) {
				(lstPhoto[i] as Bitmap).alpha = 0;
				setImageSizePostion(lstPhoto[i] as Bitmap);
			}
		}
		
		private function initSlideShow() {
			this.alpha = 0;
			initPhoto();
			initPhotoShowTimer();
			TweenLite.to(this, intPhotoTransformSec, {alpha:1});
		}
		
		private function initPhoto() {
			photoContainer = new Sprite();
			this.addChild(photoContainer);
			lstPhoto[intCurrentPhotoIndex].alpha = 1;
			photoContainer.addChild(lstPhoto[intCurrentPhotoIndex]);
		}
		
		private function removePhotoContainer() {
			this.removeChild(photoContainer);
			photoContainer.removeChildren();
			photoContainer = null;
		}
		
		private function initPhotoShowTimer() {
			photoShowTimer = new Timer(10);
			photoShowTimer.addEventListener(TimerEvent.TIMER, onPhotoShowTimer);
		}
		
		private function removePhotoShowTimer() {
			if (photoShowTimer) {
				photoShowTimer.stop();
				photoShowTimer.removeEventListener(TimerEvent.TIMER, onPhotoShowTimer);
			}
			photoShowTimer = null;
		}
		
		private function onPhotoShowTimer(e:TimerEvent) {
			var intCurrentAudioPosition:Number = audioControl.getCurrentAudioPosition();
			var strCurrentTime:String = getTimeString(int(intCurrentAudioPosition/10));
			var isLargerThanNextPhotoTime:Boolean = false;

			if (lstImageInfo[0][strLanguageType] != "") {
				isLargerThanNextPhotoTime = (strCurrentTime > lstPhotoShowTime[0][strLanguageType]);
			} else {
				isLargerThanNextPhotoTime = (intCurrentAudioPosition > lstPhotoShowTime[0][strLanguageType]);
			}
			
//			trace("SlideShow.as / onPhotoShowTimer: intCurrentAudioPosition, strCurrentTime, photoTime", intCurrentAudioPosition, strCurrentTime, lstPhotoShowTime[0][strLanguageType]);

			if (isLargerThanNextPhotoTime && intCurrentPhotoIndex != lstPhoto.length-1) {
				trace("SlideShow.as / onPhotoShowTimer: removeOldPhotoAndAddNewPhoto");
				var intNextPhotoIndex:int = (intCurrentPhotoIndex+1 < lstPhoto.length) ? intCurrentPhotoIndex+1 : 0;
				intCurrentPhotoIndex = intNextPhotoIndex;
				lstPhotoShowTime.shift();
				
				if (lstPhotoShowTime.length == 0) {
					cloneLstImageInfoToLstPhotoShowTime();
				}
				
				removeOldPhotoAndAddNewPhoto();
			}
		}
		
		private function removeOldPhotoAndAddNewPhoto() {
			var currentBitmap:Bitmap = photoContainer.getChildAt(0) as Bitmap;
			TweenLite.to(currentBitmap, intPhotoTransformSec, {alpha:0, onComplete:removePhoto, onCompleteParams:[currentBitmap]});
			photoContainer.addChild(lstPhoto[intCurrentPhotoIndex]);
			TweenLite.to(lstPhoto[intCurrentPhotoIndex], intPhotoTransformSec, {alpha:1});
		}
		
		private function removePhoto(photo:Bitmap) {
			if (photoContainer) photoContainer.removeChild(photo);
		}

		public function playSlideShow() {
			photoShowTimer.start();
			audioControl.playSound();
		}
		
		public function stopSlideShow() {
			photoShowTimer.stop();
			audioControl.stopSound();
		}
		
		public function resetAndPlay() {
			audioControl.resetAndPlaySound();
			intCurrentPhotoIndex = 0;
			removeOldPhotoAndAddNewPhoto();
			cloneLstImageInfoToLstPhotoShowTime();
			photoShowTimer.start();
		}
		
		private function onSoundPlayEnd(e:Event) {
			photoShowTimer.stop();
			intCurrentPhotoIndex = 0;
			removeOldPhotoAndAddNewPhoto();
			this.dispatchEvent(new Event(SlideShow.PLAY_END));
		}
		
		private function setImageSizePostion(image:Bitmap) {
			var intScaleRatio:Number = (image.width/image.height > intDefaultWidth/intDefaultHeight) ? intDefaultHeight/image.height : intDefaultWidth/image.width;
			image.width *= intScaleRatio;
			image.height *= intScaleRatio;
			image.x = -(image.width - intDefaultWidth)/2;
			image.y = -(image.height - intDefaultHeight)/2;
		}
		
		private function getTimeString(intCurrentAudioPosition:int):String {
			var intHour:int = intCurrentAudioPosition / 360000;
			var strHour:String = (intHour < 10) ? "0" + String(intHour) : String(intHour);
			var intRemainTime:int = intCurrentAudioPosition % 360000;
			var intMinute:int = intRemainTime / 6000;
			var strMinute:String = (intMinute < 10) ? "0" + String(intMinute) : String(intMinute);
			intRemainTime = intRemainTime % 6000;
			var intSecond:int = intRemainTime / 100;
			intRemainTime = intRemainTime % 100;
			var strSecond:String = (intSecond < 10) ? "0" + String(intSecond) : String(intSecond);
			var strMillisecond:String = (intRemainTime < 10) ? "0" + String(intRemainTime) : String(intRemainTime);
			var strTimeString:String = strHour + ":" + strMinute + ":" + strSecond + "," + strMillisecond;
			
			return strTimeString;
		}
	}
	
}
