/*
 * Adds killed event handler to HVT that announces death
 * 
 * Arguments:
 * 0: OBJECT - The HVT unit
 * 
 * Return Value:
 * NUMBER - Event handler ID
 * 
 * Example:
 * [_hvtUnit] call nzf_fnc_setupHVTKilledEH;
 */

params ["_hvt"];

_hvt addMPEventHandler ["MPKilled", {
	params ["_unit", "_killer", "_instigator", "_useEffects"];
	
	// Check if HVT killed themselves (suicide vest detonation)
	private _isSuicide = (_killer == _unit) || (isNull _killer);
	
	if (_isSuicide) then {
		// Suicide vest already logged the detonation, skip this event
		// to avoid duplicate "martyred themselves" messages
	} else {
		// Normal death by other means
		[format ["%1 has been killed by %2", name _unit, name _killer]] remoteExec ["hintsilent", [0,-2] select isDedicated];
		
		// Add diary entry with marker and OCAP event
		private _msg = format ["%1 was killed by %2", name _unit, name _killer];
		["HVT Killed", _msg, getPosASL _unit, "ColorRed"] remoteExec ["nzf_fnc_addHVTDiaryEntry", 2];
		["HVT_KILLED", format ["<t color='#ff0000'>%1</t>", _msg], _unit] call nzf_fnc_addHVTOcapEvent;
	};
	
	detach _unit;
	removeAllActions _unit;
	if (vehicle _unit isEqualTo _unit) then { _unit switchaction "die"; };
}]

