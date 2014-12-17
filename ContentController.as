package  {
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.system.System;
	import flash.system.Capabilities;
	import flash.desktop.NativeApplication;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	
	import tw.cameo.EventChannel;
	import tw.cameo.Navigator;
	import tw.cameo.TempData;
	
	public class ContentController {
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var mappingData:MappingData = MappingData.getInstance();
		private var tempData:TempData = TempData.getInstance();
		private var mainMovieClip:DisplayObjectContainer = null;
		private var contentContainer:Sprite = null;
		private var toolsContainer:Sprite = null;
		private var navigator:Navigator = null;
		private var titlebar:Titlebar = null;
		private var guidanceTool:GuidanceTool = null;
		private var scanRoomQrCode:ScanRoomQrCode = null;
		
		public function ContentController(mainMovieClipIn:DisplayObjectContainer) {
			// constructor code
			contentContainer = new Sprite();
			toolsContainer = new Sprite();
			mainMovieClip = mainMovieClipIn;
			mainMovieClip.addChild(contentContainer);
			mainMovieClip.addChild(toolsContainer);
			navigator = new Navigator(contentContainer);
			
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyDownEevnt);
			mainMovieClip.stage.addEventListener(Event.DEACTIVATE, deactivateHandler);
			
			createGuidanceTool();
			createTitlebar();
			createHome();
			
			addEventChannelListener();
		}
		
		public function dispose() {
			removeEventChannelListener();
			removeScanRoomQrCode();
			disposeGuidanceTool();
			navigator.dispose();
			navigator = null;
			
			contentContainer.parent.removeChild(contentContainer);
			toolsContainer.parent.removeChild(toolsContainer);
			
			contentContainer = null;
			toolsContainer = null;
		}
		
		private function createHome() {
			eventChannel.addEventListener(Home.OPENING_MOVIE_ADDED, onOpeningMovieAdded);
			var dicContentParameter = {
				className: "Home",
				data: true,
				showDirection: null,
				hideDirection: null
			};
			
			showContent(dicContentParameter);
			setHomeAnimationDisable();
			System.gc();
		}
		
		private function onOpeningMovieAdded(e:Event) {
			eventChannel.removeEventListener(Home.OPENING_MOVIE_ADDED, onOpeningMovieAdded);
			(mainMovieClip as Main).removeStartScreen();
		}
		
		private function setHomeAnimationDisable() {
			var dicHomeParameter:Object= navigator.getContentParameter(0);
			dicHomeParameter.data = false;
			
			navigator.setContentParameter(0, dicHomeParameter);
		}
		
		private function onIntoGuidanceClick(e:Event) {
			tempData.deleteTempData("intRoomListMoveY");
			var dicContentParameter:Object = {
				className: "RoomList",
				data: null,
				showDirection: Navigator.FADE_IN,
				hideDirection: Navigator.FADE_OUT
			};
			
			showContent(dicContentParameter);
		}
		
		private function onRoomListItemClick(e:Event) {
			var currentContent:MovieClip = navigator.getCurrentContent();
			var strClickColumnName:String = (currentContent as RoomList).getClickColumnName();
			var strFloor:String = "";
			var strRoom:String = "";
			var intIndexOfDashLine:int = 0;
			
			intIndexOfDashLine = strClickColumnName.indexOf("-");
			strFloor = strClickColumnName.slice(0, intIndexOfDashLine);
			strRoom = strClickColumnName.slice(intIndexOfDashLine+1);
			
			var dicContentParameter:Object = {
				className: "RoomExhibitList",
				data: [strFloor, strRoom],
				showDirection: Navigator.FADE_IN,
				hideDirection: Navigator.FADE_OUT
			};
			
			showContent(dicContentParameter);
		}
		
		private function onQrCodeClick(e:Event = null) {
			if (scanRoomQrCode == null) {
				scanRoomQrCode = new ScanRoomQrCode();
				scanRoomQrCode.addEventListener(ScanRoomQrCode.SCAN_OK, onScanRoomQrCodeComplete);
			}
			scanRoomQrCode.startScan();
		}
		
		private function removeScanRoomQrCode() {
			if (scanRoomQrCode) {
				scanRoomQrCode.dispose();
				scanRoomQrCode.removeEventListener(ScanRoomQrCode.SCAN_OK, onScanRoomQrCodeComplete);
			}
			scanRoomQrCode = null;
		}
		
		private function onScanRoomQrCodeComplete(e:Event) {
			var strRoomLabel:String = scanRoomQrCode.getRoomLabel();
			
			startGuide(mappingData.getExhibitList(strRoomLabel));
		}
		
		private function onCheckInClick(e:Event) {
			trace("ContentController.as / onCheckInClick");
			var isBackToHome:Boolean = true;
			tempData.saveTempData("isNavigatorBackToGuide", false);
			tempData.saveTempData("isFinishToHome", true);
			
			if (e.type == Titlebar.CLICK_CAMERA) {
				isBackToHome = false;
				tempData.saveTempData("isNavigatorBackToGuide", true);
				tempData.saveTempData("isFinishToHome", false);
			}
			
			var dicContentParameter = {
				className: "ChosePicture",
				data: isBackToHome,
				showDirection: Navigator.FADE_IN,
				hideDirection: Navigator.FADE_OUT
			};
			
			showContent(dicContentParameter);
		}
		
		private function onLoadPhotoComplete(e:Event) {
			trace("ContentController.as / onLoadPhotoComplete");
			var chosePicture:ChosePicture = navigator.getCurrentContent() as ChosePicture;
			var photoBitmap:Bitmap = chosePicture.getBitmap();
			var dicContentParameter = {
				className: "TakeAPolaroid",
				data: photoBitmap,
				showDirection: Navigator.NONE,
				hideDirection: Navigator.HIDE_DOWN
			};
			
			showContent(dicContentParameter);
		}
		
		private function onTakePictureComplete(e:Event) {
			if (tempData.getTempData("isFinishToHome")) {
				navigator.popContent(1);
			} else {
				var intContentNumber:int = navigator.getContentNumber();
				navigator.popContent(intContentNumber-2);
			}
			tempData.deleteTempData("isFinishToHome");
		}
		
		private function onTrafficClick(e:Event) {
			var dicContentParameter = {
				className: "Traffic",
				data: null,
				showDirection: Navigator.SHOW_LEFT,
				hideDirection: Navigator.HIDE_RIGHT
			};
			
			showContent(dicContentParameter);
		}
		
		private function createTitlebar() {
			titlebar = Titlebar.getInstance();
			titlebar.addEventListener(Titlebar.CLICK_BACK, onTitlebarBackClick);
			titlebar.addEventListener(Titlebar.CLICK_HOME, onTitlebarHomeClick);
			titlebar.addEventListener(Titlebar.CLICK_QRCODE, onQrCodeClick);
			titlebar.addEventListener(Titlebar.CLICK_CAMERA, onCheckInClick);
			titlebar.initTitleBar(toolsContainer);
		}
		
		private function disposeTitlebar() {
			titlebar.removeEventListener(Titlebar.CLICK_BACK, onTitlebarBackClick);
			titlebar.removeEventListener(Titlebar.CLICK_HOME, onTitlebarHomeClick);
			titlebar.removeEventListener(Titlebar.CLICK_QRCODE, onQrCodeClick);
			titlebar.removeEventListener(Titlebar.CLICK_CAMERA, onCheckInClick);
			titlebar = null;
		}
		
		private function onTitlebarHomeClick(e:Event) {
			navigatorHomeHandler();
		}
		
		private function onTitlebarBackClick(e:Event) {
			navigatorBackHandler();
		}
		
		private function reloadRoomExhibitList(e:Event) {
			eventChannel.removeEventListener(Titlebar.SIDEMENU_CLOSE, reloadRoomExhibitList);
			var roomExhibitList:RoomExhibitList = navigator.getCurrentContent() as RoomExhibitList;
			roomExhibitList.reloadExhibitList();
		}
		
		private function createGuidanceTool() {
			guidanceTool = GuidanceTool.getInstance();
			guidanceTool.create(toolsContainer);
//			guidanceTool.showGuidanceTool();
			guidanceTool.addEventListener(GuidanceToolEvent.VIEW_GUIDANCE, onStartGuideToolEvent);
		}
		
		private function disposeGuidanceTool() {
			guidanceTool.removeEventListener(GuidanceToolEvent.VIEW_GUIDANCE, onStartGuideToolEvent);
			guidanceTool.dispose();
			guidanceTool = null;
		}
		
		private function onStartGuideToolEvent(e:GuidanceToolEvent) {
//			trace("ContentController.as / onStartGuideToolEvent: Exhibit no.", e.getInputExhibitNumber());
			startGuide([e.getInputExhibitNumber()]);
		}
		
		private function onStartGuideEvent(e:GuideEvent) {
			var lstExhibitFolder:Array = e.lstExhibitFolder;
			startGuide(lstExhibitFolder);
		}
		
		private function startGuide(lstExhibitFolder:Array) {
			var currentContent:MovieClip = navigator.getCurrentContent();
			var lstFloorAndRoom:Array = mappingData.getFloorAndRoomFromExhibitNumber(lstExhibitFolder[0]);
			var strFloor:String = lstFloorAndRoom[0];
			var strRoom:String = lstFloorAndRoom[1];
			
			if (currentContent is Guide) { // current page is Guide
				if (String(currentContent.lstExhibitFolder) == String(lstExhibitFolder)) {
					currentContent.replayGuide();
				} else {
					currentContent.lstExhibitFolder = lstExhibitFolder;
					currentContent.reloadGuide();
				}
			} else {
				var isBackToHome:Boolean = (navigator.getContentNumber() == 1) ? true : false;
				var lstParameter:Array = [lstExhibitFolder, isBackToHome];
				var dicContentParameter = {
					className: "Guide",
					data: lstParameter,
					showDirection: Navigator.SHOW_UP,
					hideDirection: Navigator.HIDE_DOWN
				};
			
				showContent(dicContentParameter);
			}
		}
		
		private function addEventChannelListener() {
			eventChannel.addEventListener(Home.CLICK_INTO_GUIDANCE, onIntoGuidanceClick);
			eventChannel.addEventListener(Home.CLICK_QRCODE, onQrCodeClick);
			eventChannel.addEventListener(Home.CLICK_CHECK_IN, onCheckInClick);
			eventChannel.addEventListener(Home.CLICK_TRAFFIC, onTrafficClick);
			eventChannel.addEventListener(RoomListItem.COLUMN_CLICK, onRoomListItemClick);
			eventChannel.addEventListener(GuideEvent.START_GUIDANCE, onStartGuideEvent);
			eventChannel.addEventListener(ChosePicture.LOAD_PHOTO_COMPLETE, onLoadPhotoComplete);
			eventChannel.addEventListener(TakeAPolaroid.TAKE_PICTURE_COMPLETE, onTakePictureComplete);
		}
		
		private function removeEventChannelListener() {
			eventChannel.removeEventListener(Home.OPENING_MOVIE_ADDED, onOpeningMovieAdded);
			eventChannel.removeEventListener(Home.CLICK_INTO_GUIDANCE, onIntoGuidanceClick);
			eventChannel.removeEventListener(Home.CLICK_QRCODE, onQrCodeClick);
			eventChannel.removeEventListener(Home.CLICK_CHECK_IN, onCheckInClick);
			eventChannel.removeEventListener(Home.CLICK_TRAFFIC, onTrafficClick);
			eventChannel.removeEventListener(RoomListItem.COLUMN_CLICK, onRoomListItemClick);
			eventChannel.removeEventListener(GuideEvent.START_GUIDANCE, onStartGuideEvent);
			eventChannel.removeEventListener(ChosePicture.LOAD_PHOTO_COMPLETE, onLoadPhotoComplete);
			eventChannel.removeEventListener(TakeAPolaroid.TAKE_PICTURE_COMPLETE, onTakePictureComplete);
		}
		
		private function showContent(dicContentParameter:Object):void {
			if (navigator == null) {
				navigator = new Navigator(contentContainer, dicContentParameter);
			} else {
				navigator.pushContent(dicContentParameter);
			}
		}
		
		private function navigatorHomeHandler(e:Event = null) {
			navigator.popContent(1);
		}
		
		private function navigatorBackHandler(e:Event = null) {
			navigator.popContent();
		}
		
		private function keyDownEevnt(ev:KeyboardEvent):void {
			if (ev.keyCode == Keyboard.BACK) {
				if (navigator.getContentNumber() > 1) {
					ev.preventDefault();
        			ev.stopImmediatePropagation();
					
					var currentContent:MovieClip = navigator.getCurrentContent();
					if (currentContent is Guide && (currentContent as Guide).isGuideTextShow()) {
						(currentContent as Guide).hideGuideText();
						return;
					}
					
					if (currentContent is TakeAPolaroid && (currentContent as TakeAPolaroid).isHelpPageShow()) {
						(currentContent as TakeAPolaroid).removeHelpPage();
						return;
					}
					
					navigatorBackHandler();
				}
			}
		}
		
		private function deactivateHandler(e:Event) {
			var currentContent = navigator.getCurrentContent();
			if (currentContent is Home) {
				(currentContent as Home).removeWelcomeSound();
				(currentContent as Home).stopBackgroundMusic();
			}
			if (currentContent is Guide) (currentContent as Guide).pauseSlideShow();
		}
		
		private function forDynamicCreate() {
			var home:Home = null;
			var roomList:RoomList = null;
			var traffic:Traffic = null;
			var roomExhibitList:RoomExhibitList = null;
			var guide:Guide = null;
			var chosePicture:ChosePicture = null;
			var takeAPolaroid:TakeAPolaroid = null;
		}

	}
	
}
