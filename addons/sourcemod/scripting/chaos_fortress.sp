//#define DEBUG_CHARACTER_CREATION
//#define DEBUG_ROUND_STATE
//#define DEBUG_KILLSTREAKS
//#define DEBUG_ONTAKEDAMAGE
//#define DEBUG_BUTTONS
//#define DEBUG_GAMERULES
//#define DEBUG_SOUNDS
//#define USE_PREVIEWS
//#define TESTING

//	- MANDATORY TO-DO LIST (these MUST be done before the initial release):
//	- TODO: Rewrite the wiki.
//		- May end up just scrapping the wiki. It adds way too much upkeep for next to no benefit.
//	- TODO: The following plugins are mandatory for CF to run, and need to be added to the GitHub's prerequisites:
//		- None, currently.
//	- TODO: The current development branch has the following fatal issues which break the plugin, and will need to be fixed in the release branch:
//		- None, currently.
//	- TODO: Implement notes in the #cf-notes channel.
//
//	- OPTIONAL TO-DO LIST (these do not need to be done for the initial release, but would be nice future additions):
//	- TODO: Add support for translations. This will be a huge pain in the ass, but does not need to be done until public release.
//
//	- MINOR BUGS (bugs which have no impact on gameplay and just sort of look bad):
//	- Certain hats, when equipped via the wearable system, do not visually appear on bots (but they do work *sometimes*). Count Heavnich's "Noble Amassment of Hats" is an example of such a hat. 
//	- CF_Teleport can get you stuck in enemy spawn doors. I'm not going to bother fixing this, if you're enough of a scumbag to try to teleport into the enemy's spawn you deserve to get stuck and die.
//
//	- MAJOR BUGS (bugs which impact gameplay or character creation in any significant way):
//	- DEVELOPMENT: The "preserve" variable of cf_generic_wearable does not work. This feature may actually not be possible without an enormous workaround due to interference from TF2's source code, I am not sure.
//			- Scrap this feature entirely and remove all mentions of it from the code. This will be a giant pain in the ass but does not need to be done until public release.
//
//	- PRESUMED UNFIXABLE (major bugs which I don't believe can be fixed with my current SourceMod expertise. The best thing you can do is classify these as exploits and punish them as such):
//	- None! (Currently)

#define PLUGIN_NAME           		  "Chaos Fortress"

#define PLUGIN_AUTHOR         "Spookmaster"
#define PLUGIN_DESCRIPTION    "Team Fortress 2 with custom classes!"
#define PLUGIN_VERSION        "0.2.0"
#define PLUGIN_URL            "https://github.com/SupremeSpookmaster/Chaos-Fortress"

#pragma semicolon 1

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

#include "chaos_fortress/cf_core.sp"

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("PNPC.b_IsABuilding.get");
	MarkNativeAsOptional("PNPC.Index.get");
	MarkNativeAsOptional("PNPC.i_Health.get");
	MarkNativeAsOptional("PNPC.i_Health.set");
	MarkNativeAsOptional("PNPC_IsNPC");
	MarkNativeAsOptional("PNPC_Explosion");
	CF_MakeNatives();
	return APLRes_Success;
}

