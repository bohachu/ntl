package  {
	
	import flash.system.Capabilities;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.MovieClip;
	import flash.media.SoundMixer;
	import flash.events.Event;
	import tw.cameo.EventChannel;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.WebViewLog;
	import tw.cameo.CheckAppVersion;
	import tw.cameo.SplashScreen;
	
	import Config;
	import LoadingScreen;
	import CheckUpdate;
	
	// BACK KEY
	import flash.desktop.NativeApplication;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	
	public class Main extends MovieClip {
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var splashScreen:SplashScreen = null;
		private var loadingScreen:LoadingScreen = null;
		private var checkAppVersion:CheckAppVersion = null;
		private var checkUpdate:CheckUpdate = null;
		
		public function Main() {
			// constructor code
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			this.stage.addEventListener(Event.DEACTIVATE, deactivateHandler);
		}
		
		private function init (e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyDownEevnt);
			
			LayoutManager.setLayout(this);
			splashScreen = new SplashScreen(this.stage);
			splashScreen.addEventListener(SplashScreen.FINISH, onSplashScreenFinish);
			splashScreen.init();
			
			if (Capabilities.os.indexOf("iPhone")) NativeApplication.nativeApplication.executeInBackground = true;
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeLoadingScreen();
			removeSplashScreen();
		}
		
		private function onSplashScreenFinish(e:Event) {
			removeSplashScreen();
			initLoadingScreen();
			checkVersion();
		}
		
		private function removeSplashScreen() {
			if (splashScreen) splashScreen.dispose();
			splashScreen = null;
		}
		
		private function initLoadingScreen() {
			loadingScreen = new LoadingScreen(this);
		}
		
		private function removeLoadingScreen() {
			if (loadingScreen) loadingScreen.dispose();
			loadingScreen = null;
		}
		
		private function checkVersion() {
			eventChannel.addEventListener(CheckAppVersion.FINISH, onCheckVersionFinish);
			var strCheckUrl:String = (Capabilities.os.indexOf("iPhone") == -1) ? Config.strAppVersionUrl : Config.strAppVersionUrlIos;
			
			CheckAppVersion.checkVersion(strCheckUrl, Config.strUpdateUrl, this);
		}
		
		private function onCheckVersionFinish(e:Event) {
			eventChannel.removeEventListener(CheckAppVersion.FINISH, onCheckVersionFinish);
			checkUpdate = new CheckUpdate();
			checkUpdate.addEventListener(CheckUpdate.UPDATE_FINISH, onCheckUpdateFinish);
			checkUpdate.init();
		}
		
		private function onCheckUpdateFinish(e:Event) {
			checkUpdate.removeEventListener(CheckUpdate.UPDATE_FINISH, onCheckUpdateFinish);
			checkUpdate.dispose();
			checkUpdate = null;
			removeLoadingScreen();
		}
		
		private function deactivateHandler(e:Event) {
			SoundMixer.stopAll();
		}
		
		private function keyDownEevnt(ev:KeyboardEvent):void {
			if (ev.keyCode == Keyboard.BACK) {
//				if (navigator.getContentNumber() > 0) {
//					ev.preventDefault();
//        			ev.stopImmediatePropagation();
//					
//					navigatorBackHandler();
//				}
			}
		}
	}
	
}
