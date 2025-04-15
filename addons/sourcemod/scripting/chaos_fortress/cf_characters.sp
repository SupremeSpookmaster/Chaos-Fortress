#define MODEL_PREVIEW_DOORS		"models/vgui/versus_doors_win.mdl"
#define MODEL_PREVIEW_STAGE		"models/props_ui/competitive_stage.mdl"
#define MODEL_PREVIEW_UNKNOWN	"models/class_menu/random_class_icon.mdl"

#define SOUND_CHARACTER_PREVIEW	"ui/quest_status_tick_advanced_pda.wav"

public const char s_PreviewParticles[][] =
{
	"drg_wrenchmotron_teleport",
	"wrenchmotron_teleport_beam",
	"wrenchmotron_teleport_flash",
	"wrenchmotron_teleport_glow_big",
	"wrenchmotron_teleport_sparks"
};

public const char s_ModelFileExtensions[][] =
{
	".dx80.vtx",
	".dx90.vtx",
	".mdl",
	".phy",
	".sw.vtx",
	".vvd"
};

public const TFClassType Classes[] = 
{
	TFClass_Scout,
	TFClass_Soldier,
	TFClass_Pyro,
	TFClass_DemoMan,
	TFClass_Heavy,
	TFClass_Engineer,
	TFClass_Medic,
	TFClass_Sniper,
	TFClass_Spy
};

public const float f_ClassBaseHP[] =
{
	125.0,
	200.0,
	175.0,
	175.0,
	300.0,
	125.0,
	150.0,
	125.0,
	125.0
};

public const float f_ClassBaseSpeed[] =
{
	400.0,
	240.0,
	300.0,
	280.0,
	230.0,
	300.0,
	320.0,
	300.0,
	320.0
};

//Abilities are split into two types:
//	• CFAbility
//	• CFEffect
//
//CFAbility is the methodmap used for "official" abilities, the ones triggered on M2, M3, Reload, and Ultimate.
//It contains the following: slot, cooldown, next use time, display name, stockpile system info, resource costs, whether or not it is a held ability

//CFEffect is the methodmap used for the abilities themselves.
//It contains the following: "plugin_name", "ability_name", slot, and a list of the ability's args and their corresponding values.

bool b_EffectExists[2048] = { false, ... };

int i_EffectSlot[2048] = { -1, ... };
int i_EffectArgs[2048] = { 0, ... };

char s_EffectPluginName[2048][255];
char s_EffectAbilityName[2048][255];
char s_EffectAbilityIndex[2049][255];
char s_EffectArgNames[2048][255][255];
char s_EffectArgValues[2048][255][255];

methodmap CFEffect __nullable__
{
	public CFEffect()
	{
		int slot = -1;
		for (int i = 0; i < 2048; i++)
		{
			if (!b_EffectExists[i])
			{
				slot = i;
				break;
			}
		}

		if (slot != -1)
		{
			b_EffectExists[slot] = true;
		}

		return view_as<CFEffect>(slot);
	}

	property int index
	{
		public get() { return view_as<int>(this); }
	}

	property int i_AbilitySlot
	{
		public get() { return i_EffectSlot[this.index]; }
		public set(int value) { i_EffectSlot[this.index] = value; }
	}

	property int i_NumArgs
	{
		public get() { return i_EffectArgs[this.index]; }
	}

	property bool b_Exists
	{
		public get() { return b_EffectExists[this.index]; }
	}

	public void Destroy()
	{ 
		this.ClearArgsAndValues();
		this.i_AbilitySlot = -1;
		this.SetPluginName("");
		this.SetAbilityName("");
		this.SetAbilityIndex("");
		b_EffectExists[this.index] = false;
	}

	public void SetPluginName(char[] pluginName) { strcopy(s_EffectPluginName[this.index], 255, pluginName); }
	public void GetPluginName(char[] output, int size) { strcopy(output, size, s_EffectPluginName[this.index]); }

	public void SetAbilityName(char[] abilityName) { strcopy(s_EffectAbilityName[this.index], 255, abilityName); }
	public void GetAbilityName(char[] output, int size) { strcopy(output, size, s_EffectAbilityName[this.index]); }

	public void SetAbilityIndex(char[] abilityIndex) { strcopy(s_EffectAbilityIndex[this.index], 255, abilityIndex); }
	public void GetAbilityIndex(char[] output, int size) { strcopy(output, size, s_EffectAbilityIndex[this.index]); }

	public int GetArgI(char[] arg, int defaultValue = 0)
	{
		char def[16], val[255];
		Format(def, 16, "%i", defaultValue);
		this.GetArgS(arg, val, 255, def);

		return StringToInt(val);
	}

	public float GetArgF(char[] arg, float defaultValue = 0.0)
	{
		char def[64], val[255];
		Format(def, 64, "%f", defaultValue);
		this.GetArgS(arg, val, 255, def);

		return StringToFloat(val);
	}

	public void GetArgS(char[] arg, char[] output, int size, char[] defaultValue = "")
	{
		for (int i = 0; i < this.i_NumArgs; i++)
		{
			if (StrEqual(s_EffectArgNames[this.index][i], arg))
			{
				strcopy(output, size, s_EffectArgValues[this.index][i]);
				return;
			}
		}

		strcopy(output, size, defaultValue);
	}

	public void SetArgsAndValues(ConfigMap map)
	{
		this.ClearArgsAndValues();

		StringMapSnapshot snap = map.Snapshot();

		for (int i = 0; i < snap.Length; i++)
		{
			char key[255];
			snap.GetKey(i, key, 255);

			if (StrEqual(key, "plugin_name") || StrEqual(key, "slot") || StrEqual(key, "ability_name"))
				continue;

			strcopy(s_EffectArgNames[this.index][this.i_NumArgs], 255, key);
			map.Get(key, s_EffectArgValues[this.index][this.i_NumArgs], 255);
			i_EffectArgs[this.index]++;
		}

		delete snap;
	}

	public void ClearArgsAndValues()
	{
		for (int i = 0; i < this.i_NumArgs; i++)
		{
			strcopy(s_EffectArgNames[this.index][i], 255, "");
			strcopy(s_EffectArgValues[this.index][i], 255, "");
		}

		i_EffectArgs[this.index] = 0;
	}
}

bool b_AbilityExists[2048] = { false, ... };

int i_AbilitySlot[2048] = { -1, ... };
int i_AbilityWeaponSlot[2048] = { -1, ...};
int i_AbilityAmmo[2048] = { 0, ... };
int i_AbilityStocks[2048] = { 0, ...};
int i_AbilityMaxStocks[2048] = { 0, ...};
int i_AbilityClient[2049] = { -1, ... };
int i_AbilityType[2049] = { -1, ... };

float f_AbilityCD[2048] = { 0.0, ... };
float f_AbilityNextUseTime[2048] = { 0.0, ... };
float f_AbilityCost[2048] = { 0.0, ... };
float f_AbilityScale[2048] = { 0.0, ... };

bool b_AbilityIsHeld[2048] = { false, ... };
bool b_AbilityHeldBlock[2048] = { false, ... };
bool b_AbilityIsGrounded[2048] = { false, ... };
bool b_AbilityIsBlocked[2048] = { false, ... };
bool b_AbilityCurrentlyHeld[2048] = { false, ... };

char s_AbilityName[2048][255];

methodmap CFAbility  __nullable__
{
	public CFAbility()
	{
		for (int i = 0; i < 2048; i++)
		{
			if (!b_AbilityExists[i])
			{
				b_AbilityExists[i] = true;
				return view_as<CFAbility>(i);
			}
		}

		return view_as<CFAbility>(-1);
	}

	property int index
	{
		public get() { return view_as<int>(this); }
	}

	property int i_Client
	{
		public get() { return GetClientOfUserId(i_AbilityClient[this.index]); }
		public set(int value) { i_AbilityClient[this.index] = (IsValidClient(value) ? GetClientUserId(value) : -1); }
	}

	property int i_AbilitySlot
	{
		public get() { return i_AbilitySlot[this.index]; }
		public set(int value) { i_AbilitySlot[this.index] = value; }
	}

	property int i_Type
	{
		public get() { return i_AbilityType[this.index]; }
		public set(int value) { i_AbilityType[this.index] = value; }
	}

	property int i_WeaponSlot
	{
		public get() { return i_AbilityWeaponSlot[this.index]; }
		public set(int value) { i_AbilityWeaponSlot[this.index] = value; }
	}

	property int i_AmmoRequirement
	{
		public get() { return i_AbilityAmmo[this.index]; }
		public set(int value) { i_AbilityAmmo[this.index] = value; }
	}

	property int i_Stocks
	{
		public get() { return i_AbilityStocks[this.index]; }
		public set(int value) { i_AbilityStocks[this.index] = value; }
	}

	property int i_MaxStocks
	{
		public get() { return i_AbilityMaxStocks[this.index]; }
		public set(int value) { i_AbilityMaxStocks[this.index] = value; }
	}

	property float f_Cooldown
	{
		public get() { return f_AbilityCD[this.index]; }
		public set(float value) { f_AbilityCD[this.index] = value; }
	}

	property float f_NextUseTime
	{
		public get() { return f_AbilityNextUseTime[this.index]; }
		public set(float value) { f_AbilityNextUseTime[this.index] = value; }
	}

	property float f_ResourceCost
	{
		public get() { return f_AbilityCost[this.index]; }
		public set(float value) { f_AbilityCost[this.index] = value; }
	}

	property float f_Scale
	{
		public get() { return f_AbilityScale[this.index]; }
		public set(float value) { f_AbilityScale[this.index] = value; }
	}

	property bool b_HeldAbility
	{
		public get() { return b_AbilityIsHeld[this.index]; }
		public set(bool value) { b_AbilityIsHeld[this.index] = value; }
	}

	property bool b_HeldAbilityBlocksOthers
	{
		public get() { return b_AbilityHeldBlock[this.index]; }
		public set(bool value) { b_AbilityHeldBlock[this.index] = value; }
	}

	property bool b_RequireGrounded
	{
		public get() { return b_AbilityIsGrounded[this.index]; }
		public set(bool value) { b_AbilityIsGrounded[this.index] = value; }
	}

	property bool b_Exists
	{
		public get() { return b_AbilityExists[this.index]; }
	}

	property bool b_Blocked
	{
		public get() { return b_AbilityIsBlocked[this.index]; }
		public set(bool value) { b_AbilityIsBlocked[this.index] = value; }
	}

	property bool b_CurrentlyHeld
	{
		public get() { return b_AbilityCurrentlyHeld[this.index]; }
		public set(bool value) { b_AbilityCurrentlyHeld[this.index] = value; }
	}

	public void GetName(char[] output, int size) { strcopy(output, size, s_AbilityName[this.index]); }
	public void SetName(char[] name) { strcopy(s_AbilityName[this.index], 255, name); }

	public void Destroy()
	{ 
		char name[255];
		this.GetName(name, 255);
		this.i_AbilitySlot = -1;
		this.i_Type = -1;
		this.i_WeaponSlot = -1;
		this.i_AmmoRequirement = 0;
		this.i_Stocks = 0;
		this.i_MaxStocks = 0;
		this.f_Cooldown = 0.0;
		this.f_NextUseTime = 0.0;
		this.f_ResourceCost = 0.0;
		this.f_Scale = 0.0;
		this.b_HeldAbility = false;
		this.b_HeldAbilityBlocksOthers = false;
		this.b_RequireGrounded = false;
		this.b_Blocked = false;
		this.b_CurrentlyHeld = false;
		this.SetName("");
		this.i_Client = -1;
		b_AbilityExists[this.index] = false; 
	}
}

CFAbility g_Abilities[2048];

//A quick little optimization trick for looking up abilities in GetAbilityFromClient.
//If we've previously successfully found an existing ability for this client in the given slot, check that cell first before we cycle through the entire array.
int i_LastSlot[MAXPLAYERS + 1][5];

public CFAbility GetAbilityFromClient(int client, CF_AbilityType type)
{
	int slot = view_as<int>(type) + 1;

	if (i_LastSlot[client][slot] > -1 && i_LastSlot[client][slot] < 2048)
	{
		CFAbility ab = g_Abilities[i_LastSlot[client][slot]];
		if (ab != null && ab.b_Exists && ab.i_Client == client && ab.i_Type == slot)
			return ab;
	}

	for (int i = 0; i < 2048; i++)
	{
		CFAbility ab = g_Abilities[i];
		if (ab == null || !ab.b_Exists)
			continue;

		if (ab.i_Client == client && ab.i_Type == slot)
		{
			i_LastSlot[client][slot] = i;
			return ab;
		}
	}

	return null;
}

public void DestroyAbility(int client, CF_AbilityType type)
{
	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab != null)
		ab.Destroy();
}

int i_CharacterClient[MAXPLAYERS + 1];
int i_CharacterNumSoundCues[MAXPLAYERS + 1];

float f_CharacterSpeed[MAXPLAYERS + 1];
float f_CharacterMaxHP[MAXPLAYERS + 1];
float f_CharacterScale[MAXPLAYERS + 1];
float f_CharacterBaseSpeed[MAXPLAYERS + 1];
float f_CharacterWeight[MAXPLAYERS + 1];
float f_CharacterUltCharge[MAXPLAYERS + 1];
float f_CharacterUltChargeRequired[MAXPLAYERS + 1];
float f_CharacterUltChargeOnRegen[MAXPLAYERS + 1];
float f_CharacterUltChargeOnDamage[MAXPLAYERS + 1];
float f_CharacterUltChargeOnHurt[MAXPLAYERS + 1];
float f_CharacterUltChargeOnHeal[MAXPLAYERS + 1];
float f_CharacterUltChargeOnKill[MAXPLAYERS + 1];
float f_CharacterUltChargeOnBuildingDamage[MAXPLAYERS + 1];
float f_CharacterUltChargeOnDestruction[MAXPLAYERS + 1];