public void OnPluginStart()
{
	HookEvent("post_inventory_application", PlayerReset);
	HookEvent("player_spawn", PlayerSpawn);
	//HookEvent("player_spawn", PlayerReset);
	HookEvent("player_death", PlayerKilled);
	HookEvent("player_death", PlayerKilled_Pre, EventHookMode_Pre);
	HookEvent("teamplay_waiting_begins", Waiting);
	HookEvent("teamplay_round_start", Waiting);
	HookEvent("teamplay_setup_finished", RoundStart);
	HookEvent("teamplay_round_win", RoundEnd);
	HookEvent("teamplay_round_stalemate", RoundEnd);
	HookEvent("player_changeclass", ClassChange);
	HookEvent("player_healed", PlayerHealed);
	HookEvent("crossbow_heal", PlayerHealed_Crossbow);
	
	RegAdminCmd("cf_reloadrules", CF_ReloadRules, ADMFLAG_KICK, "Chaos Fortress: Reloads the settings in game_rules.cfg.");
	RegAdminCmd("cf_reloadcharacters", CF_ReloadCharacters, ADMFLAG_KICK, "Chaos Fortress: Reloads the character packs, as defined in characters.cfg.");
	RegAdminCmd("cf_makecharacter", CF_ForceCharacter, ADMFLAG_KICK, "Chaos Fortress: Forces a client to become the specified character.");
	RegAdminCmd("cf_giveult", CF_GiveUltCommand, ADMFLAG_SLAY, "Chaos Fortress: Gives a percentage of ult charge to the specified client(s).");
	
	CF_OnPluginStart();
}

#define SND_ADMINCOMMAND		"ui/cyoa_ping_in_progress.wav"
#define SND_RESPAWN				"mvm/mvm_revive.wav"
#define SND_HINT				"buttons/button9.wav"

public OnMapStart()
{
	//GameRules_SetProp("m_iRoundState", RoundState_BetweenRounds);
	CF_MapStart();
	CFW_MapChange();
	CFS_MapChange();
	PrecacheSound(SND_ADMINCOMMAND);
	PrecacheSound(SND_RESPAWN);
	PrecacheSound(SND_HINT);
}

public OnMapEnd()
{
	CFA_MapEnd();
	CFC_MapEnd();
	CFS_MapChange();
	CFB_MapEnd();
	CFW_MapChange();
}

public Action PlayerKilled(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int victim = GetClientOfUserId(hEvent.GetInt("userid"));
	int inflictor = hEvent.GetInt("inflictor_entindex");
	int attacker = GetClientOfUserId(hEvent.GetInt("attacker"));
	
	bool ringer = false; 
	if (GetEventInt(hEvent, "death_flags") & TF_DEATHFLAG_DEADRINGER)
	{
		ringer = true;
	}
	
	if (IsValidClient(victim))
	{
		CF_PlayerKilled(victim, inflictor, attacker, ringer);
	}
	
	return Plugin_Continue;
}

public Action PlayerKilled_Pre(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int victim = GetClientOfUserId(hEvent.GetInt("userid"));
	int inflictor = hEvent.GetInt("inflictor_entindex");
	int custom = hEvent.GetInt("customkill");
	int critType = hEvent.GetInt("crit_type");
	int bits = hEvent.GetInt("damagebits");
	int attacker = GetClientOfUserId(hEvent.GetInt("attacker"));
	char weapon[255], console[255];
	hEvent.GetString("weapon", weapon, sizeof(weapon), "Generic");
	hEvent.GetString("weapon_logclassname", weapon, sizeof(weapon), "Generic");
	
	bool ringer = false; 
	if (GetEventInt(hEvent, "death_flags") & TF_DEATHFLAG_DEADRINGER)
	{
		ringer = true;
	}
	
	Action result = Plugin_Continue;
	
	if (IsValidClient(victim))
	{
		CFDMG_GetIconFromLastDamage(victim, weapon);
		result = CF_PlayerKilled_Pre(victim, inflictor, attacker, weapon, console, custom, ringer, critType, bits);
		
		hEvent.SetInt("userid", (IsValidClient(victim) ? GetClientUserId(victim) : 0));
		hEvent.SetInt("inflictor_entindex", inflictor);
		hEvent.SetInt("customkill", custom);
		hEvent.SetInt("crit_type", critType);
		
		if (critType > 0 && critType < 3 && ((bits & DMG_CRIT) == 0))
			bits |= DMG_CRIT;
		hEvent.SetInt("damagebits", bits);
		
		hEvent.SetInt("attacker", (IsValidClient(attacker) ? GetClientUserId(attacker) : 0));
		hEvent.SetString("weapon", weapon);
		hEvent.SetString("weapon_logclassname", console);
	}
	
	return result;
}

