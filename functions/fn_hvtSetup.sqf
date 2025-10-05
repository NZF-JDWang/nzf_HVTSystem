params [
	["_logic", objNull, [objNull]],		// Argument 0 is module logic
	["_units", [], [[]]],				// Argument 1 is a list of affected units (affected by value selected in the 'class Units' argument))
	["_activated", true, [true]]		// True when the module was activated, false when it is deactivated (i.e., synced triggers are no longer active)
];
{
	_x params ["_hvt"];
	
	_hvt addMPEventHandler ["MPKilled", {
	params ["_unit", "_killer", "_instigator", "_useEffects"];
	[format ["%1 has been killed by %2",name _unit, name _killer]] remoteExec ["hintsilent",[0,-2] select isDedicated];
	detach _unit;
	removeAllActions _unit;
	if (vehicle _unit isEqualTo _unit) then { _unit switchaction "die";};
	}]; 

	
	// Module specific behavior. Function can extract arguments from logic and use them.
	if (_activated) then
	{
		// Attribute values are saved in module's object space under their class names
		private _surrender = _logic getVariable ["nzf_surrender", false]; // (as per the previous example, but you can define your own)
		private _svest = _logic getVariable ["nzf_svest", "false"];
		private _svest_range = parseNumber (_logic getVariable ["nzf_svest_range", "5"]);
		private _boom = _logic getVariable ["nzf_svest_explosion", "Small"];
		private _scream = _logic getVariable ["nzf_svest_scream", "false"];
		private _delay = parseNumber (_logic getVariable ["nzf_svest_delay", "0"]);
		private _losRequired = _logic getVariable ["nzf_svest_los", false]; // New LOS option
		private _zTolerance = 2.5; // Max Z difference for same floor

			 
		diag_log "**********************************************NZF HVT Created**********************************************";
		diag_log format ["Surrender- %1, S-vest- %2, Range- %3, Explosion Type- %4, LOS Required- %5", _surrender,_svest,_svest_range,_boom, _losRequired];
		diag_log "**********************************************NZF HVT Created**********************************************";

		_hvt disableAI "ALL";


		if (_surrender) then 
			{
				_surrenderTrigger = createTrigger ["EmptyDetector", [0,0,0], false];
				_surrenderTrigger setvariable ["mission_args", [_hvt]];
				_surrenderTrigger setTriggerArea [0, 0, 0, false];
				_surrenderTrigger setTriggerActivation ["NONE", "present", false];
				_surrenderTrigger setTriggerStatements ["thisTrigger getVariable 'mission_args' params ['_hvt'];((toUpperANSI cameraView == 'GUNNER') && (cursorObject == _hvt) && (player distance _hvt < 7)) AND !(isNull _hvt) && (alive _hvt)","thisTrigger getVariable 'mission_args' params ['_hvt']; ['ACE_captives_setSurrendered', [_hvt, true], _hvt] call CBA_fnc_targetEvent;", ""];
			};

		if !(_svest isEqualTo "false") then 
			{
				removeVest _hvt;
				_hvt addvest _svest;

				_sVestTrigger = createTrigger ["EmptyDetector", getPos _hvt, false];
				_sVestTrigger setVariable ["svest_args", [_hvt, _svest_range, _boom, _scream, _delay, _losRequired, _zTolerance]]; // Added _losRequired and _zTolerance
				_sVestTrigger setTriggerArea [0, 0, 0, false];
				_sVestTrigger setTriggerActivation ["ANYPLAYER", "present", false];
				_sVestTrigger setTriggerStatements [
					"thisTrigger getVariable 'svest_args' params ['_hvt','_svest_range','_boom', '_scream', '_delay', '_losRequired', '_zTolerance'];" +
					"alive _hvt && !(_hvt getVariable ['ACE_isUnconscious', false]) && " +
					"({" +
						"(_x distance2D _hvt <= _svest_range) && " +
						"(abs ((getPosASL _x select 2) - (getPosASL _hvt select 2)) < _zTolerance) && " +
						"(!_losRequired || ((lineIntersectsSurfaces [eyePos _hvt, eyePos _x, _hvt, _x, true, 1, 'GEOM', 'NONE']) isEqualTo []))" +
					"} count allPlayers > 0)",
					"thisTrigger getVariable 'svest_args' params ['_hvt','_svest_range','_boom','_scream', '_delay', '_losRequired', '_zTolerance'];[_hvt, _boom, _scream, _delay] spawn nzf_fnc_svest",
					""
				];
			};
	};
} forEach  _units;
// Module function is executed by spawn command, so returned value is not necessary, but it is good practice.
true;