float f_CharacterResources[MAXPLAYERS + 1];
float f_CharacterMaxResources[MAXPLAYERS + 1];
float f_CharacterResourceRegenInterval[MAXPLAYERS + 1];
float f_CharacterResourceNextRegen[MAXPLAYERS + 1];
float f_CharacterResourcesOnRegen[MAXPLAYERS + 1];
float f_CharacterResourcesOnDamage[MAXPLAYERS + 1];
float f_CharacterResourcesOnHurt[MAXPLAYERS + 1];
float f_CharacterResourcesOnHeal[MAXPLAYERS + 1];
float f_CharacterResourcesOnKill[MAXPLAYERS + 1];
float f_CharacterResourcesOnBuildingDamage[MAXPLAYERS + 1];
float f_CharacterResourcesOnDestruction[MAXPLAYERS + 1];
float f_CharacterResourcesToTriggerSound[MAXPLAYERS + 1];
float f_CharacterResourcesSinceLastGain[MAXPLAYERS + 1];
bool b_CharacterResourceIsUlt[MAXPLAYERS + 1];
bool b_CharacterResourceIsPercentage[MAXPLAYERS + 1];
bool b_CharacterResourceIsMetal[MAXPLAYERS + 1];
char s_CharacterResourceName[MAXPLAYERS + 1][255];
char s_CharacterResourceNamePlural[MAXPLAYERS + 1][255];

TFClassType i_CharacterClass[MAXPLAYERS + 1];
ArrayList g_CharacterEffects[MAXPLAYERS + 1] = { null, ... };
CFSoundCue g_CharacterSoundCues[MAXPLAYERS + 1][2048];

char s_CharacterModel[MAXPLAYERS + 1][255];
char s_CharacterName[MAXPLAYERS + 1][255];
char s_CharacterArchetype[MAXPLAYERS + 1][255];
char s_CharacterConfigMapPath[MAXPLAYERS + 1][255];

bool b_CharacterExists[MAXPLAYERS + 1] = { false, ... };
bool b_CharacterUsesResources[MAXPLAYERS + 1] = { false, ... };

methodmap CFCharacter __nullable__
{
	public CFCharacter()
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!b_CharacterExists[i])
			{
				b_CharacterExists[i] = true;
				return view_as<CFCharacter>(i);
			}
		}

		CPrintToChatAll("{red}CHARACTER SLOT OVERFLOW! THIS SHOULD NEVER HAPPEN, SEND A SCREENSHOT OF THIS TO A DEV!");
		return view_as<CFCharacter>(-1);
	}

	property int index
	{
		public get() { return view_as<int>(this); }
	}

	property int i_Client
	{
		public get() { return GetClientOfUserId(i_CharacterClient[this.index]); }
		public set(int value) { i_CharacterClient[this.index] = (IsValidClient(value) ? GetClientUserId(value) : -1); }
	}

	property int i_NumSoundCues
	{
		public get() { return i_CharacterNumSoundCues[this.index]; }
		public set(int value) { i_CharacterNumSoundCues[this.index] = value; }
	}

	property bool b_Exists
	{
		public get() { return b_CharacterExists[this.index]; }
	}

	property bool b_UsingResources
	{
		public get() { return b_CharacterUsesResources[this.index]; }
		public set(bool value) { b_CharacterUsesResources[this.index] = value; }
	}

	property bool b_ResourceIsUlt
	{
		public get() { return b_CharacterResourceIsUlt[this.index]; }
		public set(bool value) { b_CharacterResourceIsUlt[this.index] = value; }
	}

	property bool b_ResourceIsPercentage
	{
		public get() { return b_CharacterResourceIsPercentage[this.index]; }
		public set(bool value) { b_CharacterResourceIsPercentage[this.index] = value; }
	}

	property bool b_ResourceIsMetal
	{
		public get() { return b_CharacterResourceIsMetal[this.index]; }
		public set(bool value) { b_CharacterResourceIsMetal[this.index] = value; }
	}

	property float f_Speed
	{
		public get() { return f_CharacterSpeed[this.index]; }
		public set(float value) { f_CharacterSpeed[this.index] = value; }
	}

	property float f_MaxHP
	{
		public get() { return f_CharacterMaxHP[this.index]; }
		public set(float value) { f_CharacterMaxHP[this.index] = value; }
	}

	property float f_Scale
	{
		public get() { return f_CharacterScale[this.index]; }
		public set(float value) { f_CharacterScale[this.index] = value; }
	}

	property float f_BaseSpeed
	{
		public get() { return f_CharacterBaseSpeed[this.index]; }
		public set(float value) { f_CharacterBaseSpeed[this.index] = value; }
	}

	property float f_Weight
	{
		public get() { return f_CharacterWeight[this.index]; }
		public set(float value) { f_CharacterWeight[this.index] = value; }
	}

	property float f_UltCharge
	{
		public get() { return f_CharacterUltCharge[this.index]; }
		public set(float value) { f_CharacterUltCharge[this.index] = value; }
	}

	property float f_UltChargeRequired
	{
		public get() { return f_CharacterUltChargeRequired[this.index]; }
		public set(float value) { f_CharacterUltChargeRequired[this.index] = value; }
	}

	property float f_UltChargeOnRegen
	{
		public get() { return f_CharacterUltChargeOnRegen[this.index]; }
		public set(float value) { f_CharacterUltChargeOnRegen[this.index] = value; }
	}

	property float f_UltChargeOnDamage
	{
		public get() { return f_CharacterUltChargeOnDamage[this.index]; }
		public set(float value) { f_CharacterUltChargeOnDamage[this.index] = value; }
	}

	property float f_UltChargeOnHurt
	{
		public get() { return f_CharacterUltChargeOnHurt[this.index]; }
		public set(float value) { f_CharacterUltChargeOnHurt[this.index] = value; }
	}

	property float f_UltChargeOnHeal
	{
		public get() { return f_CharacterUltChargeOnHeal[this.index]; }
		public set(float value) { f_CharacterUltChargeOnHeal[this.index] = value; }
	}

	property float f_UltChargeOnKill
	{
		public get() { return f_CharacterUltChargeOnKill[this.index]; }
		public set(float value) { f_CharacterUltChargeOnKill[this.index] = value; }
	}

	property float f_UltChargeOnBuildingDamage
	{
		public get() { return f_CharacterUltChargeOnBuildingDamage[this.index]; }
		public set(float value) { f_CharacterUltChargeOnBuildingDamage[this.index] = value; }
	}

	property float f_UltChargeOnDestruction
	{
		public get() { return f_CharacterUltChargeOnDestruction[this.index]; }
		public set(float value) { f_CharacterUltChargeOnDestruction[this.index] = value; }
	}

	property float f_Resources
	{
		public get() { return f_CharacterResources[this.index]; }
		public set(float value) { f_CharacterResources[this.index] = value; }
	}

	property float f_MaxResources
	{
		public get() { return f_CharacterMaxResources[this.index]; }
		public set(float value) { f_CharacterMaxResources[this.index] = value; }
	}

	property float f_ResourceRegenInterval
	{
		public get() { return f_CharacterResourceRegenInterval[this.index]; }
		public set(float value) { f_CharacterResourceRegenInterval[this.index] = value; }
	}

	property float f_NextResourceRegen
	{
		public get() { return f_CharacterResourceNextRegen[this.index]; }
		public set(float value) { f_CharacterResourceNextRegen[this.index] = value; }
	}

	property float f_ResourcesOnRegen
	{
		public get() { return f_CharacterResourcesOnRegen[this.index]; }
		public set(float value) { f_CharacterResourcesOnRegen[this.index] = value; }
	}

	property float f_ResourcesOnDamage
	{
		public get() { return f_CharacterResourcesOnDamage[this.index]; }
		public set(float value) { f_CharacterResourcesOnDamage[this.index] = value; }
	}

	property float f_ResourcesOnHurt
	{
		public get() { return f_CharacterResourcesOnHurt[this.index]; }
		public set(float value) { f_CharacterResourcesOnHurt[this.index] = value; }
	}

	property float f_ResourcesOnHeal
	{
		public get() { return f_CharacterResourcesOnHeal[this.index]; }
		public set(float value) { f_CharacterResourcesOnHeal[this.index] = value; }
	}

	property float f_ResourcesOnKill
	{
		public get() { return f_CharacterResourcesOnKill[this.index]; }
		public set(float value) { f_CharacterResourcesOnKill[this.index] = value; }
	}

	property float f_ResourcesOnBuildingDamage
	{
		public get() { return f_CharacterResourcesOnBuildingDamage[this.index]; }
		public set(float value) { f_CharacterResourcesOnBuildingDamage[this.index] = value; }
	}

	property float f_ResourcesOnDestruction
	{
		public get() { return f_CharacterResourcesOnDestruction[this.index]; }
		public set(float value) { f_CharacterResourcesOnDestruction[this.index] = value; }
	}

	property float f_ResourcesToTriggerSound
	{
		public get() { return f_CharacterResourcesToTriggerSound[this.index]; }
		public set(float value) { f_CharacterResourcesToTriggerSound[this.index] = value; }
	}

	property float f_ResourcesSinceLastGain
	{
		public get() { return f_CharacterResourcesSinceLastGain[this.index]; }
		public set(float value) { f_CharacterResourcesSinceLastGain[this.index] = value; }
	}

	property TFClassType i_Class
	{
		public get() { return i_CharacterClass[this.index]; }
		public set(TFClassType value)
		{ 
			i_CharacterClass[this.index] = value;

			if (IsValidMulti(this.i_Client))
				TF2_SetPlayerClass(this.i_Client, value);
		}
	}

	property ArrayList g_Effects
	{
		public get() { return g_CharacterEffects[this.index]; }
		public set(ArrayList value) { g_CharacterEffects[this.index] = value; }
	}

	public void SetModel(char[] model)
	{
		strcopy(s_CharacterModel[this.index], PLATFORM_MAX_PATH, model);
	}

	public void GetModel(char[] output, int size)
	{
		strcopy(output, size, s_CharacterModel[this.index]);
	}

	public void SetName(char[] name)
	{
		strcopy(s_CharacterName[this.index], 255, name);
	}

	public void GetName(char[] output, int size)
	{
		strcopy(output, size, s_CharacterName[this.index]);
	}

	public void SetConfigMapPath(char[] path)
	{
		strcopy(s_CharacterConfigMapPath[this.index], PLATFORM_MAX_PATH, path);
	}

	public void GetConfigMapPath(char[] output, int size)
	{
		strcopy(output, size, s_CharacterConfigMapPath[this.index]);
	}

	public void SetArchetype(char[] name)
	{
		strcopy(s_CharacterArchetype[this.index], 255, name);
	}

	public void GetArchetype(char[] output, int size)
	{
		strcopy(output, size, s_CharacterArchetype[this.index]);
	}

	public void SetResourceName(char[] name)
	{
		strcopy(s_CharacterResourceName[this.index], 255, name);
	}

	public void GetResourceName(char[] output, int size)
	{
		strcopy(output, size, s_CharacterResourceName[this.index]);
	}

	public void SetResourceNamePlural(char[] name)
	{
		strcopy(s_CharacterResourceNamePlural[this.index], 255, name);
	}

	public void GetResourceNamePlural(char[] output, int size)
	{
		strcopy(output, size, s_CharacterResourceNamePlural[this.index]);
	}

	public void AddSoundCue(CFSoundCue cue)
	{
		g_CharacterSoundCues[this.index][this.i_NumSoundCues] = cue;
		this.i_NumSoundCues++;
	}

	public void ClearSoundCues()
	{
		for (int i = 0; i < this.i_NumSoundCues; i++)
		{
			CFSoundCue cue = g_CharacterSoundCues[this.index][i];
			if (cue.b_Exists)
				cue.Destroy();
		}

		this.i_NumSoundCues = 0;
	}

	public void DebugCues()
	{
		for (int i = 0; i < this.i_NumSoundCues; i++)
		{
			CFSoundCue cue = g_CharacterSoundCues[this.index][i];
			if (cue.b_Exists)
			{
				char sndCue[255];
				cue.GetCue(sndCue, 255);
				CPrintToChat(this.i_Client, "{yellow}Found sound cue: {green}%s", sndCue);
				cue.DebugSounds(this.i_Client);
			}
		}
	}

	public bool PlaySoundReplacement(char Sound[255])
	{
		StringToLower(Sound);

		for (int i = 0; i < this.i_NumSoundCues; i++)
		{
			CFSoundCue cue = g_CharacterSoundCues[this.index][i];
			if (cue.b_Exists)
			{
				char cueName[255], tempName[255];
				cue.GetCue(cueName, 255);
				Format(tempName, sizeof(tempName), "%s", cueName);
				ReplaceString(tempName, sizeof(tempName), "sound_replace_", "");
				
				if (StrContains(Sound, tempName) != -1)
				{
					return this.PlayRandomSound(cueName);
				}
			}
		}

		return false;
	}

	public bool PlayRandomSound(char[] cue)
	{
		CFSound randSnd = this.GetRandomSound(cue);
		if (randSnd == null)
			return false;

		return randSnd.Play(this.i_Client);
	}

	public CFSound GetRandomSound(char[] cue)
	{
		CFSoundCue sndCue = null;
		for (int i = 0; i < this.i_NumSoundCues; i++)
		{
			char name[255];
			g_CharacterSoundCues[this.index][i].GetCue(name, 255);
			if (StrEqual(name, cue))
			{
				sndCue = g_CharacterSoundCues[this.index][i];
				break;
			}
		}

		if (sndCue == null)
			return null;

		return sndCue.GetRandomSound();
	}

	public void Destroy(bool fullClear = false)
	{
		if (this.g_Effects != null)
		{
			for (int i = 0; i < GetArraySize(this.g_Effects); i++)
			{
				view_as<CFEffect>(GetArrayCell(this.g_Effects, i)).Destroy();
			}

			delete this.g_Effects;
			this.g_Effects = null;
		}

		for (int i = 0; i < 4; i++)
		{
			CFAbility ab = GetAbilityFromClient(this.i_Client, view_as<CF_AbilityType>(i));
			if (ab != null)
				ab.Destroy();
		}

		this.b_ResourceIsUlt = false;
		this.b_ResourceIsPercentage = false;
		this.b_ResourceIsMetal = false;

		this.f_Speed = 0.0;
		this.f_MaxHP = 0.0;
		this.f_Scale = 0.0;
		this.f_BaseSpeed = 0.0;
		this.f_Weight = 0.0;
		this.f_UltChargeOnRegen = 0.0;
		this.f_UltChargeOnHurt = 0.0;
		this.f_UltChargeOnDamage = 0.0;
		this.f_UltChargeOnHeal = 0.0;
		this.f_UltChargeOnKill = 0.0;
		this.f_UltChargeOnBuildingDamage = 0.0;
		this.f_UltChargeOnDestruction = 0.0;
		this.f_ResourcesToTriggerSound = 0.0;
		this.f_ResourcesSinceLastGain = 0.0;
		this.f_ResourceRegenInterval = 0.0;
		this.f_NextResourceRegen = 0.0;
		this.f_ResourcesOnRegen = 0.0;
		this.f_ResourcesOnHurt = 0.0;
		this.f_ResourcesOnDamage = 0.0;
		this.f_ResourcesOnHeal = 0.0;
		this.f_ResourcesOnKill = 0.0;
		this.f_ResourcesOnBuildingDamage = 0.0;
		this.f_ResourcesOnDestruction = 0.0;

		this.SetModel("");
		this.SetName("");
		this.SetConfigMapPath("");
		this.SetResourceName("");
		this.SetResourceNamePlural("");
		this.SetArchetype("");
		this.ClearSoundCues();

		//This is used only for cases where we need to *completely* remove a client's character status, such as on map end or if the client disconnects.
		//Otherwise, we preserve their current ult/resource stats so that we don't lose everything just because we died or switched our character.
		if (fullClear)
		{
			RemoveCharacterFromList(view_as<CFCharacter>(this.index));
			this.i_Client = -1;
			this.f_UltCharge = 0.0;
			this.f_UltChargeRequired = 0.0;
			this.f_Resources = 0.0;
			this.f_MaxResources = 0.0;
			b_CharacterExists[this.index] = false;
		}
	}
}

