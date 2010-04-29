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
		
		private var scalef:Number;
		
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
		//private var loader:URLLoader = new URLLoader();
		
		private var xmlCountyData:XML;
		//private var dictCountyPopArray:Array = new Array();
		//private var dictChangePopArray:Array = new Array();
		
		private var mapLoadedCount:Number = 0;
		private var _bar:ProgressBar;
		
		private var tt_county:String = "";
		private var tt_category:String = "";
		private var tt_pop:String = "";
		private var tt_ph:String = "";
		private var tt_pa:String = "";
		
		
		// "none", "percapita_physicians", "population", "density", "percent"
		public var showMode:String = "utah";
		public var years:Array = new Array(1998, 2003, 2008);
		
		private var border:Boolean;  
		
		public function ShpMapObject(width:int, height:int, mapContainer:Sprite, progressBar:ProgressBar = null)
		{
			BGColor = 0x000000;
			_stage_width = width;
			_stage_height = height;
			_container = mapContainer;
			_bar = progressBar;
			
			/*
			TODO: this is original code, to be removed
			var i:int, year:int;
			for (i=0; i<17; i++) {
			year = 1850 + i*10;
			var loader:URLLoader = new URLLoader();
			loader.load(new URLRequest("../dat/census" + year.toString() + ".xml"));
			loader.addEventListener(Event.COMPLETE, xmlLoadComplete);
			loaderArray.push(loader);
			}
			*/

			var i:int, year:int;
			for (i = 0; i < years.length; i++) {
				year = years[i];
				var loader:URLLoader = new URLLoader();
				loader.load(new URLRequest("../dat/Utah_PH_PA_" + year.toString() + ".xml"));
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
			trace('$utah data loaded$');
			var i:int;
			for (i=0; i < years.length ; i++) {
				var censusData:Dictionary = new Dictionary();

				xmlCountyData = new XML(loaderArray[i].data);
				for each (var county:Object in xmlCountyData.county) {
					var obj:Object = new Object;

					/*
					obj["fips"] = county["fips"].toString();
					obj["countyname"] = county["countyname"].toString();
					obj["numPhys"] = parseInt(county["numPhys"]);
					obj["numPop"] = parseInt(county["numPop"]);
					obj["state"] = county["state"].toString();
					*/
					obj["countyname"] = county["countyname"].toString();
					obj["fips"] = county["fips"].toString();
					obj["category"] = county["category"].toString();
					obj["ph"] = parseInt(county["ph"]);
					obj["pa"] = parseInt(county["pa"]);
					obj["pop"] = parseInt(county["pop"]);
					
					censusData[county["fips"].toString()] = obj;
					
				}
				
				var year:Number = this.years[i];
				var elem:ShpMapElement = new ShpMapElement(year, censusData);
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
		
		// THESE ARE FOR TOOL TIPS:
		private function countyChangeHandler(event:Event):void
		{
			tt_county = event.currentTarget.getCounty();
			tt_category = event.currentTarget.getCategory();
			tt_pop = event.currentTarget.getPop();
			tt_ph = event.currentTarget.getPh();
			tt_pa = event.currentTarget.getPa();
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function getCounty():String{
			return tt_county;
		}
		public function getCategory():String{
			return tt_category;
		}
		public function getPop():String{
			return tt_pop;
		}
		public function getPh():String{
			return tt_ph;
		}
		public function getPa():String{
			return tt_pa;
		}
		
		// THE ABOVE WERE FOR TOOLTIPS
		
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
			//image_left = 90;
			//  image_top = -70;
			
			// just for fun, add a marker to somewhere around my house!
			///addMarkerAt( 42.36,-71.11 );
		}
		
		public function getShpScale():Number
		{
			//var elem:ShpMapElement = mapArray[0];
			//scalef = elem.scaleX;
			return scalef;
		}
		
		// To demonstrate retrieving a particular feature and doing something to it. This colors Wisconsin green.
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
			for (var i:int = 0; i<3; i++) {
				mapArray[i].getBorder(border);
				mapArray[i].updateMapColor(showMode);
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
			var obj:ShpMapElement;
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
	}
}