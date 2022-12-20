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

/*
	Frequency ranges:
	- Experimental Antenna (390-500Mhz)
	- Jammer Antenna (433Mhz)
	- Military Antenna (78-89Mhz)
*/

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
	sxp_esd_ehHandler = [SXP_esd_fnc_eachFrame, 0.1] call CBA_fnc_addPerFrameHandler;
};

missionNamespace setVariable ["SXP_esd_transmitStartTime", -1];

["XP Spectrum Device","sxp_esd_key_transmit", "Transmit", {
	if (!isNull (findDisplay 602) || !isNull (findDisplay 24) || !isNull (findDisplay 160) || visibleMap) exitWith {};
	missionNamespace setVariable ["#EM_Transmit", true];
	private _transmitHandle = [SXP_esd_fnc_transmitEachFrame, 0.1] call CBA_fnc_addPerFrameHandler;
}, {
	missionNamespace setVariable ["#EM_Transmit", false];
}, [0xF0, [false, false, false]]] call CBA_fnc_addKeybind;

// Set local parameters for transmit handling
localNamespace setVariable ["sxp_esd_transmit_target", nil];
localNamespace setVariable ["sxp_esd_transmit_active", false];
localNamespace setVariable ["sxp_esd_transmit_startTime", nil];