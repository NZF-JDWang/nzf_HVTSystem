[
    "NZF Systems",
    "Create HVT",
    {
        if (!isServer) exitWith {
            ["HVT Creation", "Must be executed on server"] call zen_common_fnc_showMessage;
        };
        
        params [["_position", [0,0,0], [[]], 3], ["_attachedObject", objNull, [objNull]]];
        
        if (isNull _attachedObject) exitWith {
            ["HVT Creation", "Must be placed on a unit"] call zen_common_fnc_showMessage;
        };
        
        if !(_attachedObject isKindOf "CAManBase") exitWith {
            ["HVT Creation", "Must be placed on a person"] call zen_common_fnc_showMessage;
        };
        
        // Build dialog options dynamically
        private _dialogOptions = [
            // === Basic Info ===
            ["EDIT", ["HVT Name", "Custom name for the HVT unit (leave empty to keep original name)"], ""],
            
            // === AI Behavior ===
            ["CHECKBOX", ["Will Surrender", "HVT will surrender when confronted"], false],
            ["COMBO", ["AI Behavior", "How the HVT should behave"], [
                ["static", "fleeing"],
                ["Static (No movement)", "Fleeing (Runs when players close)"],
                0
            ]],
            ["EDIT", ["Flee Detection Range (m)", "Range at which HVT starts fleeing (if fleeing enabled)"], "25"]
        ];
        
        // Add ACM Plot Armor option if ACM is loaded
        if (isClass (configFile >> "CfgPatches" >> "ACM_main")) then {
            _dialogOptions pushBack ["CHECKBOX", ["Plot Armor (ACM)", "HVT will have plot armor (cannot be killed)"], false];
        };
        
        // === Suicide Vest Options ===
        _dialogOptions append [
            ["COMBO", ["Explosion Size", "Size of explosion for suicide vest"], [
                ["M_PG_AT", "IEDUrbanSmall_Remote_Ammo", "R_60mm_HE"],
                ["Small", "Medium", "Large"],
                0
            ]],
            ["EDIT", ["Detonation Range (m)", "Range (m) players need to be to set off vest"], "5"],
            ["EDIT", ["Detonation Delay (s)", "Seconds between trigger and explosion"], "2"],
            ["EDIT", ["Fear Timeout (s)", "Seconds after fear before auto-detonation (0 = disabled)"], "6"],
            ["CHECKBOX", ["Allahu Akbar", "HVT will scream before detonating"], false],
            ["CHECKBOX", ["Require Line of Sight", "Vest will only trigger if HVT has line of sight to a player"], true]
        ];
        
        [
            "Configure HVT", 
            _dialogOptions,
            {
                params ["_values", "_attachedObject"];
                
                // Extract parameters based on dialog structure
                private _hvtName = _values select 0;           // HVT Name
                private _surrender = _values select 1;         // Will Surrender
                private _aiBehavior = _values select 2;        // AI Behavior
                private _fleeRange = _values select 3;         // Flee Detection Range
                
                // Plot Armor (conditional - only present if ACM is loaded)
                private _plotArmor = false;
                private _acmOffset = 0;
                if (isClass (configFile >> "CfgPatches" >> "ACM_main")) then {
                    _plotArmor = _values select 4;
                    _acmOffset = 1;  // Shift following indices by 1
                };
                
                // Suicide Vest parameters (indices shift if ACM is present)
                private _explosionType = _values select (4 + _acmOffset);    // Explosion Size
                private _svestRange = _values select (5 + _acmOffset);        // Detonation Range
                private _detonationDelay = _values select (6 + _acmOffset);   // Detonation Delay
                private _fearTimeout = _values select (7 + _acmOffset);       // Fear Timeout
                private _scream = _values select (8 + _acmOffset);            // Allahu Akbar
                private _losRequired = _values select (9 + _acmOffset);       // Require Line of Sight
                
                // Handle AI behavior based on selection
                switch (_aiBehavior) do {
                    case "static": {
                        _attachedObject disableAI "PATH";
                        _attachedObject setUnitPos "UP";
                        _attachedObject setBehaviour "CARELESS";
                        _attachedObject setSkill ["courage", 1];
                    };
                    case "fleeing": {
                        _attachedObject disableAI "PATH";
                        _attachedObject setUnitPos "UP";
                        _attachedObject setBehaviour "CARELESS";
                        _attachedObject setSkill ["courage", 0];
                        
                        // Create proximity trigger for fleeing
                        private _fleeTrigger = createTrigger ["EmptyDetector", getPos _attachedObject, false];
                        _fleeTrigger setVariable ["flee_args", [_attachedObject, parseNumber _fleeRange]];
                        _fleeTrigger setTriggerArea [0, 0, 0, false];
                        _fleeTrigger setTriggerActivation ["ANYPLAYER", "present", false];
                        _fleeTrigger setTriggerStatements [
                            format ["thisTrigger getVariable 'flee_args' params ['_hvt', '_range']; alive _hvt && ({(_x distance _hvt) < _range} count allPlayers > 0)"],
                            "thisTrigger getVariable 'flee_args' params ['_hvt', '_range']; _hvt enableAI 'PATH'; _hvt setSkill ['courage', 1]; {_hvt reveal [_x, 4]} forEach (allPlayers select {(_x distance _hvt) < _range}); deleteVehicle thisTrigger;",
                            ""
                        ];
                    };
                };
                // Change unit name if custom name provided
                if (_hvtName != "") then {
                    _attachedObject setVariable ["nzf_hvt_name", _hvtName];
                    [_attachedObject, _hvtName] remoteExec ["setName", _attachedObject];
                };
                
                _attachedObject setVariable ["nzf_svest_los", _losRequired];
                _attachedObject setVariable ["nzf_surrender", _surrender];
                _attachedObject setVariable ["nzf_svest", _explosionType];
                _attachedObject setVariable ["nzf_svest_range", _svestRange];
                _attachedObject setVariable ["nzf_svest_explosion", _explosionType];
                _attachedObject setVariable ["nzf_svest_scream", _scream];
                _attachedObject setVariable ["nzf_svest_delay", _detonationDelay];
                
                // Apply ACM Plot Armor if enabled
                if (_plotArmor) then {
                    _attachedObject setVariable ["ACM_PlotArmor", true, true];
                };
                
                // Always setup fear animation
                [_attachedObject] call nzf_fnc_setupHVTFear;
                
                // Setup surrender functionality
                if (_surrender) then {
                    [_attachedObject] call nzf_fnc_setupSurrender;
                };
                
                // Setup suicide vest functionality
                if (_explosionType != "") then {
                    [_attachedObject, _explosionType, parseNumber _svestRange, parseNumber _detonationDelay, _scream, _losRequired, parseNumber _fearTimeout] call nzf_fnc_setupSuicideVest;
                };
                
                // Add killed event handler
                [_attachedObject] call nzf_fnc_setupHVTKilledEH;
                
            }, {}, _attachedObject] call zen_dialog_fnc_create;
    }
] call zen_custom_modules_fnc_register; 