public Action PlayerHealed(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int patient = GetClientOfUserId(hEvent.GetInt("patient"));
	int healer = hEvent.GetInt("healer");
	int amount = GetClientOfUserId(hEvent.GetInt("amount"));

	if (IsValidClient(healer) && healer != patient)
	{
		CFA_GiveChargesForHealing(healer, float(amount));
		CFA_AddHealingPoints(healer, amount);
	}

	return Plugin_Continue;
}

public Action PlayerHealed_Crossbow(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int healer = hEvent.GetInt("healer");
	int patient = GetClientOfUserId(hEvent.GetInt("target"));
	int amount = GetClientOfUserId(hEvent.GetInt("amount"));

	if (IsValidClient(healer) && healer != patient)
	{
		CFA_GiveChargesForHealing(healer, float(amount));
		CFA_AddHealingPoints(healer, amount);
	}

	return Plugin_Continue;
}

public void Waiting(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	CF_Waiting();
}

public void ClassChange(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	CF_ResetMadeStatus(client);
}

public void RoundStart(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	CF_RoundStart();
}

public void RoundEnd(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	CF_RoundEnd();
}

public void PlayerSpawn(Event gEvent, const char[] sEvName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(gEvent.GetInt("userid"));

	if (IsValidClient(client))
	{
		float duration = GetSpawnGrace();

		if (duration > 0.0)
		{
			TF2_AddCondition(client, TFCond_Buffed, duration);
			TF2_AddCondition(client, TFCond_UberchargedCanteen, duration);
			EmitSoundToClient(client, SND_RESPAWN);
		}
	}
}

public void HookForDamage(int id)
{
	int client = GetClientOfUserId(id);
	if (IsValidClient(client))
	{
		SDKUnhook(client, SDKHook_OnTakeDamageAlive, CFDMG_OnTakeDamageAlive);
 		SDKHook(client, SDKHook_OnTakeDamageAlive, CFDMG_OnTakeDamageAlive);
		SDKUnhook(client, SDKHook_OnTakeDamageAlivePost, CFDMG_OnTakeDamageAlive_Post);
 		SDKHook(client, SDKHook_OnTakeDamageAlivePost, CFDMG_OnTakeDamageAlive_Post);
	}
}

public void PlayerReset(Event gEvent, const char[] sEvName, bool bDontBroadcast)
{    
	int client = GetClientOfUserId(gEvent.GetInt("userid"));
	
	if (IsValidClient(client))
	{
		RequestFrame(HookForDamage, GetClientUserId(client));
		CF_MakeCharacter(client, _, _, _, "You became: %s");
	}
	
	#if defined DEBUG_CHARACTER_CREATION
	if (CF_IsPlayerCharacter(client))
	{
		char buffer[255];
		CF_GetPlayerConfig(client, buffer, 255);
		
		CPrintToChatAll("%N spawned with the following character config: %s.", client, buffer);
	}
	else
	{
		CPrintToChatAll("%N spawned but is not a character, and therefore does not have a config.", client);
	}
	#endif
}

public Action CF_ReloadRules(int client, int args)
{	
	if (IsValidClient(client))
	{
		CPrintToChat(client, "{indigo}[Chaos Fortress] {default}Reloaded data/chaos_fortress/game_rules.cfg. {olive}View your console{default} to see the new game rules.");
		EmitSoundToClient(client, SND_ADMINCOMMAND);
		CF_SetGameRules(client);
	}	
	
	return Plugin_Continue;
}

public Action CF_ReloadCharacters(int client, int args)
{	
	if (IsValidClient(client))
	{
		CPrintToChat(client, "{indigo}[Chaos Fortress] {default}Reloaded data/chaos_fortress/characters.cfg. {olive}View the !characters menu{default} to see the updated character list.");
		EmitSoundToClient(client, SND_ADMINCOMMAND);
		CF_LoadCharacters(client);
	}	
	
	return Plugin_Continue;
}

