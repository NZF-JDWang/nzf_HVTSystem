class CfgPatches
{
	class nzf_HVTSystem
	{
		units[] = {"nzf_HVTSystem"};
		requiredVersion = 1.0;
		requiredAddons[] = {"A3_Modules_F", "ace_main", "zen_custom_modules", "zen_dialog"};
		category = "NZF Systems";
	};
};

class CfgFactionClasses
{
	class NO_CATEGORY;
	class NZF_Systems: NO_CATEGORY
	{
		displayName = "NZF Systems";
	};
};

class CfgVehicles
{
	class Logic;
	class Module_F : Logic
	{
		class AttributesBase
		{
			class Default;
			class Edit;					// Default edit box (i.e. text input field)
			class Combo;				// Default combo box (i.e. drop-down menu)
			class Checkbox;				// Default checkbox (returned value is Boolean)
			class CheckboxNumber;		// Default checkbox (returned value is Number)
			class ModuleDescription;	// Module description
			class Units;				// Selection of units on which the module is applied
		};

		// Description base classes (for more information see below):
		class ModuleDescription
		{
			class AnyBrain;
		};
	};

	class nzf_Module_HVT : Module_F
	{
		// Standard object definitions:
		scope = 2;										// Editor visibility; 2 will show it in the menu, 1 will hide it.
		displayName = "Create HVT";				// Name displayed in the menu
		icon = "\A3\Ui_f\data\IGUI\Cfg\simpleTasks\types\kill_ca.paa";	// Map icon. Delete this entry to use the default icon.
		category = "NZF_Systems";

		function = "nzf_fnc_hvtSetup";	// Name of function triggered once conditions are met
		functionPriority = 2;				// Execution priority, modules with lower number are executed first. 0 is used when the attribute is undefined
		isGlobal = 2;						// 0 for server only execution, 1 for global execution, 2 for persistent global execution
		isTriggerActivated = 0;				// 1 for module waiting until all synced triggers are activated
		isDisposable = 1;					// 1 if modules is to be disabled once it is activated (i.e. repeated trigger activation will not work)
		is3DEN = 0;							// 1 to run init function in Eden Editor as well
		curatorCanAttach = 0;				// 1 to allow Zeus to attach the module to an entity
//		curatorInfoType = "RscDisplayAttributeModuleNuke"; // Menu displayed when the module is placed or double-clicked on by Zeus

		// 3DEN Attributes Menu Options
		canSetArea = 0;						// Allows for setting the area values in the Attributes menu in 3DEN
		canSetAreaShape = 0;				// Allows for setting "Rectangle" or "Ellipse" in Attributes menu in 3DEN
		canSetAreaHeight = 0;				// Allows for setting height or Z value in Attributes menu in 3DEN
		class AttributeValues
		{
			// This section allows you to set the default values for the attributes menu in 3DEN
			size3[] = { 0, 0, -1 };		// 3D size (x-axis radius, y-axis radius, z-axis radius)
			isRectangle = 0;				// Sets if the default shape should be a rectangle or ellipse
		};

		// Module attributes (uses https://community.bistudio.com/wiki/Eden_Editor:_Configuring_Attributes#Entity_Specific):
		class Attributes : AttributesBase
		{
			// Arguments shared by specific module type (have to be mentioned in order to be present):
			class Units : Units
			{
				property = "nzf_fnc_hvt_units";
				typeName = "OBJECT"; // Single object instead of group
			};

			// === BASIC INFO ===
			class nzf_hvt_name : Edit
			{
				displayName = "HVT Name";
				tooltip = "Custom name for the HVT unit (leave empty to keep original name)";
				property = "nzf_Module_hvt_name";
				defaultValue = """""";
			};

			// === AI BEHAVIOR ===
			class nzf_surrender : Checkbox
			{
				displayName = "Will Surrender";
				tooltip = "HVT will surrender when confronted by a player";
				property = "nzf_Module_hvt_surrender";
				defaultValue = "(false)";
			};

			class nzf_ai_behavior : Combo
			{
				displayName = "AI Behavior";
				tooltip = "How the HVT should behave";
				property = "nzf_Module_hvt_ai_behavior";
				defaultValue = "''";
				expression = "_this setVariable ['%s',_value,true];";
				class Values
				{
					class static	{default = 1; name = "Static (No movement)"; value = "static"; };
					class fleeing	{default = 0; name = "Fleeing (Runs when players close)"; value = "fleeing"; };
				};
			};

