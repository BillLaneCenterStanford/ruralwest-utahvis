package
{
	import flare.widgets.ProgressBar;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	public class ShpMapObject extends Sprite
	{
		private var BGColor:uint;
		private var mapArray:Array = new Array();
		private var mapBoundArray:Array = new Array(4);
		
		private var _ox:int = -2;
		private var _oy:int = 53;
		
		private var _stage_width:int;
		private var _stage_height:int;    
		private var _current_map:int = 1;
		private var _container:Sprite;
		
		private var loaderArray:Array = new Array();
		private var countLoadedXML:Number = 0;
		
		private var xmlData:XML;
		
		private var mapLoadedCount:Number = 0;
		private var _bar:ProgressBar;
		
		// data interface, used to shift among different data sets
		private var dataInterface:DataInterface;
		
		public var years:Array;
		
		private var border:Boolean;  
		private var highlight_urban:Boolean = false;
		
		
		public function ShpMapObject(width:int, height:int, mapContainer:Sprite, inputDataInterface:DataInterface, progressBar:ProgressBar = null)
		{
			BGColor = 0x000000;
			_stage_width = width;
			_stage_height = height;
			_container = mapContainer;
			_bar = progressBar;
			
			this.dataInterface = inputDataInterface;

			this.years = dataInterface.getYears();
			
			var i:int, year:int;
			for (i = 0; i < years.length; i++) {
				year = years[i];
				var loader:URLLoader = new URLLoader();
				loader.load(new URLRequest(dataInterface.getXmlFileName(year.toString())));
				loader.addEventListener(Event.COMPLETE, xmlLoadComplete);
				loaderArray.push(loader);
			}
			
			border = true;
		}
		
		private function xmlLoadComplete(event:Event):void {
			countLoadedXML += 1;
			trace(countLoadedXML);
			if (countLoadedXML == years.length) {
				loadShpMaps();
			}
		}
		
		private function loadShpMaps():void {
			var i:int;
			for (i=0; i < years.length ; i++) {
				var year:String = this.years[i];
				
				var dictData:Dictionary = new Dictionary();
				
				xmlData = new XML(loaderArray[i].data);
				for each (var area:Object in xmlData.area) {
					var obj:Object = new Object;
					
					// loop through attributes and add to data obj
					var arrayAttr:Array = dataInterface.getDataAttributes();
					for each (var attr:String in arrayAttr) {
						obj[attr] = area[attr].toString();
					}
					
					// use identifying key attribute to index into dictionary of data
					dictData[area[dataInterface.getKeyAttribute()].toString()] = obj;					
				}
				
				/*
				 * CODE FOR READING SHAPE FILES
				 */
				// if using shp files on server
				// super("http://ruralwest.stanford.edu/GIS/us"+year.toString()+".shp", "http://ruralwest.stanford.edu/GIS/US"+year.toString()+".DBF", dictData);
				
				// if using shp files on local
				var elem:ShpMap = new ShpMap(
					dataInterface.getShpFileName(year.toString()), 
					dataInterface.getDbfFileName(year.toString()),
					dictData, dataInterface);
				
				elem.addEventListener(Event.CHANGE, countyChangeHandler);
				
				elem.visible = false;
				elem.addEventListener("map loaded",onMapLoaded);
				elem.addEventListener("attributes loaded",onAttributesLoaded);
				
				mapArray.push(elem);
				mapBoundArray[i] = new Shape();
				var shp:Shape = mapBoundArray[i];
				shp.graphics.clear();
				shp.graphics.beginFill(BGColor);
				shp.graphics.drawRect(_ox, _oy, _stage_width, _stage_height);
				shp.graphics.endFill();
				shp.x = 7;
				shp.y = -18;
				
				elem.mask = shp;
			}
			
		}
		
		// FOR TOOL TIPS:
		private function countyChangeHandler(event:Event):void
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		// Need to wait for the map to finish loading/drawing before it can be resized correctly.
		//private var onMapLoaded:Function = function(event:Event):void
		private function onMapLoaded(event:Event):void
		{
			trace("$onMapLoaded$");
			var map:Object = event.target;
			_container.addChild(Sprite(map));
			//map.scaleX = map.scaleY = map.width > map.height ? _stage_width/map.width : _stage_height/map.height;
			map.scaleX = map.scaleY = 0.3;
			map.x = 60;
			map.y = 50;
		}
		
		private function onAttributesLoaded(event:Event):void
		{
			trace("$onAttributedsLoaded$")
			mapLoadedCount++;
			trace(mapLoadedCount);
			
			_bar.progress = mapLoadedCount / years.length;
			if (mapLoadedCount >= years.length) {
				dispatchEvent(new Event("all map loaded",true));
			}
			
			var map:Object = event.target;
			
		}
		
		public function updateMapColor():void {
			for (var i:int = 0; i < this.mapArray.length; i++) {
				mapArray[i].setBorder(border);
				mapArray[i].setHighlightUrban(highlight_urban);
				mapArray[i].updateMapColor();
			}
		}
		
		// Super basic method for adding a green box at a specified lat/long.
		private function addMarkerAt( lat : Number, lon : Number )  : void
		{
			var box : Sprite = new Sprite();
			box.graphics.lineStyle(1,0,1,false,"none");
			box.graphics.beginFill(0x009933);
			box.graphics.drawRect(-.5,-.5,1,1);
			box.graphics.endFill();
			mapArray[_current_map].addMarker(lat,lon,box);
		}
		
		public function SetMapEmbedSrc(sel:int):void
		{
			var obj:Object;
			for each (obj in mapArray){
				obj.visible = false;
			}
			mapArray[sel].visible = true;
			_current_map = sel;
		}
		
		public function SetMapColor(color:uint):void
		{
			BGColor = color;
		}
		
		public function ScaleMap(factor:Number):void
		{
			var obj:Sprite;
			for each(obj in mapArray){
				obj.width *= factor;
				obj.height *= factor;
			}
		}
		
		public function ScaleAndTranslateMap(sc:Number, sx:int, sy:int):void
		{
			var obj:ShpMap;
			for each(obj in mapArray){
				obj.scaleX = sc;
				obj.scaleY = sc;
				obj.x = sx;
				obj.y = sy;
			}
		}
		
		public function SetMap(ox:int, oy:int, width:int, height:int):void
		{
			var shp:Shape;
			for each(shp in mapBoundArray){
				shp.graphics.clear();
				shp.graphics.beginFill(BGColor);
				shp.graphics.drawRect(ox, oy, width, height);
				shp.graphics.endFill();
			}
			
			var obj:Sprite;
			var i:int;
			for each (obj in mapArray){
				obj.mask = mapBoundArray[i];
				i++;
			}
		}
		
		public function GetMap():Sprite
		{
			return mapArray[_current_map]; 
		}
		
		public function GetVizAt(i:int):Sprite
		{
			return mapArray[i];
		}
		
		public function getBorder(inbool:Boolean):void{
			border = inbool;
		}
		
		public function getHighlightUrban (inbool:Boolean):void{
			highlight_urban = inbool;
		}
	}
}