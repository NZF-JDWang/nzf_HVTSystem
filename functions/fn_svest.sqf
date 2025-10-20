params ["_bomber","_bomb","_scream","_delay"];

// Scream first (if enabled)
if (_scream) then {
    if (isServer) then {
        [_bomber, ["nzf_hvt_allahuAkbar", 100]] remoteExec ["say3D", 0, false];
        // Get sound duration from config
        private _soundDuration = getNumber (configFile >> "CfgSounds" >> "nzf_hvt_allahuAkbar" >> "duration");
        if (_soundDuration == 0) then { _soundDuration = 2; }; // Fallback duration if not defined
        sleep _soundDuration;
    };
};

// Stop fear animation and play detonation animation loop (holds pose)
_bomber switchMove "";  // Clear current animation
sleep 0.1;  // Brief pause to clear animation state
[_bomber, "Acts_Kore_TalkingOverRadio_loop"] remoteExec ["switchMove", 0];  // Loop version holds the pose

// Additional delay (subtract animation clear time, ensure non-negative)
private _remainingDelay = (_delay - 0.1) max 0;  // Just the 0.1s clear time
if (_remainingDelay > 0) then {
    sleep _remainingDelay;
};

// Second scream right before detonation (if enabled)
if (_scream) then {
    if (isServer) then {
        [_bomber, ["nzf_hvt_allahuAkbar", 100]] remoteExec ["say3D", 0, false];
        // Brief delay for dramatic effect, but don't wait for full sound
        sleep 0.3;
    };
};

if (isServer) then {
    // Add diary entry with marker and OCAP event
    private _msg = format ["%1 detonated suicide vest", name _bomber];
    ["HVT Detonated", _msg, getPosASL _bomber, "ColorOrange"] remoteExec ["nzf_fnc_addHVTDiaryEntry", 2];
    ["HVT_DETONATED", format ["<t color='#ff9900'>%1</t>", _msg], _bomber] call nzf_fnc_addHVTOcapEvent;
    
    // Kill HVT instantly (prevent bleedout/unconscious state)
    _bomber setDamage 1;
    
    // Create explosion
    _boom = _bomb createVehicle getPosATL _bomber;
    hideObjectGlobal _boom;
    _boom setdamage 1;
};
