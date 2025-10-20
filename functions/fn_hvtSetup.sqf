params [
	["_logic", objNull, [objNull]],		// Argument 0 is module logic
	["_units", [], [[]]],				// Argument 1 is a list of affected units (affected by value selected in the 'class Units' argument))
	["_activated", true, [true]]		// True when the module was activated, false when it is deactivated (i.e., synced triggers are no longer active)
];

{
	_x params ["_hvt"];
	
	// Module specific behavior. Function can extract arguments from logic and use them.
	if (_activated) then
	{
		// Attribute values are saved in module's object space under their class names
		private _hvtName = _logic getVariable ["nzf_hvt_name", ""];
		private _surrender = _logic getVariable ["nzf_surrender", false];
		private _aiBehavior = _logic getVariable ["nzf_ai_behavior", "static"];
		private _fleeRange = parseNumber (_logic getVariable ["nzf_flee_range", "25"]);
		private _svest = _logic getVariable ["nzf_svest", "false"];
		private _svest_range = parseNumber (_logic getVariable ["nzf_svest_range", "5"]);
		private _boom = _logic getVariable ["nzf_svest_explosion", "Small"];
		private _scream = _logic getVariable ["nzf_svest_scream", "false"];
		private _delay = parseNumber (_logic getVariable ["nzf_svest_delay", "0"]);
		private _fearTimeout = parseNumber (_logic getVariable ["nzf_svest_fear_timeout", "6"]);
		private _losRequired = _logic getVariable ["nzf_svest_los", true]; // LOS option (default true)
		private _plotArmor = _logic getVariable ["nzf_plot_armor", false];

		// Debug logging
		diag_log "**********************************************NZF HVT Created**********************************************";
		diag_log format ["Name- %1, Surrender- %2, AI Behavior- %3, Flee Range- %4, S-vest- %5, Range- %6, Explosion Type- %7, LOS Required- %8, Plot Armor- %9", _hvtName, _surrender, _aiBehavior, _fleeRange, _svest, _svest_range, _boom, _losRequired, _plotArmor];
		diag_log "**********************************************NZF HVT Created**********************************************";

		// Basic HVT setup - only change name if custom name provided
		if (_hvtName != "") then {
			_hvt setVariable ["nzf_hvt_name", _hvtName];
			[_hvt, _hvtName] remoteExec ["setName", _hvt];
		};
		
		// Handle AI behavior based on selection
		switch (_aiBehavior) do {
			case "static": {
				_hvt disableAI "PATH";
				_hvt setUnitPos "UP";
				_hvt setBehaviour "CARELESS";
				_hvt setSkill ["courage", 1];
			};
			case "fleeing": {
				_hvt disableAI "PATH";
				_hvt setUnitPos "UP";
				_hvt setBehaviour "CARELESS";
				_hvt setSkill ["courage", 0];
				
				// Create proximity trigger for fleeing
				private _fleeTrigger = createTrigger ["EmptyDetector", getPos _hvt, false];
				_fleeTrigger setVariable ["flee_args", [_hvt, _fleeRange]];
				_fleeTrigger setTriggerArea [0, 0, 0, false];
				_fleeTrigger setTriggerActivation ["ANYPLAYER", "present", false];
				_fleeTrigger setTriggerStatements [
					format ["thisTrigger getVariable 'flee_args' params ['_hvt', '_range']; alive _hvt && ({(_x distance _hvt) < _range} count allPlayers > 0)"],
					"thisTrigger getVariable 'flee_args' params ['_hvt', '_range']; _hvt enableAI 'PATH'; _hvt setSkill ['courage', 1]; {_hvt reveal [_x, 4]} forEach (allPlayers select {(_x distance _hvt) < _range}); deleteVehicle thisTrigger;",
					""
				];
			};
		};
		
		// Apply ACM Plot Armor if enabled
		if (_plotArmor) then {
			_hvt setVariable ["ACM_PlotArmor", true, true];
		};
		
		// Always setup fear animation
		[_hvt] call nzf_fnc_setupHVTFear;
		
		// Setup surrender functionality
		if (_surrender) then {
			[_hvt] call nzf_fnc_setupSurrender;
		};
		
		// Setup suicide vest functionality
		if !(_svest isEqualTo "false") then {
			removeVest _hvt;
			_hvt addvest _svest;
			_hvt setVariable ["nzf_svest_explosion", _boom]; // Mark as suicide bomber
			[_hvt, _boom, _svest_range, _delay, _scream, _losRequired, _fearTimeout] call nzf_fnc_setupSuicideVest;
		};
		
		// Add killed event handler
		[_hvt] call nzf_fnc_setupHVTKilledEH;
	};
} forEach _units;
// Module function is executed by spawn command, so returned value is not necessary, but it is good practice.
true;
