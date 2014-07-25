package  {
	
	import flash.system.Capabilities;
	import flash.desktop.NativeApplication;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.MovieClip;
	import flash.media.SoundMixer;
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.filesystem.File;
	import tw.cameo.EventChannel;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.WebViewLog;
	import tw.cameo.CheckAppVersion;
	import tw.cameo.SplashScreen;
	
	import Config;
	import LoadingScreen;
	import CheckUpdate;
	import Language;
	import MappingData;
	import I18n;
	
	public class Main extends MovieClip {
		
		private var sharedObjectSavedStatus:SharedObject = SharedObject.getLocal("SavedStatus");
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var language:Language = Language.getInstance();
		private var mappingData:MappingData = MappingData.getInstance();
		private var splashScreen:SplashScreen = null;
		private var loadingScreen:LoadingScreen = null;
		private var checkAppVersion:CheckAppVersion = null;
		private var checkUpdate:CheckUpdate = null;
		private var i18n:I18n = null;
		private var contentController:ContentController = null;
		
		public function Main() {
			// constructor code
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			
			CAMEO::Debug {
				sharedObjectSavedStatus.clear();
				sharedObjectSavedStatus.flush();
				var sourceFolder:File = File.applicationDirectory.resolvePath("");
				var targetFolder:File = File.applicationStorageDirectory.resolvePath("");
				trace(sourceFolder.nativePath, targetFolder.nativePath);
			}
		}
		
		private function init (e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			LayoutManager.setLayout(this);
			splashScreen = new SplashScreen(this.stage);
			splashScreen.addEventListener(SplashScreen.FINISH, onSplashScreenFinish);
			splashScreen.init();
			
//			if (Capabilities.os.indexOf("iPhone")) NativeApplication.nativeApplication.executeInBackground = true;
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeContent();
			removeLoadingScreen();
			removeSplashScreen();
		}
		
		private function onSplashScreenFinish(e:Event) {
			removeSplashScreen();
			initLoadingScreen();
			checkDataUpdate();
		}
		
		private function removeSplashScreen() {
			if (splashScreen) splashScreen.dispose();
			splashScreen = null;
		}
		
		private function initLoadingScreen() {
			if (loadingScreen == null) loadingScreen = new LoadingScreen(this);
		}
		
		private function removeLoadingScreen() {
			if (loadingScreen) loadingScreen.dispose();
			loadingScreen = null;
		}
//		
//		private function checkVersion() {
//			eventChannel.addEventListener(CheckAppVersion.FINISH, onCheckVersionFinish);
//			var strCheckUrl:String = (Capabilities.os.indexOf("iPhone") == -1) ? Config.strAppVersionUrl : Config.strAppVersionUrlIos;
//			
//			CheckAppVersion.checkVersion(strCheckUrl, Config.strUpdateUrl, this);
//		}
		
		private function checkDataUpdate() {
//			eventChannel.removeEventListener(CheckAppVersion.FINISH, onCheckVersionFinish);
			checkUpdate = new CheckUpdate();
			checkUpdate.addEventListener(CheckUpdate.UPDATE_FINISH, onCheckUpdateFinish);
			checkUpdate.init();
		}
		
		private function onCheckUpdateFinish(e:Event) {
			checkUpdate.removeEventListener(CheckUpdate.UPDATE_FINISH, onCheckUpdateFinish);
			checkUpdate.dispose();
			checkUpdate = null;
			removeLoadingScreen();
			
			if (!sharedObjectSavedStatus.data.hasOwnProperty("isNotFirstTimeUse")) {
				firstTimeUseSelectLanguage();
			} else {
				loadMappingData();
			}
		}
		
		private function firstTimeUseSelectLanguage() {
			language.addEventListener(Language.SET_LANGUAGE_COMPLETE, onSetLanguageComplete);
			language.initSelectLanguageScreen(this);
		}
		
		private function onSetLanguageComplete(e:Event) {
			language.disposeSelectLanguageScreen();
			language.removeEventListener(Language.SET_LANGUAGE_COMPLETE, onSetLanguageComplete);
			loadMappingData();
		}
		
		private function loadMappingData() {
			mappingData.addEventListener(MappingData.LOAD_MAPPING_DATA_COMPLETE, onLoadMappingDataComplete);
			mappingData.loadMappingData();
		}
		
		private function onLoadMappingDataComplete(e:Event) {
			mappingData.removeEventListener(MappingData.LOAD_MAPPING_DATA_COMPLETE, onLoadMappingDataComplete);
			loadingI18n();
		}
		
		private function loadingI18n() {
			initLoadingScreen();
			i18n = I18n.getInstance();
			i18n.addEventListener(I18n.LOAD_TRANSLATION_COMPLETE, onLoadTranslationComplete);
			i18n.loadTranslation();
		}
		
		private function onLoadTranslationComplete(e:Event) {
			i18n.removeEventListener(I18n.LOAD_TRANSLATION_COMPLETE, onLoadTranslationComplete);
			removeLoadingScreen();
			createContent();
		}
		
		private function createContent() {
			contentController = new ContentController(this);
		}
		
		private function removeContent() {
			if (contentController) contentController.dispose();
			contentController = null;
		}
	}
	
}
