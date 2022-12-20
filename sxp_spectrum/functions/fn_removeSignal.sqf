/*
	SXP_esd_fnc_removeSignal
	Author: Superxpdude
	Removes a signal from the spectrum device's array.
	
	Must be executed on the server to ensure consistency with all machines.
	
	Parameters:
		0: Object - The object that will have its signal removed.
	
	Returns:
		Nothing
*/
if (!isServer) exitWith {};

params [
	["_obj", objNull, [objNull]]
];

if (isNull _obj) exitWith {};

// If the array doesn't exist, create it
if (isNil "SXP_esd_sources") then {
	SXP_esd_sources = [];
};

// Check if the object already exists in the array.
private _index = SXP_esd_sources findIf {_x select 0 == _obj};

// If the object already exists, remove the entry
if (_index >= 0) then {
	SXP_esd_sources deleteAt _index;
};
// Broadcast the updated array to all clients
publicVariable "SXP_esd_sources";