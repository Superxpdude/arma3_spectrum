/*
	SXP_esd_fnc_initServer
	Author: Superxpdude
	Initializes server-side sections of the spectrum device system
	
	Executed only on the server at mission start during preInit
	
	Parameters:
		None
	
	Returns:
		Nothing
*/

// Only execute on the server
if (!isServer) exitWith {};

if (isNil "SXP_esd_sources") then {
	SXP_esd_sources = [];
	publicVariable "SXP_esd_sources";
};

if (isNil "SXP_esd_targets") then {
	SXP_esd_targets = [];
	publicVariable "SXP_esd_targets";
};