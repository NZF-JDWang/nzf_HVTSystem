/*
 * Sets up suicide vest functionality for an HVT
 * 
 * Arguments:
 * 0: OBJECT - The HVT unit
 * 1: STRING - Explosion type classname
 * 2: NUMBER - Trigger range in meters
 * 3: NUMBER - Detonation delay in seconds
 * 4: BOOL - Whether to scream before detonation
 * 5: BOOL - Whether to require line of sight
 * 6: NUMBER - Fear timeout in seconds (0 = no timeout)
 * 
 * Return Value:
 * OBJECT - The created trigger
 * 
 * Example:
 * [_hvtUnit, "M_PG_AT", 5, 2, false, true, 6] call nzf_fnc_setupSuicideVest;
 */

params ["_hvt", "_explosionType", "_svestRange", "_detonationDelay", "_scream", "_losRequired", ["_fearTimeout", 0]];

private _zTolerance = 2.5; // Max Z difference for same floor

private _sVestTrigger = createTrigger ["EmptyDetector", getPos _hvt, false];
_sVestTrigger setVariable ["svest_args", [_hvt, _svestRange, _explosionType, _scream, _detonationDelay, _losRequired, _zTolerance, _fearTimeout]];
_sVestTrigger setTriggerArea [0, 0, 0, false];
_sVestTrigger setTriggerActivation ["ANYPLAYER", "present", false];
_sVestTrigger setTriggerStatements [
	"thisTrigger getVariable 'svest_args' params ['_hvt','_svest_range','_boom', '_scream', '_delay', '_losRequired', '_zTolerance', '_fearTimeout'];" +
	"_isFeared = _hvt getVariable ['nzf_isFeared', false];" +
	"_fearTime = _hvt getVariable ['nzf_fearTime', 0];" +
	"_timedOut = (_fearTimeout > 0 && _isFeared && ((time - _fearTime) > _fearTimeout));" +
	"_inRange = ({" +
		"(_x distance2D _hvt <= _svest_range) && " +
		"(abs ((getPosASL _x select 2) - (getPosASL _hvt select 2)) < _zTolerance) && " +
		"(!_losRequired || ((lineIntersectsSurfaces [eyePos _hvt, eyePos _x, _hvt, _x, true, 1, 'GEOM', 'NONE']) isEqualTo []))" +
	"} count allPlayers > 0);" +
	"alive _hvt && !(_hvt getVariable ['ACE_isUnconscious', false]) && (_inRange || _timedOut)",
	format ["thisTrigger getVariable 'svest_args' params ['_hvt','_svest_range','_boom','_scream', '_delay', '_losRequired', '_zTolerance', '_fearTimeout'];[_hvt, _boom, _scream, %1] spawn nzf_fnc_svest; deleteVehicle thisTrigger;", _detonationDelay],
	""
];

_sVestTrigger

