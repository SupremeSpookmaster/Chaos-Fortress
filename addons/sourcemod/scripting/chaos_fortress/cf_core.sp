#if defined _cf_included_
#endinput
#endif
#define _cf_included_

#include <cf_stocks>
#include <cf_include>
#include <SteamWorks>

#include "chaos_fortress/cf_killstreak.sp"
#include "chaos_fortress/cf_damage.sp"
#include "chaos_fortress/cf_buttons.sp"
#include "chaos_fortress/cf_characters.sp"
#include "chaos_fortress/cf_sounds.sp"
#include "chaos_fortress/cf_weapons.sp"
#include "chaos_fortress/cf_abilities.sp"
#include "chaos_fortress/cf_animator.sp"

bool b_InSpawn[2049][4];

float f_SpawnGrace = 3.0;
float f_RespawnTimeRed = 9.0;
float f_RespawnTimeBlue = 9.0;
float f_GlobalKnockbackValue = 0.66;
bool b_PreserveUlt = false;

public float GetSpawnGrace() { return f_SpawnGrace; }
public bool GetPreserveUlt() { return b_PreserveUlt; }

GlobalForward g_OnPlayerKilled;
GlobalForward g_OnRoundStateChanged;
GlobalForward g_OnPlayerKilled_Pre;
GlobalForward g_PhysTouch;

public ConfigMap GameRules;

ConVar g_WeaponDropLifespan;

#define GAME_DESCRIPTION	"Chaos Fortress: Open Beta"

public void CF_SetRespawnTime(int client)
{
	float time = (TF2_GetClientTeam(client) == TFTeam_Red ? f_RespawnTimeRed : f_RespawnTimeBlue);
	if (time >= 0.0)
		TF2Util_SetPlayerRespawnTimeOverride(client, time);
}

/**
 * Creates all of Chaos Fortress' natives.
 */
public void CF_MakeNatives()
{
	RegPluginLibrary("chaos_fortress");
	
	CFKS_MakeNatives();
	CFB_MakeNatives();
	CFC_MakeNatives();
	CFW_MakeNatives();
	CFA_MakeNatives();
	CFS_MakeNatives();
	
	CreateNative("CF_IsEntityInSpawn", Native_CF_IsEntityInSpawn);
}

/**
 * Creates all of Chaos Fortress forwards.
 */
