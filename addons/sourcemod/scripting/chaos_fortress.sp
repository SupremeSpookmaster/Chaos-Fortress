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

#include <cf_stocks>

public void OnPluginStart()
{
	HookEvent("player_death", PlayerKilled);
	HookEvent("teamplay_round_win", RoundEnd);
}

public OnMapStart()
{
	
}

public Action PlayerKilled(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int victim = GetClientOfUserId(hEvent.GetInt("userid"));
	
	if(GetEventInt(hEvent, "death_flags") & TF_DEATHFLAG_DEADRINGER) //Ignore Dead Ringers
	return Plugin_Continue;
	
	if (IsValidClient(victim))
	{
		
	}
	
	return Plugin_Continue;
}

public void RoundEnd(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
}