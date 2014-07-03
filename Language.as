package  {
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.net.SharedObject;
	
	import tw.cameo.EventChannel;
	import tw.cameo.LayoutManager;
	import Config;
	
	public class Language extends EventDispatcher {
		
		public static const SET_LANGUAGE_COMPLETE:String = "Language.SET_LANGUAGE_COMPLETE";
		public static var _instance:Language = null;
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var sharedObjectSavedStatus:SharedObject = SharedObject.getLocal("SavedStatus");
		private var selectLanguageScreen:MovieClip = null;

		public static function getInstance():Language {
			if (_instance == null) _instance = new Language();
			return _instance;
		}
		
		public function Language() {
			if (!sharedObjectSavedStatus.data.hasOwnProperty("strLanguage")) {
				setLanguage("CHT");
			}
		}

		public function initSelectLanguageScreen(container:DisplayObjectContainer) {
			selectLanguageScreen = (LayoutManager.useIphone5Layout()) ? new SelectLanguageScreenIphone5() : new SelectLanguageScreenIphone4();
			selectLanguageScreen.btnSelectCHT.addEventListener(MouseEvent.CLICK, onSelectLanguage);
			selectLanguageScreen.btnSelectENU.addEventListener(MouseEvent.CLICK, onSelectLanguage);
			selectLanguageScreen.btnSelectJPN.addEventListener(MouseEvent.CLICK, onSelectLanguage);
			container.addChild(selectLanguageScreen);
		}
		
		private function onSelectLanguage(e:MouseEvent) {
			switch (e.target.name) {
				case "btnSelectCHT":
					setLanguage("CHT");
				break;
				case "btnSelectENU":
					setLanguage("ENU");
				break;
				case "btnSelectJPN":
					setLanguage("JPN");
				break;
			}
		}
		
		public function disposeSelectLanguageScreen() {
			if (selectLanguageScreen) {
				selectLanguageScreen.btnSelectCHT.removeEventListener(MouseEvent.CLICK, onSelectLanguage);
				selectLanguageScreen.btnSelectENU.removeEventListener(MouseEvent.CLICK, onSelectLanguage);
				selectLanguageScreen.btnSelectJPN.removeEventListener(MouseEvent.CLICK, onSelectLanguage);
				selectLanguageScreen.parent.removeChild(selectLanguageScreen);
			}
			selectLanguageScreen = null;
		}
		
		public function setLanguage(strType:String) {
			sharedObjectSavedStatus.data["strLanguage"] = strType;
			sharedObjectSavedStatus.flush();
			eventChannel.writeEvent(new Event(Language.SET_LANGUAGE_COMPLETE));
			this.dispatchEvent(new Event(Language.SET_LANGUAGE_COMPLETE));
		}
		
		public function getLanguageType():String {
			return sharedObjectSavedStatus.data["strLanguage"];
		}
	}
	
}
