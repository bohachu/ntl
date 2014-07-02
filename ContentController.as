﻿package  {
	
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
	import Titlebar;
	import GuidanceTool;
	import GuidanceToolEvent;
	import Traffic;
	import MappingData;
	import RoomExhibitList;
	
	public class ContentController {
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var mappingData:MappingData = MappingData.getInstance();
		private var contentContainer:Sprite = null;
		private var toolsContainer:Sprite = null;
		private var navigator:Navigator = null;
		private var titlebar:Titlebar = null;
		private var guidanceTool:GuidanceTool = null;
		
		public function ContentController(mainMovieClip:DisplayObjectContainer) {
			// constructor code
			contentContainer = new Sprite();
			toolsContainer = new Sprite();
			mainMovieClip.addChild(contentContainer);
			mainMovieClip.addChild(toolsContainer);
			navigator = new Navigator(contentContainer);
			
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyDownEevnt);
			
			createGuidanceTool();
			createTitlebar();
			createHome();
			
			addEventChannelListener();
		}
		
		public function dispose() {
			removeEventChannelListener();
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
			var dicContentParameter = {
				className: "RoomExhibitList",
				data: [strFloor, strRoom],
				showDirection: Navigator.SHOW_LEFT,
				hideDirection: Navigator.HIDE_RIGHT
			};
			
			showContent(dicContentParameter);
		}
		
		private function onQrCodeClick(e:Event) {
			trace("ContentController.as / onQrCodeClick");
		}
		
		private function onCheckInClick(e:Event) {
			trace("ContentController.as / onCheckInClick");
		}
		
		private function onTrafficClick(e:Event) {
			createTrafficPage();
		}
		
		private function createTrafficPage() {
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
			titlebar.initTitleBar(toolsContainer);
		}
		
		private function disposeTitlebar() {
			titlebar.removeEventListener(Titlebar.CLICK_BACK, onTitlebarBackClick);
			titlebar.removeEventListener(Titlebar.CLICK_HOME, onTitlebarHomeClick);
			titlebar = null;
		}
		
		private function onTitlebarHomeClick(e:Event) {
			navigatorHomeHandler();
		}
		
		private function onTitlebarBackClick(e:Event) {
			navigatorBackHandler();
		}
		
		private function createGuidanceTool() {
			guidanceTool = GuidanceTool.getInstance();
			guidanceTool.create(toolsContainer);
			guidanceTool.showGuidanceTool();
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
		
		private function forDynamicCreate() {
			var home:Home = null;
			var traffic:Traffic = null;
			var roomExhibitList:RoomExhibitList = null;
		}

	}
	
}
