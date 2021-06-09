/*
	SXP_esd_fnc_init
	Author: Superxpdude
	Initializes the spectrum device system on all machines
	
	Needs to be executed on all clients at mission start
	By default this is executed in postInit
	
	Parameters:
		None
	
	Returns:
		Nothing
*/

// Does not need to run on dedicated servers or headless clients
if (!hasInterface) exitWith {};

// ESD frequency range
missionNamespace setVariable ["#EM_FMin", 78];
missionNamespace setVariable ["#EM_FMax", 89];

// ESD sensitivity
missionNamespace setVariable ["#EM_SMin", -60];
missionNamespace setVariable ["#EM_SMax", -10];

// ESD selected frequency
missionNamespace setVariable ["#EM_SelMin", 81.0];
missionNamespace setVariable ["#EM_SelMax", 81.5];

// Miscellanious variables
missionNamespace setVariable ["#EM_Progress", 0];
missionNamespace setVariable ["#EM_Transmit", false];

[] spawn {
	waitUntil {!isNil "SXP_esd_sources"};
	addMissionEventHandler ["EachFrame", SXP_esd_fnc_eachFrame];
};