/*
	SXP_esd_fnc_removeTarget
	Author: Superxpdude
	Removes a signal target (receiver) from the spectrum device's array.
	
	Must be executed on the server to ensure consistency with all machines.
	
	Parameters:
		0: Object - The object to remove
		1: Number - The frequency of the signal
		
	Returns:
		Nothing
*/
if (!isServer) exitWith {};

params [
	["_obj", objNull, [objNull]],
	["_freq", -1, [0]]
];

if (isNull _obj) exitWith {};
if (_freq == -1) exitWith {};

// If the array doesn't exist, create it
if (isNil "SXP_esd_targets") then {
	SXP_esd_targets = [];
};

// Check if the object already exists in the array.
private _index = SXP_esd_targets findIf {(_x select 0 == _obj) and (_x select 1 == _freq)};

// If the object already exists, remove the entry
if (_index >= 0) then {
	SXP_esd_targets deleteAt _index;
};
// Broadcast the updated array to all clients
publicVariable "SXP_esd_targets";