/*
	SXP_esd_fnc_serverTransmit
	Author: Superxpdude
	Handles initializing a server loop for transmission deactivation code
	
	Should be remoteExec'd from a client that starts a transmission
	
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

