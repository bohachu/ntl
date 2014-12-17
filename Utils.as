package  {
	
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	
	public class Utils {

		public static function removeDoubleQuote(textString:String, strLanguageType:String = ""):String {
			if (textString.charAt(0) == "\"") {
				textString = textString.slice(1, textString.length-1);
				textString = textString.replace(/\"\"/g, "\"");
			}
			if (textString.charAt(0) == "'") {
				textString = textString.slice(1, textString.length);
			}
			if (strLanguageType == "CHT") {
				textString = textString.replace(/,/g, "，");
			}
			return textString;
		}
		
		
		public static function keepAppIdleModeAwake() {
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
		}
		
		public static function keepAppIdleModeNormal() {
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
		}
	}
	
}
