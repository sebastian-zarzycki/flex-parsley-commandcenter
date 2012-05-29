package com.feerie.command
{
	public class SimpleCommand extends Command
	{
		public function SimpleCommand()
		{
		}
		
		public function execute():String 
		{
			notifyCompleted();
			return "Bazinga!";
		}
	}
}