ArrayList g_Characters = null;

//Same as i_LastSlot but for CFCharacter:
int i_MostRecentCharaSlot[MAXPLAYERS + 1] = { -1, ... };

public CFCharacter GetCharacterFromClient(int client)
{
	if (g_Characters == null)
		return null;

	if (i_MostRecentCharaSlot[client] > -1 && i_MostRecentCharaSlot[client] < GetArraySize(g_Characters))
	{
		CFCharacter chara = view_as<CFCharacter>(GetArrayCell(g_Characters, i_MostRecentCharaSlot[client]));
		if (chara.i_Client == client)
			return chara;
	}

	for (int i = 1; i < GetArraySize(g_Characters); i++)
	{
		CFCharacter chara = view_as<CFCharacter>(GetArrayCell(g_Characters, i));
		if (chara.i_Client == client)
		{
			i_MostRecentCharaSlot[client] = i;
			return chara;
		}
	}

	return null;
}

public void AddCharacterToList(CFCharacter chara)
{ 
	if (chara == null || chara.index < 0 || chara.index > MAXPLAYERS || !chara.b_Exists)
		return;

	if (g_Characters == null)
		g_Characters = CreateArray(255);
		
	PushArrayCell(g_Characters, chara.index);
}

public void RemoveCharacterFromList(CFCharacter chara)
{
	if (g_Characters == null)
		return;

	for (int i = 0; i < GetArraySize(g_Characters); i++)
	{
		if (GetArrayCell(g_Characters, i) == chara.index)
		{
			RemoveFromArray(g_Characters, i);
			break;
		}
	}

	if (GetArraySize(g_Characters) < 1)
	{
		delete g_Characters;
		g_Characters = null;
	}
}

public void CFC_ApplyCharacter(int client, float speed, float maxHP, TFClassType class, char model[255], char name[255], float scale, float weight, char configMapPath[255], char archetype[255])
{
	CFCharacter character = GetCharacterFromClient(client);
	if (character == null)
	{
		character = new CFCharacter();
		character.i_Client = client;
		AddCharacterToList(character);
	}

	character.i_Client = client;
	character.i_Class = class;

	character.f_Speed = speed;
	character.f_BaseSpeed = speed;
	character.f_MaxHP = maxHP;
	character.f_Scale = scale;
	character.f_Weight = weight;

	character.SetModel(model);
	character.SetName(name);
	character.SetConfigMapPath(configMapPath);
	character.SetArchetype(archetype);
}

public void CFC_CreateEffect(int client, ConfigMap subsection, char abNum[255])
{
	CFEffect effect = new CFEffect();

	char plName[255], abName[255];
	subsection.Get("plugin_name", plName, sizeof(plName));
	subsection.Get("ability_name", abName, sizeof(abName));
	int slot = GetIntFromCFGMap(subsection, "slot", -1);

	effect.SetPluginName(plName);
	effect.SetAbilityName(abName);
	effect.SetAbilityIndex(abNum);
	effect.i_AbilitySlot = slot;
	effect.SetArgsAndValues(subsection);

	CFCharacter chara = GetCharacterFromClient(client);
	ArrayList effects = chara.g_Effects;
	if (effects == null)
		effects = CreateArray(255);

	PushArrayCell(effects, effect);
	chara.g_Effects = effects;
}

public void CFC_CreateAbility(int client, ConfigMap subsection, CF_AbilityType type, bool NewChar)
{
	int slot = view_as<int>(type) + 1;

	CFAbility ability = GetAbilityFromClient(client, type);
	if (ability == null)
	{
		ability = new CFAbility();
	}

	ability.i_AbilitySlot = slot;
	ability.i_Type = slot;
	ability.i_Client = client;

	char name[255];
	subsection.Get("name", name, sizeof(name));
	ability.SetName(name);

	ability.b_HeldAbility = GetBoolFromCFGMap(subsection, "held", false);
	ability.f_ResourceCost = GetFloatFromCFGMap(subsection, "cost", 0.0);
		
	ability.f_Scale = GetFloatFromCFGMap(subsection, "max_scale", 0.0);
	ability.b_RequireGrounded = GetBoolFromCFGMap(subsection, "grounded", false);
	ability.b_HeldAbilityBlocksOthers = GetBoolFromCFGMap(subsection, "held_block", false) && ability.b_HeldAbility;
	ability.i_WeaponSlot = GetIntFromCFGMap(subsection, "weapon_slot", -1);
	ability.i_AmmoRequirement = GetIntFromCFGMap(subsection, "ammo", 0);

	if (NewChar)
	{
		ability.i_Stocks = GetIntFromCFGMap(subsection, "starting_stocks", 0);
	}

	ability.i_MaxStocks = GetIntFromCFGMap(subsection, "max_stocks", 0);

	ability.f_Cooldown = GetFloatFromCFGMap(subsection, "cooldown", 0.0);
	float startingCD = GetFloatFromCFGMap(subsection, "starting_cd", 0.0);
	if (ability.i_MaxStocks > 0 && ability.i_MaxStocks <= ability.i_Stocks)
		startingCD = 0.0;
		
	CF_ApplyAbilityCooldown(client, startingCD, type, true, false);

	ability.GetName(name, 255);

	g_Abilities[ability.index] = ability;
}

public void CFC_StoreAbilities(int client, ConfigMap abilities)
{
	ArrayList effects = GetCharacterFromClient(client).g_Effects;
	if (effects != null)
		effects.Clear();

	if (abilities == null)
		return;

	char ab[255];
	Format(ab, sizeof(ab), "ability_1");
	int slot = 1;
	ConfigMap subsection = abilities.GetSection(ab);
	while (subsection != null)
	{
		CFC_CreateEffect(client, subsection, ab);

		slot++;
		Format(ab, sizeof(ab), "ability_%i", slot);
		subsection = abilities.GetSection(ab);
	}
}

//Store configs and names in two separate arrays so we aren't reading every single character's config every single time someone opens the !characters menu:
Handle CF_Characters_Configs;
Handle CF_Characters_Names;
Handle CF_CharacterParticles[MAXPLAYERS + 1] = { null, ... };

ConfigMap Characters;

#if defined USE_PREVIEWS
int i_CFPreviewModel[MAXPLAYERS + 1] = { -1, ... };
int i_PreviewOwner[2049] = { -1, ... };
int i_CFPreviewProp[MAXPLAYERS + 1] = { -1, ... };
int i_CFPreviewWeapon[MAXPLAYERS + 1] = { -1, ... };
float f_CFPreviewRotation[MAXPLAYERS + 1] = { 0.0, ... };
bool b_SpawnPreviewParticleNextFrame[MAXPLAYERS + 1] = { false, ... };
#endif

int i_CharacterParticleOwner[2049] = { -1, ... };
int i_DialogueReduction[MAXPLAYERS + 1] = { 0, ... };
int i_DetailedDescPage[MAXPLAYERS + 1] = { -1, ... };

bool b_DisplayRole = true;
bool b_CharacterApplied[MAXPLAYERS + 1] = { false, ... }; //Whether or not the client's character has been applied to them already. If true: skip MakeCharacter for that client. Set to false automatically on death, round end, disconnect, and if the player changes their character selection.
bool b_ReadingLore[MAXPLAYERS + 1] = { false, ... };
bool b_IsDead[MAXPLAYERS + 1] = { false, ... };
bool b_CharacterParticlePreserved[2049] = { false, ... };
bool b_WearableIsPreserved[2049] = { false, ... };
bool b_FirstSpawn[MAXPLAYERS + 1] = { true, ... };

char s_CharacterConfig[MAXPLAYERS+1][255];	//The config currently used for this player's character. If empty: that player is not a character.
char s_CharacterConfigInMenu[MAXPLAYERS+1][255];	//The config currently used this player's info menu.
char s_PreviousCharacter[MAXPLAYERS+1][255];
//char s_DesiredCharacterConfig[MAXPLAYERS+1][255];	//The config of the character this player will become next time they spawn.
char s_DefaultCharacter[255];

Handle c_DesiredCharacter;

//Queue CF_CharacterParticles[MAXPLAYERS + 1];

public void CFC_Disconnect(int client)
{
	b_FirstSpawn[client] = true;
	CFCharacter chara = GetCharacterFromClient(client);
	if (chara != null)
		chara.Destroy(true);
}

public void CFC_MakeNatives()
{
	CreateNative("CF_GetRoundState", Native_CF_GetRoundState);
	
	CreateNative("CF_GetPlayerConfig", Native_CF_GetPlayerConfig);
	CreateNative("CF_SetPlayerConfig", Native_CF_SetPlayerConfig);
	
	CreateNative("CF_IsPlayerCharacter", Native_CF_IsPlayerCharacter);
	
	CreateNative("CF_GetCharacterClass", Native_CF_GetCharacterClass);
	CreateNative("CF_SetCharacterClass", Native_CF_SetCharacterClass);
	
	CreateNative("CF_GetCharacterMaxHealth", Native_CF_GetCharacterMaxHealth);
	CreateNative("CF_SetCharacterMaxHealth", Native_CF_SetCharacterMaxHealth);
	
	CreateNative("CF_GetCharacterName", Native_CF_GetCharacterName);
	CreateNative("CF_SetCharacterName", Native_CF_SetCharacterName);
	
	CreateNative("CF_GetCharacterModel", Native_CF_GetCharacterModel);
	CreateNative("CF_SetCharacterModel", Native_CF_SetCharacterModel);

	CreateNative("CF_GetCharacterArchetype", Native_CF_GetCharacterArchetype);
	CreateNative("CF_SetCharacterArchetype", Native_CF_SetCharacterArchetype);
	
	CreateNative("CF_GetCharacterSpeed", Native_CF_GetCharacterSpeed);
	CreateNative("CF_SetCharacterSpeed", Native_CF_SetCharacterSpeed);
	
	CreateNative("CF_GetCharacterWeight", Native_CF_GetCharacterWeight);
	CreateNative("CF_SetCharacterWeight", Native_CF_SetCharacterWeight);
	CreateNative("CF_ApplyKnockback", Native_CF_ApplyKnockback);
	
	CreateNative("CF_GetCharacterScale", Native_CF_GetCharacterScale);
	CreateNative("CF_SetCharacterScale", Native_CF_SetCharacterScale);
	
	CreateNative("CF_AttachParticle", Native_CF_AttachParticle);
	CreateNative("CF_AttachWearable", Native_CF_AttachWearable);
	
	CreateNative("CF_GetCharacterBaseSpeed", Native_CF_GetCharacterBaseSpeed);
	
	CreateNative("CF_MakeClientCharacter", Native_CF_MakeClientCharacter);
}

GlobalForward g_OnCharacterCreated;
GlobalForward g_OnCharacterRemoved;

public void CFC_MakeForwards()
{
	CF_Characters_Configs = CreateArray(255);
	CF_Characters_Names = CreateArray(255);
	
	RegConsoleCmd("characters", CFC_OpenMenu, "Opens the Chaos Fortress character selection menu.");
	RegConsoleCmd("character", CFC_OpenMenu, "Opens the Chaos Fortress character selection menu.");
	RegConsoleCmd("setcharacter", CFC_OpenMenu, "Opens the Chaos Fortress character selection menu.");
	RegConsoleCmd("changecharacter", CFC_OpenMenu, "Opens the Chaos Fortress character selection menu.");
	RegConsoleCmd("ch", CFC_OpenMenu, "Opens the Chaos Fortress character selection menu.");
	RegConsoleCmd("cha", CFC_OpenMenu, "Opens the Chaos Fortress character selection menu.");
	RegConsoleCmd("char", CFC_OpenMenu, "Opens the Chaos Fortress character selection menu.");
	RegConsoleCmd("c", CFC_OpenMenu, "Opens the Chaos Fortress character selection menu.");
	
	c_DesiredCharacter = RegClientCookie("DesiredCharacter", "The character this player has chosen to spawn as. If blank: reverts to the default character.", CookieAccess_Private);
	
	#if defined USE_PREVIEWS
	PrecacheModel(MODEL_PREVIEW_DOORS);
	PrecacheModel(MODEL_PREVIEW_STAGE);
	PrecacheModel(MODEL_PREVIEW_UNKNOWN);
	PrecacheSound(SOUND_CHARACTER_PREVIEW);
	#endif
	
	g_OnCharacterCreated = new GlobalForward("CF_OnCharacterCreated", ET_Ignore, Param_Cell);
	g_OnCharacterRemoved = new GlobalForward("CF_OnCharacterRemoved", ET_Ignore, Param_Cell, Param_Cell);
}

