if (!isServer) exitWith {};

if (isNil "DGAA_AINVGSpawnChance") then
{
	["%1 Waiting until configuration completes...", "DG Airborne Assault"] call DGCore_fnc_log;
	waitUntil{uiSleep 10; !(isNil "DGAA_AINVGSpawnChance")}
};

["Initializing Dagovax Games Airborne Assault", DGAA_MessageName] call DGCore_fnc_log;

/****************************************************************************************************/
/********************************  DO NOT EDIT THE CODE BELOW!!  ************************************/
/****************************************************************************************************/
if(DGAA_DebugMode) then 
{
	["Running in Debug mode!", DGAA_MessageName, "debug"] call DGCore_fnc_log;
	DGAA_MinAmountPlayers = 1;
	DGAA_MaxAssaultCount = 1;
	DGAA_TimeToFirstMission = [30, 120];
	DGAA_TimeBetweenMissions = [60, 240];
	DGAA_PlaneArrivalTime = 30;
	DGAA_PlaneSpawnDistance = 2000;
	DGAA_PlaneCount = [1,1];
	DGCore_MissionTimeout = 120;
};

if (DGAA_MinAmountPlayers > 0) then
{
	[format["Waiting for %1 players to be online.", DGAA_MinAmountPlayers], DGAA_MessageName, "debug"] call DGCore_fnc_log;
	waitUntil { uiSleep 10; count( playableUnits ) > ( DGAA_MinAmountPlayers - 1 ) };
};
[format["%1 players reached. Initializing main loop of airborne assaults", DGAA_MinAmountPlayers], DGAA_MessageName, "debug"] call DGCore_fnc_log;

DGAA_AssaultQueue = []; // Current mission queue

// Sleep until first spawn
_initialWaitTime =  (DGAA_TimeToFirstMission select 0) + random((DGAA_TimeToFirstMission select 1) - (DGAA_TimeToFirstMission select 0));
[format["Waiting %1 seconds before first airborne spawn", _initialWaitTime], DGAA_MessageName, "debug"] call DGCore_fnc_log;
uiSleep _initialWaitTime; // Wait until the random counter started

