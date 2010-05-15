package
{
	import flare.display.TextSprite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class DataUtahByZip implements DataInterface
	{
		private var years:Array = new Array(1998, 2003);
		
		// tooltip text sprites
		private var tt_zip:TextSprite;
		// TODO other tooltip informations
		private var tt_pop:TextSprite;
		
		// attribute strings for tooltip
		private var zip:String;
		private var pop:String;
		private var ph:String;
		private var panp:String;
		private var change_ph:String;
		private var change_panp:String;
		
		public function DataUtahByZip()
		{
			// do nothing right now, all hard coded...
		}
		
		public function getYears():Array
		{
			return this.years;
		}
		
		public function getXmlFileName(year:String):String
		{
			return "../dat/utah_by_zip_" + year + ".xml";
		}
		
		public function getShpFileName(year:String):String
		{
			//return "../shp/by_zip/zip_poly.shp";
			return "../shp/utzip.shp";
		}
		
		public function getDbfFileName(year:String):String
		{
			//return "../shp/by_zip/zip_poly.dbf";
			return "../shp/utzip.dbf";
		}
		
		public function getDataAttributes():Array
		{
			return new Array("zip", "year", "np", "pa", "ph",
				"panp", "pop", "change_ph", "change_panp", "change_pop");
		}
		
		public function getKeyAttribute():String
		{
			return "zip";
		}
		
		public function keyAttributeNameInDbfFile():String
		{
			return "ZIP";
		}
		
		public function updateMapColor(dictData:Dictionary, features:Array, highlightBorder:Boolean, highlightUrban:Boolean):void
		{
		}
		
		public function drawLegendForLegendBar(ox:int, oy:int, segLength:int, legendSprite:Sprite, textContainer:Sprite):void
		{
		}
		
		public function drawTooltip(root:Sprite):void
		{
		}
		
		public function handleTooltip(mapObj:ShpMapObject, event:Event):void
		{
		}
		
		public function readTooltipDataFromShpMap(shpMap:ShpMap, event:MouseEvent, dictData:Dictionary):void
		{
		}
		
		public function removeTooltipDataFromShpMap(shpMap:ShpMap, event:MouseEvent, dictData:Dictionary):void
		{
		}
		
		public function getDataByFieldName(field:String):String
		{
			return null;
		}
		
		public function getDefaultMapIndex():int
		{
			return this.years.length - 1;
		}
	}
}