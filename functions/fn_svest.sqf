params ["_bomber","_bomb","_scream","_delay"];

if (_scream) then {
    if (isServer) then {
        [_bomber, ["nzf_hvt_allahuAkbar", 100]] remoteExec ["say3D", 0, false];
        // Get sound duration from config
        private _soundDuration = getNumber (configFile >> "CfgSounds" >> "nzf_hvt_allahuAkbar" >> "duration");
        if (_soundDuration == 0) then { _soundDuration = 2; }; // Fallback duration if not defined
        sleep _soundDuration;
    };
};

sleep _delay;

if (isServer) then {
    _boom = _bomb createVehicle getPosATL _bomber;
    hideObjectGlobal _boom;
    _boom setdamage 1;
};
