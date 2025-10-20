/*
 * Sets up surrender functionality for an HVT
 * Triggers surrender when player gets close (<3m) OR after 4 seconds of fear
 * Note: Fear animation is handled by fn_setupHVTFear which should be called separately
 * Note: Will NOT trigger if HVT has a suicide vest (checked via nzf_svest_explosion variable)
 * 
 * Arguments:
 * 0: OBJECT - The HVT unit
 * 
 * Return Value:
 * OBJECT - The surrender trigger
 * 
 * Example:
 * [_hvtUnit] call nzf_fnc_setupSurrender;
 */

params ["_hvt"];

// Full surrender trigger (3m range OR 4 seconds after fear)
private _surrenderTrigger = createTrigger ["EmptyDetector", [0,0,0], false];
_surrenderTrigger setVariable ["mission_args", [_hvt]];
_surrenderTrigger setTriggerArea [0, 0, 0, false];
_surrenderTrigger setTriggerActivation ["NONE", "present", false];
_surrenderTrigger setTriggerStatements [
	"thisTrigger getVariable 'mission_args' params ['_hvt']; " +
	"_isFeared = _hvt getVariable ['nzf_isFeared', false]; " +
	"_fearTime = _hvt getVariable ['nzf_fearTime', 0]; " +
	"_hasSurrendered = _hvt getVariable ['nzf_hasSurrendered', false]; " +
	"_hasSuicideVest = !isNil {_hvt getVariable 'nzf_svest_explosion'}; " +
	"_closeEnough = ((toUpperANSI cameraView == 'GUNNER') && (cursorObject == _hvt) && (player distance _hvt < 3)); " +
	"_timedOut = (_isFeared && ((time - _fearTime) > 4)); " +
	"!(isNull _hvt) && (alive _hvt) && !_hasSurrendered && !_hasSuicideVest && (_closeEnough || _timedOut)",
	"thisTrigger getVariable 'mission_args' params ['_hvt']; " +
	"_hvt setVariable ['nzf_hasSurrendered', true, true]; " +
	"['ACE_captives_setSurrendered', [_hvt, true], _hvt] call CBA_fnc_targetEvent; " +
	"_hvt setVariable ['nzf_surrenderedTo', name player, true]; " +
	"_msg = format ['%1 has surrendered to %2', name _hvt, name player]; " +
	"['HVT Captured', _msg, getPosASL _hvt, 'ColorGreen'] remoteExec ['nzf_fnc_addHVTDiaryEntry', 2]; " +
	"['HVT_SURRENDERED', format ['<t color=''#00ff00''>%1</t>', _msg], _hvt] call nzf_fnc_addHVTOcapEvent; " +
	"deleteVehicle thisTrigger;",
	""
];

_surrenderTrigger

