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
		
		private var dicExhibitData:Object = null;
		private var lstImageInfo:Array = null;
		private var lstPhoto:Array = null;
		private var soundAudio:Sound = null;
		private var intAudioLength:Number = 0;
		private var intCurrentAudioPosition:Number = 0;
		private var audioControl:AudioControl = null;
		private var intCurrentPhotoIndex:int = 0;
		private var intPhotoTransformSec:int = 1.5;
		private var intPhotoShowTime:int = 3500;
		private var photoShowTimer:Timer = null;
		private var photoContainer:Sprite = null;
		private var imageTitleContainer:Sprite = null;
		private var imageTitleText:TextField = null;
		private var imageTitleTextFormat:TextFormat = null;
		private var isOnAir:Boolean = false;

		public function SlideShow(dicExhibitDataIn:Object, lstPhotoIn:Array, soundAudioIn:Sound) {
			// constructor code
			dicExhibitData = dicExhibitDataIn;
			lstImageInfo = dicExhibitData["lstImageInfo"];
			lstPhoto = lstPhotoIn;
			soundAudio = soundAudioIn;
			intAudioLength = soundAudio.length;
			intCurrentAudioPosition = 0;
			adjustPhoto();
			
			initSlideShow();
			
			audioControl = new AudioControl(soundAudio);
			audioControl.addEventListener(AudioControl.PLAY_END, onSoundPlayEnd);
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removePhotoShowTimer();
			removeImageTitle();
			removePhotoContainer();
			audioControl.removeEventListener(AudioControl.PLAY_END, onSoundPlayEnd);
			audioControl.dispose();
			audioControl = null;
			dicExhibitData = null;
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
			initImageTitle();
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
		
		private function initImageTitle() {
			imageTitleContainer = new Sprite();
			imageTitleContainer.y = intDefaultHeight;
//			this.addChild(imageTitleContainer);
			var bg:Sprite = new Sprite();
			bg.graphics.beginFill(0, 0.8);
			bg.graphics.drawRect(0, 0, 640, 480);
			bg.graphics.endFill();
			imageTitleContainer.addChild(bg);
			
			initImageTitleTextField();
			setImageTitle(getImageTitle(intCurrentPhotoIndex));
		}
		
		private function initImageTitleTextField() {
			imageTitleTextFormat = new TextFormat();
			imageTitleText = new TextField();
			imageTitleText.width = 600;
			imageTitleText.multiline = true;
			imageTitleText.wordWrap = true;
			imageTitleText.autoSize = TextFieldAutoSize.LEFT;
			imageTitleText.selectable = false;
			imageTitleTextFormat.size = 35;
			imageTitleTextFormat.font = "Arial, _san";
			imageTitleTextFormat.color = 0xffffff;
			imageTitleText.setTextFormat(imageTitleTextFormat);
			imageTitleText.y = imageTitleText.x = 20;
			imageTitleContainer.addChild(imageTitleText);
		}
		
		private function removeImageTitle() {
//			this.removeChild(imageTitleContainer);
			imageTitleContainer.removeChild(imageTitleText);
			imageTitleText = null;
			imageTitleTextFormat = null;
			imageTitleContainer = null;
		}
		
		private function setImageTitle(strContent:String) {
			imageTitleText.text = strContent;
			imageTitleText.setTextFormat(imageTitleTextFormat);
			var intY:int = intDefaultHeight - (imageTitleText.height + 40);
			imageTitleContainer.y = intY;
		}
		
		private function getImageTitle(intPhotoIndex:int):String {
			var strImageNumber:String = (intPhotoIndex+1 >= 10) ? String(intPhotoIndex+1) : "0" + String(intPhotoIndex+1);
			var strKeyName:String = "Image" + strImageNumber + "_" + language.getLanguageType();
			
			return lstImageInfo[intPhotoIndex][strKeyName];
		}
		
		private function initPhotoShowTimer() {
			intPhotoShowTime = Math.floor(((intAudioLength - (lstPhoto.length-1)*1000) / lstPhoto.length)/100) * 100;
			trace(intAudioLength, intCurrentAudioPosition, lstPhoto.length, intPhotoShowTime);
			photoShowTimer = new Timer(intPhotoShowTime, lstPhoto.length-1);
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
			photoShowTimer.stop();
			if (photoShowTimer.delay != intPhotoShowTime) photoShowTimer.delay = intPhotoShowTime;
			var intNextPhotoIndex:int = (intCurrentPhotoIndex+1 < lstPhoto.length) ? intCurrentPhotoIndex+1 : 0;
			intCurrentPhotoIndex = intNextPhotoIndex;
			removeOldPhotoAndAddNewPhoto();
//			setImageTitle(getImageTitle(intCurrentPhotoIndex));
		}
		
		private function removeOldPhotoAndAddNewPhoto() {
			var currentBitmap:Bitmap = photoContainer.getChildAt(0) as Bitmap;
			TweenLite.to(currentBitmap, intPhotoTransformSec, {alpha:0, onComplete:removePhoto, onCompleteParams:[currentBitmap]});
			photoContainer.addChild(lstPhoto[intCurrentPhotoIndex]);
			TweenLite.to(lstPhoto[intCurrentPhotoIndex], intPhotoTransformSec, {alpha:1});
		}
		
		private function removePhoto(photo:Bitmap) {
			if (photoShowTimer && isOnAir) photoShowTimer.start();
			if (photoContainer) photoContainer.removeChild(photo);
		}

		public function playSlideShow() {
			isOnAir = true;
			photoShowTimer.start();
			audioControl.playSound();
		}
		
		public function stopSlideShow() {
			isOnAir = false;
			photoShowTimer.stop();
			audioControl.stopSound();
			intCurrentAudioPosition = audioControl.getCurrentAudioPosition();
			setNextPhotoTimerDelay();
		}
		
		public function resetAndPlay() {
			isOnAir = true;
			photoShowTimer.delay = intPhotoShowTime;
			photoShowTimer.start();
			audioControl.resetAndPlaySound();
			intCurrentAudioPosition = 0;
			intCurrentPhotoIndex = 0;
			removeOldPhotoAndAddNewPhoto();
		}
		
		private function onSoundPlayEnd(e:Event) {
			isOnAir = false;
			intCurrentAudioPosition = 0;
			photoShowTimer.stop();
			photoShowTimer.delay = intPhotoShowTime;
			this.dispatchEvent(new Event(SlideShow.PLAY_END));
		}
		
		private function setImageSizePostion(image:Bitmap) {
			var intScaleRatio:Number = (image.width/image.height > intDefaultWidth/intDefaultHeight) ? intDefaultHeight/image.height : intDefaultWidth/image.width;
			image.width *= intScaleRatio;
			image.height *= intScaleRatio;
			image.x = -(image.width - intDefaultWidth)/2;
			image.y = -(image.height - intDefaultHeight)/2;
		}
		
		private function setNextPhotoTimerDelay() {
			var intNextShowPhotoTime:Number = (intCurrentPhotoIndex+1)*intPhotoShowTime + intCurrentPhotoIndex*1000;
			var intDiffTime:Number = Math.floor((intNextShowPhotoTime - intCurrentAudioPosition)/100) * 100;
			photoShowTimer.delay = intDiffTime;
		}
	}
	
}
