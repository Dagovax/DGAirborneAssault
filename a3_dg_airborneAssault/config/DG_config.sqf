
DGAA_MessageName = "DG Airborne Assault";

if (!isServer) exitWith {
	["Failed to load configuration data, as this code is not being executed by the server!", DGAA_MessageName] call DGCore_fnc_log;
};

["Loading configuration data...", DGAA_MessageName] call DGCore_fnc_log;

/****************************************************************************************************/
/********************************  CONFIG PART. EDIT AS YOU LIKE!!  ************************************/
/****************************************************************************************************/

// Generic
DGAA_DebugMode				= false; 			// For testing purposes. Do not set this on live server or players will die
DGAA_MinAmountPlayers		= 0; 				// Amount of players required to start the missions spawning. Set to 0 to have no wait time for players

// Asasault settings
DGAA_MaxAssaultCount		= 3; 				// Maximum amount of airborne assault missions active at the same time
DGAA_TimeToFirstMission 	= [50,360];			// [Minimum,Maximum] time between first mission spawn. | DEFAULT: 3-7 minutes.
DGAA_TimeBetweenMissions	= [300,900];		// [Minimum,Maximum] time between missions (if mission limit is not reached) | DEFAULT: 10-15 mins
DGAA_PlaneSpawnDistance 	= 7000; 		 	// Amount of meters the planes spawn away from the mission. DG_mapRange = max calculated range.
DGAA_PlaneCountPerLevel		= 					// Range of plane counts. A random integer will be selected. Make both values equal to have a static count.
[
	[2, 5],  // low
	[3, 7],  // medium
	[4, 10], // high
	[6, 12]  // veteran
];	
DGAA_FlyHeightRange			= [250, 400]; 		// A random flyheight will be used between these numbers
DGAA_FlySpeedLimit			= 150; 				// Generic speed limit for air vehicles. 
DGAA_AIEasyTroopCount		= [1,2];			// Array containing min - max troops
DGAA_AINormalTroopCount		= [2,5];			// Array containing min - max troops
DGAA_AIHardTroopCount		= [3,6];			// Array containing min - max troops
DGAA_AIExtremeTroopCount	= [4,8]; 			// Array containing min - max troops
DGAA_ShowNotification		= true;				// Broadcast notifications
DGAA_EnableAlarmSound		= true; 			// Setting this to false willl disable the alarm soundss
DGAA_AlarmSounds = 								// Sound names, length, pitch, array of objects that will play this sound
[ 												
	["DG_AirSirensLong", 65, 1, ["Land_Loudspeakers_F"]]
];
DGAA_AlarmSoundTime			= 120; 				// Amount of seconds the alarms will be played
DGAA_AlarmSoundDistance		= 4500; 			// Distance in meters that first aircraft has to be away from the mission to start alarm sound.
DGAA_AlarmSoundRange		= 5000; 			// Range around the sound that it will be hearable
DGAA_LootCratePerLevel =						// Amount of loot crates that can spawn per mission, based on difficulty level (set at DGAA_AISkillLevel)
[
	[1, 2],	// low
	[1, 3],	// medium
	[2, 3],	// high
	[2, 4]	// veteran
];
DGAA_ForceCrate				= true;				// Force at least one loot crate per mission
DGAA_PlaneTypes =
[
	"CUP_B_AC47_Spooky_USA"
];
DGAA_PlaneAllowDamage		= true; 			// Allow damage to the assault planes AFTER they dropped their cargo. 
DGAA_PlaneSetCaptive		= false;			// If set to true, planes will be ignored by AI. Default false
DGAA_NoRandomBase			= false; 			// If set to true, no predefined camp buildings will spawn on the target position. Set this to true if you want to use custom buildings.
DGAA_SpawnGroundVehicle		= true;				// If set to true, spawns a ground vehicle as well. Spawns outside mission zone and moves to the mission position. Check DGCore config for vehicle count + crew percentage
DGAA_GroundVehicleSpawnDis	= 1500;				// Minimum distance in meters away from the mission the ground vehicles will spawn.
DGAA_VehicleGround = 							// List of vehicles that will be randomly used on ground, if DGAA_SpawnGroundVehicle = true.
[
	"B_MRAP_01_hmg_F",
	"B_LSV_01_armed_F",
	"B_Quadbike_01_F",
	"O_MRAP_02_hmg_F",
	"CUP_O_UAZ_MG_CSAT",
	"CUP_I_LR_SF_HMG_AAF",
	"BTR40_MG_TK_INS_EP1",
	"B_G_Offroad_01_armed_F",
	"Exile_Car_Offroad_Armed_Guerilla02"
];

// Marker settings
DGAA_MarkerType 			= "ELLIPSE";		// Marker type
DGAA_MarkerSize				= [250,250];		// Marker size
DGAA_MarkerBrush			= "SolidBorder";	// Marker brush
DGAA_MarkerColors =								// Marker color for the different difficulty levels. DGAA_AISkillLevel will be used to pick the color per difficulty
[ 												
	"ColorGreen",	// low
	"ColorOrange",	// medium
	"ColorEast",	// high
	"ColorBlack"	// veteran
];
	
DGAA_MarkerText				= "Airborne Assault"; 			// Marker text
DGAA_MarkerTextColor		= "ColorWhite";					// Marker text color

// AI Settings
DGAA_AISkillLevel			= "random";						// AI Skill level. Choose between [random | low | medium | high | veteran]
DGAA_CountAliveAI			= true;							// Count alive AI 
DGAA_AIUseNVG				= true; 						// If set to true, AI might spawn with NVG goggles. The random percentage is defined below.
DGAA_AINVGSpawnChance		= 60;							// Percentage. So a valid value between <0> and <100>. 0 will mean that no unit will spawn with NVG. 100 means they all have NVG
DGAA_EnableLaunchers		= DGCore_EnableLaunchers;		// AI may spawn with launchers if set to true. Default: same value as in DGCore config.

// Mission Position settings
DGAA_UseStaticPositions		= false; 						// If set to true, mission position pool will first try to find a random static position from the array below.
DGAA_IgnoreStaticPosCheck	= true;							// If set to true, static positions will always be picked no matter if other missions are nearby, or territories etc. 
DGAA_StaticPosition =										// Array of static positions. If no missions are defined a dynamic position will be searched unless above setting is set to false. 
[
	//[4072.67,4507.11,0], // EXAMPLE: Napf South airfield
	//[14617.5,16761.3,0]  // EXAMPLE: Napf international airfield
];
		
["Configuration loaded", DGAA_MessageName] call DGCore_fnc_log;
