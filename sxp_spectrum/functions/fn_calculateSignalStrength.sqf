/*
	SXP_esd_fnc_calculateSignalStrength
	Author: Superxpdude
	Calculates the signal strength from the player to a specified signal
	
	Parameters:
		0: Object - Object that the signal is attached to
		1: Number - Maximum distance of signal
	
	Returns:
		Number - Percentage signal strength (from 0 to 1)
*/

params [
	["_obj", objNull, [objNull]],
	["_maxDist", -1, [0]],
	["_requireCone", false, [false]]
];

// Basic check to make sure that we're within the maximum distance of the object
private _distance = player distance _obj;
// If we're further away than the max distance, return a strength of zero
if (_distance > _maxDist) exitWith {0};

// Determine our "fallback" modifier if the signal is outside of the cone
private _fallbackDirStr = if (_requireCone) then {0} else {0.1};

// Calculate our signal strength by distance
// Start by figuring out the relative distance from the player to the object
// compared to the max signal distance
private _distPct = linearConversion [_maxDist, 0, _distance, 0, 1, true];

// Calculate the terrain interception coefficient.
// Heavily inspired by how TFAR calculates terrain interception.
// Does not factor in other objects in the way
private _playerEyePos = eyePos player;
private _objCenterPos = _obj modelToWorldVisualWorld [0,0,0];
private _terrainInterceptCoef = if (terrainIntersectASL [_playerEyePos, _objCenterPos]) then {
	private _max = 250.0;
	private _min = 10.0;
	private _offset = 100.0;
	
	// Get position directly between the two objects
	private _centerPos = [(_playerEyePos # 0 + _objCenterPos # 0) / 2, (_playerEyePos # 1 + _objCenterPos # 1) / 2, (_playerEyePos # 2 + _objCenterPos # 2) / 2];
	private _base = _centerPos # 2; // Get the z-coordinate of this position
	
	// This is the extremely clever way that TFAR uses to calculate this
	while {(_max - _min) > 10} do {
		_centerPos set [2, (_base + _offset)];
		if ((!terrainIntersectASL [_playerEyePos, _centerPos]) and {!terrainIntersectASL [_objCenterPos, _centerPos]}) then {
			_max = _offset; // No intersect. True offset must be less than the one we used.
		} else {
			_min = _offset; // Terrain still intersects, true offset must be greater than the one we used.
		};
		_offset = (_min + _max) / 2; // Get the center point between our max and min offsets
	};
	
	// Now that we have our true offset (in distance), we convert that to an angle
	private _offsetAngle = atan (_offset / (_distance / 2));
	// With our angle, we return the cosine as our intercept coefficient
	linearConversion [0.7, 1, cos _offsetAngle, 0, 1, true]
} else {
	1
};

// Throw the percentage distance into a quadratic equation to get a good approximation
// of signal strength over distance
// Note that the range here is [0,1]
private _distStr = (_distPct ^ 2) * _terrainInterceptCoef;

// Calculate the signal strength by direction
// Uses vector math to account for weapon (i.e. antenna) direction
private _vectorAngleDiff = (acos (((getPosASL player) vectorFromTo (getPosASL _obj)) vectorCos (player weaponDirection (currentWeapon player))));
// If we're outside of our 30 degree cone, return 0.1. as the modifier
// This isn't necessarily *realistic*, but it works well for gameplay purposes
private _dirStr = if (_vectorAngleDiff <= 30) then {1 - ((_vectorAngleDiff ^ 2) / 1000)} else {_fallbackDirStr};

// Our final value can be reached by the combination of our distance and direction strengths
(_distStr * _dirStr)