package  {
	
	public class Utils {

		public static function removeDoubleQuote(textString:String):String {
			if (textString.charAt(0) == "\"") {
				textString = textString.slice(1, textString.length-1);
				textString = textString.replace(/\"\"/g, "\"");
			}
			if (textString.charAt(0) == "'") {
				textString = textString.slice(1, textString.length-1);
			}
			return textString;
		}
	}
	
}
