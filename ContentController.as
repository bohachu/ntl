package  {
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.system.System;
	import flash.system.Capabilities;
	import flash.desktop.NativeApplication;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	
	import tw.cameo.EventChannel;
	import tw.cameo.Navigator;
	import Home;
	import GuidanceTool;
	import GuidanceToolEvent;
	
	public class ContentController {
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var contentContainer:Sprite = null;
		private var guidanceToolContainer:Sprite = null;
		private var navigator:Navigator = null;
		private var guidanceTool:GuidanceTool = null;
		
		public function ContentController(mainMovieClip:DisplayObjectContainer) {
			// constructor code
			contentContainer = new Sprite();
			guidanceToolContainer = new Sprite();
			mainMovieClip.addChild(contentContainer);
			mainMovieClip.addChild(guidanceToolContainer);
			navigator = new Navigator(contentContainer);
			
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyDownEevnt);
			
			createHome();
			createGuidanceTool();
			
			addEventChannelListener();
		}
		
		public function dispose() {
			removeEventChannelListener();
			disposeGuidanceTool();
			navigator.dispose();
			navigator = null;
			
			contentContainer.parent.removeChild(contentContainer);
			guidanceToolContainer.parent.removeChild(guidanceToolContainer);
			
			contentContainer = null;
			guidanceToolContainer = null;
		}
		
		private function createHome() {
			var dicContentParameter = {
				className: "Home",
				data: null,
				showDirection: null,
				hideDirection: null
			};
			
			setupNavigator(dicContentParameter);
			System.gc();
		}
		
		private function onIntoGuidanceClick(e:Event) {
			trace("ContentController.as / onIntoGuidanceClick");
		}
		
		private function onQrCodeClick(e:Event) {
			trace("ContentController.as / onQrCodeClick");
		}
		
		private function onCheckInClick(e:Event) {
			trace("ContentController.as / onCheckInClick");
		}
		
		private function onTrafficClick(e:Event) {
			trace("ContentController.as / onTrafficClick");
		}
		
		private function createGuidanceTool() {
			guidanceTool = GuidanceTool.getInstance();
			guidanceTool.create(guidanceToolContainer);
			guidanceTool.addEventListener(GuidanceToolEvent.VIEW_GUIDANCE, onViewGuidance);
		}
		
		private function disposeGuidanceTool() {
			guidanceTool.removeEventListener(GuidanceToolEvent.VIEW_GUIDANCE, onViewGuidance);
			guidanceTool.dispose();
			guidanceTool = null;
		}
		
		private function onViewGuidance(e:GuidanceToolEvent) {
			trace("ContentController.as / onViewGuidance: Exhibit no.", e.getInputExhibitNumber());
		}
		
		private function addEventChannelListener() {
			eventChannel.addEventListener(Home.CLICK_INTO_GUIDANCE, onIntoGuidanceClick);
			eventChannel.addEventListener(Home.CLICK_QRCODE, onQrCodeClick);
			eventChannel.addEventListener(Home.CLICK_CHECK_IN, onCheckInClick);
			eventChannel.addEventListener(Home.CLICK_TRAFFIC, onTrafficClick);
		}
		
		private function removeEventChannelListener() {
			eventChannel.removeEventListener(Home.CLICK_INTO_GUIDANCE, onIntoGuidanceClick);
			eventChannel.removeEventListener(Home.CLICK_QRCODE, onQrCodeClick);
			eventChannel.removeEventListener(Home.CLICK_CHECK_IN, onCheckInClick);
			eventChannel.removeEventListener(Home.CLICK_TRAFFIC, onTrafficClick);
		}
		
		private function setupNavigator(dicContentParameter:Object):void {
			if (navigator == null) {
				navigator = new Navigator(contentContainer, dicContentParameter);
			} else {
				navigator.pushContent(dicContentParameter);
			}
		}
		
		private function navigatorBackHandler(e:Event = null) {
			navigator.popContent();
		}
		
		private function keyDownEevnt(ev:KeyboardEvent):void {
			if (ev.keyCode == Keyboard.BACK) {
				if (navigator.getContentNumber() > 0) {
					ev.preventDefault();
        			ev.stopImmediatePropagation();
					
					navigatorBackHandler();
				}
			}
		}
		
		private function forDynamicCreate() {
			var home:Home = null;
		}

	}
	
}
