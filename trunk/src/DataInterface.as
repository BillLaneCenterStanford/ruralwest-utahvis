package
{
	import flash.display.Sprite;
	import flash.events.*;
	import flash.utils.Dictionary;
	
	public interface DataInterface
	{
		function getYears():Array;
		
		function getXmlFileName(year:String):String;
		function getShpFileName(year:String):String;
		function getDbfFileName(year:String):String;
		
		function getDataAttributes():Array;
		function getKeyAttribute():String;
		function keyAttributeNameInDbfFile():String;
		
		function updateMapColor(dictData:Dictionary, features:Array, highlightBorder:Boolean, highlightUrban:Boolean):void;
		
		function drawLegendForLegendBar(ox:int, oy:int, segLength:int, legendSprite:Sprite, textContainer:Sprite):void;
		
		function drawTooltip(root:Sprite):void;
		function handleTooltip(mapObj:ShpMapObject, event:Event):void;
		
		function readTooltipDataFromShpMap(shpMap:ShpMap, event:MouseEvent, dictData:Dictionary):void;
		function removeTooltipDataFromShpMap(shpMap:ShpMap, event:MouseEvent, dictData:Dictionary):void;
		
		function getDataByFieldName(field:String):String;
		
		function getDefaultMapIndex():int;
		
		function getDebugString():String;
		
		function getInitialZoom():Number;
		function getMaxZoom():Number;
		function getMinZoom():Number;
		
		function getImageLeft():int;
		function getImageTop():int;
	}
}
