/*
	SXP_esd_fnc_addTarget
	Author: Superxpdude
	Adds a signal target (receiver) to the spectrum device's array.
	
	Must be executed on the server to ensure consistency with all machines.
	
	Parameters:
		0: Object - The object that will receive spectrum device transmissions
		1: Number - The frequency the object will listen on
		2: Number - Distance at which the object can receive transmissions
		3: Code - Activation Function: Function to call when the object receives the signal
		4: Code (Optional) - Deactivation function: Function to call when the object stops receiving the signal
		5: Number (Optional) - Transmit time: Delay from when the transmission starts to when the "activation" function executes
	
	Returns:
		Nothing
*/
if (!isServer) exitWith {};

params [
	["_obj", objNull, [objNull]],
	["_freq", -1, [0]],
	["_dist", -1, [0]],
	["_activateFunc", {}, [{}]],
	["_deactivateFunc", nil, [{}]],
	["_activateDelay", 0, [0]]
];

if (isNull _obj) exitWith {};
if (_freq == -1) exitWith {};

// If the array doesn't exist, create it
if (isNil "SXP_esd_targets") then {
	SXP_esd_targets = [];
};

// Check if the target already exists in the array.
private _index = SXP_esd_targets findIf {(_x select 0 == _obj) and (_x select 1 == _freq)};

// If the object already exists, overwrite the existing target entry
if (_index >= 0) then {
	SXP_esd_targets set [_index, [_obj,_freq,_dist,_activateFunc,_deactivateFunc,_activateDelay]];
} else {
	// Otherwise, append the target entry to the array
	SXP_esd_targets append [[_obj,_freq,_dist,_activateFunc,_deactivateFunc,_activateDelay]];
};
// Broadcast the updated array to all clients
publicVariable "SXP_esd_targets";