package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.filesystem.File;
	import flash.media.CameraRoll;
	import flash.media.Sound;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.AddGestouchControl;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import ane.lib.VideoNativeExtensionEvents;
	import tw.cameo.ToastMessage;
	
	CAMEO::ANE {
		import ane.lib.VideoNativeExtension;
	}
	
	import I18n;
	import Titlebar;
	import GuidanceTool;
	import LoadingScreen;
	
	public class TakeAPolaroid extends MovieClip {

		public static const TAKE_PICTURE_COMPLETE:String = "TakeAPolaroid.TAKE_PICTURE_COMPLETE";

		private const strPhotoFile:String = "Polaroid.jpg"
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var i18n:I18n = I18n.getInstance();
		private var titlebar:Titlebar = Titlebar.getInstance();
		private var guidanceTool:GuidanceTool = GuidanceTool.getInstance();
		
		private var isIphone5Layout:Boolean = LayoutManager.useIphone5Layout();
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = (isIphone5Layout) ? LayoutSettings.intDefaultHeightForIphone5 : LayoutSettings.intDefaultHeight;
		
		private var bg:Sprite = null;
		private var loadingScreen:LoadingScreen = null;
		private var polaroidPhotoContainer:Sprite = null;
		private var photoBitmap:Bitmap = null;
		private var photoContainer:Sprite = null;
		private var intPhotoWidth:int = 480;
		private var intPhotoHeight:int = 550;
		private var photoContainerPoint:Point = new Point(75, (isIphone5Layout) ? 200 : 130);
		private var photoGestouchControl:AddGestouchControl = null;
		private var photoMask:Sprite = null;
		private var frameContainer:Sprite = null;
		private var intCurrentSelectFrame = 0;
		
		private var prevBtn:SimpleButton = null;
		private var prevBtnPoint:Point = new Point(7, (isIphone5Layout) ? 477 : 380);
		private var nextBtn:SimpleButton = null;
		private var nextBtnPoint:Point = new Point(596, (isIphone5Layout) ? 477 : 380);
		
		private var snapShotBitmap:Bitmap = null;
		private var cameraRoll:CameraRoll = null;
		private var cameraSound:Sound = null;
		
		CAMEO::ANE {
			private var ext:VideoNativeExtension = null;
		}
		
		public function TakeAPolaroid(photoBitmapIn:Bitmap) {
			// constructor code
			photoBitmap = photoBitmapIn;
			CAMEO::ANE {
				ext = new VideoNativeExtension();
			}
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			titlebar.setTitlebar(i18n.get("Chose_Frame"), Titlebar.TITLE_BUTTON_TYPE_BACK, Titlebar.TITLE_BUTTON_TYPE_OK);
			titlebar.showTitlebar();
			guidanceTool.hideGuidanceTool();
			
			isIphone5Layout = LayoutManager.useIphone5Layout();
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			
			createBackground();
			initContainer();
			initPhoto();
			initFrame();
			showFrame();
			setChangeFrameButton();
			titlebar.addEventListener(Titlebar.CLICK_OK, onOkToSavePhoto);
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			eventChannel.removeEventListener(ToastMessage.CLICK_OK, backToHome);
			eventChannel.removeEventListener(ToastMessage.CLICK_OK, onConfirmToShare);
			titlebar.removeEventListener(Titlebar.CLICK_OK, onOkToSavePhoto);
			removeLoadingScreen();
			removeCameraRoll();
			removePhoto();
			removePhotoMask();
			removeContainer();
			removeBackground();
			photoContainerPoint = null;
			prevBtnPoint = null;
			nextBtnPoint = null;
			snapShotBitmap = null;
			
			CAMEO::ANE {
				ext.removeEventListener(VideoNativeExtensionEvents.IMAGE_TO_JPEG_SAVED, onJpgSaved);
				ext.dispose();
				ext = null;
			}
		}
		
		private function changeLayoutForIphone5() {
		}
		
		private function createBackground() {
			bg = new BackgroundSprite();
			this.addChild(bg);
		}
		
		private function removeBackground() {
			if (bg) this.removeChild(bg);
			bg = null;
		}
		
		private function initLoadingScreen() {
			if (loadingScreen == null) loadingScreen = new LoadingScreen(this.parent);
		}
		
		private function removeLoadingScreen() {
			if (loadingScreen) loadingScreen.dispose();
			loadingScreen = null;
		}
		
		private function initContainer() {
			polaroidPhotoContainer = new Sprite();
			polaroidPhotoContainer.y = intDefaultHeight;
			photoContainer = new Sprite();
			photoMask = new Sprite();
			photoMask.graphics.beginFill(0x999999);
			photoMask.graphics.drawRect(0, 0, 640, 1136);
			photoMask.graphics.endFill();
			photoMask.mouseChildren = false;
			photoMask.mouseEnabled = false;
			frameContainer = new Sprite();
			frameContainer.mouseChildren = false;
			frameContainer.mouseEnabled = false;
			this.addChild(polaroidPhotoContainer);
			polaroidPhotoContainer.addChild(photoContainer);
			polaroidPhotoContainer.addChild(photoMask);
			polaroidPhotoContainer.addChild(frameContainer);
		}
		
		private function removeContainer() {
			this.removeChild(polaroidPhotoContainer);
			polaroidPhotoContainer.removeChild(photoContainer);
			polaroidPhotoContainer.removeChild(frameContainer);
			photoContainer = null;
			photoContainerPoint = null;
			frameContainer = null;
			polaroidPhotoContainer = null;
		}
		
		private function initPhoto() {
			photoContainer.x = photoContainerPoint.x;
			photoContainer.y = photoContainerPoint.y;
			photoContainer.addChild(photoBitmap);
			setImageSizePostion(photoContainer);
			photoGestouchControl = new AddGestouchControl(photoContainer);
		}
		
		private function removePhoto() {
			photoGestouchControl.dispose();
			photoGestouchControl = null;
			photoContainer.removeChild(photoBitmap);
			photoBitmap = null;
		}
		
		private function initFrame() {
			var date:Date = new Date();
			var strDate:String = String(date.fullYear) + "." + String(date.month+1) + "." + String(date.date);
			var frame1:MovieClip = (isIphone5Layout) ? new PolaroidFrame1Iphone5() : new PolaroidFrame1Iphone4();
			var frame2:MovieClip = (isIphone5Layout) ? new PolaroidFrame2Iphone5() : new PolaroidFrame2Iphone4();
			var frame3:MovieClip = (isIphone5Layout) ? new PolaroidFrame3Iphone5() : new PolaroidFrame3Iphone4();
			var frame4:MovieClip = (isIphone5Layout) ? new PolaroidFrame4Iphone5() : new PolaroidFrame4Iphone4();
			frame1.dateLabel.text = frame2.dateLabel.text = frame3.dateLabel.text = frame4.dateLabel.text = strDate;
			frame1.x = 0;
			frame2.x = 640;
			frame3.x = 1280;
			frame4.x = 1920;
			frameContainer.addChild(frame1);
			frameContainer.addChild(frame2);
			frameContainer.addChild(frame3);
			frameContainer.addChild(frame4);
		}
		
		private function removeFrame() {
			while (frameContainer.numChildren) {
				var frame:MovieClip = frameContainer.getChildAt(0) as MovieClip;
				frameContainer.removeChild(frame);
				frame = null;
			}
		}
		
		private function showFrame() {
			cameraSound = new CameraSound();
			cameraSound.play();
			TweenLite.to(polaroidPhotoContainer, 2, {y:0, onComplete:fadeOutPhotoMask});			
		}
		
		private function fadeOutPhotoMask() {
			TweenLite.to(photoMask, 4, {alpha:0, onComplete:removePhotoMask});
		}
		
		private function removePhotoMask() {
			if (photoMask) polaroidPhotoContainer.removeChild(photoMask);
			photoMask = null;
		}
		
		private function setChangeFrameButton() {
			if (intCurrentSelectFrame == 0) removePrevButton(); 
			if (intCurrentSelectFrame != 0) createPrevButton();
			if (intCurrentSelectFrame != 3) createNextButton();
			if (intCurrentSelectFrame == 3) removeNextButton();
		}
		
		private function createPrevButton() {
			if (prevBtn == null) {
				prevBtn = new ChangeToPrevFrameButton();
				prevBtn.x = prevBtnPoint.x;
				prevBtn.y = prevBtnPoint.y;
				prevBtn.addEventListener(MouseEvent.CLICK, onChangeFrameBtnClick);
				this.addChild(prevBtn);
			}
		}
		
		private function createNextButton() {
			if (nextBtn == null) {
				nextBtn = new ChangeToNextFrameButton();
				nextBtn.x = nextBtnPoint.x;
				nextBtn.y = nextBtnPoint.y;
				nextBtn.addEventListener(MouseEvent.CLICK, onChangeFrameBtnClick);
				this.addChild(nextBtn);
			}
		}
		
		private function removePrevButton() {
			if (prevBtn) {
				prevBtn.removeEventListener(MouseEvent.CLICK, onChangeFrameBtnClick);
				this.removeChild(prevBtn);
			}
			prevBtn = null;
		}
		
		private function removeNextButton() {
			if (nextBtn) {
				nextBtn.removeEventListener(MouseEvent.CLICK, onChangeFrameBtnClick);
				this.removeChild(nextBtn);
			}
			nextBtn = null;
		}
		
		private function onChangeFrameBtnClick(e:MouseEvent) {
			if (e.target is ChangeToPrevFrameButton) intCurrentSelectFrame--;
			if (e.target is ChangeToNextFrameButton) intCurrentSelectFrame++;
			if (intCurrentSelectFrame < 0) intCurrentSelectFrame = 0;
			if (intCurrentSelectFrame > 3) intCurrentSelectFrame = 3;
			setChangeFrameButton();
			TweenLite.to(frameContainer, 1, {x:-intCurrentSelectFrame*640, ease:Strong.easeOut});
		}
		
		private function onOkToSavePhoto(e:Event) {
			initLoadingScreen();
			titlebar.removeEventListener(Titlebar.CLICK_OK, onOkToSavePhoto);
			var snapShotBitmapData:BitmapData = new BitmapData(640, intDefaultHeight-titlebar.intTitlebarHeight);
			snapShotBitmapData.draw(polaroidPhotoContainer, new Matrix(1, 0, 0, 1, 0, -titlebar.intTitlebarHeight));
			snapShotBitmap = new Bitmap(snapShotBitmapData);
			
			var jpgFile:File = File.applicationStorageDirectory.resolvePath(strPhotoFile);
			var strJpgSavePath:String = jpgFile.nativePath;
			CAMEO::NO_ANE {
				onJpgSaved();
			}
			CAMEO::ANE {
				ext.addEventListener(VideoNativeExtensionEvents.IMAGE_TO_JPEG_SAVED, onJpgSaved);
				ext.saveToJpeg(snapShotBitmapData, strJpgSavePath);
			}
		}
		
		private function onJpgSaved(e:Event = null) {
			CAMEO::ANE {
				ext.writeConsole("TakeAPolaroid.as/onJpgSaved.");
				ext.removeEventListener(VideoNativeExtensionEvents.IMAGE_TO_JPEG_SAVED, onJpgSaved);
				cameraRoll = new CameraRoll();
				cameraRoll.addEventListener(Event.COMPLETE, onSaveToCameraRollComplete);
				cameraRoll.addEventListener(ErrorEvent.ERROR, onSaveToCameraRollFail);
				cameraRoll.addBitmapData(snapShotBitmap.bitmapData);
			}
			CAMEO::NO_ANE {
				onSaveToCameraRollComplete();
			}
		}
		
		private function removeCameraRoll() {
			CAMEO::ANE {
				cameraRoll.removeEventListener(Event.COMPLETE, onSaveToCameraRollComplete);
				cameraRoll.removeEventListener(ErrorEvent.ERROR, onSaveToCameraRollFail);
				cameraRoll = null;
			}
		}
		
		private function onSaveToCameraRollComplete(e:Event = null) {
			removeLoadingScreen();
			eventChannel.addEventListener(ToastMessage.CLICK_OK, onConfirmToShare);
			eventChannel.addEventListener(ToastMessage.CLOSE_MESSAGE, backToHome);
			ToastMessage.showConfrim(this, i18n.get("Message_SaveToCameraRollSuccess"));
		}
		
		private function onSaveToCameraRollFail(e:ErrorEvent) {
			removeLoadingScreen();
			eventChannel.addEventListener(ToastMessage.CLOSE_MESSAGE, backToHome);
			ToastMessage.showToastMessage(this, i18n.get("Message_SaveToCameraRollFail"));
		}
		
		private function onConfirmToShare(e:Event) {
			eventChannel.removeEventListener(ToastMessage.CLICK_OK, onConfirmToShare);
			CAMEO::ANE {
				var jpgFile:File = File.applicationStorageDirectory.resolvePath(strPhotoFile);
				var strJpgSavePath:String = jpgFile.nativePath;
				ext.shareImage(strJpgSavePath, "", this.stage);
			}
			backToHome();
		}
		
		private function backToHome(e:Event = null) {
			eventChannel.removeEventListener(ToastMessage.CLOSE_MESSAGE, backToHome);
			eventChannel.removeEventListener(ToastMessage.CLICK_OK, backToHome);
			eventChannel.writeEvent(new Event(TakeAPolaroid.TAKE_PICTURE_COMPLETE));
		}
		
		private function setImageSizePostion(photoSprite:Sprite) {
			var intScaleRatio:Number = (photoSprite.width/photoSprite.height > intPhotoWidth/intPhotoHeight) ? intPhotoHeight/photoSprite.height : intPhotoWidth/photoSprite.width;
			photoSprite.width *= intScaleRatio;
			photoSprite.height *= intScaleRatio;
			photoSprite.x += -(photoSprite.width - intPhotoWidth)/2;
			photoSprite.y += -(photoSprite.height - intPhotoHeight)/2;
		}

	}
	
}
