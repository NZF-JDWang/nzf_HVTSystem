/*
 * Sets up fear animation for an HVT when weapon is aimed at them
 * HVT will show fear/shock animation when player aims at them from 3-15m
 * 
 * Arguments:
 * 0: OBJECT - The HVT unit
 * 
 * Return Value:
 * OBJECT - The fear trigger
 * 
 * Example:
 * [_hvtUnit] call nzf_fnc_setupHVTFear;
 */

params ["_hvt"];

// Fear animation trigger (3-15m range)
private _fearTrigger = createTrigger ["EmptyDetector", [0,0,0], false];
_fearTrigger setVariable ["fear_args", [_hvt]];
_fearTrigger setTriggerArea [0, 0, 0, false];
_fearTrigger setTriggerActivation ["NONE", "present", false];
_fearTrigger setTriggerStatements [
	"thisTrigger getVariable 'fear_args' params ['_hvt']; ((toUpperANSI cameraView == 'GUNNER') && (cursorObject == _hvt) && (player distance _hvt < 15) && (player distance _hvt >= 3)) AND !(isNull _hvt) && (alive _hvt) && !(_hvt getVariable ['nzf_isFeared', false])",
	"thisTrigger getVariable 'fear_args' params ['_hvt']; " +
	"_hvt setVariable ['nzf_isFeared', true, true]; " +
	"_hvt setVariable ['nzf_fearTime', time, true]; " +
	"[_hvt, 'Acts_ShockedUnarmed_2_Loop'] remoteExec ['switchMove', 0];",
	""
];

_fearTrigger

