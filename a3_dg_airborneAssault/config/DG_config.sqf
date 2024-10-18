
DGAA_MessageName = "DG Airborne Assault";

if (!isServer) exitWith {
	["Failed to load configuration data, as this code is not being executed by the server!", DGAA_MessageName] call DGCore_fnc_log;
};

["Loading configuration data...", DGAA_MessageName] call DGCore_fnc_log;

/****************************************************************************************************/
/********************************  CONFIG PART. EDIT AS YOU LIKE!!  ************************************/
/****************************************************************************************************/

// Generic
DGAA_DebugMode				= false; // For testing purposes. Do not set this on live server or players will die
DGAA_SleepTime				= 60; 
DGAA_MinAmountPlayers		= 0; 	// Amount of players required to start the missions spawning. Set to 0 to have no wait time for players

// Asasault settings
DGAA_MaxAssaultCount		= 3; 				// Maximum amount of airborne assault missions active at the same time
DGAA_TimeToFirstMission 	= [50,360];			// [Minimum,Maximum] time between first mission spawn. | DEFAULT: 3-7 minutes.
DGAA_TimeBetweenMissions	= [300,900];		// [Minimum,Maximum] time between missions (if mission limit is not reached) | DEFAULT: 10-15 mins
DGAA_PlaneSpawnDistance 	= 7000; 		 	// Amount of meters the planes spawn away from the mission. DG_mapRange = max calculated range.
DGAA_PlaneCount				= [4, 12]; 			// Range of plane counts. A random integer will be selected. Make both values equal to have a static count.
DGAA_ShowNotification		= true;				// Broadcast notifications
DGAA_EnableAlarmSound		= true; 			// Setting this to false willl disable the alarm soundss
DGAA_AlarmSounds = 								// Sound names, length, pitch, array of objects that will play this sound
[ 												
	["DG_AirSirensLong", 65, 1, ["Land_Loudspeakers_F"]]
];
DGAA_AlarmSoundTime			= 120; 				// Amount of seconds the alarms will be played
DGAA_AlarmSoundDistance		= 4500; 			// Distance in meters that first aircraft has to be away from the mission to start alarm sound.
DGAA_AlarmSoundRange		= 5000; 			// Range around the sound that it will be hearable
DGAA_CrateChance			= 20;				// Chance percentage of which a plane will drop a crate
DGAA_ForceCrate				= true;				// Force at least one loot crate per mission

DGAA_PlaneTypes =
[
	"CUP_B_AC47_Spooky_USA"
];

DGAA_EnableMarker			= true; // Adds a marker and text showing remaining AI to the base being raided
DGAA_MarkerType 			= "ELLIPSE";
DGAA_MarkerText				= "Airborne Assault";
DGAA_MarkerColor			= "ColorWhite";

// AI Settings
DGAA_AIEasySettings			= [0.3, [3,5], 1, 100]; // AI easy general level, followed by array containing min - max troops, followed by inventory items | max poptabs
DGAA_AINormalSettings		= [0.5, [5,8], 2, 250]; // AI normal general level, followed by array containing min - max troops, followed by inventory items | max poptabs
DGAA_AIHardSettings			= [0.7, [8,12], 3, 500]; // AI hard general level, followed by array containing min - max troops, followed by inventory items | max poptabs
DGAA_AIExtremeSettings		= [0.9, [10,15], 4, 1000]; // AI extreme general level, followed by array containing min - max troops, followed by inventory items | max poptabs
DGAA_CountAliveAI			= true;
DGAA_AIUseNVG				= true; // If set to true, AI might spawn with NVG goggles. The random percentage is defined below.
DGAA_AINVGSpawnChance		= 60;	// Percentage. So a valid value between <0> and <100>. 0 will mean that no unit will spawn with NVG. 100 means they all have NVG
			
["Configuration loaded", DGAA_MessageName] call DGCore_fnc_log;
