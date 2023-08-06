#define DEBUG

//WARNING: To use this template, just use CTRL+F to replace all instances of "bvb_my_boss" and "my_ability" with whatever you need.
//Technically you don't actually need a MYABILITY, but it's something I like to use for my plugins.
//If you want to be even more organized, just use CTRL+F to replace all instances of MyBoss with whatever you want your plugin name to be
//defined as.

#define MYBOSS           		  "bvb_my_boss"
#define MYABILITY				  	  "my_ability"

#define PLUGIN_AUTHOR         "Spookmaster"
#define PLUGIN_DESCRIPTION    "the man"
#define PLUGIN_VERSION        "1.0"
#define PLUGIN_URL            ""

#include <spooky_stocks>

#pragma semicolon 1

public Plugin myinfo =
{
	name = MYBOSS,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

Handle DashHUD;

public void OnPluginStart()
{
	DashHUD = CreateHudSynchronizer();
	
	HookEvent("player_death", PlayerKilled);
	HookEvent("teamplay_round_win", RoundEnd);
}

public OnMapStart()
{
	
}

  ////////////////////////////////////
 //// ROUND START/INITIALIZATION ////
////////////////////////////////////

public void FF2R_OnBossCreated(int client, BossData cfg, bool setup)
{
	if (setup)
		return;
		
	PrepareMyBoss(client);
	
	SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
}

int MyBoss_NumTimers[MAXPLAYERS+1] = {0, ...};

bool MyBoss_Active[MAXPLAYERS+1] = {false, ...};

public void PrepareMyBoss(int client)
{
	if (!IsValidMulti(client))
	return;
	
	DestroyEverything(client); //Set everything to the default before messing around
	
	int IDX = FF2_GetBossIndex(client);
	
	if (FF2_HasAbility(IDX, MYBOSS, MYABILITY))
	{
		PrepareMyAbility(client, IDX);
		FF2_SetFF2flags(client, FF2_GetFF2flags(client) & FF2FLAG_HUDDISABLED);
	}
}

  ////////////////////
 //// MyBoss MYABILITY ////
////////////////////

public void PrepareMyAbility(int client, int IDX)
{
	if (!IsValidMulti(client))
		return;
	
	MyBoss_Active[client] = true;
	
	if (MyBoss_NumTimers[client] < 1)
	{
		CreateTimer(0.1, MyBoss_ShowHUD, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		MyBoss_NumTimers[client] += 1;
	}
}

  //////////////////////////////
 //// Triggering Abilities ////
//////////////////////////////

public Action MyBoss_ShowHUD(Handle CentralTimer, int id)
{
	int client = GetClientOfUserId(id);
	
	if (client < 1 || client > MaxClients)
		return Plugin_Stop;
	
	if (!IsValidMulti(client) || MyBoss_NumTimers[client] > 1 || !MyBoss_Active[client])
	{
		MyBoss_NumTimers[client] += -1;
		return Plugin_Stop;
	}
	
	char HUDText[255];
	int r = 120;
	int g = 255;
	int b = 120;
	
	int IDX = FF2_GetBossIndex(client);
	float rage = FF2_GetBossCharge(IDX, 0);
	
	if (rage >= 100.0)
	{
		r = 255;
		g = 120;
	}
	
	
	SetHudTextParams(-1.0, 0.85, 0.1, r, g, b, 255);
	ShowSyncHudText(client, DashHUD, HUDText);
	
	return Plugin_Continue;
}

//Only uncomment if needed:
/*public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] classname, bool &result)
{
	Action action = Plugin_Continue;
	
	if (MyBoss_Active[client] && IsValidMulti(client) && IsValidEntity(weapon))
	{
		
	}
	
	return action;
}*/

public Action:OnTakeDamageAlive(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon,
	Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	if (!IsValidClient(attacker) || !IsValidClient(victim))
	return Plugin_Continue;
	
	Action ReturnValue = Plugin_Continue;
	
	if (!IsInvuln(victim))
	{
		
	}
	
	return ReturnValue;
}

public Action:FF2_OnAbility(boss, const char[] pluginName, const char[] abilityName, slot, status)
{
	FF2_OnAbility2(boss, pluginName, abilityName, slot);
	return Plugin_Continue;
}

public Action:FF2_OnAbility2(index, const char[] plugin_name, const char[] ability_name, action)
{
	int client = GetClientOfUserId(FF2_GetBossUserId(index));
	
	if (IsValidMulti(client))
	{
		if (!strcmp(ability_name, MYABILITY))
		{
		}
	}
}

  ///////////////////
 //// CLEAN-UP /////
///////////////////

public Action PlayerKilled(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int victim = GetClientOfUserId(hEvent.GetInt("userid"));
	
	if(GetEventInt(hEvent, "death_flags") & TF_DEATHFLAG_DEADRINGER) //Ignore Dead Ringers
	return Plugin_Continue;
	
	if (IsValidClient(victim))
	{
		DestroyEverything(victim);
	}
	
	return Plugin_Continue;
}

public void RoundEnd(Event hEvent, const char[] sEvName, bool bDontBroadcast) //Cycles through all players and resets their variables at the end of the round.
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client))
		{
			DestroyEverything(client);
		}
	}
}

public void DestroyEverything(int client)
{
	if (IsValidClient(client))
	{
		SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
		FF2_SetFF2flags(client, FF2_GetFF2flags(client) & ~FF2FLAG_HUDDISABLED);
	}
	
	MyBoss_Active[client] = false;
}