public void CFC_OnEntityDestroyed(int entity)
{
	b_CharacterParticlePreserved[entity] = false;
	b_WearableIsPreserved[entity] = false;
}

/**
 * Loads all of the characters from data/chaos_fortress/characters.cfg.
 *
 * @param admin		The client index of the admin who reloaded characters.cfg. If valid: prints the new character list to that admin's console.
 */
 public void CF_LoadCharacters(int admin)
 {
	//if (Characters != null)
 	//	DeleteCfg(Characters);
 		
 	Characters = new ConfigMap("data/chaos_fortress/characters.cfg");
 	
 	if (Characters == null)
 		ThrowError("FATAL ERROR: FAILED TO LOAD data/chaos_fortress/characters.cfg!");
 		
 	bool FoundEnabled = false;
 	
 	#if defined DEBUG_CHARACTER_CREATION
	PrintToServer("//////////////////////////////////////////////////");
	PrintToServer("CHAOS FORTRESS CHARACTERS.CFG DEBUG MESSAGES BELOW");
	PrintToServer("//////////////////////////////////////////////////");
	#endif
 	
 	delete CF_Characters_Configs;
 	CF_Characters_Configs = CreateArray(255);
 	
 	delete CF_Characters_Names;
 	CF_Characters_Names = CreateArray(255);
 	
 	FoundEnabled = CF_CheckPack("characters.Enabled Character Packs", false);
 	CF_CheckPack("characters.Download Character Packs", true);
 	
 	if (!FoundEnabled)
 	{
 		PrintToServer("WARNING: Chaos Fortress was able to locate your characters.cfg file, but it is missing the ''Enabled Character Packs'' block. As a result, your installation of Chaos Fortress has no characters...");
 	}
 	else
 	{
 		CF_BuildCharactersMenu();
 	}
 }
 
 public bool CF_CheckPack(char[] path, bool JustDownload)
 {
 	ConfigMap subsection = Characters.GetSection(path);
 	if (subsection != null)
 	{
 		char value[255];
 		for (int i = 1; i <= subsection.Size; i++)
 		{
 			subsection.GetIntKey(i, value, sizeof(value));
 			
 			#if defined DEBUG_CHARACTER_CREATION
 			if (JustDownload)
 			{
	    		PrintToServer("\nLocated download pack: %s", value);
			}
			else
	    	{
	    		PrintToServer("\nLocated character pack: %s", value);
	    	}
	   		#endif
	   		
	   		CF_LoadCharacterPack(value, JustDownload);
 		}
 		
 		DeleteCfg(subsection);
 		
 		return true;
 	}
	
	DeleteCfg(subsection);
 	return false;
 }
 
 public void CF_LoadCharacterPack(char pack[255], bool JustDownload)
 {
 	char packChar[255];
 	Format(packChar, sizeof(packChar), "characters.%s", pack);
 	
 	ConfigMap Pack = Characters.GetSection(packChar);
 	
 	if (Pack == null)
 	{
 		PrintToServer("WARNING: data/chaos_fortress/characters.cfg defines a character pack titled ''%s'', but no such pack exists inside of the config. Skipping character pack...", pack);
 		return;
 	}
 	
 	#if defined DEBUG_CHARACTER_CREATION
	PrintToServer("\nNow searching character pack ''%s''...", pack);
	#endif
 	
 	char value[255];
 	for (int i = 1; i <= Pack.Size; i++)
 	{
 		Pack.GetIntKey(i, value, sizeof(value));
 		
 		Format(value, sizeof(value), "configs/chaos_fortress/%s.cfg", value);
 		
 		CF_LoadSpecificCharacter(value, JustDownload);
			
		if (!JustDownload)
		{
			PushArrayString(CF_Characters_Configs, value);
		}
			
		//#if defined DEBUG_CHARACTER_CREATION
		PrintToServer("\nLocated character: %s", value);
		//#endif
	}
 }
 
public int CF_GetNumPlayers(char conf[255], int client)
{
	int num = 0;
	for (int i = 0; i <= MaxClients; i++)
	{
		if (i == client || IsValidMulti(i, false, _, true, grabEnemyTeam(client)))
			continue;

		char myConf[255];
		CF_GetPlayerConfig(i, myConf, 255);
		if (StrEqual(conf, myConf))
			num++;
	}

	return num;
}

 public void CF_LoadSpecificCharacter(char path[255], bool JustDownload)
 {
	if (!path[0])
		return;
		
 	ConfigMap Character = new ConfigMap(path);
 	
 	if (Character == null)
 	{
 		PrintToServer("WARNING: One of your character packs enables a character with config ''%s'', but no such character exists in the configs/chaos_fortress directory. Skipping character...", path);
 		return;
 	}
 	
 	char str[255]; //TODO: Abstract this to a native titled CF_GetCharacterName. REMINDER: Would be easiest to just make a native called CF_GetCharacterKV and have this native use that to get the name.
 	Character.Get("character.name", str, sizeof(str));
 	
 	if (b_DisplayRole)
 	{
 		char role[255];		//TODO: Abstract this to a native titled CF_GetCharacterRole.
 		Character.Get("character.menu_display.role", role, sizeof(role));
 		
 		Format(str, sizeof(str), "[%s] %s", role, str);
 	}
 	
 	if (!JustDownload)
 	{
 		PushArrayString(CF_Characters_Names, str);
 	
 		#if defined DEBUG_CHARACTER_CREATION
		PrintToServer("\nConfig ''%s'' has a character name of ''%s''.", path, str);
 		#endif
 	}
 
 	CF_ManageCharacterFiles(Character);
 	DeleteCfg(Character);
 }
 
 public Menu CF_BuildCharactersMenu()
 {
 	Menu menu = new Menu(CFC_Menu);
	menu.SetTitle("Welcome to Chaos Fortress!\nWhich character would you like to spawn as?");
	
	char name[255];
	for (int i = 0; i < GetArraySize(CF_Characters_Names); i++)
	{
		GetArrayString(CF_Characters_Names, i, name, 255);
		
		#if defined DEBUG_CHARACTER_CREATION
		PrintToServer("CREATING CHARACTER MENU: ADDED ITEM ''%s''", name);
		#endif
		
		menu.AddItem("Character", name);
	}

	return menu;
 }
 
public CFC_Menu(Menu menu, MenuAction action, int client, int param)
{	
	if (!IsValidClient(client))
	return;
	
	if (action == MenuAction_Select)
	{
		char conf[255];
		GetArrayString(CF_Characters_Configs, param, conf, 255);

		CFC_BuildInfoMenu(client, conf, false, false, -1);
		delete menu;		
	} 
	else if (action == MenuAction_End)
	{
		#if defined USE_PREVIEWS
		CF_DeletePreviewModel(client);
		#endif
	}
}

#if defined USE_PREVIEWS
public void CF_DeletePreviewModel(int client)
{
	if (!IsValidClient(client))
		return;
		
	if (!CF_PreviewModelActive(client))
		return;
		
	CreateTimer(0.0, Timer_RemoveEntity, i_CFPreviewModel[client], TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.0, Timer_RemoveEntity, i_CFPreviewProp[client], TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.0, Timer_RemoveEntity, i_CFPreviewWeapon[client], TIMER_FLAG_NO_MAPCHANGE);
}
#endif

public Action CFC_OpenMenu(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Continue;
		
	if (GameRules_GetRoundState() == RoundState_GameOver)
	{
		ReplyToCommand(client, "Cannot be used in the post-game, please wait.");
		return Plugin_Continue;
	}
		
	Menu menu = CF_BuildCharactersMenu();
	menu.Display(client, MENU_TIME_FOREVER);
	b_ReadingLore[client] = false;
	i_DetailedDescPage[client] = -1;
	
	#if defined USE_PREVIEWS
	if (!CF_PreviewModelActive(client))
	{
		float spawnLoc[3];
		GetClientEyePosition(client, spawnLoc);
			
		float aimLoc[3];
		Handle trace = getAimTrace(client, CF_DefaultTrace);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(aimLoc, trace);
		}
		CloseHandle(trace);
		
		if (GetVectorDistance(spawnLoc, aimLoc, true) >= 140.0)
		{
			float constraint = 140.0/GetVectorDistance(spawnLoc, aimLoc);
			
			for (int i = 0; i < 3; i++)
			{
				aimLoc[i] = ((aimLoc[i] - spawnLoc[i]) * constraint) + spawnLoc[i];
			}
		}
		
		float ang[3];
		GetClientEyeAngles(client, ang);
		ang[0] = 0.0;
		ang[1] *= -1.0;
		ang[2] = 0.0;
		aimLoc[2] -= 40.0;
		
		char skin[255] = "0";
		if (TF2_GetClientTeam(client) == TFTeam_Blue)
		{
			skin = "1";
		}
		
		int preview = SpawnDummyModel(MODEL_PREVIEW_UNKNOWN, "selection", aimLoc, ang, skin);
		TF2_CreateGlow(preview, 0);
		int text = AttachWorldTextToEntity(preview, "Character Preview", "root", _, _, _, 100.0);
		
		int physProp = CreateEntityByName("prop_physics_override");
			
		if (IsValidEntity(physProp))
		{
			DispatchKeyValue(physProp, "targetname", "droneparent"); 
			DispatchKeyValue(physProp, "spawnflags", "4"); 
			DispatchKeyValue(physProp, "model", "models/props_c17/canister01a.mdl");
				
			DispatchSpawn(physProp);
				
			ActivateEntity(physProp);
			
			DispatchKeyValue(physProp, "Health", "9999999999");
			SetEntProp(physProp, Prop_Data, "m_takedamage", 0, 1);
					
			SetEntPropEnt(physProp, Prop_Data, "m_hOwnerEntity", client);
			SetEntProp(physProp, Prop_Send, "m_fEffects", 32); //EF_NODRAW
			
			aimLoc[2] += 40.0;
			TeleportEntity(physProp, aimLoc, ang, NULL_VECTOR);
			
			//SetEntityMoveType(physProp, MOVETYPE_NOCLIP);
			
			SetVariantString("!activator");
			AcceptEntityInput(preview, "SetParent", physProp);
		 
			SetEntityCollisionGroup(physProp, 0);
			SetEntProp(physProp, Prop_Send, "m_usSolidFlags", 12); 
			SetEntProp(physProp, Prop_Data, "m_nSolidType", 0x0004); 
			SetEntityGravity(physProp, 0.0);
			
			i_CFPreviewProp[client] = EntIndexToEntRef(physProp);
		}
		
		if (IsValidEntity(text))
		{
			i_PreviewOwner[text] = GetClientUserId(client);
			SetEdictFlags(text, GetEdictFlags(text)&(~FL_EDICT_ALWAYS));
			SDKHook(text, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		}
		
		i_PreviewOwner[preview] = GetClientUserId(client);
		
		SetEdictFlags(preview, GetEdictFlags(preview)&(~FL_EDICT_ALWAYS));
		SDKHook(preview, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		
		i_CFPreviewModel[client] = EntIndexToEntRef(preview);
		f_CFPreviewRotation[client] = 0.0;
	}
	else
	{
		int preview = EntRefToEntIndex(i_CFPreviewModel[client]);
		SetEntityModel(preview, MODEL_PREVIEW_UNKNOWN);
		ChangeModelAnimation(preview, "selection", 1.0);
		int wep = EntRefToEntIndex(i_CFPreviewWeapon[client]);
		if (IsValidEntity(wep))
		{
			RemoveEntity(wep);
		}
	}
	#endif
	
	return Plugin_Continue;
}
 
 #if defined USE_PREVIEWS
 public void CF_UpdatePreviewModel(int client)
 {
 	if (!IsValidClient(client))
 		return;
 	
	int preview = EntRefToEntIndex(i_CFPreviewModel[client]);
	int prop = EntRefToEntIndex(i_CFPreviewProp[client]);
	
	float spawnLoc[3];
	GetClientEyePosition(client, spawnLoc);
			
	float aimLoc[3];
	Handle trace = getAimTrace(client, CF_DefaultTrace);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(aimLoc, trace);
	}
	CloseHandle(trace);
		
	if (GetVectorDistance(spawnLoc, aimLoc, true) >= 140.0)
	{
		float constraint = 140.0/GetVectorDistance(spawnLoc, aimLoc);
			
		for (int i = 0; i < 3; i++)
		{
			aimLoc[i] = ((aimLoc[i] - spawnLoc[i]) * constraint) + spawnLoc[i];
		}
	}
		
	float ang[3], DummyAng[3];
	GetClientEyeAngles(client, DummyAng);
	GetAngleToPoint(prop, spawnLoc, DummyAng, ang, 0.0, 0.0, 40.0);
	aimLoc[2] -= 40.0;
		
	char skin[255] = "0";
	if (TF2_GetClientTeam(client) == TFTeam_Blue)
	{
		skin = "1";
	}
	
	if (b_SpawnPreviewParticleNextFrame[client])
	{
		b_SpawnPreviewParticleNextFrame[client] = false;
		
		if (TF2_GetClientTeam(client) == TFTeam_Red)
		{
			int part = SpawnParticle(aimLoc, "teleportedin_red", 2.0);
			i_PreviewOwner[part] = GetClientUserId(client);
			SetEdictFlags(part, GetEdictFlags(part)&(~FL_EDICT_ALWAYS));
			SDKHook(part, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		}
		else
		{
			int part = SpawnParticle(aimLoc, "teleportedin_blue", 2.0);
			i_PreviewOwner[part] = GetClientUserId(client);
			SetEdictFlags(part, GetEdictFlags(part)&(~FL_EDICT_ALWAYS));
			SDKHook(part, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		}
		
		CF_PlayRandomSound(client, client, "sound_selection_preview");
		
		EmitSoundToClient(client, SOUND_CHARACTER_PREVIEW);
	}
	
	aimLoc[2] += 40.0;
	f_CFPreviewRotation[client] += 1.0;
	ang[1] += f_CFPreviewRotation[client];
	PhysProp_MoveToTargetPosition_Preview(prop, client, ang, 600.0);
	//TeleportEntity(preview, NULL_VECTOR, ang, NULL_VECTOR);
	ChangeModelSkin(preview, skin);
 }
 
 public void CFC_OGF()
 {
 	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if (CF_PreviewModelActive(i))
			{
				CF_UpdatePreviewModel(i);
			}
		}
	}
}
 
 public Action CF_PreviewModelTransmit(int entity, int client)
 {
 	SetEdictFlags(entity, GetEdictFlags(entity)&(~FL_EDICT_ALWAYS));
 	if (client != GetClientOfUserId(i_PreviewOwner[entity]))
 	{
 		return Plugin_Handled;
 	}
 		
 	return Plugin_Continue;
 }
 #endif
 
 public Action CFC_ParticleTransmit(int entity, int client)
 {
 	SetEdictFlags(entity, GetEdictFlags(entity)&(~FL_EDICT_ALWAYS));
 	
 	int owner = GetClientOfUserId(i_CharacterParticleOwner[entity]);
 	/*if (!IsValidClient(owner))	//This should never happen so I've removed it for the sake of optimization, if it throws error we know what to re-enable.
 		return Plugin_Handled;*/
 		
 	if (IsPlayerInvis(owner))	//Block the particle if the user is invisible, for obvious reasons...
 		return Plugin_Handled;
 		
 	if (client != owner || (client == owner && (GetEntProp(client, Prop_Send, "m_nForceTauntCam") || TF2_IsPlayerInCondition(client, TFCond_Taunting))))
 		return Plugin_Continue;
 		
 	return Plugin_Handled;
 }
 
 #if defined USE_PREVIEWS
 bool CF_PreviewModelActive(int client)
 {
 	if (!IsValidClient(client))
 		return false;
 		
 	return IsValidEntity(EntRefToEntIndex(i_CFPreviewModel[client])) && IsValidEntity(EntRefToEntIndex(i_CFPreviewProp[client]));
 }
 #endif
 
