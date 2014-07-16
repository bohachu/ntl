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
	import Home;
	import Titlebar;
	import GuidanceTool;
	import GuidanceToolEvent;
	import Traffic;
	import MappingData;
	import RoomExhibitList;
	import GuideEvent;
	import Guide;
	import ScanRoomQrCode;
	import ChosePicture;
	import TakeAPolaroid;
	
	public class ContentController {
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var mappingData:MappingData = MappingData.getInstance();
		private var contentContainer:Sprite = null;
		private var toolsContainer:Sprite = null;
		private var navigator:Navigator = null;
		private var titlebar:Titlebar = null;
		private var guidanceTool:GuidanceTool = null;
		private var scanRoomQrCode:ScanRoomQrCode = null;
		
		public function ContentController(mainMovieClip:DisplayObjectContainer) {
			// constructor code
			contentContainer = new Sprite();
			toolsContainer = new Sprite();
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
			var dicContentParameter = {
				className: "Home",
				data: null,
				showDirection: null,
				hideDirection: null
			};
			
			showContent(dicContentParameter);
			System.gc();
		}
		
		private function onIntoGuidanceClick(e:Event) {
			var strFloor:String = mappingData.getFloorList()[0];
			var strRoom:String = mappingData.getRoomList(strFloor)[0];
			
			showContent(getExhibitListPageParameter(strFloor, strRoom));
		}
		
		private function getExhibitListPageParameter(strFloor:String, strRoom:String):Object {
			var dicContentParameter:Object = {
				className: "RoomExhibitList",
				data: [strFloor, strRoom],
				showDirection: Navigator.SHOW_LEFT,
				hideDirection: Navigator.HIDE_RIGHT
			};
			
			return dicContentParameter;
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
			var dicContentParameter = {
				className: "ChosePicture",
				data: null,
				showDirection: Navigator.SHOW_LEFT,
				hideDirection: Navigator.HIDE_RIGHT
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
			navigator.popContent(1);
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
			titlebar.addEventListener(Titlebar.CLICK_SIDE_MENU_COLUMN, onSideMenuColumnClick);
			titlebar.initTitleBar(toolsContainer);
		}
		
		private function disposeTitlebar() {
			titlebar.removeEventListener(Titlebar.CLICK_BACK, onTitlebarBackClick);
			titlebar.removeEventListener(Titlebar.CLICK_HOME, onTitlebarHomeClick);
			titlebar.removeEventListener(Titlebar.CLICK_QRCODE, onQrCodeClick);
			titlebar.removeEventListener(Titlebar.CLICK_SIDE_MENU_COLUMN, onSideMenuColumnClick);
			titlebar = null;
		}
		
		private function onTitlebarHomeClick(e:Event) {
			navigatorHomeHandler();
		}
		
		private function onTitlebarBackClick(e:Event) {
			navigatorBackHandler();
		}
		
		private function onSideMenuColumnClick(e:Event) {
			var currentContent:MovieClip = navigator.getCurrentContent();
			var strClickColumnName:String = titlebar.getClickSideMenuColumn();
			var strFloor:String = "";
			var strRoom:String = "";
			
			if (navigator.getContentNumber() == 3) { //In Guide page
				var dicPreviousContentParameter:Object = navigator.getContentParameter(1);
				strFloor = dicPreviousContentParameter.data[0];
				strRoom = dicPreviousContentParameter.data[1];
				if (strClickColumnName != strFloor + "-" + strRoom) {
					var intIndexOfDashLine:int = strClickColumnName.indexOf("-");
					dicPreviousContentParameter.data[0] = strClickColumnName.slice(0, intIndexOfDashLine);
					dicPreviousContentParameter.data[1] = strClickColumnName.slice(intIndexOfDashLine+1);
					
					navigator.setContentParameter(1, dicPreviousContentParameter);
				}
				navigatorBackHandler();
			}
			
			if (navigator.getContentNumber() == 2) { // In Room Exhibit List page
				var roomExhibitList:RoomExhibitList = navigator.getCurrentContent() as RoomExhibitList;
				if (strClickColumnName != roomExhibitList.strFloor + "-" + roomExhibitList.strRoom) {
					var intIndexOfDashLine:int = strClickColumnName.indexOf("-");
					strFloor = strClickColumnName.slice(0, intIndexOfDashLine);
					strRoom = strClickColumnName.slice(intIndexOfDashLine+1);
					roomExhibitList.resetExhibitList(strFloor, strRoom);
					eventChannel.addEventListener(Titlebar.SIDEMENU_CLOSE, reloadRoomExhibitList);
				}
			}
		}
		
		private function reloadRoomExhibitList(e:Event) {
			eventChannel.removeEventListener(Titlebar.SIDEMENU_CLOSE, reloadRoomExhibitList);
			var roomExhibitList:RoomExhibitList = navigator.getCurrentContent() as RoomExhibitList;
			roomExhibitList.reloadExhibitList();
		}
		
		private function createGuidanceTool() {
			guidanceTool = GuidanceTool.getInstance();
			guidanceTool.create(toolsContainer);
			guidanceTool.showGuidanceTool();
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
			var lstFloorAndRoom:Array = mappingData.getFloorAndRoomFromExhibitNumber(lstExhibitFolder[0]);
			var strFloor:String = lstFloorAndRoom[0];
			var strRoom:String = lstFloorAndRoom[1];
			var strColumnName:String = strFloor + "-" + strRoom;
			titlebar.setSideMenuColumn(strColumnName);
			
			if (navigator.getContentNumber() == 3) { // Navigator has ExhibitList Page and in Guide Page
				var guidePage:MovieClip = navigator.getCurrentContent();
				if (String(guidePage.lstExhibitFolder) == String(lstExhibitFolder)) {
					guidePage.replayGuide();
				} else {
					guidePage.lstExhibitFolder = lstExhibitFolder;
					guidePage.reloadGuide();
				}
			} else {
				if (navigator.getContentNumber() == 1) { // Navigator not have ExhibitList Page in Main
					var dicExhibitListPageParameter:Object = getExhibitListPageParameter(strFloor, strRoom);
					navigator.addContentParameter(dicExhibitListPageParameter);
				}
				
				var dicContentParameter = {
					className: "Guide",
					data: lstExhibitFolder,
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
			eventChannel.addEventListener(GuideEvent.START_GUIDANCE, onStartGuideEvent);
			eventChannel.addEventListener(ChosePicture.LOAD_PHOTO_COMPLETE, onLoadPhotoComplete);
			eventChannel.addEventListener(TakeAPolaroid.TAKE_PICTURE_COMPLETE, onTakePictureComplete);
		}
		
		private function removeEventChannelListener() {
			eventChannel.removeEventListener(Home.CLICK_INTO_GUIDANCE, onIntoGuidanceClick);
			eventChannel.removeEventListener(Home.CLICK_QRCODE, onQrCodeClick);
			eventChannel.removeEventListener(Home.CLICK_CHECK_IN, onCheckInClick);
			eventChannel.removeEventListener(Home.CLICK_TRAFFIC, onTrafficClick);
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
					
					navigatorBackHandler();
				}
			}
		}
		
		private function deactivateHandler(e:Event) {
			var currentContent = navigator.getCurrentContent();
			if (currentContent is Guide) (currentContent as Guide).pauseSlideShow();
		}
		
		private function forDynamicCreate() {
			var home:Home = null;
			var traffic:Traffic = null;
			var roomExhibitList:RoomExhibitList = null;
			var guide:Guide = null;
			var chosePicture:ChosePicture = null;
			var takeAPolaroid:TakeAPolaroid = null;
		}

	}
	
}
