//#define DEBUG_CHARACTER_CREATION
//#define DEBUG_ROUND_STATE
//#define DEBUG_KILLSTREAKS
//#define DEBUG_ONTAKEDAMAGE
//#define DEBUG_BUTTONS
//#define DEBUG_GAMERULES
//#define DEBUG_SOUNDS

//GENERAL TODO LIST (things I'll need to add eventually so I don't forget):
//	- Everything that happens on client disconnect.
//	- Cookies system.
//	- Collision forwards.
//	- (right before publishing) check includes to see if I will need to add anything to the prerequisites section of the readme
//	- Add support for held weapons and HOPEFULLY wearables to character preview models.
//  - BUG: If the round changes (IE round A ends then round B starts, or the waiting for players phase ends) while reading a specific character's description,
//		the character select preview model disappears until the player goes back to the main character menu. The preview's outline also permanently breaks
//		when this happens. This is very minor and has no impact on gameplay.

#define PLUGIN_NAME           		  "Chaos Fortress"

#define PLUGIN_AUTHOR         "Spookmaster"
#define PLUGIN_DESCRIPTION    "Team Fortress 2 with custom classes!"
#define PLUGIN_VERSION        "0.0.1"
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

#include <cf_core>

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CF_MakeNatives();
	return APLRes_Success;
}

public void OnPluginStart()
{
	HookEvent("post_inventory_application", PlayerReset);
	//HookEvent("player_spawn", PlayerReset);
	HookEvent("player_death", PlayerKilled);
	HookEvent("teamplay_waiting_begins", Waiting);
	HookEvent("teamplay_round_start", Waiting);
	HookEvent("teamplay_setup_finished", RoundStart);
	HookEvent("teamplay_round_win", RoundEnd);
	HookEvent("teamplay_round_stalemate", RoundEnd);
	HookEvent("player_changeclass", ClassChange);
	
	RegAdminCmd("cf_reloadrules", CF_ReloadRules, ADMFLAG_KICK, "Chaos Fortress: Reloads the settings in game_rules.cfg.");
	RegAdminCmd("cf_reloadcharacters", CF_ReloadCharacters, ADMFLAG_KICK, "Chaos Fortress: Reloads the character packs, as defined in characters.cfg.");
	
	CF_OnPluginStart();
}

#define SND_ADMINCOMMAND		"ui/cyoa_ping_in_progress.wav"

public OnMapStart()
{
	CF_MapStart();
	PrecacheSound(SND_ADMINCOMMAND);
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

public void PlayerReset(Event gEvent, const char[] sEvName, bool bDontBroadcast)
{    
	int client = GetClientOfUserId(gEvent.GetInt("userid"));
	
	if (IsValidClient(client))
	{
		CF_MakeCharacter(client);
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