int i_NumItemsInInfoMenu[MAXPLAYERS + 1] = { 0, ... };

 public void CFC_BuildInfoMenu(int client, char config[255], bool isLore, bool justReading, int detailedDescPage)
 {
 	if (!IsValidClient(client))
		return;
		
	ConfigMap Character = new ConfigMap(config);
	
 	if (Character == null)
 	{
 		PrintToServer("ERROR: Failed to locate config ''%s'' in CFC_BuildInfoMenu.", config);
 		return;
 	}
 	
 	char name[255]; char title[255]; char related[255]; char role[255]; char desc[255]; char model[255] = ""; char lore[255] = ""; char weapon[255]; char attachment[255]; char sequence[255];
 	Character.Get("character.name", name, sizeof(name));
 	Character.Get("character.model", model, sizeof(model));
 	
 	ConfigMap section = Character.GetSection("character.menu_display");
 	if (section == null)
 	{
		DeleteCfg(Character);
 		ConfigMap rules = new ConfigMap("data/chaos_fortress/game_rules.cfg");
 		
 		if (rules == null)		//Don't bother printing an error to the console because this should get thrown in SetGameRules if it's going to get thrown here, unless someone is deliberately deleting server files in which case that's their own fault.
 			return;
 		
 		section = rules.GetSection("game_rules.character_defaults.menu_display");
 		
 		if (section == null)
 		{
 			PrintToServer("ERROR: Character config ''%s'' does not have default menu information, and neither does your game_rules.cfg.");
			DeleteCfg(rules);
 			return;
 		}
 		
 		DeleteCfg(rules);
 	}
 	
 	//Should be impossible to reach this code without a valid section ConfigMap so don't bother doing security checks:
 	section.Get("related_class", related, sizeof(related));
 	section.Get("role", role, sizeof(role));
 	section.Get("description", desc, sizeof(desc));
 	section.Get("preview_weapon", weapon, sizeof(weapon));
 	section.Get("preview_attachment", attachment, sizeof(attachment));
 	section.Get("preview_sequence", sequence, sizeof(sequence));
 	section.Get("lore_description", lore, sizeof(lore));
 	
 	#if defined USE_PREVIEWS
 	if (!StrEqual(model, "") && CheckFile(model) && CF_PreviewModelActive(client) && !justReading)
 	{
 		int preview = EntRefToEntIndex(i_CFPreviewModel[client]);
 		SetEntityModel(preview, model);
 		ChangeModelAnimation(preview, sequence, 1.0);
 		b_SpawnPreviewParticleNextFrame[client] = true;
 		
 		if (!StrEqual(weapon, "") && CheckFile(weapon))
 		{
 			PrecacheModel(weapon);
 			
 			if (StrEqual(attachment, ""))
 			{
 				attachment = "weapon_bone";
 			}
 			
 			char skin[255] = "0";
 			if (TF2_GetClientTeam(client) == TFTeam_Blue)
 			{
 				skin = "1";
 			}
 			
 			float xOff = GetFloatFromCFGMap(section, "attachment_x_offset", 0.0);
 			float yOff = GetFloatFromCFGMap(section, "attachment_y_offset", 0.0);
 			float zOff = GetFloatFromCFGMap(section, "attachment_z_offset", 0.0);
 			float xRot = GetFloatFromCFGMap(section, "attachment_x_rotation", 0.0);
 			float yRot = GetFloatFromCFGMap(section, "attachment_y_rotation", 0.0);
 			float zRot = GetFloatFromCFGMap(section, "attachment_z_rotation", 0.0);
 			
 			int wep = AttachModelToEntity(weapon, attachment, preview, _, skin, xOff, yOff, zOff, xRot, yRot, zRot);
 			if (IsValidEntity(wep))
 			{
 				i_CFPreviewWeapon[client] = EntIndexToEntRef(wep);
 			}
 		}
 		
 		section = Character.GetSection("character.particles");
 		if (section != null)
 		{
 			CFC_DummyParticles(client, preview, section);
 		}
 		
 		section = Character.GetSection("character.wearables");
 		if (section != null)
 		{
 			CFC_DummyWearables(client, preview, section);
 		}
 	}
 	#endif
 	
 	if (!isLore && detailedDescPage < 0)
 	{
		ReplaceString(desc, sizeof(desc), "\\n", "\n");
 		Format(title, sizeof(title), "%s\n\nSimilar TF2 Class: %s\nRole: %s\n\n%s", name, related, role, desc);
 	}
 	else if (isLore)
 	{
		ReplaceString(lore, sizeof(lore), "\\n", "\n");
 		Format(title, sizeof(title), "%s\n\n%s", name, lore);
 	}
	else if (detailedDescPage >= 0)
	{
		char detailedPage[255], path[32];
		Format(path, sizeof(path), "desc_detailed.%i", detailedDescPage + 1);
		section.Get(path, detailedPage, sizeof(detailedPage));

		ReplaceString(detailedPage, sizeof(detailedPage), "\\n", "\n");
 		Format(title, sizeof(title), "%s\n\n%s", name, detailedPage);
	}
 	
 	s_CharacterConfigInMenu[client] = config;
 	
 	Menu menu = new Menu(CFC_InfoMenu);
 	menu.SetTitle(title);
	i_NumItemsInInfoMenu[client] = 0;
 	
 	Format(name, sizeof(name), "Spawn As %s", name);
	int limit = CF_GetCharacterLimit(config);
	bool blocked = CF_GetNumPlayers(config, client) >= limit && limit > 0;
	if (blocked)
	{
		Format(name, sizeof(name), "%s (MAX: %i)", name, limit);
 		CFC_AddItemToInfoMenu(client, menu, "Select", name, ITEMDRAW_DISABLED);
	}
	else
		CFC_AddItemToInfoMenu(client, menu, "Select", name);
 	
 	if (!isLore && detailedDescPage < 0)
 	{
		if (StrEqual(lore, ""))
	 	{
	 		CFC_AddItemToInfoMenu(client, menu, "Lore", "(No Lore)", ITEMDRAW_DISABLED);
	 	}
	 	else
	 	{
	 		CFC_AddItemToInfoMenu(client, menu, "Lore", "View Lore");
	 	}

		if (section.GetSection("desc_detailed") == null)
	 	{
	 		CFC_AddItemToInfoMenu(client, menu, "Detailed Gameplay Description", "(No Detailed Gameplay Description)", ITEMDRAW_DISABLED);
	 	}
	 	else
	 	{
	 		CFC_AddItemToInfoMenu(client, menu, "Detailed Gameplay Description", "View Detailed Gameplay Description");
	 	}
	}
	else if (isLore)
	{
		CFC_AddItemToInfoMenu(client, menu, "Lore", "Return to Overview");
	}
	else if (detailedDescPage >= 0)
	{
		CFC_AddItemToInfoMenu(client, menu, "Detailed Gameplay Description", "Return to Overview");

		CFC_AddItemToInfoMenu(client, menu, "Previous Page", "Previous Page", (detailedDescPage == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT));
		
		char checkSection[255], dummy[32];
		Format(checkSection, sizeof(checkSection), "desc_detailed.%i", detailedDescPage + 2);
		CFC_AddItemToInfoMenu(client, menu, "Next Page", "Next Page", (section.Get(checkSection, dummy, sizeof(dummy)) == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT));
	}
 	
 	CFC_AddItemToInfoMenu(client, menu, "Back", "Main Menu");
 	
 	menu.ExitButton = false;
 	menu.Display(client, MENU_TIME_FOREVER);
 	b_ReadingLore[client] = isLore;
	i_DetailedDescPage[client] = detailedDescPage;
 	
 	DeleteCfg(Character);
 }

void CFC_AddItemToInfoMenu(int client, Menu menu, const char[] info, const char[] display, int style=(0))
{
	menu.AddItem(info, display, style);
	i_NumItemsInInfoMenu[client]++;
}
 
 public CFC_InfoMenu(Menu menu, MenuAction action, int client, int param)
{	
	if (!IsValidClient(client))
	return;
	
	if (action == MenuAction_Select)
	{
		if (param < i_NumItemsInInfoMenu[client] - 1)
		{
			ConfigMap Character = new ConfigMap(s_CharacterConfigInMenu[client]);
			
			if (Character == null)
			{
				PrintToServer("ERROR: Somehow, an invalid character config (%s) was added to the !characters menu.", s_CharacterConfigInMenu[client]);
				CPrintToChat(client, "{indigo}[Chaos Fortress] {crimson}ERROR: {default}Somehow, an invalid character config {olive}(%s){default} was added to the !characters menu. This should be impossible. Please inform your server's developer.", s_CharacterConfigInMenu[client]);
				return;
			}
			
			//This should eventually get replaced with a switch statement. Lazy.
			//The first button is ALWAYS the one to confirm to spawn as this character.
			if (param == 0)
			{
				char name[255];
				Character.Get("character.name", name, sizeof(name));
				Format(name, sizeof(name), "{indigo}[Chaos Fortress] {default}You will respawn as {olive}%s{default}.", name);
				CPrintToChat(client, name);
				
				SetClientCookie(client, c_DesiredCharacter, s_CharacterConfigInMenu[client]);
				b_CharacterApplied[client] = false;
					
				#if defined USE_PREVIEWS
				CF_DeletePreviewModel(client);
				#endif
			}
			else if (param == 1)	//While at the beginning of the info menu, this button will enter the lore page. If you are reading lore or the detailed description, this button returns you to the overview.
			{
				CFC_BuildInfoMenu(client, s_CharacterConfigInMenu[client], (!b_ReadingLore[client] && i_DetailedDescPage[client] < 0), true, -1);
			}
			else if (param == 2)	//While at the beginning of the info menu, this button will enter the detailed description. If already reading the detailed description, it goes back by one page.
			{
				i_DetailedDescPage[client]--;
				if (i_DetailedDescPage[client] < 0)
					i_DetailedDescPage[client] = 0;

				CFC_BuildInfoMenu(client, s_CharacterConfigInMenu[client], (!b_ReadingLore[client] && i_DetailedDescPage[client] < 0), true, i_DetailedDescPage[client]);
			}
			else if (param == 3)	//This is only used for navigating the detailed description, it is the "next page" button.
			{
				CFC_BuildInfoMenu(client, s_CharacterConfigInMenu[client], (!b_ReadingLore[client] && i_DetailedDescPage[client] < 0), true, i_DetailedDescPage[client] + 1);
			}
			
			DeleteCfg(Character);
		}
		else
		{
			CFC_OpenMenu(client, 0);
		}

		delete menu;	
	}
	else if (action == MenuAction_End || action == MenuAction_Cancel)
	{
		#if defined USE_PREVIEWS
		CF_DeletePreviewModel(client);
		#endif
	}
}

 
/**
 * Precaches all of the files in the "downloads", "model_download", and "precache" sections of a given CFG, and adds all files in the former two to the downloads table.
 */
 public void CF_ManageCharacterFiles(ConfigMap Character)
 {
 	ConfigMap section = Character.GetSection("character.model_download");
 	if (section != null)
 	{
 		CF_DownloadAndPrecacheModels(section);
 	}
 	
 	section = Character.GetSection("character.downloads");
 	if (section != null)
 	{
 		CF_DownloadFiles(section);
 	}
 	
 	section = Character.GetSection("character.precache");
 	if (section != null)
 	{
 		CF_PrecacheFiles(section);
 	}
 }
 
 public void CF_DownloadAndPrecacheModels(ConfigMap subsection)
 {
 	char value[255];
 	
 	for (int i = 1; i <= subsection.Size; i++)
 	{
 		subsection.GetIntKey(i, value, sizeof(value));
 			
 		char fileCheck[255], actualFile[255];
				
		for (int j = 0; j < sizeof(s_ModelFileExtensions); j++)
		{
			Format(fileCheck, sizeof(fileCheck), "models/%s%s", value, s_ModelFileExtensions[j]);
			Format(actualFile, sizeof(actualFile), "%s%s", value, s_ModelFileExtensions[j]);
			if (CheckFile(fileCheck))
			{
				if (StrEqual(s_ModelFileExtensions[j], ".mdl"))
				{
					#if defined DEBUG_CHARACTER_CREATION
					int check = PrecacheModel(fileCheck);
					
					if (check != 0)
					{
						PrintToServer("Successfully precached file ''%s''.", fileCheck);
					}
					else
					{
						PrintToServer("Failed to precache file ''%s''.", fileCheck);
					}
					#else
					PrecacheModel(fileCheck);
					#endif
				}

				AddFileToDownloadsTable(fileCheck);
						
				#if defined DEBUG_CHARACTER_CREATION
				PrintToServer("Successfully added model file ''%s'' to the downloads table.", fileCheck);
				#endif
			}
			else
			{
				#if defined DEBUG_CHARACTER_CREATION
				PrintToServer("ERROR: Failed to find model file ''%s''.", fileCheck);
				#endif
			}
		}
	}
 }
 
 public void CF_DownloadFiles(ConfigMap subsection)
 {
 	char value[255];
 	
 	for (int i = 1; i <= subsection.Size; i++)
 	{
 		subsection.GetIntKey(i, value, sizeof(value));
 			
 		char actualFile[255];
 		
 		if (CheckFile(value))
		{
			AddFileToDownloadsTable(value);
			
			if (StrContains(value, "sound") == 0)
			{
				for (int j = 6; j < sizeof(value); j++)	//Write the path to the sound without the "sound/" to a new string so we can precache it.
				{
					actualFile[j - 6] = value[j];
				}

				#if defined DEBUG_CHARACTER_CREATION
				bool succeeded = PrecacheSound(actualFile);
				
				if (succeeded)
				{
					PrintToServer("Successfully precached file ''%s''.", actualFile);
				}
				else
				{
					PrintToServer("Failed to precache file ''%s''.", actualFile);
				}
				#else
				PrecacheSound(actualFile);
				#endif
			}
			
			#if defined DEBUG_CHARACTER_CREATION
			PrintToServer("Successfully added file ''%s'' to the downloads table.", value);
			#endif
		}
		else
		{
			#if defined DEBUG_CHARACTER_CREATION
			PrintToServer("ERROR: Failed to find file ''%s''.", value);
			#endif
		}
	}
 }

 public void CF_PrecacheFiles(ConfigMap subsection)
 {
 	char value[255];
 	
 	for (int i = 1; i <= subsection.Size; i++)
 	{
 		subsection.GetIntKey(i, value, sizeof(value));
 		
 		char file[255];
				
		bool exists = false;
				
		Format(file, sizeof(file), "models/%s", value);
				
				
		if (CheckFile(file))
		{
			exists = true;
					
			#if defined DEBUG_CHARACTER_CREATION
			int check = PrecacheModel(file);
			if (check != 0)
			{
				PrintToServer("Successfully precached file ''%s''.", file);
			}
			else
			{
				PrintToServer("Failed to precache file ''%s''.", file);
			}
			#else
			PrecacheModel(file);
			#endif
		}
		else
		{
			Format(file, sizeof(file), "sound/%s", value);
					
			if (CheckFile(file))
			{
				exists = true;
					
				#if defined DEBUG_CHARACTER_CREATION
				bool check = PrecacheSound(value);
				if (check)
				{
					PrintToServer("Successfully precached file ''%s''.", file);
				}
				else
				{
					PrintToServer("Failed to precache file ''%s''.", file);
				}
				#else
				PrecacheSound(value);
				#endif
			}
		}
				
		if (!exists)
		{
			#if defined DEBUG_CHARACTER_CREATION
			PrintToServer("Failed to find file ''%s''.", file);
			#endif
		}
	}
}

