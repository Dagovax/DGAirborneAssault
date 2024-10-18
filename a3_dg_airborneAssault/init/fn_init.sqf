waitUntil {uiSleep 5; !(isNil "DGCore_Initialized")}; // Wait until DGCore was initialized

["Starting Dagovax Games Airborne Assault"] call DGCore_fnc_log;
execvm "\x\addons\a3_dg_airborneAssault\config\DG_config.sqf";
execvm "\x\addons\a3_dg_airborneAssault\init\airborneAssault.sqf";