			class nzf_flee_range : Edit
			{
				displayName = "Flee Detection Range (m)";
				tooltip = "Range at which HVT starts fleeing (only used if AI Behavior is 'Fleeing')";
				property = "nzf_Module_hvt_flee_range";
				defaultValue = """25""";
			};

			class nzf_plot_armor : Checkbox
			{
				displayName = "Plot Armor (ACM)";
				tooltip = "HVT will have plot armor and cannot be killed. REQUIRES ACM mod to be loaded to function.";
				property = "nzf_Module_hvt_plot_armor";
				defaultValue = "(false)";
				condition = "isClass (configFile >> 'CfgPatches' >> 'ACM_main')";
			};

			// === SUICIDE VEST OPTIONS ===
			class nzf_svest : Edit
			{
				displayName = "S-Vest Classname";
				tooltip = "Classname of vest to use (leave as 'false' for no S-vest)";
				property = "nzf_Module_hvt_svest";
				defaultValue = """false"""; 
			};

			class nzf_svest_explosion : Combo
			{
				displayName = "Explosion Size";
				tooltip = "Size of explosion when suicide vest detonates";
				property = "nzf_Module_hvt_svest_explosion";
				defaultValue = "''";
				expression = "_this setVariable ['%s',_value,true];";
				class Values
				{
					class small_boom	{default = 1; name = "Small";	value = "M_PG_AT"; };
					class medium_boom	{default = 0; name = "Medium"; value = "IEDUrbanSmall_Remote_Ammo"; };
					class large_boom	{default = 0; name = "Large"; value = "R_60mm_HE"; };
				};
			};

			class nzf_svest_range : Edit
			{
				displayName = "Detonation Range (m)";
				tooltip = "Range in meters that players must be within to trigger the vest";
				property = "nzf_Module_hvt_svest_range";
				defaultValue = """5""";
			};

			class nzf_svest_time : Edit
			{
				displayName = "Detonation Delay (s)";
				tooltip = "Seconds between trigger and explosion";
				property = "nzf_Module_hvt_svest_time";
				defaultValue = """2""";
			};

			class nzf_svest_fear_timeout : Edit
			{
				displayName = "Fear Timeout (s)";
				tooltip = "Seconds after fear animation before auto-detonation (0 = disabled)";
				property = "nzf_Module_hvt_svest_fear_timeout";
				defaultValue = """6""";
			};

			class nzf_svest_scream : Checkbox
			{
				displayName = "Allahu Akbar";
				tooltip = "HVT will scream Allahu Akbar before detonating";
				property = "nzf_Module_hvt_svest_scream";
				defaultValue = "(false)";
			};

			class nzf_svest_los : Checkbox
			{
				displayName = "Require Line of Sight";
				tooltip = "Vest will only trigger if HVT has line of sight to a player";
				property = "nzf_svest_los";
				defaultValue = "(true)";
			};

			class ModuleDescription : ModuleDescription {}; // Module description should be shown last
		};

		// Module description (must inherit from base class, otherwise pre-defined entities won't be available)
		class ModuleDescription : ModuleDescription
		{
			description = "HVT Setup";	// Short description, will be formatted as structured text
			sync[] = {};				// Array of synced entities (can contain base classes)

			class LocationArea_F
			{
				description[] = { // Multi-line descriptions are supported
					"First line",
					"Second line"
				};
				position = 0;	// Position is taken into effect
				direction = 0;	// Direction is taken into effect
				optional = 0;	// Synced entity is optional
				duplicate = 0;	// Multiple entities of this type can be synced
				synced[] = { "AnyAI"};	// Pre-defined entities like "AnyBrain" can be used (see the table below)
			};

		};
	};
};

class CfgFunctions
{
	class nzf
	{
		class hvt
		{
			file = "\nzf_hvtSystem\functions";
			class hvtSetup {};
			class svest {};
			class createHVTZeusModule {};
		class setupHVTFear {};
		class setupSurrender {};
		class setupSuicideVest {};
		class setupHVTKilledEH {};
		class addHVTDiaryEntry {};
		class addHVTOcapEvent {};
		};
	};
};

class CfgSounds {

    sounds[] = {};

        class nzf_hvt_allahuAkbar
        { 
            name = "allahuAkbar";
            sound[] = {"\nzf_hvtSystem\sounds\allahuAkbar.ogg", 5, 1, 100};
            titles[] = {};
            distance = 100;
            duration = 2;
        };
};

class Extended_PostInit_EventHandlers {
    class nzf_hvtSystem {
        init = "call compile preprocessFileLineNumbers 'nzf_hvtSystem\XEH_postInit.sqf'";
    };
};