public void CF_OnRoundStateChanged(int state)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (state == 0)
			b_CharacterApplied[i] = false;
		if (state == 2)
		{
			if (!GetPreserveUlt())
				CF_SetUltCharge(i, 0.0, true);
		}
	}
}

public void CF_ResetMadeStatus(int client)
{
	if (client >= 1 && client <= MaxClients)
	{
		b_CharacterApplied[client] = false;
	}
}

public void CFC_MapEnd()
{
	delete CF_Characters_Configs;
	delete CF_Characters_Names;

	for (int i = 0; i <= MaxClients; i++)
	{
		delete CF_CharacterParticles[i];
	}

	if (Characters != null)
	{
		delete Characters;
		Characters = null;
	}
}

public void CF_DestroyAllBuildings(int client)
{
	DestroyAllBuildings(client, "obj_sentrygun", false);
	DestroyAllBuildings(client, "obj_dispenser", false);
	DestroyAllBuildings(client, "obj_teleporter", false);
}

/**
 * Turns a player into their selected Chaos Fortress character, or the default specified in game_rules if they haven't chosen.
 *
 * @param client				The client to convert.
 * @param callForward			Set to true to call the OnCharacterCreated forward.
 * @param ForceNewCharStatus	Set to true to force this event to treat the player as if they have swapped to a new character.
 * @param ForcedCharacter 		Set to the full path of a character's CFG to force the player to become a specific character.
 * @param message				Optional message to be printed to the client's screen.
 */
 void CF_MakeCharacter(int client, bool callForward = true, bool ForceNewCharStatus = false, char ForcedCharacter[255] = "", char message[255] = "")
 {
 	if (!IsValidClient(client) || !IsPlayerAlive(client))
 		return;

	EndHeldAbility(client, CF_AbilityType_M2, true, true);
	EndHeldAbility(client, CF_AbilityType_M3, true, true);
	EndHeldAbility(client, CF_AbilityType_Reload, true, true);

	char conf[255];
	GetClientCookie(client, c_DesiredCharacter, conf, sizeof(conf));
	
	if (CF_CharacterExists(ForcedCharacter))
		conf = ForcedCharacter;
		
	if (!CF_CharacterExists(conf) || IsFakeClient(client))
	{
		if (!CF_CharacterExists(s_DefaultCharacter) || IsFakeClient(client))	//Choose a random character if the default character does not exist, or the client is a bot
		{
			GetArrayString(CF_Characters_Configs, GetRandomInt(0, GetArraySize(CF_Characters_Configs) - 1), conf, sizeof(conf));
		}
		else
		{
			conf = s_DefaultCharacter;
		}
	}
	
	ConfigMap map = new ConfigMap(conf);
	if (map == null)
		return;
		
	bool ConfigsAreDifferent = !StrEqual(conf, s_PreviousCharacter[client]);
	if (ConfigsAreDifferent)
		CF_DestroyAllBuildings(client);

	//CF_UnmakeCharacter(client, false, _, false);
	bool IsNewCharacter = ConfigsAreDifferent || b_IsDead[client] || b_FirstSpawn[client] || ForceNewCharStatus;
	if (IsNewCharacter)
		CF_UnmakeCharacter(client, true, ConfigsAreDifferent ? CF_CRR_SWITCHED_CHARACTER : CF_CRR_RESPAWNED);
		
	CF_SetPlayerConfig(client, conf);
	SetClientCookie(client, c_DesiredCharacter, conf);
		
	char model[255], name[255], arms[255], archetype[255]/*, animator[255]*/;
	map.Get("character.model", model, sizeof(model));
	map.Get("character.name", name, sizeof(name));
	map.Get("character.arms", arms, sizeof(arms));
	map.Get("character.menu_display.role", archetype, sizeof(archetype));
	//map.Get("character.animator_model", animator, sizeof(animator));
	float speed = GetFloatFromCFGMap(map, "character.speed", 300.0);
	float health = GetFloatFromCFGMap(map, "character.health", 250.0);
	float weight = GetFloatFromCFGMap(map, "character.weight", 0.0);
	int class = GetIntFromCFGMap(map, "character.class", 1) - 1;
	i_DialogueReduction[client] = GetIntFromCFGMap(map, "character.be_quiet", 1);
	float scale = GetFloatFromCFGMap(map, "character.scale", 1.0);
	
	CFC_ApplyCharacter(client, speed, health, Classes[class], model, name, scale, weight, conf, archetype);

	ConfigMap abilities = map.GetSection("character.abilities");
	if (abilities != null)
		CFC_StoreAbilities(client, abilities);

	ConfigMap sounds = map.GetSection("character.sounds");
	if (sounds != null)
		CFS_CreateSounds(client, sounds);
		
	ConfigMap GameRules = new ConfigMap("data/chaos_fortress/game_rules.cfg");
	
	int entity;
	while((entity = FindEntityByClassname(entity, "tf_wearable")) != -1)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if (owner == client)
		{
			TF2_RemoveWearable(owner, entity);
		}
	}
	
	entity = -1;
	while((entity = FindEntityByClassname(entity, "tf_wearable_*")) != -1)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if (owner == client)
		{
			TF2_RemoveWearable(owner, entity);
		}
	}
	
	if (CheckFile(model))
	{
		SetVariantString(model);
		AcceptEntityInput(client, "SetCustomModelWithClassAnimations");
		
		/*if (CheckFile(animator))
		{
			DataPack pack = new DataPack();
			WritePackCell(pack, GetClientUserId(client));
			WritePackString(pack, animator);
			WritePackString(pack, model);
			RequestFrame(CFA_ApplyAnimatorOnDelay, pack);
		}*/
	}
	
	CF_SetCharacterScale(client, scale, CF_StuckMethod_DelayResize, "");
	
	ConfigMap wearables = map.GetSection("character.wearables");
	if (wearables == null)
	{
		wearables = GameRules.GetSection("game_rules.character_defaults.wearables");
	}
		
	if (wearables != null)
	{
		CFC_GiveWearables(client, wearables);
	}
	SDKCall_RecalculatePlayerBodygroups(client);
	
	ConfigMap weapons = map.GetSection("character.weapons");
	if (weapons == null)
	{
		weapons = GameRules.GetSection("game_rules.character_defaults.weapons");
	}
	
	if (weapons != null)
	{
		CFC_GiveWeapons(client, weapons);
	}
	
	CFCharacter chara = GetCharacterFromClient(client);
	TF2_SetPlayerClass(client, chara.i_Class);
	CF_UpdateCharacterHP(client, chara.i_Class, true);
	CF_UpdateCharacterSpeed(client, TF2_GetPlayerClass(client));
	
	ConfigMap particles = map.GetSection("character.particles");
	if (particles != null)
	{
		CFC_AttachParticles(client, particles, IsNewCharacter);
	}
 	
 	if (!StrEqual(conf, s_PreviousCharacter[client]))	//We are respawning as a new character, default to spawn_intro
 	{
 		bool played = CF_PlayRandomSound(client, client, "sound_spawn_intro");
 		if (!played)
 			CF_PlayRandomSound(client, client, "sound_spawn_neutral");
 		
 		CFA_ReduceUltCharge_CharacterSwitch(client);
 	}
 	else if (b_IsDead[client])
 	{
 		bool played = false;
 		
 		switch(CF_GetCharacterEmotion(client))
 		{
 			case CF_Emotion_Angry:
 			{
 				played = CF_PlayRandomSound(client, client, "sound_spawn_angry");
 			}
 			case CF_Emotion_Happy:
 			{
 				played = CF_PlayRandomSound(client, client, "sound_spawn_happy");
 			}
 		}
 		
 		if (!played)
 			CF_PlayRandomSound(client, client, "sound_spawn_neutral");
 	}
 	
 	if (!StrEqual(message, ""))
 	{
 		int r = 255;
	 	int b = 120;
	 	if (TF2_GetClientTeam(client) == TFTeam_Blue)
	 	{
	 		b = 255;
	 		r = 120;
	 	}
	 	
	 	SetHudTextParams(-1.0, 0.25, 5.0, r, 120, b, 255, 0, 5.0, 0.8, 0.4);
	 	ShowHudText(client, -1, message, name);
	}
 	
	bool hasUlt = CFA_InitializeUltimate(client, map, IsNewCharacter);
	bool hasAbilities = CFA_InitializeAbilities(client, map, IsNewCharacter);
		
	CFA_ToggleHUD(client, hasUlt || hasAbilities);
 	CF_SetHUDColor(client, 255, 255, 255, 255);
 	
 	b_CharacterApplied[client] = true;
 	b_IsDead[client] = false;
 	s_PreviousCharacter[client] = conf;
 	
	DeleteCfg(map);
 	DeleteCfg(GameRules);
 	
 	CFA_UpdateMadeCharacter(client);
	CF_SetRespawnTime(client);
 	
 	b_FirstSpawn[client] = false;
 	
 	if (callForward)
 	{
	 	Call_StartForward(g_OnCharacterCreated);
	 	
	 	Call_PushCell(client);
	 	
	 	Call_Finish();
	 }
 }
 
 //Shortened is set to true if the character is located using ONLY their config name and not the full path.
 bool CF_CharacterExists(char conf[255], bool &shortened = false)
 {
 	if (StrEqual(conf, ""))
 		return false;
 		
 	for (int i = 0; i < GetArraySize(CF_Characters_Configs); i++)
 	{
 		char item[255];
 		GetArrayString(CF_Characters_Configs, i, item, sizeof(item));
 		
 		if (!StrEqual(item, conf))
 		{
 			char copy[255];
			Format(copy, sizeof(copy), "configs/chaos_fortress/%s.cfg", conf);
		
			if (StrEqual(item, copy))
			{
				shortened = true;
				return true;
			}
 		}
 		else
 		{
 			return true;
 		}
 	}
 	
 	return false;
 }
 
 #if defined USE_PREVIEWS
 public void CFC_DummyWearables(int client, int entity, ConfigMap wearables)
 {
	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "wearable_%i", i);
		
	ConfigMap subsection = wearables.GetSection(secName);
	while (subsection != null)
	{
		char classname[255], atts[255];
		
		subsection.Get("classname", classname, sizeof(classname));
		int index = GetIntFromCFGMap(subsection, "index", 0);
		subsection.Get("attributes", atts, sizeof(atts));
		bool visible = GetBoolFromCFGMap(subsection, "visible", true);
		int paint = GetIntFromCFGMap(subsection, "paint", -1);
		//TODO: Maybe add support for wearable scale?
		
		int hat = CreateWearable(client, index, atts, paint, visible, 0.0, true);
		int wearable = CreateEntityByName("prop_dynamic_override");
		if (IsValidEntity(hat) && IsValidEntity(wearable))
		{
       	 	SetEntProp(wearable, Prop_Send, "m_nModelIndex", GetEntProp(hat, Prop_Send, "m_nModelIndex"));
			RemoveEntity(hat);
			DispatchSpawn(wearable);
			
			SetEntProp(wearable, Prop_Send, "m_fEffects", 1|512);
			SetEntityMoveType(wearable, MOVETYPE_NONE);
			SetEntProp(wearable, Prop_Data, "m_nNextThinkTick", -1.0);
			SetEntityCollisionGroup(wearable, 0);
			
			if (TF2_GetClientTeam(client) == TFTeam_Blue)
			{
				DispatchKeyValue(wearable, "skin", "1");
			}
			else
			{
				DispatchKeyValue(wearable, "skin", "0");
			}
			
			SetVariantString("!activator");
			AcceptEntityInput(wearable, "SetParent", entity);
		
			i_PreviewOwner[wearable] = GetClientUserId(client);
			//SetEdictFlags(wearable, GetEdictFlags(wearable)&(~FL_EDICT_ALWAYS));
			SDKHook(wearable, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		}
		
		i++;
		Format(secName, sizeof(secName), "wearable_%i", i);
		delete subsection;
		subsection = wearables.GetSection(secName);
	}
 }
 #endif
 
 public void CFC_GiveWearables(int client, ConfigMap wearables)
 {
	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "wearable_%i", i);
		
	ConfigMap subsection = wearables.GetSection(secName);
	while (subsection != null)
	{
		char classname[255], atts[255];
		
		subsection.Get("classname", classname, sizeof(classname));
		int index = GetIntFromCFGMap(subsection, "index", 0);
		subsection.Get("attributes", atts, sizeof(atts));
		bool visible = GetBoolFromCFGMap(subsection, "visible", true);
		int paint = GetIntFromCFGMap(subsection, "paint", -1);
		int style = GetIntFromCFGMap(subsection, "style", 0);
		//TODO: Maybe add support for wearable scale?
		
		CF_AttachWearable(client, index, classname, visible, paint, style, false, atts, 0.0);
		
		i++;
		Format(secName, sizeof(secName), "wearable_%i", i);
		subsection = wearables.GetSection(secName);
	}
 }
 
 public void CFC_GiveWeapons(int client, ConfigMap weapons)
 {
 	TF2_RemoveAllWeapons(client);
 	
 	/*for (int i = 1; i <= 5; i++)	//Extra security measure. Also guarantees items like engineer's PDAs and spy's sapper get removed, which TF2_RemoveAllWeapons does not do.
 	{
 		TF2_RemoveWeaponSlot(client, i);
 	}*/
		
	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "weapon_%i", i);
		
	ConfigMap subsection = weapons.GetSection(secName);
	while (subsection != null)
	{
		char classname[255], attributes[255], override[255], icon[255];
		subsection.Get("classname", classname, sizeof(classname));
		subsection.Get("kill_icon", icon, sizeof(icon));
			
		int index = GetIntFromCFGMap(subsection, "index", 1);
		int level = GetIntFromCFGMap(subsection, "level", 77);
		int quality = GetIntFromCFGMap(subsection, "quality", 7);
		int slot = GetIntFromCFGMap(subsection, "slot", 0);
		int reserve = GetIntFromCFGMap(subsection, "reserve", 0);
		int clip = GetIntFromCFGMap(subsection, "clip", 0);
		int ForceClass = GetIntFromCFGMap(subsection, "force_class", 0);
			
		subsection.Get("attributes", attributes, sizeof(attributes));
			
		bool visible = GetBoolFromCFGMap(subsection, "visible", true);
		if (visible)
		{
			subsection.Get("model_override", override, sizeof(override));
		}
		bool unequip = GetBoolFromCFGMap(subsection, "unequip", true);
			
		char fireAbility[255], firePlugin[255], fireSound[255], fireSlot[255];
		subsection.Get("fire_ability", fireAbility, 255);
		subsection.Get("fire_plugin", firePlugin, 255);
		subsection.Get("fire_sound", fireSound, 255);
		subsection.Get("fire_slot", fireSlot, 255);
			
		int weapon = CF_SpawnWeapon(client, classname, index, level, quality, slot, reserve, clip, attributes, fireSlot, visible, unequip, ForceClass, true, fireAbility, firePlugin, fireSound, false);
		if (IsValidEntity(weapon))
		{
			ConfigMap custAtts = subsection.GetSection("custom_attributes");
			if (custAtts != null)
			{
				StringMapSnapshot snap = custAtts.Snapshot();
				
				for (int j = 0; j < snap.Length; j++)
				{
					char custAtt[255], custVal[255];
					snap.GetKey(j, custAtt, sizeof(custAtt));
					custAtts.Get(custAtt, custVal, sizeof(custVal));
					
					TF2CustAttr_SetString(weapon, custAtt, custVal);
					TF2Attrib_SetFromStringValue(weapon, custAtt, custVal);
				}
				
				delete snap;
			}

			EquipPlayerWeapon(client, weapon);
			CF_SetWeaponKillIcon(weapon, icon);
		}
		
		i++;
		Format(secName, sizeof(secName), "weapon_%i", i);
		subsection = weapons.GetSection(secName);
	}
 }
 
 void CFC_DeleteParticles(int client, bool IgnorePreserve = false)
 {
 	if (!IsValidClient(client))
 		return;
 		
 	if (CF_CharacterParticles[client] == null)
		return;
 		
 	for (int i = 0; i < GetArraySize(CF_CharacterParticles[client]); i++)
 	{
 		int part = EntRefToEntIndex(GetArrayCell(CF_CharacterParticles[client], i));
 		bool RemoveIt = false;
 		
 		if (IsValidEntity(part))
 		{
 			if (IgnorePreserve || !b_CharacterParticlePreserved[part])
 			{
 				RemoveIt = true;
 				RemoveEntity(part);
 			}
 		}
 		else
 			RemoveIt = true;
 			
 		if (RemoveIt)
 		{
 			RemoveFromArray(CF_CharacterParticles[client], i);
 			i--;
 		}
 	}
 	
 	if (GetArraySize(CF_CharacterParticles[client]) < 1)
 		delete CF_CharacterParticles[client];
 }
 
 #if defined USE_PREVIEWS
 public void CFC_DummyParticles(int client, int entity, ConfigMap particles)
 {
 	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "particle_%i", i);
		
	ConfigMap subsection = particles.GetSection(secName);
	while (subsection != null)
	{
		char partName[255]; char point[255];
		if (TF2_GetClientTeam(client) == TFTeam_Red)
		{
			subsection.Get("name_red", partName, sizeof(partName));
		}
		else
		{
			subsection.Get("name_blue", partName, sizeof(partName));
		}
		
		subsection.Get("point", point, sizeof(point));
		
		float xOff = GetFloatFromCFGMap(subsection, "x_offset", 0.0);
		float yOff = GetFloatFromCFGMap(subsection, "y_offset", 0.0);
		float zOff = GetFloatFromCFGMap(subsection, "z_offset", 0.0);
		
		int part = AttachParticleToEntity(entity, partName, point, 0.0, xOff, yOff, zOff);
		i_PreviewOwner[part] = GetClientUserId(client);
		SetEdictFlags(part, GetEdictFlags(part)&(~FL_EDICT_ALWAYS));
		SDKHook(part, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		
		i++;
		Format(secName, sizeof(secName), "particle_%i", i);
		delete subsection;
		subsection = particles.GetSection(secName);
	}
 }
 #endif
 
 public void CFC_AttachParticles(int client, ConfigMap particles, bool IgnorePreserve)
 {
 	CFC_DeleteParticles(client, IgnorePreserve);
 	
 	if (CF_CharacterParticles[client] == null)
 		CF_CharacterParticles[client] = CreateArray(16);
 	
 	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "particle_%i", i);
		
	ConfigMap subsection = particles.GetSection(secName);
	while (subsection != null)
	{
		char partName[255]; char point[255];
		if (TF2_GetClientTeam(client) == TFTeam_Red)
		{
			subsection.Get("name_red", partName, sizeof(partName));
		}
		else
		{
			subsection.Get("name_blue", partName, sizeof(partName));
		}
		
		subsection.Get("point", point, sizeof(point));
		
		float xOff = GetFloatFromCFGMap(subsection, "x_offset", 0.0);
		float yOff = GetFloatFromCFGMap(subsection, "y_offset", 0.0);
		float zOff = GetFloatFromCFGMap(subsection, "z_offset", 0.0);
		
		CF_AttachParticle(client, partName, point, false, 0.0, xOff, yOff, zOff);
		
		i++;
		Format(secName, sizeof(secName), "particle_%i", i);
		subsection = particles.GetSection(secName);
	}
 }
 
 public void CF_OnPlayerKilled(int victim, int inflictor, int attacker, int deadRinger)
 {
 	if (victim > 0 && victim <= MaxClients && !deadRinger)
 	{
 		b_IsDead[victim] = true;
 	}
 }
 
 public void CF_UpdateCharacterHP(int client, TFClassType class, bool spawn)
 {
 	if (!IsValidClient(client))
 		return;
 	
 	int num = 0;
 	while (Classes[num] != class)
 	{
 		num++;
 	}
 	
 	if (num > 8)
 		return;
 	
 	float maxHP = CF_GetCharacterMaxHealth(client);
 	float deduction = f_ClassBaseHP[num];
 	float health = maxHP - deduction;
 	
 	TF2Attrib_RemoveByDefIndex(client, 125);
 	TF2Attrib_RemoveByDefIndex(client, 26);
 	
	if (health < 0.0)
	{
		TF2Attrib_SetByDefIndex(client, 125, -health);
	}
	else
	{
		TF2Attrib_SetByDefIndex(client, 26, health);
	}
	
	if (spawn)
	{
		DataPack pack = new DataPack();
		RequestFrame(CF_GiveMaxHP, pack);
		WritePackCell(pack, client);
		WritePackCell(pack, RoundFloat(maxHP));
	}
 }
 
 public void CF_UpdateCharacterSpeed(int client, TFClassType class)
 {
 	if (!IsValidClient(client))
 		return;
 	
 	int num = 0;
 	while (Classes[num] != class)
 	{
 		num++;
 	}
 	
 	if (num > 8)
 		return;
 		
 	float targSpd = GetCharacterFromClient(client).f_Speed;
 	float baseSpd = f_ClassBaseSpeed[num];
 	float speed = targSpd / baseSpd;
 	
 	TF2Attrib_RemoveByDefIndex(client, 54);
 	TF2Attrib_RemoveByDefIndex(client, 107);
 	
	if (speed < 1.0)
	{
		TF2Attrib_SetByDefIndex(client, 54, speed);
	}
	else
	{
		TF2Attrib_SetByDefIndex(client, 107, speed);
	}
 }
 
 public void CF_GiveMaxHP(DataPack pack)
 {
 	ResetPack(pack);
 	int client = ReadPackCell(pack);
 	int hp = ReadPackCell(pack);
 	delete pack;
 	
 	if (IsValidClient(client))
 		SetEntProp(client, Prop_Send, "m_iHealth", hp);
 }
 
 public any Native_CF_GetCharacterMaxHealth(Handle plugin, int numParams)
 {
 	int client = GetNativeCell(1);
 	
 	if (!CF_IsPlayerCharacter(client))
 		return 0.0;
 		
 	return GetCharacterFromClient(client).f_MaxHP;
 }
 
 public Native_CF_SetCharacterMaxHealth(Handle plugin, int numParams)
 {
 	int client = GetNativeCell(1);
 	float NewMax = GetNativeCell(2);

 	if (CF_IsPlayerCharacter(client))
 	{
		CFCharacter chara = GetCharacterFromClient(client);
 		chara.f_MaxHP = NewMax;
 		CF_UpdateCharacterHP(client, chara.i_Class, false);
 	}
 }
 
 public any Native_CF_GetCharacterWeight(Handle plugin, int numParams)
 {
 	int client = GetNativeCell(1);
 	
 	if (!CF_IsPlayerCharacter(client))
 		return 0.0;
 		
 	return GetCharacterFromClient(client).f_Weight;
 }
 
 public Native_CF_SetCharacterWeight(Handle plugin, int numParams)
 {
 	int client = GetNativeCell(1);
 	float NewWeight = GetNativeCell(2);

 	if (CF_IsPlayerCharacter(client))
 		GetCharacterFromClient(client).f_Weight = NewWeight;
 }
 
 public Native_CF_ApplyKnockback(Handle plugin, int numParams)
 {
 	int client = GetNativeCell(1);
 	float force = GetNativeCell(2);
 	float angles[3];
 	GetNativeArray(3, angles, sizeof(angles));
 	bool IgnoreWeight = GetNativeCell(4);
 	bool IgnoreQuickFix = GetNativeCell(5);
 	bool IgnoreInvuln = GetNativeCell(6);
 	bool OverrideCurrentVelocity = GetNativeCell(7);
 	
 	if ((!IgnoreQuickFix && TF2_IsPlayerInCondition(client, TFCond_MegaHeal)) || (!IgnoreInvuln && IsInvuln(client)))
 		return;
 		
 	if (!IgnoreWeight)
 	{
 		force *= 1.0 - (CF_GetCharacterWeight(client));
 		if (force <= 0.0)
 			return;
 	}
 	
 	float buffer[3], vel[3];
 	GetAngleVectors(angles, buffer, NULL_VECTOR, NULL_VECTOR);
 	for (int i = 0; i < 3; i++)
 		vel[i] = buffer[i] * force;

	if (GetEntityFlags(client) & FL_ONGROUND != 0)
	{
		vel[2] += 200.0;
	}
 		
 	if (OverrideCurrentVelocity)
 		TeleportEntity(client, _, _, vel);
 	else
 	{
 		float clientVel[3];
 		GetEntPropVector(client, Prop_Data, "m_vecVelocity", clientVel);
 		
 		for (int i = 0; i < 3; i++)
 			clientVel[i] += vel[i];
 			
 		TeleportEntity(client, _, _, clientVel);
 	}
 }
 
