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
        
        [
            "Configure HVT", 
            [
                ["CHECKBOX", ["Will Surrender", "HVT will surrender when confronted"], false],
                ["COMBO", ["Explosion Size", "Size of explosion for suicide vest"], [
                    ["M_PG_AT", "IEDUrbanSmall_Remote_Ammo", "R_60mm_HE"],
                    ["Small", "Medium", "Large"],
                    0
                ]],
                ["EDIT", ["S-Vest Range", "Range (m) players need to be to set off vest"], "5"],
                ["EDIT", ["Detonation Delay", "Seconds between trigger and explosion"], "2"],
                ["CHECKBOX", ["Allahu Akbar", "HVT will scream before detonating"], false],
                ["CHECKBOX", ["Require Line of Sight", "If checked, vest will only trigger if HVT has line of sight to a player."], false]
            ],
            {
                params ["_values", "_attachedObject"];
                _values params [
                    "_surrender",
                    "_explosionType",
                    "_svestRange",
                    "_detonationDelay",
                    "_scream",
                    "_losRequired"
                ];
                
                _attachedObject disableAI "ALL";
                _attachedObject setVariable ["nzf_svest_los", _losRequired];
                _attachedObject setVariable ["nzf_surrender", _surrender];
                _attachedObject setVariable ["nzf_svest", _explosionType];
                _attachedObject setVariable ["nzf_svest_range", _svestRange];
                _attachedObject setVariable ["nzf_svest_explosion", _explosionType];
                _attachedObject setVariable ["nzf_svest_scream", _scream];
                _attachedObject setVariable ["nzf_svest_delay", _detonationDelay];
                
                // Handle surrender functionality
                if (_surrender) then {
                    private _surrenderTrigger = createTrigger ["EmptyDetector", [0,0,0], false];
                    _surrenderTrigger setVariable ["mission_args", [_attachedObject]];
                    _surrenderTrigger setTriggerArea [0, 0, 0, false];
                    _surrenderTrigger setTriggerActivation ["NONE", "present", false];
                    _surrenderTrigger setTriggerStatements [
                        "thisTrigger getVariable 'mission_args' params ['_hvt'];((toUpperANSI cameraView == 'GUNNER') && (cursorObject == _hvt) && (player distance _hvt < 7)) AND !(isNull _hvt) && (alive _hvt)",
                        "thisTrigger getVariable 'mission_args' params ['_hvt']; ['ACE_captives_setSurrendered', [_hvt, true], _hvt] call CBA_fnc_targetEvent;",
                        ""
                    ];
                };
                
                // Handle suicide vest functionality
                if (_explosionType != "") then {
                    private _zTolerance = 2.5;
                    private _sVestTrigger = createTrigger ["EmptyDetector", getPos _attachedObject, false];
                    _sVestTrigger setVariable ["svest_args", [_attachedObject, parseNumber _svestRange, _explosionType, _scream, parseNumber _detonationDelay, _losRequired, _zTolerance]];
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
                        format ["thisTrigger getVariable 'svest_args' params ['_hvt','_svest_range','_boom','_scream', '_delay', '_losRequired', '_zTolerance'];[_hvt, _boom, _scream, %1] spawn nzf_fnc_svest", parseNumber _detonationDelay],
                        ""
                    ];
                };
                
                // Add killed EH
                _attachedObject addMPEventHandler ["MPKilled", {
                    params ["_unit", "_killer", "_instigator", "_useEffects"];
                    [format ["%1 has been killed by %2", name _unit, name _killer]] remoteExec ["hintsilent", [0,-2] select isDedicated];
                    detach _unit;
                    removeAllActions _unit;
                    if (vehicle _unit isEqualTo _unit) then { _unit switchaction "die"; };
                }];
                
            }, {}, _attachedObject] call zen_dialog_fnc_create;
    }
] call zen_custom_modules_fnc_register; 