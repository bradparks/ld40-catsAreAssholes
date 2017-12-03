package en.h;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class Grandma extends en.Hero {
	var rollAng = 0.;

	public function new(x,y) {
		super(x,y);

		spr.anim.registerStateAnim("heroPostRollEnd",4, function() return cd.has("rolling") && cd.getRatio("rolling")<0.2 );
		spr.anim.registerStateAnim("heroPostRoll",3, function() return cd.getRatio("rolling")>=0.2 && cd.getRatio("rolling")<0.5 );
		spr.anim.registerStateAnim("heroRoll",2, 0.2, function() return cd.getRatio("rolling")>=0.5 );
		spr.anim.registerStateAnim("heroWalk",1, 0.2, function() return cd.has("walking") );
		spr.anim.registerStateAnim("heroIdle",0);
	}

	override function getThrowAng() {
		return rollAng;
	}


	override public function update() {
		super.update();

		var spd = 0.03;

		if( !cd.has("locked") && onGround ) {
			// Movement
			if( Key.isDown(Key.RIGHT) ) {
				dir = 1;
				dx += dir*spd;
				cd.setS("walking",0.1);
			}
			else if( Key.isDown(Key.LEFT) ) {
				dir = -1;
				dx += dir*spd;
				cd.setS("walking",0.1);
			}

			if( Key.isDown(Key.UP) ) {
				dy -= spd;
				cd.setS("walking",0.1);
			}
			else if( Key.isDown(Key.DOWN) ) {
				dy += spd;
				cd.setS("walking",0.1);
			}

			// Use
			if( Key.isPressed(Key.SPACE) ) {
				var dh = new DecisionHelper(en.Interactive.ALL);
				dh.remove( function(e) return !e.canBeActivated(this) || !sightCheck(e) || distCase(e)>2.5 );
				dh.score( function(e) return isLookingAt(e) ? 5 : 0 );
				dh.score( function(e) return -distCase(e) );
				var e = dh.getBest();
				if( e!=null && ( !e.is(en.inter.ItemDrop) || item==null ) )
					e.activate(this);
				else
					dropItem();
			}

			// Call sidekick
			if( Key.isPressed(Key.C) ) {
				var dh = new DecisionHelper(en.Interactive.ALL);
				dh.remove( function(e) return !sightCheck(e) || distCase(e)>2.5 );
				dh.score( function(e) return isLookingAt(e) ? 5 : 0 );
				dh.score( function(e) return -distCase(e) );
				var e = dh.getBest();
				if( e!=null )
					side.callOn(e);
			}

			// Roll
			if( Key.isDown(Key.CTRL) && !cd.has("rollLock") ) {
				//cd.setS("rollLock",0.5);
				cd.setS("locked",0.4);
				cd.setS("rolling",0.4);
			}

			rollAng =
				Key.isDown(Key.UP) && Key.isDown(Key.RIGHT) ? -MLib.PIHALF*0.5 :
				Key.isDown(Key.DOWN) && Key.isDown(Key.RIGHT) ? MLib.PIHALF*0.5 :
				Key.isDown(Key.UP) && Key.isDown(Key.LEFT) ? -MLib.PIHALF*1.5 :
				Key.isDown(Key.DOWN) && Key.isDown(Key.LEFT) ? MLib.PIHALF*1.5 :
				Key.isDown(Key.UP) ? -MLib.PIHALF :
				Key.isDown(Key.RIGHT) ? 0 :
				Key.isDown(Key.DOWN) ? MLib.PIHALF :
				Key.isDown(Key.LEFT) ? MLib.PI :
				rollAng;
		}

		#if debug
		if( Key.isPressed(Key.NUMPAD_ENTER) )
			jump(1);
		#end

		// Roll effect
		if( cd.has("rolling") ) {
			dx += Math.cos(rollAng)*0.095 * (0.+1*cd.getRatio("rolling"));
			dy += Math.sin(rollAng)*0.095 * (0.+1*cd.getRatio("rolling"));
		}

		// Assist movement near collisions
		if( dx<0 ) {
			// Left
			if( xr<=0.6 && yr>=0.6 && level.hasColl(cx+dir,cy) && !level.hasColl(cx+dir,cy+1) ) dy+=spd*0.5;
			if( xr<=0.6 && yr<=0.7 && level.hasColl(cx+dir,cy) && !level.hasColl(cx+dir,cy-1) ) dy-=spd*0.5;
		}
		if( dx>0 ) {
			// Right
			if( xr>=0.4 && yr>=0.6 && level.hasColl(cx+dir,cy) && !level.hasColl(cx+dir,cy+1) ) dy+=spd*0.5;
			if( xr>=0.4 && yr<=0.7 && level.hasColl(cx+dir,cy) && !level.hasColl(cx+dir,cy-1) ) dy-=spd*0.5;
		}
		if( dy<0 ) {
			// Up
			if( xr>=0.5 && yr<=0.4 && level.hasColl(cx,cy-1) && !level.hasColl(cx+1,cy-1) ) dx+=spd*0.5;
			if( xr<=0.5 && yr<=0.4 && level.hasColl(cx,cy-1) && !level.hasColl(cx-1,cy-1) ) dx-=spd*0.5;
		}
		if( dy>0 ) {
			// Down
			if( xr>=0.5 && yr>=0.7 && level.hasColl(cx,cy+1) && !level.hasColl(cx+1,cy+1) ) dx+=spd*0.5;
			if( xr<=0.5 && yr>=0.7 && level.hasColl(cx,cy+1) && !level.hasColl(cx-1,cy+1) ) dx-=spd*0.5;
		}
	}
}