/*
 * Adds an HVT event to OCAP if available
 * 
 * Arguments:
 * 0: STRING - Event tag (e.g., "HVT_SURRENDERED", "HVT_KILLED", "HVT_DETONATED")
 * 1: STRING - Event description (supports HTML formatting)
 * 2: OBJECT - Unit/position to mark on map
 * 
 * Return Value:
 * BOOL - True if OCAP event was created, false if OCAP not available
 * 
 * Example:
 * ["HVT_KILLED", "<t color='#ff0000'>Abu Hassan was killed by John</t>", _hvtUnit] call nzf_fnc_addHVTOcapEvent;
 */

params ["_eventTag", "_description", "_unit"];

if (!isNil "ocap_fnc_exportCustomEvent") then {
	[_eventTag, _description, _unit] call ocap_fnc_exportCustomEvent;
	true
} else {
	false
}

