//Space Shuttle Land Program ver. 0.2
//Created July 9, 2017 by Ziyang Yuan Atomoxide



declare function phaseAngleFun 
{
	//Kerbin, Return Phase Angle (Exponential Regression)
	parameter orbitAlt.
	if orbitAlt <= 495080
	{
		local fita to 66.202895028591414.
		local fitb to -0.000010645891569.
		local fitc to 49.452185257004714.
		local fitd to 0.000000011018120.
		return fita*(constant:e^(fitb*orbitAlt))+fitc*(constant:e^(fitd*orbitAlt)).
	}
	else if orbitAlt > 495080
	{
		local fita to 28.662822292358253.
		local fitb to -0.000004147840292.
		local fitc to 39.369731475172358.
		local fitd to 0.000000334948801.
		return fita*(constant:e^(fitb*orbitAlt))+fitc*(constant:e^(fitd*orbitAlt)).
	}

}

declare function phaseAngleCalc
{
	parameter targetPosition.
	local targetvector to targetPosition:position.
	local shipvector1 to kerbin:position.
	local dis1 to (targetvector-shipvector1):mag.
	wait 0.05.
	local shipvector2 to kerbin:position.
	local dis2 to (targetvector-shipvector2):mag.
	local ang to vectorangle(shipvector2,(targetvector-shipvector2)).
	if dis1<dis2
	{
		return ang.
	}
	if dis1>dis2
	{
		return -(ang-180)+180.
	}
	
}

set ksc to kerbin:geopositionlatlng(-0.0974261199040705,-74.5579576634516).

set orbitAltitude to (ship:apoapsis+ship:periapsis)/2.
set phaseAngle to phaseAngleFun(orbitAltitude).
print orbitAltitude.
print phaseAngle.
set burnflag to 0.

until burnflag = 1
{
	set phaseang to phaseAngleCalc(ksc).
	print phaseang at (5,20).
	lock steering to -1*ship:velocity:orbit:normalized.
	//set burnang to 180 - phaseang.
	if abs(phaseang - phaseAngle)<0.05
	{
		set burnflag to 1.
	}
}

lock steering to -1*ship:velocity:orbit:normalized.

set targetPE to max(500,12500-12500*((orbitAltitude-70000)/(138000-70000))).

until ship:periapsis < targetPE
{
	lock throttle to 1.
	wait 0.01.
}

lock throttle to 0.
