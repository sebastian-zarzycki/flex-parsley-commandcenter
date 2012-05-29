package com.feerie.command
{

   	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;

	public class AsyncCommand extends Command
	{
		[Inject("model")]
		public var model:MyModel;
		[Inject("serviceDelegate")]
		public var serviceDelegate:IServiceDelegate;
		
		public function AsyncCommand()
		{
		}
		
		public function execute(event:TriggerEvent):AsyncToken 
		{
			this.event = event;
			return serviceDelegate.loadSomething(this.event.id);
		}
		
		public function result(result:Object):void 
		{
			if (result && result is MyType)
			{
				var obj:MyType = result as MyType;
				model.myObject = obj;
				
				notifyCompleted();
			}
			else
			{
				notifyCompleted(false);
			}
		}
		
		public function error(fault:FaultEvent):void 
		{
				notifyCompleted(false);
		}
	}
}