﻿package{	import flash.display.DisplayObject;	import flash.display.Sprite;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.geom.Rectangle;	import flash.net.URLLoader;	import flash.net.URLLoaderDataFormat;	import flash.net.URLRequest;	import flash.utils.ByteArray;	import flash.utils.Dictionary;		import org.vanrijkom.dbf.*;	import org.vanrijkom.shp.*;		/**	 * The ShpMap class represents a map drawn from a single shapefile.	 * This class currently supports basic point, polyline, and polygon shapefiles.	 * @author Andy Woodruff (http://www.cartogrammar.com/blog);	 * 	 */	public class ShpMap extends Sprite{				/**		 * The geographic (e.g. states or countries) features contained in the shapefile.		 */		public var features : Array = new Array();				public var attributeFields : Array;				private var dataInterface:DataInterface;		public var dictData : Dictionary;				/**		 * A Sprite on which features will be added. This exists so that it can be positioned correctly within the ShpMap.		 */		private var map : Sprite = new Sprite();				private var dataLoader : URLLoader = new URLLoader();		private var shpLoaded : Boolean = false;				private var highlightBorder : Boolean = true;		private var highlightUrban : Boolean = false;				private var debugString:String = "$ShpMap$";				/**		 * Constructor		 * @param src A String giving the location of the source shapefile.		 * @param dbfSrc (optional) A string giving the location of the DBF file associated with the shapefile		 */		public function ShpMap( src : String, dbfSrc : String, 								dictData : Dictionary, inputDataInterface:DataInterface)		{			addChild(map);						this.dictData = dictData;			this.dataInterface = inputDataInterface;						// load the shapefile			dataLoader.dataFormat = URLLoaderDataFormat.BINARY;			dataLoader.load( new URLRequest(src) );			dataLoader.addEventListener( Event.COMPLETE, onShapefile );						if ( dbfSrc != null ) {				var dbfLoader : URLLoader = new URLLoader();				dbfLoader.dataFormat = URLLoaderDataFormat.BINARY;				dbfLoader.load( new URLRequest(dbfSrc) );				dbfLoader.addEventListener( Event.COMPLETE, onDBF );			}		}				private function onShapefile( event:Event ) : void		{						// use the ShpTools class to parse the shapefile into an array of records			var records : Array = ShpTools.readRecords(event.target.data).records;						// create a feature (point, polyline, or polygon) from each record			for each( var record : ShpRecord in records ){				var feature : ShpFeature = createFeature(record);				if ( feature != null ) features.push( feature );			}						shpLoaded = true;						// draw the features			drawMap();						// to signal the completion of map loading/drawing			dispatchEvent(new Event("map loaded",true));		}				/**		 * Creates the appropriate type of feature for a record.		 * @param record The source record.		 * @return A point, polyline, or polygon feature.		 * 		 */		private function createFeature( record : ShpRecord ) : ShpFeature		{			var feature : ShpFeature;			switch( record.shapeType ) {								case ShpType.SHAPE_POINT:					feature = new PointFeature(record);					break;								case ShpType.SHAPE_POLYLINE:					feature = new PolylineFeature(record);					break;								case ShpType.SHAPE_POLYGON:					feature = new PolygonFeature(record);					break;							}						// other shape types will return null			return feature;		}				// Event handler for DBF load.		private function onDBF( event:Event ) : void		{			// Wait to create attributes until the shapefile is loaded.			if (shpLoaded){				createAttributes(event.target.data);			} else {				dataLoader.addEventListener( Event.COMPLETE, function(e:Event):void{ createAttributes(event.target.data); } );			}		}				private function createAttributes( dbf : ByteArray ) : void		{			var dbfHeader : DbfHeader = new DbfHeader(dbf);						// Checking if the DBF has the same number of records as the shapefile is a basic test of whether the two files match.			if (dbfHeader.recordCount != features.length) {				throw new Error("Shapefile/DBF record count mismatch. Attributes were not loaded.");				return;			}						// Populate attribute field names array.			attributeFields = new Array();			for each ( var field : DbfField in dbfHeader.fields ) {				attributeFields.push( field.name );			}						for ( var i : int = 0; i < features.length; i++ ) {				features[i].values = DbfTools.getRecord(dbf, dbfHeader, i).values;				features[i].addEventListener(MouseEvent.MOUSE_OVER, displayAreaInfo);				features[i].addEventListener(MouseEvent.ROLL_OUT, removeAreaInfo);			}						updateMapColor();						dispatchEvent(new Event("attributes loaded", true));		}				public function updateMapColor():void {			dataInterface.updateMapColor(dictData, features, highlightBorder, highlightUrban);		}				private function displayAreaInfo(event:MouseEvent):void {			dataInterface.readTooltipDataFromShpMap(this, event, dictData);		}				private function removeAreaInfo(event:MouseEvent):void {			dataInterface.removeTooltipDataFromShpMap(this, event, dictData);		}				/**		 * Retrieves a feature from the shapefile based on a specified attribute name and value.		 * This is meant for searching unique identifiers. If the field being searched has non-unique 		 * values, this method will only return the first encountered feature with a matching <code>value</code>.		 * @param key The attribute field name.		 * @param value  The attribute value.		 * @return The feature with the value <code>value</code> for the specified <code>key</code>, or <code>null</null> if no match is found or the <code>key</code> is invalid.		 * 		 */		public function getFeatureByAttribute( key : String, value : * ) : ShpFeature		{			if ( attributeFields.indexOf( key ) == -1 ) return null;  // Fail if there is no such attribute name.			for each ( var feature : ShpFeature in features ) {				if ( feature.values[key] is String ) {					var attribute : String = trim(feature.values[key]);				} else {					attribute = feature.values[key];				}								if ( attribute == value ) return feature;							}			return null;		}				// trims whitespace		private function trim(str:String) : String {			return str.replace(/^\s+|\s+$/g, '');		}				/**		 * Adds all the features to the display. 		 * 		 */		private function drawMap() : void 		{			for each ( var feature : ShpFeature in features ) {				map.addChild(feature);			}						/*  Features are all positioned according to their lat/long,			meaning that x is somewhere from -180 to 180 and y is			between -90 and 90. Here we get the actual bounds of all			features and move the whole map so that its top left			is at the normal (0,0) of Flash coordinate space. */			var bounds : Rectangle = map.getBounds(this);			map.x = -bounds.left;			map.y = -bounds.top;		}				/**		 * Adds a given marker at a specified lat/long location.		 * A simple demonstration of how the everything is still geo-referenced.		 * @param lat The latitude at which to add the marker.		 * @param lon The longitude at which to add the marker.		 * @param marker The marker to add to the map.		 * 		 */		public function addMarker( lat : Number, lon : Number, marker : DisplayObject ) :void		{			marker.x = lon;			marker.y = -lat;  // remember that negative is UP in Flash but DOWN in latitude! hence the switch here and elsewhere			map.addChild(marker);		}				public function setBorder( inbool:Boolean ):void{			highlightBorder = inbool;		}				public function setHighlightUrban (inbool:Boolean):void{			highlightUrban = inbool;		}				public function getDebugString():String {			return this.debugString;		}	}}