public Action CF_GiveUltCommand(int client, int args)
{
	if (args != 2)
	{
		ReplyToCommand(client, "[Chaos Fortress] Usage: cf_giveult <target> <ult percentage> | EXAMPLE: cf_giveult john 80 will give John 80% ult.");
		return Plugin_Continue;
	}

	char target[32], amtStr[32];
	GetCmdArg(1, target, 32);
	GetCmdArg(2, amtStr, 32);
	float amt = StringToFloat(amtStr);

	int targets[MAXPLAYERS];
	char targName[MAX_TARGET_LENGTH];
	bool tnml;

	int targCount;
	if ((targCount = ProcessTargetString(target, client, targets, MAXPLAYERS, 0, targName, sizeof(targName), tnml)) <= 0)
	{
		ReplyToTargetError(client, targCount);
		return Plugin_Continue;
	}

	for (int i = 0; i < targCount; i++)
	{
		CF_GiveUltCharge(targets[i], amt, CF_ResourceType_Percentage, true);
		char repl[255];
		Format(repl, sizeof(repl), "[Chaos Fortress] Gave %i[PCNTG] ult charge to %N.", RoundToFloor(amt), targets[i]);
		ReplyToCommand(client, repl);
	}

	return Plugin_Continue;
}

public Action CF_ForceCharacter(int client, int args)
{	
	if (args < 2 || args > 32)
	{
		ReplyToCommand(client, "[Chaos Fortress] Usage: cf_makecharacter <client> <name of character's config> <optional message printed to client's screen>");
		return Plugin_Continue;
	}
		
	char name[32], character[255], message[255];
	GetCmdArg(1, name, sizeof(name));
	GetCmdArg(2, character, sizeof(character));
	if (args >= 3)
	{
		bool prevWasNotAlpha = false;
		for (int i = 3; i <= args; i++)
		{
			char word[32];
			GetCmdArg(i, word, sizeof(word));
			
			if (i == 3)
				Format(message, sizeof(message), "%s", word);
			else if ((!IsCharAlpha(word[0]) && !IsCharNumeric(word[0])) || prevWasNotAlpha)
			{
				Format(message, sizeof(message), "%s%s", message, word);
				prevWasNotAlpha = !prevWasNotAlpha;
			}
			else
				Format(message, sizeof(message), "%s %s", message, word);
		}
	}
	else
		message = "";
	
	if (!CF_CharacterExists(character))
	{
		ReplyToCommand(client, "[Chaos Fortress] Failure: character config ''%s'' does not exist.", character);
		return Plugin_Continue;
	}
	
	if (StrEqual(name, "@all"))
	{
		CF_ForceCharacterOnGroup(character, TFTeam_Unassigned, message);
	}
	else if (StrEqual(name, "@red"))
	{
		CF_ForceCharacterOnGroup(character, TFTeam_Red, message);
	}
	else if (StrEqual(name, "@blue"))
	{
		CF_ForceCharacterOnGroup(character, TFTeam_Blue, message);
	}
	else
	{
		int target = FindTarget(client, name, false, false);
		
		if (!IsValidMulti(target) && IsValidClient(client))
		{
			ReplyToCommand(client, "[Chaos Fortress] Failure: the target must be alive and in-game.");
			return Plugin_Continue;
		}
		
		CF_MakeClientCharacter(target, character, message);
	}

	return Plugin_Continue;
}

public void CF_ForceCharacterOnGroup(char character[255], TFTeam group, char message[255])
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidMulti(i) && (TF2_GetClientTeam(i) == group || group == TFTeam_Unassigned))
		{
			CF_MakeClientCharacter(i, character, message);
		}
	}
}