_reInitialize = true; // Only initialize this when _reInitialize is true
while {true} do // Main Loop
{
	if(_reInitialize) then
	{
		private ["_missionPos", "_fndPosition"];
		_reInitialize = false;
		_fndPosition = false;
		
		if(DGAA_DebugMode) then
		{
			private _allPlayers = call BIS_fnc_listPlayers;
			private _playerCount = count(_allPlayers);
			if(_playerCount > 0) then
			{
				private _player = _allPlayers select 0;
				_player allowDamage false;
				private _playerPos = getPos _player;
				_missionPos = [_playerPos, 100, 2500] call DGCore_fnc_findPosition; // Random pos on the map
				if !(_missionPos isEqualTo [-1,-1,-1]) then
				{
					_fndPosition = true;
				};
			};
		};
		
		if(!_fndPosition) then
		{
			_missionPos = [] call DGCore_fnc_findPosition; // Random pos on the map
		};
		
		if(isNil "_missionPos" || _missionPos isEqualTo [-1,-1,-1]) exitWith
		{
			[format["Could not find a valid mission position! Skipping this iteration..."], DGAA_MessageName, "warning"] call DGCore_fnc_log;
		};
		
		private _camp = [_missionPos] call DGCore_fnc_spawnRandomCamp;
		if(isNil "_camp" || typeName _camp != "ARRAY") exitWith
		{
			[format["Failed to spawn a mission camp/base! Skipping this iteration..."], DGAA_MessageName, "warning"] call DGCore_fnc_log;
		};
		
		private _campName = _camp select 0;
		["Airborne Assault", format["A %1 is being targeted by an airborne assault! Clear the objective from enemies.", _campName], "info"] call DGCore_fnc_sendNotification;
		private _missionLabel = "Airborne Assault";
		private _markers = ["airborneAssault", _missionPos, _missionLabel] call DGCore_fnc_createMarkers;
		private _dummy = [_missionPos] call DGCore_fnc_getDummy;
		
		DGAA_AssaultQueue pushBack _dummy;
		[_dummy, _missionPos, _camp, _campName, _missionLabel, _markers] spawn
		{
			private ["_allGroups", "_planes"];
			params ["_dummy", "_missionPos", "_camp", "_campName", "_missionLabel", "_markers"];
			
			private _missionTimer = 0;
			private _missionTimedOut = true; // Default to true
			while {_missionTimer < (DGCore_MissionTimeout)} do 
			{
				private _nearbyPlayers = allPlayers select {(_x distance _missionPos) < DGCore_PlayerSearchRadius};
				if ((count _nearbyPlayers) > 0) exitWith {
					_missionTimedOut = false;
				};
				_missionTimer = _missionTimer + 2;
				uiSleep 2;
			};

			if(_missionTimedOut) exitWith
			{
				[_markers] call DGCore_fnc_deleteMarkers;
				
				DGAA_AssaultQueue deleteAt (DGAA_AssaultQueue find _dummy);
				deleteVehicle _dummy;
				["Airborne Assault", format["The paratroopers destroyed the %1 before any player could help! Mission failed.", _campName], "error"] call DGCore_fnc_sendNotification;
				{
					deleteVehicle _x; // delete map objects
				} foreach (_camp select 1);
			};

			private _objective = [selectRandom (DGAA_PlaneTypes), _missionPos, (DGAA_PlaneCount call BIS_fnc_randomInt), DGAA_PlaneSpawnDistance, DGAA_CrateChance, DGAA_ForceCrate] call DGCore_fnc_spawnAirborneAssault;			
			private _sirensSound = false;
			
			["Airborne Assault", format["The assault on the %1 started! Enemy planes incoming!", _campName], "info"] call DGCore_fnc_sendNotification;
			
			// Wait until we have a main group with units...
			while {true} do
			{
				_allGroups = _objective getVariable ["DGCore_AIGroups", []];
				_planes = _objective getVariable ["DGCore_AirborneAssaultPlanes", []];
				if(_planes isEqualTo []) exitWith{}; // Not any plane spawned
				
				{
					if(isNull _x || !alive _x) then
					{
						_planes deleteAt (_planes find _x);
						_objective setVariable ["DGCore_AirborneAssaultPlanes", _planes];
					} else
					{
						if(DGAA_EnableAlarmSound && !_sirensSound) then
						{
							private _distance = _x distance2D _missionPos;
							if(_distance <= DGAA_AlarmSoundDistance) then
							{
								_sirensSound = true;
								
								// Add a bit of alarm sounds
								{
									private _soundArray = _x;
									private _cfgSound = _soundArray select 0;
									private _sndLength = _soundArray select 1;
									private _pitch = _soundArray select 2;
									private _objects = _soundArray select 3;
									
									if (!(isNil "_objects") && (count _objects > 0)) then
									{
										[format["Adding sound '%1' with length = %2 and pitch = %3 to %4 classes! They will loop this sound for %6 seconds in a range of %6m!", _cfgSound, _sndLength, _pitch, (count _objects), DGAA_AlarmSoundTime, DGAA_AlarmSoundRange], DGAA_MessageName, "debug"] call DGCore_fnc_log;
										{
											private _nearbyObjects = nearestObjects [_missionPos, [_x], 200];
											{
												_soundLoop = [_x, _cfgSound, _sndLength, _pitch];
												_soundLoop spawn {
													params ["_object", "_cfgSound", "_sndLength", "_pitch"];
													uiSleep (random 5);
													private _timer = 0;
													while {_timer < DGAA_AlarmSoundTime} do
													{
														[_object,[_cfgSound, DGAA_AlarmSoundRange, _pitch]] remoteExec ["say3d",0,true];
														uiSleep _sndLength;
														_timer = _timer + _sndLength;
													};
												};
											} forEach _nearbyObjects;
											[format["Playing this sound on %1 objects with class '%2'!", count _nearbyObjects, _x], DGAA_MessageName, "debug"] call DGCore_fnc_log;
										} forEach _objects;
									};
								} forEach DGAA_AlarmSounds;
							};							
						};
					};
				} forEach _planes;
				
				if(_planes isEqualTo []) exitWith{}; // Not any plane spawned
				
				if !(_allGroups isEqualTo []) exitWith{}; // We have a main group spawn
				
				uiSleep 2;
			};
			
			uiSleep 5;
			
			private _firstMarker = _markers select 0; // ellipse
			private _textMarker = _markers select 1; // second marker contains text
			private _thirdMarker = _markers select 2; // third marker only contains black dot.
			private _finished = false;
			private _totalCount = 0;
			
			// Main mission active checker
			while {true} do
			{
				if(_allGroups isEqualTo []) exitWith{};
				_totalCount = 0;
				{
					_grpCount = [_x] call DGCore_fnc_countAI;
					_totalCount = _totalCount + _grpCount;
				} forEach _allGroups;
				
				if(DGAA_CountAliveAI) then
				{
					if !(_textMarker isEqualTo "") then
					{
						_textMarker setMarkerText format["%1 (%2 Units remaining)", _missionLabel, _totalCount];
					};
				};
				uiSleep 4;
				
				if(_totalCount < 1) exitWith
				{
					_finished = true;
					[format["Mission (%1) set to complete => No more AI remaining!", _missionLabel], DGAA_MessageName, "debug"] call DGCore_fnc_log;
				};
				
				if (_finished) exitWith {};
			};
			
			[_markers] call DGCore_fnc_deleteMarkers;
			
			DGAA_AssaultQueue deleteAt (DGAA_AssaultQueue find _dummy);
			
			if(_finished) then
			{
				["UAV_03"] remoteExec ["playSound",0];
				["Airborne Assault", format["Convicts successfully cleared the %1 from enemies!", _campName], "success"] call DGCore_fnc_sendNotification;
				
				[format["Mission (%1) completed! Unlocking loot now...", _missionLabel], DGAA_MessageName, "debug"] call DGCore_fnc_log;
			
				
				[_missionPos, _missionLabel] call DGCore_fnc_createMarkerComplete;
				
				private _allCrates = _objective getVariable ["DGCore_Crates", []];
				if ((count _allCrates) > 0) then
				{
					{
						[format["Crate %1 @ %2 is now unlocked!", _x, getPos _x], DGAA_MessageName, "debug"] call DGCore_fnc_log;
						_x setVariable ["ExileIsLocked", 0,true]; // Unlock crate
					} forEach _allCrates;
				};
			} else
			{
				["Airborne Assault", format["The airborne assault on the %1 failed!", _campName], "error"] call DGCore_fnc_sendNotification;
			};
			deleteVehicle _objective;
			deleteVehicle _dummy;
		};
	};

	_count = count DGAA_AssaultQueue;
	if(_count < DGAA_MaxAssaultCount) then
	{
		// Sleep until next spawn
		_nextWaitTime = (DGAA_TimeBetweenMissions select 0) + random((DGAA_TimeBetweenMissions select 1) - (DGAA_TimeBetweenMissions select 0));
		[format["Waiting %1 seconds before next airborne spawn. (Assault queue count = %2)", _nextWaitTime, _count], DGAA_MessageName, "debug"] call DGCore_fnc_log;
		uiSleep _nextWaitTime; // Wait until the random counter started
		_reInitialize = true;
	};
	uiSleep 2;
};