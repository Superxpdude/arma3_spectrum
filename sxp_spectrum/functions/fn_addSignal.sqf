/*
	SXP_esd_fnc_addSignal
	Author: Superxpdude
	Adds a signal to the spectrum device's array.
	
	Must be executed on the server to ensure consistency with all machines.
	
	Parameters:
		0: Object - The object that will have the signal attached to it.
		1: Number - The frequency of the signal.
		2: Number - The maximum distance at which the signal can be picked up.
	
	Returns:
		Nothing
*/
if (!isServer) exitWith {};

params [
	["_obj", objNull, [objNull]],
	["_freq", -1, [0]],
	["_str", -1, [0]]
];

if (isNull _obj) exitWith {};
if (_freq == -1) exitWith {};
if (_str == -1) exitWith {};

// If the array doesn't exist, create it
if (isNil "SXP_esd_sources") then {
	SXP_esd_sources = [];
};

// Check if the object already exists in the array.
private _index = SXP_esd_sources findIf {_x select 0 == _obj};

// If the object already exists, overwrite the existing signal
if (_index >= 0) then {
	SXP_esd_sources set [_index, [_obj,_freq,_str]];
} else {
	// Otherwise, append the object entry to the array
	SXP_esd_sources append [[_obj,_freq,_str]];
};
// Broadcast the updated array to all clients
publicVariable "SXP_esd_sources";