public void OnClientDisconnect(int client)
{
	CF_UnmakeCharacter(client, false, CF_CRR_DISCONNECT);
	CFC_Disconnect(client);
	CFA_Disconnect(client);
}

#if defined DEBUG_ONTAKEDAMAGE

public Action CF_OnTakeDamageAlive_Pre(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom)
{
	CPrintToChatAll("Called CF_OnTakeDamageAlive_Pre. Damage is currently %i.", RoundFloat(damage));
	return Plugin_Continue;
}

public Action CF_OnTakeDamageAlive_Bonus(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom)
{
	CPrintToChatAll("Called CF_OnTakeDamageAlive_Bonus. Damage is currently %i.", RoundFloat(damage));
	
	damage *= 2.0;
	
	CPrintToChatAll("Damage is now %i after attempting to double it.", RoundFloat(damage));
	
	return Plugin_Changed;
}

public Action CF_OnTakeDamageAlive_Resistance(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom)
{
	CPrintToChatAll("Called CF_OnTakeDamageAlive_Resistance. Damage is currently %i.", RoundFloat(damage));
	
	damage *= 0.66;
	
	CPrintToChatAll("Damage is now %i after attempting to reduce it by 33%.", RoundFloat(damage));
	
	return Plugin_Changed;
}

public Action CF_OnTakeDamageAlive_Post(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom)
{
	CPrintToChatAll("Called CF_OnTakeDamageAlive_Post. Damage is currently %i.", RoundFloat(damage));
	
	CPrintToChatAll("Gained %i imaginary tokens for dealing %i damage", RoundFloat(damage / 40.0), RoundFloat(damage));
	
	return Plugin_Continue;
}

#endif

#if defined DEBUG_BUTTONS

float DebugButtonsGameTimeToPreventLotsOfAnnoyingSpam = 0.0;
public Action CF_OnPlayerRunCmd(int client, int &buttons, int &impulse, int &weapon)
{
	if (GetGameTime() >= DebugButtonsGameTimeToPreventLotsOfAnnoyingSpam)
	{
		CPrintToChatAll("Detected a button press (this will run every second instead of every frame to prevent excessive chat spam).");
		DebugButtonsGameTimeToPreventLotsOfAnnoyingSpam = GetGameTime() + 1.0;
	}
	
	return Plugin_Continue;
}

public Action CF_OnPlayerM2(int client, int &buttons, int &impulse, int &weapon)
{
	CPrintToChatAll("Detected a right-click.");

	return Plugin_Continue;
}

public Action CF_OnPlayerM3(int client, int &buttons, int &impulse, int &weapon)
{
	CPrintToChatAll("Detected a mouse3.");
	
	return Plugin_Continue;
}

public Action CF_OnPlayerReload(int client, int &buttons, int &impulse, int &weapon)
{
	CPrintToChatAll("Detected a reload.");
	
	return Plugin_Continue;
}

public Action CF_OnPlayerTab(int client, int &buttons, int &impulse, int &weapon)
{
	CPrintToChatAll("Detected a tab.");
	
	return Plugin_Continue;
}

public Action CF_OnPlayerJump(int client, int &buttons, int &impulse, int &weapon)
{
	CPrintToChatAll("Detected a jump.");
	
	return Plugin_Continue;
}

public Action CF_OnPlayerCrouch(int client, int &buttons, int &impulse, int &weapon)
{
	CPrintToChatAll("Detected a crouch.");
	
	return Plugin_Continue;
}

public void CF_OnPlayerCallForMedic(int client)
{
	CPrintToChatAll("Detected a medic call.");
}

#endif

public void OnEntityDestroyed(int entity)
{
	if (!IsValidEntity(entity) || entity < 0 || entity > 2049)
		return;
		
	CFW_OnEntityDestroyed(entity);
	CFC_OnEntityDestroyed(entity);
	CFA_OnEntityDestroyed(entity);
	Core_OnEntityDestroyed(entity);
}