public void CF_OnPluginStart()
{
	CFDMG_MakeForwards();
	CFB_MakeForwards();
	CFKS_MakeForwards();
	CFC_MakeForwards();
	CFW_OnPluginStart();
	CFA_MakeForwards();
	CFS_OnPluginStart();
	CFW_MakeForwards();
	
	g_OnPlayerKilled = new GlobalForward("CF_OnPlayerKilled", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_OnPlayerKilled_Pre = new GlobalForward("CF_OnPlayerKilled_Pre", ET_Event, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_String, Param_String, Param_CellByRef, Param_Cell, Param_CellByRef, Param_CellByRef);
	g_OnRoundStateChanged = new GlobalForward("CF_OnRoundStateChanged", ET_Ignore, Param_Cell);
	g_PhysTouch = new GlobalForward("CF_OnPhysPropHitByProjectile", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_String, Param_Cell, Param_Float, Param_Array);
	
	g_WeaponDropLifespan = FindConVar("tf_dropped_weapon_lifetime");
	g_WeaponDropLifespan.IntValue = 0;
	
	SteamWorks_SetGameDescription(GAME_DESCRIPTION);

	//TODO
	GameData gd = new GameData("chaos_fortress");

    DynamicDetour dtApplyPushFromDamage = DynamicDetour.FromConf(gd, "CTFPlayer::ApplyPushFromDamage()");

    if(!dtApplyPushFromDamage)
        SetFailState("Failed to setup detour for CTFPlayer::ApplyPushFromDamage()");

    dtApplyPushFromDamage.Enable(Hook_Pre, OnApplyPushFromDamagePre);
    dtApplyPushFromDamage.Enable(Hook_Post, OnApplyPushFromDamagePost);

    delete gd;
}

public void CF_ReloadSubplugins()
{
	char path[PLATFORM_MAX_PATH], folder[128], filename[PLATFORM_MAX_PATH], filepath1[PLATFORM_MAX_PATH], filepath2[PLATFORM_MAX_PATH];
	folder = "cf_subplugins";
	BuildPath(Path_SM, path, sizeof(path), "plugins/%s", folder);
	
	FileType filetype;
	DirectoryListing dir = OpenDirectory(path);
	if (dir)
	{
		while(dir.GetNext(filename, sizeof(filename), filetype))
		{
			if(filetype == FileType_File)
			{
				int pos = strlen(filename) - 4;
				if(pos > 0)
				{
					if(StrEqual(filename[pos], ".smx"))
					{
						FormatEx(filepath1, sizeof(filepath1), "%s/%s", path, filename);
								
						if(!IsSubpluginLoaded(filename))
							InsertServerCommand("sm plugins load %s/%s", folder, filename);
								
						if(!StrEqual(folder, "disabled") && !StrEqual(folder, "optional"))
						{
							DataPack pack = new DataPack();
							pack.WriteString(filepath1);
							RequestFrame(CF_RenameSubplugin, pack);
						}
					}
					else if(StrEqual(filename[pos], ".cf2"))
					{
						FormatEx(filepath1, sizeof(filepath1), "%s/%s", path, filename);
								
						strcopy(filename[pos], 5, ".smx");
						FormatEx(filepath2, sizeof(filepath2), "%s/%s", path, filename);
								
						if(FileExists(filepath2))
						{
							DeleteFile(filepath1);
						}
						else
						{
							RenameFile(filepath2, filepath1);
							InsertServerCommand("sm plugins load %s/%s", folder, filename);
						}
								
						if(!StrEqual(folder, "disabled") && !StrEqual(folder, "optional"))
						{
							DataPack pack = new DataPack();
							pack.WriteString(filepath2);									
							RequestFrame(CF_RenameSubplugin, pack);
						}
					}
				}
			}
		}
				
		ServerExecute();
	}
}

static void CF_RenameSubplugin(DataPack pack)
{
	pack.Reset();
	
	char buffer1[PLATFORM_MAX_PATH], buffer2[PLATFORM_MAX_PATH];
	pack.ReadString(buffer1, sizeof(buffer1));
	
	delete pack;
	
	int pos = strcopy(buffer2, sizeof(buffer2), buffer1) - 4;
	strcopy(buffer2[pos], 5, ".cf2");
	
	if(!RenameFile(buffer2, buffer1))
		LogError("Failed to rename '%s' to '%s'", buffer1, buffer2);
}

static bool IsSubpluginLoaded(const char[] name)
{
	char filename[PLATFORM_MAX_PATH];
	Handle iter = GetPluginIterator();
	while(MorePlugins(iter))
	{
		Handle plugin = ReadPlugin(iter);
		GetPluginFilename(plugin, filename, sizeof(filename));
		if(StrContains(filename, name, false) != -1)
		{
			delete iter;
			return true;
		}
	}
	delete iter;
	return false;
}

/*public void OnClientPutInServer(int client)
{
	//SDKHook(client, SDKHook_WeaponSwitch, CFC_WeaponEquipped);
	//SDKHook(client, SDKHook_WeaponCanSwitchTo, CFA_WeaponCanSwitch);

	if (!CFA_GetHUDTimerStatus())
	{
		CreateTimer(1.0, StartHUDTimerOnDelay, _, TIMER_FLAG_NO_MAPCHANGE);
		CFA_SetHUDTimerStatus(true);
	}
}

public Action StartHUDTimerOnDelay(Handle timer)
{
	CreateTimer(0.1, CFA_HUDTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}*/

#define SOUND_PHYSTOUCH_HIT		"@weapons/fx/rics/arrow_impact_metal2.wav"
#define SOUND_PHYSTOUCH_BLAST	"@weapons/explode1.wav"

static char g_ArrowImpactSounds_World[][] = {
	")weapons/fx/arrow_impact_concrete.wav",
	")weapons/fx/arrow_impact_concrete2.wav",
	")weapons/fx/arrow_impact_concrete4.wav"
};

static char g_ArrowImpactSounds_Player[][] = {
	")weapons/fx/arrow_impact_flesh.wav",
	")weapons/fx/arrow_impact_flesh2.wav",
	")weapons/fx/arrow_impact_flesh3.wav",
	")weapons/fx/arrow_impact_flesh4.wav"
};

/**
 * Called when the map starts.
 */
public void CF_MapStart()
{
	CF_SetRoundState(0);
	
	CF_SetGameRules(-1);
	
	CF_LoadCharacters(-1);
	
	CFW_MapStart();
	
	CFA_MapStart();
	
	PrecacheSound(SOUND_PHYSTOUCH_HIT);
	PrecacheSound(SOUND_PHYSTOUCH_BLAST);
	PrecacheSound("weapons/fx/rics/arrow_impact_metal.wav");
	PrecacheSound("weapons/fx/rics/arrow_impact_metal2.wav");
	PrecacheSound("weapons/fx/rics/arrow_impact_metal4.wav");

	for (int i = 0; i < (sizeof(g_ArrowImpactSounds_World));   i++) { PrecacheSound(g_ArrowImpactSounds_World[i]);   }
	for (int i = 0; i < (sizeof(g_ArrowImpactSounds_Player));   i++) { PrecacheSound(g_ArrowImpactSounds_Player[i]);   }

	CreateTimer(0.1, CFA_HUDTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	CF_ReloadSubplugins();
}

/**
 * Sets the game rules for Chaos Fortress by reading game_rules.cfg.
 *
 * @param admin		The client index of the admin who reloaded game_rules. If valid: prints the new rules to that admin's console.
 */
public void CF_SetGameRules(int admin)
{
	//DeleteCfg(GameRules);
	GameRules = new ConfigMap("data/chaos_fortress/game_rules.cfg");
	
	if (GameRules == null)
		ThrowError("FATAL ERROR: FAILED TO LOAD data/chaos_fortress/game_rules.cfg!");
	
	#if defined DEBUG_GAMERULES
	PrintToServer("//////////////////////////////////////////////");
	PrintToServer("CHAOS FORTRESS GAME_RULES DEBUG MESSAGES BELOW");
	PrintToServer("//////////////////////////////////////////////");
	#endif
	
	ConfigMap subsection = GameRules.GetSection("game_rules.general_rules");
	if (subsection != null)
	{
		subsection.Get("default_character", s_DefaultCharacter, 255);
		Format(s_DefaultCharacter, sizeof(s_DefaultCharacter), "configs/chaos_fortress/%s.cfg", s_DefaultCharacter);
		CFA_SetChargeRetain(GetFloatFromConfigMap(subsection, "charge_retain", 0.0));
		b_DisplayRole = GetBoolFromConfigMap(subsection, "display_role", false);
		b_PreserveUlt = GetBoolFromConfigMap(subsection, "preserve_ult", false);
		f_SpawnGrace = GetFloatFromConfigMap(subsection, "spawn_grace", 3.0);
		f_RespawnTimeRed = GetFloatFromConfigMap(subsection, "respawn_red", 9.0);
		f_RespawnTimeBlue = GetFloatFromConfigMap(subsection, "respawn_blue", 9.0);
		f_GlobalKnockbackValue = GetFloatFromConfigMap(subsection, "knockback_modifier", 0.0);
		
		float KillValue = GetFloatFromConfigMap(subsection, "value_kills", 1.0);
		float DeathValue = GetFloatFromConfigMap(subsection, "value_deaths", 1.0);
		float HealValue = GetFloatFromConfigMap(subsection, "value_healing", 1000.0);
		float KDA_Angry = GetFloatFromConfigMap(subsection, "kd_angry", 0.33);
		float KDA_Happy = GetFloatFromConfigMap(subsection, "kd_happy", 2.33);
		
		CFKS_ApplyKDARules(KillValue, DeathValue, KDA_Angry, KDA_Happy, HealValue);
		
		if (IsValidClient(admin))
		{
			PrintToConsole(admin, "\nNew game rules under general_rules:");
			PrintToConsole(admin, "\nDefault Character: %s", s_DefaultCharacter);
			PrintToConsole(admin, "Ult Charge Retained On Character Switch: %.2f", f_ChargeRetain);
			PrintToConsole(admin, "Display Role: %i", view_as<int>(b_DisplayRole));
		}
		
		#if defined DEBUG_GAMERULES
		PrintToServer("\nNow reading general_rules...");
		PrintToServer("\nDefault Character: %s", s_DefaultCharacter);
		PrintToServer("Ult Charge Retained On Character Switch: %.2f", f_ChargeRetain);
		PrintToServer("Display Role: %i", view_as<int>(b_DisplayRole));
		#endif
	}
	
	subsection = GameRules.GetSection("game_rules.killstreak_settings");
	if (subsection != null)
	{
		int announcer = GetIntFromConfigMap(subsection, "killstreak_announcements", 0);
		int interval = GetIntFromConfigMap(subsection, "killstreak_interval", 0);
		int ended = GetIntFromConfigMap(subsection, "killstreak_ended", 0);
		int godlike = GetIntFromConfigMap(subsection, "killstreak_godlike", 0);
		
		CFKS_Prepare(announcer, interval, ended, godlike);
		
		if (IsValidClient(admin))
		{
			PrintToConsole(admin, "\nKillstreak Announcer: %i", announcer);
			PrintToConsole(admin, "Killstreak Interval: Every %i Kill(s)", interval);
			PrintToConsole(admin, "Announce Ended Killstreaks at: %i Kill(s)", ended);
			PrintToConsole(admin, "Killstreaks Are Godlike At: %i Kill(s)", godlike);
		}
		
		#if defined DEBUG_GAMERULES
		PrintToServer("\nKillstreak Announcer: %i", announcer);
		PrintToServer("Killstreak Interval: Every %i Kill(s)", interval);
		PrintToServer("Announce Ended Killstreaks at: %i Kill(s)", ended);
		PrintToServer("Killstreaks Are Godlike At: %i Kill(s)", godlike);
		#endif
	}
	
	subsection = GameRules.GetSection("game_rules.chat_messages");
	if (subsection != null)
	{
		ConfigMap messageSection = subsection.GetSection("message_1");
		int currentMessage = 1;
		while (messageSection != null)
		{
			char messageText[255];
			messageSection.Get("message", messageText, 255);
			float interval = GetFloatFromConfigMap(messageSection, "interval", 300.0);
			int holiday = GetIntFromConfigMap(messageSection, "holiday", 0);
			
			bool permissible = true;
			
			//mild YandereDev-tier code, whoopsies!
			if (holiday == 1 && !TF2_IsHolidayActive(TFHoliday_Invalid))
				permissible = false;
			if (holiday == 2 && !TF2_IsHolidayActive(TFHoliday_HalloweenOrFullMoon))
				permissible = false;
			if (holiday == 3 && !TF2_IsHolidayActive(TFHoliday_AprilFools))
				permissible = false;
			if (holiday == 4 && !TF2_IsHolidayActive(TFHoliday_Birthday))
				permissible = false;
			if (holiday == 5 && !TF2_IsHolidayActive(TFHoliday_Christmas))
				permissible = false;
			
			if (permissible)
			{
				DataPack pack = new DataPack();
				WritePackString(pack, messageText);
				CreateTimer(interval, CF_PrintMessage, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			}
			
			currentMessage++;
			char name[255];
			Format(name, sizeof(name), "message_%i", currentMessage);
			messageSection = subsection.GetSection(name);
		}
	}
	else
		PrintToServer("Failed to find chat messages!");
	
	DeleteCfg(GameRules);
	
	#if defined DEBUG_GAMERULES
	PrintToServer("//////////////////////////////////////////////");
	PrintToServer("CHAOS FORTRESS GAME_RULES DEBUG MESSAGES ABOVE");
	PrintToServer("//////////////////////////////////////////////");
	#endif
}

public int CF_GetCharacterLimit(char conf[255])
{
	GameRules = new ConfigMap("data/chaos_fortress/game_rules.cfg");

	char myConf[255];
	myConf = conf;
	ReplaceString(myConf, sizeof(myConf), "configs/chaos_fortress/", "");
	ReplaceString(myConf, sizeof(myConf), ".cfg", "");

	char path[255];
	Format(path, sizeof(path), "game_rules.character_limits.%s", myConf);
	
	int limit = GetIntFromConfigMap(GameRules, path, 0);
	if (limit == 0)
		limit = GetIntFromConfigMap(GameRules, "game_rules.character_limits.all", 0);

	DeleteCfg(GameRules);

	return limit;
}

public Action CF_PrintMessage(Handle timer, DataPack pack)
{
	ResetPack(pack);

	char message[255];
	ReadPackString(pack, message, 255);
	CPrintToChatAll(message);

	return Plugin_Continue;
}

/**
 * Called when a player is killed.
 *
 * @param victim			The client who was killed.
 * @param inflictor			The entity index of whatever inflicted the killing blow.
 * @param attacker			The player who dealt the damage.
 * @param deadRinger		Was this a fake death caused by the Dead Ringer?
 */
public void CF_PlayerKilled(int victim, int inflictor, int attacker, bool deadRinger)
{
	Call_StartForward(g_OnPlayerKilled);
	
	Call_PushCell(victim);
	Call_PushCell(inflictor);
	Call_PushCell(attacker);
	Call_PushCell(view_as<int>(deadRinger));
	
	Call_Finish();
	
	CFKS_PlayerKilled(victim, attacker, deadRinger);
	
	if (!deadRinger)
	{
		RequestFrame(UnmakeAfterDelay, GetClientUserId(victim));
		CFA_PlayerKilled(attacker, victim);
	}
}

/**
 * Called when a player is killed, using EventHookMode_Pre. Change any of the following variables (excluding deadRinger) to modify the event.
 *
 * @param victim			The client who was killed.
 * @param inflictor			The entity index of whatever inflicted the killing blow.
 * @param attacker			The player who dealt the damage.
 * @param weapon			The weapon used to kill the target. Changing this will modify the kill icon as well as the name of the weapon displayed in the console.
 * @param custom			Certain kill icons require you to set this, as they cannot be achieved by simply setting the weapon string.
 * @param deadRinger		Was this a fake death caused by the Dead Ringer?
 *
 * @return	Plugin_Changed to apply your changes if you changed any variables, Plugin_Stop or Plugin_Handled to prevent the event from being fired, or Plugin_Continue to proceed as normal.
 */
public Action CF_PlayerKilled_Pre(int &victim, int &inflictor, int &attacker, char weapon[255], char console[255], int &custom, bool deadRinger, int &critType, int &damagebits)
{
	Action result;
	
	Call_StartForward(g_OnPlayerKilled_Pre);
	
	Call_PushCellRef(victim);
	Call_PushCellRef(inflictor);
	Call_PushCellRef(attacker);
	Call_PushStringEx(weapon, sizeof(weapon), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushStringEx(console, sizeof(console), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCellRef(custom);
	Call_PushCell(view_as<int>(deadRinger));
	Call_PushCellRef(critType);
	Call_PushCellRef(damagebits);
	
	Call_Finish(result);
	
	return result;
}

public void UnmakeAfterDelay(int id)
{
	int victim = GetClientOfUserId(id);
	if (IsValidClient(victim))
	{
		CF_UnmakeCharacter(victim, false, CF_CRR_DEATH);
	}
}

/**
 * Called when the round starts.
 */
void CF_Waiting()
{
	CF_SetRoundState(0);
}

/**
 * Called when the round starts.
 */
void CF_RoundStart()
{
	CF_SetRoundState(1);
}

/**
 * Called when the round ends.
 */
void CF_RoundEnd()
{
	CF_SetRoundState(2);
}

/**
 * Sets the current round state.
 *
 * @param state		The round state to set. 0: pre-game, 1: round in progress, 2: round has ended.
 */
void CF_SetRoundState(int state)
{
	if (state == 0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			CF_SetKillstreak(i, 0, 0, false);
			CF_MakeCharacter(i, true, true);
		}
	}
	
	Call_StartForward(g_OnRoundStateChanged);
	
	Call_PushCell(state);
	
	Call_Finish();
	
	#if defined DEBUG_ROUND_STATE
	CPrintToChatAll("The current round state is %i.", i_CFRoundState);
	#endif
}

public Native_CF_GetRoundState(Handle plugin, int numParams)
{
	if (FindEntityByClassname(-1, "tf_gamerules") == -1)
		return 0;

	RoundState state = GameRules_GetRoundState();
	if (state == RoundState_RoundRunning || state == RoundState_Bonus)
		return 1;
	else if (state == RoundState_GameOver || state == RoundState_TeamWin || state == RoundState_Restart || state == RoundState_Stalemate)
		return 2;
	
	return 0;
}

public void OnGameFrame()
{
	CFA_OGF();
	
	#if defined USE_PREVIEWS
	CFC_OGF();
	#endif
}

public void OnEntityCreated(int entity, const char[] classname)
{
	CFA_OnEntityCreated(entity, classname);
	CFDMG_OnEntityCreated(entity, classname);
	
	//Don't let players drop Mannpower powerups on death:
	if (StrContains(classname, "powerup") != -1)
	{
		RemoveEntity(entity);
	}
	if (StrContains(classname, "tf_projectile_arrow") != -1)
	{
		SDKHook(entity, SDKHook_Touch, ArrowTouchNonCombatEntity);
	}
	if (StrContains(classname, "func_respawnroom") != -1)
	{
		SDKHook(entity, SDKHook_StartTouch, EnterSpawn);
		SDKHook(entity, SDKHook_EndTouch, ExitSpawn);
	}
	
	if (StrContains(classname, "prop_physics") != -1)
	{
		SDKHook(entity, SDKHook_TouchPost, PhysTouch);
	}
}

public Action EnterSpawn(int spawn, int entity)
{
	int team = GetEntProp(spawn, Prop_Send, "m_iTeamNum");
	b_InSpawn[entity][team] = true;
	
	return Plugin_Continue;
}

public Action ExitSpawn(int spawn, int entity)
{
	int team = GetEntProp(spawn, Prop_Send, "m_iTeamNum");
	b_InSpawn[entity][team] = false;
	
	return Plugin_Continue;
}

public void Core_OnEntityDestroyed(int entity)
{
	if (entity >= 0 && entity < 2049)
	{
		for (int i = 0; i < 4; i++)
			b_InSpawn[entity][i] = false;
	}
}

public Native_CF_IsEntityInSpawn(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	int team = GetNativeCell(2);
	
	return b_InSpawn[entity][team];
} 

public Action PhysTouch(int prop, int entity)
{
	char classname[255];
	if (!TF2_IsDamageProjectileWithoutImpactExplosion(entity, classname))
		return Plugin_Continue;
		
	if (StrContains(classname, "remote") != -1)
		return Plugin_Continue;
		
	int team1 = GetEntProp(prop, Prop_Send, "m_iTeamNum");
	int team2 = GetEntProp(entity, Prop_Send, "m_iTeamNum");
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	int launcher = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
	
	float damage = GetProjectileDamage(entity, 100.0);
	
	//Building damage attributes:
	if (IsValidEntity(launcher))
	{
		damage *= GetAttributeValue(launcher, 137, 1.0);
		damage *= GetAttributeValue(launcher, 775, 1.0);
	}
		
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	
	Action result = Plugin_Continue;
	
	Call_StartForward(g_PhysTouch);
	
	Call_PushCell(prop);
	Call_PushCell(entity);
	Call_PushCell(view_as<TFTeam>(team1));
	Call_PushCell(view_as<TFTeam>(team2));
	Call_PushCell(GetEntPropEnt(prop, Prop_Send, "m_hOwnerEntity"));
	Call_PushCell(owner);
	Call_PushString(classname);
	Call_PushCell(launcher);
	Call_PushFloat(damage);
	Call_PushArray(pos, sizeof(pos));
	
	Call_Finish(result);
	
	if (team1 != team2 && result != Plugin_Stop && result != Plugin_Handled)
	{	
		if (result != Plugin_Stop && result != Plugin_Handled)
		{
			SDKHooks_TakeDamage(prop, entity, (IsValidClient(owner) ? owner : 0), damage, _, (IsValidEntity(launcher) ? launcher : -1), _, pos, false);
		}
	}
	
	if (IsValidClient(owner) && result != Plugin_Stop && result != Plugin_Handled)
		EmitSoundToClient(owner, SOUND_PHYSTOUCH_HIT, _, _, 110, _, _, GetRandomInt(80, 110));
		
	return result;
}

//Gets a projectile's damage. Only works for non-explosive, non-jar, non-spell projectiles because that's all I need.
public float GetProjectileDamage(int entity, float defaultVal)
{
	char classname[255];
	GetEntityClassname(entity, classname, sizeof(classname));
	
	//oh boy it's YandereDev time
	//Most of these should work, but only tf_projectile_arrow has actually been tested.
	//TODO: Test both balls and the syringe
	if (StrEqual(classname, "tf_projectile_arrow"))
		return GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Arrow", "m_iDeflected") + 4);
	else if (StrEqual(classname, "tf_projectile_balloffire"))
		return GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_BallOfFire", "m_iDeflected") + 4);
	else if (StrEqual(classname, "tf_projectile_ball_ornament"))
		return GetEntPropFloat(entity, Prop_Send, "m_flDamage");
	else if (StrEqual(classname, "tf_projectile_energy_ball"))
		return GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_EnergyBall", "m_iDeflected") + 4);
	else if (StrEqual(classname, "tf_projectile_flare"))
		return GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Flare", "m_iDeflected") + 4);
	else if (StrEqual(classname, "tf_projectile_grapplinghook"))
		return GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_GrapplingHook", "m_iDeflected") + 4);
	else if (StrEqual(classname, "tf_projectile_healing_bolt"))
		return GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_HealingBolt", "m_iDeflected") + 4);
	else if (StrEqual(classname, "tf_projectile_stun_ball"))
		return GetEntPropFloat(entity, Prop_Send, "m_flDamage");
	else if (StrEqual(classname, "tf_projectile_syringe"))
		return GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Syringe", "m_iDeflected") + 4);
	
	return defaultVal;
}


//this DOES NOT handle all collisions, only for buildings, arrow can do its other things itself.
public void ArrowTouchNonCombatEntity(int entity, int other)
{
	if (other <= 0 || entity > 2048)
		return;

	char classname[255];
	GetEntityClassname(other, classname, sizeof(classname));
	if (StrEqual(classname, "obj_sentrygun") || StrEqual(classname, "obj_teleporter") || StrEqual(classname, "obj_dispenser"))
	{
		int attacker = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

		if (CF_IsValidTarget(other, grabEnemyTeam(attacker)))
		{
			float original_damage = GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4);
			int Weapon = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");

			float chargerPos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", chargerPos);
			EmitSoundToAll(g_ArrowImpactSounds_Player[GetRandomInt(0, sizeof(g_ArrowImpactSounds_Player) - 1)], entity);
			if (IsValidClient(attacker))
			{
				EmitSoundToClient(attacker, g_ArrowImpactSounds_Player[GetRandomInt(0, sizeof(g_ArrowImpactSounds_Player) - 1)]);
			}

			SDKHooks_TakeDamage(other, attacker, attacker, original_damage , DMG_BULLET, Weapon, NULL_VECTOR, chargerPos);

			RemoveEntity(entity);
		}
	}
}

enum eTakeDamageInfo {
    // Vectors.
    m_DamageForce,
    m_DamagePosition = 12,
    m_ReportedPosition = 24,

    m_Inflictor = 36,
    m_Attacker,
    m_Weapon,
    m_Damage,
    m_MaxDamage,
    m_BaseDamage,
    m_BitsDamageType,
    m_DamageCustom,
    m_DamageStats,
    m_AmmoType,
    m_DamagedOtherPlayers,
    m_PlayerPenetrationCount,
    m_DamageBonus,
    m_DamageBonusProvider,
    m_ForceFriendlyFire,
    m_DamageForForce,
    m_CritType
};

bool b_IgnoreKnockbackModifier[MAXPLAYERS + 1] = { false, ... };

void CF_IgnoreNextKB(int client) { b_IgnoreKnockbackModifier[client] = true; }

//Thank you Suza/Zabaniya!
//TODO: Turn the weight stat into a multiplier instead of a flat value, apply it here.
//Also make sure to update the custom knockback to account for this.
//Also also, make a forward and call it in here to allow for knockback modification.
public MRESReturn OnApplyPushFromDamagePre(int iClient, DHookParam hParams)
{
    if(!IsValidClient(iClient))
        return MRES_Ignored;

	if (b_IgnoreKnockbackModifier[iClient])
		return MRES_Ignored;

    float fCurrentKnockback = TF2Attrib_GetFloatValueFromName(iClient, "damage force increase hidden");

    float fNewKnockback = fCurrentKnockback * f_GlobalKnockbackValue;

    TF2Attrib_AddCustomPlayerAttribute(iClient, "damage force increase hidden", fNewKnockback);

    return MRES_Ignored;
}

public MRESReturn OnApplyPushFromDamagePost(int iClient, DHookParam hParams)
{
    if(!IsValidClient(iClient))
        return MRES_Ignored;

	if (b_IgnoreKnockbackModifier[iClient])
	{
		b_IgnoreKnockbackModifier[iClient] = false;
		return MRES_Ignored;
	}

    // Retrieving the original knockback ( the one before we changed theirs ) by doing math.
    float fOldKnockback = TF2Attrib_GetFloatValueFromName(iClient, "damage force increase hidden") / f_GlobalKnockbackValue;
    TF2Attrib_RemoveCustomPlayerAttribute(iClient, "damage force increase hidden");
    TF2Attrib_AddCustomPlayerAttribute(iClient, "damage force increase hidden", fOldKnockback);

    return MRES_Ignored;
}