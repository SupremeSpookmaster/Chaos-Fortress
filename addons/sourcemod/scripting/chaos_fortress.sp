//#define DEBUG_CHARACTER_CREATION
//#define DEBUG_ROUND_STATE
//#define DEBUG_KILLSTREAKS
//#define DEBUG_ONTAKEDAMAGE
//#define DEBUG_BUTTONS

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
	HookEvent("player_death", PlayerKilled);
	HookEvent("teamplay_waiting_begins", Waiting);
	HookEvent("teamplay_round_start", Waiting);
	HookEvent("teamplay_setup_finished", RoundStart);
	HookEvent("teamplay_round_win", RoundEnd);
	HookEvent("teamplay_round_stalemate", RoundEnd);
	
	CF_MakeForwards();
}

public OnMapStart()
{
	CF_MapStart();
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
		CPrintToChatAll("Detected a button press (this will run every half second instead of every frame to prevent excessive chat spam).");
		DebugButtonsGameTimeToPreventLotsOfAnnoyingSpam = GetGameTime() + 0.5;
	}
	
	return Plugin_Continue;
}

public Action CF_OnPlayerM2(int client, int &buttons, int &impulse, int &weapon)
{
	CPrintToChatAll("Detected a right-click, but we're going to block it to test.");
	
	buttons &= ~IN_ATTACK2;
	
	return Plugin_Changed;
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

#endif