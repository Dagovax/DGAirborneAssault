class CfgPatches {
	class a3_dg_airborneAssault {
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {};
	};
};
class CfgFunctions {
	class DGAirborneAssault {
		tag = "DGAirborneAssault";
		class Main {
			file = "\x\addons\a3_dg_airborneAssault\init";
			class init {
				postInit = 1;
			};
		};
	};
};
