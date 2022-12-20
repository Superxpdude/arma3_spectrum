/*
	SXP_esd_transmitEachFrame
	Author: Superxpdude
	
	EachFrame mission event handler function to handle spectrum device transmissions.
	Removes itself when conditions are no longer met for transmitting.
	
	Parameters:
		None
	
	Returns:
		Nothing
*/

params ["_args", "_handle"];

private _exitFunc = {
	[_handle] call CBA_fnc_removePerFrameHandler;
	missionNamespace setVariable ["#EM_Progress", 0];
	localNamespace setVariable ["sxp_esd_transmit_target", nil];
	localNamespace setVariable ["sxp_esd_transmit_active", false];
	localNamespace setVariable ["sxp_esd_transmit_startTime", nil];
};

// Make sure that we're still transmitting
if !(missionNamespace getVariable ["#EM_Transmit", false]) exitWith _exitFunc;

// Make sure that the player is alive
if !(alive player) exitWith _exitFunc;

// Make sure the current weapon is a spectrum device
// If not, remove the event handler
if !("hgun_esd_" in (currentWeapon player)) exitWith _exitFunc;

// Make sure that the player does not have a dialog open (such as the map, or an inventory)
if (!isNull (findDisplay 602) || !isNull (findDisplay 24) || !isNull (findDisplay 160) || visibleMap) exitWith _exitFunc;

// Check if we have a "locked" target
if (isNil {localNamespace getVariable "sxp_esd_transmit_target"}) then {
	
	private ["_newTarget"];
	private _newTargetStr = 0;
	
	// No target, scan for a valid target
	{
		_x params ["_obj", "_freq", "_str", "_activateFunc", "_deactivateFunc", "_delay"];
		
		private _dist = player distance _obj;
		
		// Only continue if the player is within transmission distance
		if (_dist <= _str) then {		
			// Calculate our final signal strength
			private _effectiveStr = [_obj, _str, true] call SXP_esd_fnc_calculateSignalStrength;
			
			// Check to see if this is our new "best" signal
			if (isNil "_newTarget") then {
				// No existing target. Set new target.
				_newTarget = _x;
				_newTargetStr = _effectiveStr;
			} else {
				// Only set the new target if our signal strength is higher
				if (_effectiveStr > _newTargetStr) then {
					_newTarget = _x;
					_newTargetStr = _effectiveStr;
				};
			};
		};
		
	} forEach (SXP_esd_targets select {
		(_x#1 >= missionNamespace getVariable ["#EM_SelMin", 0]) and 
		(_x#1 <= missionNamespace getVariable ["#EM_SelMax", 0])
	});
	
	// If we have a new target, we need to set some values
	if (!isNil "_newTarget") then {
		localNamespace setVariable ["sxp_esd_transmit_target", _newTarget];
		localNamespace setVariable ["sxp_esd_transmit_startTime", cba_missionTime];
	};
};

// Run our next calculation only if we have a valid target
if (!isNil {localNamespace getVariable "sxp_esd_transmit_target"}) then {
	(localNamespace getVariable "sxp_esd_transmit_target") params ["_obj", "_freq", "_str", "_activateFunc", "_deactivateFunc", "_delay"];

	// Make sure that our target is still in the targets array
	if (
		((localNamespace getVariable "sxp_esd_transmit_target") in SXP_esd_targets) and
		{_freq >= missionNamespace getVariable ["#EM_SelMin", 0]} and
		{_freq <= missionNamespace getVariable ["#EM_SelMax", 0]} and
		{([_obj, _str, true] call SXP_esd_fnc_calculateSignalStrength) > 0}
	) then {
		// Check if our transmit time is greater than the required transmit time
		private _transmitTime = cba_missionTime - (localNamespace getVariable ["sxp_esd_transmit_startTime", 0]);
		
		// Set the transmit progress
		if (_delay > 0) then {
			missionNamespace setVariable ["#EM_Progress", (_transmitTime / _delay) min 1];
		} else {
			missionNamespace setVariable ["#EM_Progress", 1];
		};
		
		// If our transmission is done, 
		if ((_transmitTime >= _delay) and {!(localNamespace getVariable ["sxp_esd_transmit_active", true])}) then {
			// Set our "active" flag on the transmission
			localNamespace setVariable ["sxp_esd_transmit_active", true];
			// Run the activate function where the object is local
			// Don't re-run the activate function if someone is already transmitting
			// to the object, and the object has a deactivate function
			if !(_obj getVariable ["sxp_esd_transmit_serverActive", false]) then {
				[_obj,_activateFunc] remoteExec ["BIS_fnc_spawn", _obj];
			};
		};
		
		// If the object has a deactivate function, we need to check
		// if we need to start a server-check for transmission deactivated
		// We also need to check if we should update a "last transmitted time"
		// value for disconnect-handling
		/*
		if (!isNil "_deactivateFunc") then {
			// CHANGE THIS TO ONLY RUN ONCE EVERY 5 SECONDS
			if (cba_missionTime > ((_obj getVariable ["sxp_esd_transmit_lastTransmitTime", -5]) + 5)) then {
				_obj setVariable ["sxp_esd_transmit_lastTransmitTime", cba_missionTime, true];
			};
		};
		*/
	} else {
		// Target no longer valid
		localNamespace setVariable ["sxp_esd_transmit_target", nil];
		localNamespace setVariable ["sxp_esd_transmit_active", false];
		missionNamespace setVariable ["#EM_Progress", 0];
	};
};