/**
 * Disables the player's active Chaos Fortress character.
 *
 * @param client			The client to disable.
 * @param isCharacterChange			Is this just a character change? If true: reduce ultimate charge instead of completely removing it.
 * @param reason			The reason the player's character is being unmade.
 */
 void CF_UnmakeCharacter(int client, bool isCharacterChange, CF_CharacterRemovalReason reason = CF_CRR_GENERIC, bool CallForward = true)
 {
	if (CallForward)
	{
		Call_StartForward(g_OnCharacterRemoved);
		
		Call_PushCell(client);
		Call_PushCell(reason);
		
		Call_Finish();
	}
 	
 	CF_UnblockAbilitySlot(client, CF_AbilityType_Ult);
 	CF_UnblockAbilitySlot(client, CF_AbilityType_M2);
 	CF_UnblockAbilitySlot(client, CF_AbilityType_M3);
 	CF_UnblockAbilitySlot(client, CF_AbilityType_Reload);
 	//CF_GetPlayerConfig(client, s_PreviousCharacter[client], 255);
 	CF_SetPlayerConfig(client, "");
 	SDKUnhook(client, SDKHook_OnTakeDamageAlive, CFDMG_OnTakeDamageAlive);
	SDKUnhook(client, SDKHook_OnTakeDamageAlivePost, CFDMG_OnTakeDamageAlive_Post);
 	b_CharacterApplied[client] = false;

 	CFCharacter chara = GetCharacterFromClient(client);
	if (chara != null)
		chara.Destroy(false);

 	CFC_DeleteParticles(client, true);
 	CFA_RemoveAnimator(client);
 }
 
 public Native_CF_GetPlayerConfig(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int size = GetNativeCell(3);
	
	if (IsValidClient(client))
	{
		SetNativeString(2, s_CharacterConfig[client], size, false);
		
		#if defined DEBUG_CHARACTER_CREATION
		char debugStrGet[255];
		GetNativeString(2, debugStrGet, 255);
		
		CPrintToChatAll("%N's PlayerConfig is currently %s.", client, debugStrGet);
		#endif
	}
	else
	{
		SetNativeString(2, "", size + 1, false);
	}
	
	return;
}

