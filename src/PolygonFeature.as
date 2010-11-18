package
{
	import flash.geom.Rectangle;
	
	import org.vanrijkom.shp.ShpPolygon;
	import org.vanrijkom.shp.ShpRecord;
	
	/**
	 * A display object for a single polygon feature.
	 * @author Andy Woodruff
	 * 
	 */
	public class PolygonFeature extends ShpFeature
	{
		/**
		 * Polygon geometry consists of one or more rings of points.
		 * Each ring is an Array and defines a separate polygon.
		 * (Consider Hawaii as a polygon feature: it is one feature
		 * consisting of several separate shapes, i.e. islands.)
		 */
		private var geometry : Array;
		
		public function PolygonFeature(record:ShpRecord)
		{
			super();
			geometry = (record.shape as ShpPolygon).rings;
			
			/* project points in ring[] */
			/*
			* reference on page
			*     http://goo.gl/oAQA
			*/
			for each (var ring:Array in geometry) {
				for (var i:int = 0; i < ring.length; i++) {
					
					var xx:Number = ring[i].x;
					var yy:Number = ring[i].y;
					var theta:Number = 0;
					
					xx += 111.6;
					yy -= 39.5;
					
					xx *= 0.8;
					
					var rho:Number = 40;
					
					xx *= (Math.abs(rho - yy) / rho);
					theta = Math.atan(xx / (rho-yy));
					theta -= 12 / 180 * 3.142;
					
					xx = (rho-yy) * Math.sin(theta);
					yy = rho - (rho-yy) * Math.cos(theta);

					ring[i].x = xx;
					ring[i].y = yy;
				}
			}
			/* project points in ring[] */
			
			a[0] = Number.POSITIVE_INFINITY;
			a[1] = Number.NEGATIVE_INFINITY;
			a[2] = Number.POSITIVE_INFINITY;
			a[3] = Number.NEGATIVE_INFINITY;
			
			for each (var ring:Array in geometry) {
				for (var i : int = 0; i < ring.length; i++) {
					a[0] = Math.min(a[0], ring[i].x);
					a[1] = Math.max(a[1], ring[i].x);
					a[2] = Math.min(a[2], ring[i].y);
					a[3] = Math.max(a[3], ring[i].y);
				}
			}
			
			/* call draw from ShpMap explicitly */
			draw();
		}
		
		override public function draw(lineColor:uint = 0x666666, fillColor:uint = 0xcccccc, fillAlpha:Number = 1.0):void
		{
			shape.graphics.clear();
			shape.graphics.lineStyle(1,lineColor,1,false,"none");
			for each ( var ring:Array in geometry ) {
				shape.graphics.moveTo( ring[0].x*scaleFactor, -ring[0].y*scaleFactor );
				shape.graphics.beginFill(fillColor, fillAlpha);
				for ( var i : int = 1; i < ring.length; i ++ ) {
					shape.graphics.lineTo( ring[i].x*scaleFactor, -ring[i].y*scaleFactor );
				}
				shape.graphics.endFill();
			}
			shape.scaleX = shape.scaleY = 1/scaleFactor;  // see comment on scaleFactor in ShpFeature.as
			addChild(shape);
			
			var bounds : Rectangle = shape.getBounds(this);
			shape.x = -bounds.x;
			shape.y = -bounds.y;
			this.x = bounds.x;
			this.y = bounds.y;
		}
		
		private var a:Array = new Array(4);
		public function dim():Array {
			return a;
		}
	}
}