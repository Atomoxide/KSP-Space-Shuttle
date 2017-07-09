//Space Shuttle Launch Program ver. 1.1
//Created July 6, 2017 by Atomoxide

RCS on.
SAS off.
lock throttle to 0. 
set stageflag to 0.


clearscreen.
print "   Space Shuttle Launch Sequence   " at (3,2).
print "        ver. 1.1   July 6, 2017    " at (3,3).
print "***************Orbit***************" at (3,5).
print "___________________________________" at (3,8).
print "************Stage Status***********" at (3,10).
print "Boosters: Inactive" at (3,11).
print "ET: Inactive" at (3,12).
print "SSMEs: Inactive" at (3,13).
print "OMEs: Inactive" at (3,14).
print "___________________________________" at (3,15).
print "***********Sequence Status*********" at (3,17).
if ship:status = "prelaunch"
{
	set phase to 1.
}

else
{
	set phase to -1.
}

set UIupdate to 1.
until phase = 0	//exit phase
{
	if UIupdate = 1
	{
		print "                                                " at (3,19).
		print "                                                " at (3,20).	//re-initialize Phase UI
		print "                                                " at (3,21).
		print "                                                " at (3,22).
		print "                                                " at (3,23).
		print "                                                " at (3,24).
		print "                                                " at (3,25).
	}
	
	if phase = -1	//phase -1: master alert, abort launch
	{
		print "Master Alert! Launch Sequence Abort" at (3,22).
		set UIupdate to 0.
		wait 3.
		set phase to 0.
	}
	
	else if phase = 1	//phase 1: Initiating Launching Sequences
	{
		print "Phase: 1" at (3,18).
		print "Description: Initialize Launch Sequences." at (3,19).
		print "Launch Sequence Initiating..." at (3,20).
		set UIupdate to 0.
		set targetAP to 120000.
		set booster to ship:partstagged("booster")[0].
		set externaltank to ship:partstagged("ExternalTank")[0].
		set ome to ship:partstagged("OME")[0].
		set str to heading(90,80)+R(0,0,-180).
		wait 1.
		print "Launch Sequence Initiated." at (3,20).
		print "Launch in:" at (3,21).
		from {local countdown to 5.} until countdown = 0 step {set countdown to countdown - 1.} 
		do 
		{
			print countdown + " sec" at (3,22).
			WAIT 1.	
		}.
		set thr to 1.
		stage.
		print "Boosters: Burning     " at (3,11).
		print "ET: Active     " at (3,12).
		print "SSMEs: Burning     " at (3,13).
		set phase to 2.
		set UIupdate to 1.
	}
	
	else if phase = 2	//phase 2: Ascending under 5km
	{
		print "Description: Ascending Before Gravity Turn." at (3,19).
		set UIupdate to 0.
		set thr to 1.
		if ship:altitude > 5000
		{
			set phase to 3.
			set UIupdate to 1.
		}
	}
	
	else if phase = 3	//phase 3: gravity turn
	{
		print "Description: Perform Gravity Turn." at (3,19).
		set turnAngle to max(5, 80*(1-(ship:altitude-5000)/45000)).
		set str to heading(90,turnAngle)+R(0,0,-180).
		set thr to max(0.5,1*(1-(ship:altitude-5000)/55000)).
		print "Pitch Angle: " + round(turnAngle,3) + " degree       " at (3,20).
		print "Throttle Percent: " + round(100*thr,1) + " %         " at (3,21).
		set UIupdate to 0.
		if ship:apoapsis >= targetAP	//reach ap, good
		{
			set phase to 4.
			set UIupdate to 1.
		}
		else if (ship:apoapsis < targetAP and (externaltank:mass = externaltank:drymass))	
		//cant reach ap before running out of fuel, alert but countinue
		{
			print "Warning: Unable to Reach Target Apoapsis!" at (3,22).
			set phase to 4.
			set UIupdate to 1.
		}
	}
	
	else if phase = 4	//phase 4: detach external tank, main engine shutdown, orbital maneuvering engine fire
	{
		print "Description: Detach ET, Switch Engine Mode." at (3,19).
		set UIupdate to 0.
		rcs off.
		set str to ship:velocity:orbit.
		set thr to 0.
		ag1 on.
		print "ET: Detached    " at (3,12).
		print "SSMEs: Inactive    " at (3,13).
		print "OMEs: Active    " at (3,14).
		set targetPE to ship:apoapsis.
		set targetAP to ship:apoapsis.
		set phase to 5.
		set UIupdate to 1.
		wait 3.
	}
	
	else if phase = 5	//phase 5: Plan Sub-orbit maneuvering 
	{
		print "Description: Plan Sub-orbit Maneuvering." at (3,19).
		set UIupdate to 0.
		set acc to (maxthrust/ship:mass).
		local orbitradius to kerbin:radius+ship:apoapsis.
		local orbitspeed to sqrt(kerbin:mu*(1/orbitradius)).
		local currentspeed to velocityat(ship,time+eta:apoapsis):orbit:mag.
		local delv to (orbitspeed - currentspeed).
		set orbitalmaneuver1 to node(time:seconds+eta:apoapsis,0,0,delv).
		add orbitalmaneuver1.
		set estburntime to delv/acc.
		set phase to 6.
		set UIupdate to 1.
		wait 3.
	}
	
	else if phase = 6	//phase 6: Wait until burn start
	{
		print "Description: Wait Unitl Burn Start." at (3,19).
		rcs on.
		set str to orbitalmaneuver1:deltav:normalized.
		set burncountdown to orbitalmaneuver1:eta-(0.5*estburntime).
		print "Burn Countdown: " + round(burncountdown,3) + " sec   " at (3,20).
		print "Maneuver Point ETA: " + round(orbitalmaneuver1:eta,3) + " sec   " at (3,21).
		set UIupdate to 0.
		print "Est. Burn Time: " + round(estburntime,3) + " sec   " at (3,22).
		if (burncountdown < 0.1 and burncountdown > -1)
		{
			set phase to 7.
			set UIupdate to 1.
		}
		else if burncountdown < -1
		{
			print "Warning: Unable to Reach Target Orbit!" at (3,23).
			set phase to 7.
			set UIupdate to 1.
		}
	}
	
	else if phase = 7	//phase 7: accelerate into orbit
	{
		print "Description: Burn to Accelerate into Orbit." at (3,19).
		set fuelpercent to (ship:mass-ship:drymass)/(ship:wetmass-ship:drymass).
		set str to orbitalmaneuver1:deltav:normalized.
		lock realacc to ((2*ome:thrust)/ship:mass).
		set kp to 0.4.
		set ki to 0.1.
		set kd to 0.005.
		lock Err to acc-realacc.
		set I to 0.
		set D to 0.
		set P to Err.
		set t0 to time:seconds.
		set thr to 0.97.
		lock dthr to kp*P + ki*I + kd*D.
		until abs(ship:periapsis-targetPE)<500
		{
			set dt to time:seconds - t0.
			print "OMEs: Burning    " at (3,14).
			if dt > 0
			{
				set I to I + Err*dt.
				set I to min(1/ki,max(-1/ki,i)).
				set D to (Err-P)/dt.
				set thr to min(1,max(0,thr+dthr)).
				set P to Err.
			}
			if (fuelpercent < 0.1 and ship:periapsis < 70000) 
			{
				print "Warning: Unable to Reach Stable Orbit!" at (3,23).
				set phase to -1.
				break.
			}
			else if (fuelpercent < 0.1 and ship:periapsis > 70000 and ship:periapsis < targetPE)
			{
				print "Warning: Unable to Reach Target Orbit!" at (3,23).
				set phase to 8.
				break.
			}
			print "Set Acceleration: " + round(acc,3) + " m s^-2        " at (3,20).
			print "Actual Acceleration: " + round(realacc,3) + " m s^-2        " at (3,21).
			print "Difference: " + round(Err,3) + " m s^-2        " at (3,22).
			set UIupdate to 0.
			print "Apoapsis: " + round(ship:apoapsis,3) + " m " at (3,6).
			print "Periapsis: " + round(ship:periapsis,3) + " m " at (3,7).
			set t0 to time:seconds.
		}
		set thr to 0.
		print "OMEs: Inactive    " at (3,14).
		set phase to 8.
		remove orbitalmaneuver1.
		set UIupdate to 1.
	}
	
	else if phase = 8	//phase 8: check orbit, finalize sequence
	{
		print "Description: Check Orbit and Finalize." at (3,19).
		ag2 on.
		unlock steering.
		unlock throttle.
		rcs off.
		if (ship:apoapsis > 1.1*targetAP or ship:apoapsis < 0.9*targetAP)
		{
			print "Warning: Orbit does not Match Target!Launch Sequence End!" at (3,20).
		}
		else if (ship:periapsis > 1.1*targetPE or ship:periapsis < 0.9*targetPE)
		{
			print "Warning: Orbit does not Match Target!Launch Sequence End!" at (3,20).
		}
		else
		{
			print "Shuttle is in Target Orbit. Launch Sequence End!" at (3,20).
		}
		set UIupdate to 0.
		wait 5.
		set phase to 0.
		set UIupdate to 1.
	}
	
	if (booster:maxthrust <= 0 and stageflag = 0)	//staging booster
	{
		stage.
		print "Boosters: Detached     " at (3,11).
		set stageflag to 1.
	}
	lock steering to str.
	lock throttle to thr.
	print "Apoapsis: " + round(ship:apoapsis,3) + " m " at (3,6).
	print "Periapsis: " + round(ship:periapsis,3) + " m " at (3,7).
	print "Phase: " + phase at (3,18).
}