public Native_CF_SetPlayerConfig(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char newConf[255];
	GetNativeString(2, newConf, sizeof(newConf));
	
	if (IsValidClient(client))
	{
		Format(s_CharacterConfig[client], 255, newConf);
		
		#if defined DEBUG_CHARACTER_CREATION
		CPrintToChatAll("Attempted to set %N's PlayerConfig to %s.", client, newConf)
		CPrintToChatAll("{orange}%s", s_CharacterConfig[client]);
		
		char debugStr[255];
		CF_GetPlayerConfig(client, debugStr, 255);
		#endif
	}
}

public Native_CF_IsPlayerCharacter(Handle plugin, int numParams)
{
	bool ReturnValue = false;
	
	int client = GetNativeCell(1);
	
	if (IsValidClient(client))
	{
		ReturnValue = GetCharacterFromClient(client) != null;
	}
	
	return ReturnValue;
}

public any Native_CF_GetCharacterClass(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return TFClass_Unknown;
		
	return GetCharacterFromClient(client).i_Class;
}

public Native_CF_SetCharacterClass(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	TFClassType NewClass = GetNativeCell(2);
	
	if (CF_IsPlayerCharacter(client))
	{
		CFCharacter chara = GetCharacterFromClient(client);
		chara.i_Class = NewClass;
		
		TF2_SetPlayerClass(client, chara.i_Class);
		CF_UpdateCharacterHP(client, chara.i_Class, false);
		CF_UpdateCharacterSpeed(client, TF2_GetPlayerClass(client));
	}
}

public Native_CF_AttachParticle(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return -1;
		
	if (CF_CharacterParticles[client] == null)
		CF_CharacterParticles[client] = CreateArray(16);
		
	char partName[255], point[255];
	GetNativeString(2, partName, sizeof(partName));
	GetNativeString(3, point, sizeof(point));
	bool preserve = GetNativeCell(4);
	float lifespan = GetNativeCell(5);
	float xOff = GetNativeCell(6);
	float yOff = GetNativeCell(7);
	float zOff = GetNativeCell(8);
		
	int particle = AttachParticleToEntity(client, partName, point, lifespan, xOff, yOff, zOff);
	
	if (IsValidEntity(particle))
	{
		SetEdictFlags(particle, GetEdictFlags(particle)&(~FL_EDICT_ALWAYS));
			
		i_CharacterParticleOwner[particle] = GetClientUserId(client);
		b_CharacterParticlePreserved[particle] = preserve;
		SDKHook(particle, SDKHook_SetTransmit, CFC_ParticleTransmit);
		PushArrayCell(CF_CharacterParticles[client], EntIndexToEntRef(particle));
		
		return particle;
	}
	
	return -1;
}

public Native_CF_AttachWearable(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return -1;
		
	char atts[255], classname[255];
	int index = GetNativeCell(2);
	GetNativeString(3, classname, sizeof(classname));
	bool visible = GetNativeCell(4);
	int paint = GetNativeCell(5);
	int style = GetNativeCell(6);
	bool preserve = GetNativeCell(7);
	GetNativeString(8, atts, sizeof(atts));
	float lifespan = GetNativeCell(9);
		
	int wearable = CreateWearable(client, index, classname, atts, paint, style, visible, lifespan);
	if (IsValidEntity(wearable))
	{
		SDKCall_EquipWearable(client, wearable);
		b_WearableIsPreserved[wearable] = preserve;
		SetEntProp(wearable, Prop_Send, "m_iTeamNum", GetEntProp(client, Prop_Send, "m_iTeamNum"));
		return wearable;
	}
	
	return -1;
}

public Native_CF_GetCharacterName(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int size = GetNativeCell(3);
	
	if (CF_IsPlayerCharacter(client))
	{
		char name[255];
		GetCharacterFromClient(client).GetName(name, 255);
		SetNativeString(2, name, size, false);
		
		#if defined DEBUG_CHARACTER_CREATION
		char debugStrGet[255];
		GetNativeString(2, debugStrGet, 255);
		
		CPrintToChatAll("%N's character's name is currently %s.", client, debugStrGet);
		#endif
	}
	else
	{
		SetNativeString(2, "", size + 1, false);
	}
	
	return;
}

public Native_CF_SetCharacterName(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char NewName[255];
	GetNativeString(2, NewName, sizeof(NewName));
	
	if (CF_IsPlayerCharacter(client))
	{
		GetCharacterFromClient(client).SetName(NewName);
	}
}

public Native_CF_GetCharacterModel(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int size = GetNativeCell(3);
	
	if (CF_IsPlayerCharacter(client))
	{
		char model[255];
		GetCharacterFromClient(client).GetModel(model, 255);
		SetNativeString(2, model, size, false);
		
		#if defined DEBUG_CHARACTER_CREATION
		char debugStrGet[255];
		GetNativeString(2, debugStrGet, 255);
		
		CPrintToChatAll("%N's character's model is currently %s.", client, debugStrGet);
		#endif
	}
	else
	{
		SetNativeString(2, "", size + 1, false);
	}
	
	return;
}

public Native_CF_GetCharacterArchetype(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int size = GetNativeCell(3);
	
	if (CF_IsPlayerCharacter(client))
	{
		char archetype[255];
		GetCharacterFromClient(client).GetArchetype(archetype, 255);
		SetNativeString(2, archetype, size, false);
	}
	else
	{
		SetNativeString(2, "", size + 1, false);
	}
	
	return;
}

public Native_CF_SetCharacterModel(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char NewModel[255];
	GetNativeString(2, NewModel, sizeof(NewModel));
	
	if (CF_IsPlayerCharacter(client) && CheckFile(NewModel))
	{
		GetCharacterFromClient(client).SetModel(NewModel);
		//PrecacheModel(NewModel);
		
		SetVariantString(NewModel);
		AcceptEntityInput(client, "SetCustomModelWithClassAnimations");
	}
}

public Native_CF_SetCharacterArchetype(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char NewArchetype[255];
	GetNativeString(2, NewArchetype, sizeof(NewArchetype));
	
	if (CF_IsPlayerCharacter(client) && CheckFile(NewArchetype))
	{
		GetCharacterFromClient(client).SetArchetype(NewArchetype);
	}
}

public any Native_CF_GetCharacterSpeed(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	if (CF_IsPlayerCharacter(client))
	{
		return GetCharacterFromClient(client).f_Speed;
	}
	
	return 0.0;
}

public any Native_CF_GetCharacterBaseSpeed(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	if (CF_IsPlayerCharacter(client))
	{
		return GetCharacterFromClient(client).f_BaseSpeed;
	}
	
	return 0.0;
}

public any Native_CF_SetCharacterSpeed(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float NewSpeed = GetNativeCell(2);

	if (CF_IsPlayerCharacter(client))
	{
		GetCharacterFromClient(client).f_Speed = NewSpeed;
		CF_UpdateCharacterSpeed(client, TF2_GetPlayerClass(client));
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.0001);
	}
	
	return 0.0;
}

public any Native_CF_MakeClientCharacter(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char character[255], message[255];
	GetNativeString(2, character, sizeof(character));
	GetNativeString(3, message, sizeof(message));
	
	if (!IsValidMulti(client))
		return false;
	
	bool shortened;
	if (!CF_CharacterExists(character, shortened))
		return false;
	
	if (shortened)
		Format(character, sizeof(character), "configs/chaos_fortress/%s.cfg", character);
	
	//CF_MakeCharacter(client, true, true, character);
	//CF_MakeCharacter(client, true, true, character);
	CF_UnmakeCharacter(client, true, CF_CRR_SWITCHED_CHARACTER);
	CF_MakeCharacter(client, false, _, character);
	CF_MakeCharacter(client, _, _, character, message);
	
	return true;
}

public any Native_CF_GetCharacterScale(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	if (CF_IsPlayerCharacter(client))
	{
		return GetCharacterFromClient(client).f_Scale;
	}
	
	return 0.0;
}

public any Native_CF_SetCharacterScale(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float NewScale = GetNativeCell(2);
	CF_StuckMethod StuckMethod = GetNativeCell(3);
	char message_failure[255], message_success[255];
	GetNativeString(4, message_failure, sizeof(message_failure));
	GetNativeString(5, message_success, sizeof(message_success));

	if (CF_IsPlayerCharacter(client))
	{
		bool success = StuckMethod == CF_StuckMethod_None || !CheckPlayerWouldGetStuck(client, NewScale);
		if (!success)
		{
			switch(StuckMethod)
			{
				case CF_StuckMethod_Kill:
				{
					FakeClientCommand(client, "explode");
				}
				case CF_StuckMethod_Respawn:
				{
					TF2_RespawnPlayer(client);
				}
				case CF_StuckMethod_DelayResize:
				{
					DataPack pack = new DataPack();
					WritePackCell(pack, GetClientUserId(client));
					WritePackFloat(pack, NewScale);
					WritePackString(pack, message_success);
					
					RequestFrame(SetScale_DelayResize, pack);
				}
			}
			
			if (!StrEqual(message_failure, ""))
				CPrintToChat(client, message_failure);
		}
		else
		{
			GetCharacterFromClient(client).f_Scale = NewScale;
			
			SetEntPropFloat(client, Prop_Send, "m_flModelScale", NewScale);
			SetEntPropFloat(client, Prop_Send, "m_flStepSize", 18.0 * NewScale);
			
			float mins[3], maxs[3];
			
			mins[0] = -24.0 * NewScale;
			mins[1] = -24.0 * NewScale;
			mins[2] = 0.0;
			maxs[0] = 24.0 * NewScale;
			maxs[1] = 24.0 * NewScale;
			maxs[2] = 82.0 * NewScale;
			
			SetEntPropVector(client, Prop_Send, "m_vecMins", mins);
			SetEntPropVector(client, Prop_Send, "m_vecMaxs", maxs);
			SetEntPropVector(client, Prop_Send, "m_vecMinsPreScaled", mins);
			SetEntPropVector(client, Prop_Send, "m_vecMaxsPreScaled", maxs);
			SetEntPropVector(client, Prop_Send, "m_vecSpecifiedSurroundingMins", mins);
			SetEntPropVector(client, Prop_Send, "m_vecSpecifiedSurroundingMaxs", maxs);
			SetEntPropVector(client, Prop_Send, "m_vecSpecifiedSurroundingMinsPreScaled", mins);
			SetEntPropVector(client, Prop_Send, "m_vecSpecifiedSurroundingMaxsPreScaled", maxs);
			
			if (!StrEqual(message_success, ""))
				CPrintToChat(client, message_success);
		}
	}
	
	return 0.0;
}

public void SetScale_DelayResize(DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	float NewScale = ReadPackFloat(pack);
	char message_success[255];
	ReadPackString(pack, message_success, 255);
	
	delete pack;
	
	if (!IsValidMulti(client))
		return;
		
	if (!CheckPlayerWouldGetStuck(client, NewScale))
	{
		GetCharacterFromClient(client).f_Scale = NewScale;
			
		SetEntPropFloat(client, Prop_Send, "m_flModelScale", NewScale);
		SetEntPropFloat(client, Prop_Send, "m_flStepSize", 18.0 * NewScale);
		
		float mins[3], maxs[3];
			
		mins[0] = -24.0 * NewScale;
		mins[1] = -24.0 * NewScale;
		mins[2] = 0.0;
		maxs[0] = 24.0 * NewScale;
		maxs[1] = 24.0 * NewScale;
		maxs[2] = 82.0 * NewScale;
			
		SetEntPropVector(client, Prop_Send, "m_vecMins", mins);
		SetEntPropVector(client, Prop_Send, "m_vecMaxs", maxs);
		SetEntPropVector(client, Prop_Send, "m_vecMinsPreScaled", mins);
		SetEntPropVector(client, Prop_Send, "m_vecMaxsPreScaled", maxs);
		SetEntPropVector(client, Prop_Send, "m_vecSpecifiedSurroundingMins", mins);
		SetEntPropVector(client, Prop_Send, "m_vecSpecifiedSurroundingMaxs", maxs);
		SetEntPropVector(client, Prop_Send, "m_vecSpecifiedSurroundingMinsPreScaled", mins);
		SetEntPropVector(client, Prop_Send, "m_vecSpecifiedSurroundingMaxsPreScaled", maxs);
		
		if (!StrEqual(message_success, ""))
			CPrintToChat(client, message_success);
		
		return;
	}
	
	DataPack pack2 = new DataPack();
	WritePackCell(pack2, GetClientUserId(client));
	WritePackFloat(pack2, NewScale);
	WritePackString(pack2, message_success);
					
	RequestFrame(SetScale_DelayResize, pack2);
}

public int CF_GetDialogueReduction(int client)
{
	if (!CF_IsPlayerCharacter(client))
		return 0;
		
	return i_DialogueReduction[client];
}