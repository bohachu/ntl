package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.display.Bitmap;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.game.ChosePicturePannelWithNewCameraRollAndCameraUI;
	
	import I18n;
	import Titlebar;
	import GuidanceTool;
	
	public class ChosePicture extends MovieClip {
		
		public static const LOAD_PHOTO_COMPLETE:String = "ChosePicture.LOAD_PHOTO_COMPLETE";

		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var i18n:I18n = I18n.getInstance();
		private var titlebar:Titlebar = Titlebar.getInstance();
		private var guidanceTool:GuidanceTool = GuidanceTool.getInstance();
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		
		private var testTimer:Timer = null;
		
		private var chosePicturePannel:ChosePicturePannelWithNewCameraRollAndCameraUI = null;
		private var pictureBitmap:Bitmap = null;
		
		public function ChosePicture(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			titlebar.setTitlebar(i18n.get("Chose_Picture_Title"), Titlebar.TITLE_BUTTON_TYPE_HOME);
			titlebar.showTitlebar();
			guidanceTool.hideGuidanceTool();
			
			isIphone5Layout = LayoutManager.useIphone5Layout();
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			
			chosePicture();
			
			CAMEO::NO_ANE {
				testTimer = new Timer(3000, 1);
				testTimer.addEventListener(TimerEvent.TIMER, onTimer);
				testTimer.start();
			}
		}
		
		private function onTimer(e:TimerEvent) {
			removeTestTimer();
			pictureBitmap = new Bitmap(new TestPhoto());
			eventChannel.writeEvent(new Event(ChosePicture.LOAD_PHOTO_COMPLETE));
		}
		
		private function removeTestTimer() {
			if (testTimer) {
				testTimer.stop();
				testTimer.removeEventListener(TimerEvent.TIMER, onTimer);
			}
			testTimer = null;
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeTestTimer();
			removeChosePicturePannel();
		}
		
		private function changeLayoutForIphone5() {
		}
		
		private function chosePicture() {
			var strHint:String = i18n.get("Chose_Picture");
			chosePicturePannel = new ChosePicturePannelWithNewCameraRollAndCameraUI(strHint);
			chosePicturePannel.addEventListener(ChosePicturePannelWithNewCameraRollAndCameraUI.PICTURE_LOADED, onPictureLoaded);
			this.addChild(chosePicturePannel);
		}
		
		private function removeChosePicturePannel() {
			if (chosePicturePannel) {
				chosePicturePannel.removeEventListener(ChosePicturePannelWithNewCameraRollAndCameraUI.PICTURE_LOADED, onPictureLoaded);
				this.removeChild(chosePicturePannel);
			}
			chosePicturePannel = null;
		}
		
		private function onPictureLoaded(e:Event) {
			pictureBitmap = chosePicturePannel.getBitmap();
			eventChannel.writeEvent(new Event(ChosePicture.LOAD_PHOTO_COMPLETE));
		}
		
		public function getBitmap():Bitmap {
			return pictureBitmap;
		}
	}
	
}
