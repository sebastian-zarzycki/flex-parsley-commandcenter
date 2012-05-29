package com.feerie.command
{
	public class Command
	{
		public var completeHandler:Function;

		public function Command()
		{
		}

		protected function notifyCompleted(success:Boolean = true, message:Object = null):void
		{
			if (completeHandler != null)
			{
				completeHandler(success, this, message);
			}
		}
	}
}
