/*
	SXP_esd_fnc_eachFrame
	Author: Superxpdude
	
	EachFrame mission event handler function for the spectrum device
	
	Parameters:
		None
	
	Returns:
		Nothing
*/

// This only needs to run if the player has a spectrum device in hand
if ("hgun_esd_" in (currentWeapon player)) then {
	// Define some basic variables
	private _minDirDiff = 5; // Minimum direction difference before signal begins to drop
	private _maxDirDiff = 60; // Maximum direction difference before signal is at minimum strength
	private _maxSignalStr = 50; // Maximum signal strength above 0
	private _signalStrMod = -60; // Modifier applied to signal strength result
	
	// Variables for the spectrum device itself
	private _emSignals = [];
	private _em_selMin = missionNamespace getVariable ["#EM_SelMin", 0];
	private _em_selMax = missionNamespace getVariable ["#EM_SelMax", 0];
	
	// Iterate through each signal source
	{
		private _obj = _x#0;
		private _freq = _x#1;
		private _str = _x#2;
		private ["_effectiveStr", "_effectiveStrDist", "_effectiveStrDir", "_relDir"];
		
		private _dist = player distance _obj;
		// Only continue if the player is within signal distance
		if (_dist <= _str) then {
			// Calculate the direction loss for the signal
			_relDir = player getRelDir _obj;
			_effectiveStrDir = (linearConversion [_maxDirDiff,_minDirDiff,_relDir,0.2,1,true]) max (linearConversion [360 - _maxDirDiff,360 - _minDirDiff,_relDir,0.2,1,true]); // Strength modifier for direction
			// Calculate the distance loss for the signal
			_effectiveStrDist = linearConversion [_str,0,_dist,0,1,true]; // Strength modifier for distance
			// Calculate our final signal strength
			_effectiveStr = ((_maxSignalStr * _effectiveStrDist) * _effectiveStrDir) + _signalStrMod;
			// Append the signal to our signals array
			_emSignals append [_freq, _effectiveStr];
		};	
	} forEach SXP_esd_sources;
	
	// Set the signals array
	missionNamespace setVariable ["#EM_Values",_emSignals];
};