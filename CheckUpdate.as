package  {
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	public class CheckUpdate extends EventDispatcher {
		
		public static const UPDATE_FINISH:String = "CheckUpdate.UPDATE_FINISH";

		public function CheckUpdate() {
			// constructor code
		}
		
		public function init() {
			this.dispatchEvent(new Event(CheckUpdate.UPDATE_FINISH));
		}
		
		public function dispose() {
			
		}

	}
	
}
