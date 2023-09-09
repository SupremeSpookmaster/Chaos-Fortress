#if defined _cf_included_
  #endinput
#endif
#define _cf_included_

#include <cf_stocks>
#include <cf_killstreak>
#include <cf_damage>
#include <cf_buttons>
#include <cf_include>
#include <cf_characters>
#include <cf_sounds>
#include <cf_weapons>
#include <cf_abilities>

int i_CFRoundState = 0;						//The current round state.

GlobalForward g_OnPlayerKilled;
GlobalForward g_OnRoundStateChanged;

public ConfigMap GameRules;

ConVar g_WeaponDropLifespan;

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
	
	g_OnPlayerKilled = new GlobalForward("CF_OnPlayerKilled", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_OnRoundStateChanged = new GlobalForward("CF_OnRoundStateChanged", ET_Ignore, Param_Cell);
	
	g_WeaponDropLifespan = FindConVar("tf_dropped_weapon_lifetime");
	g_WeaponDropLifespan.IntValue = 0;
}

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
 	
 	//CF_PrecacheAnnouncerDialogue();
 }
 
 /**
 * Precaches the dialogue used for announcers.
 */
 /*public void CF_PrecacheAnnouncerDialogue()
 {
 	//TODO: After reading game_rules, add a check here to only precache files which will be needed.
 	//This may not actually be necessary, we already precache killstreak announcer dialogue and the in-game announcer should be enough for in-game events.
 }*/
 
/**
 * Sets the game rules for Chaos Fortress by reading game_rules.cfg.
 *
 * @param admin		The client index of the admin who reloaded game_rules. If valid: prints the new rules to that admin's console.
 */
 public void CF_SetGameRules(int admin)
 { 	
 	DeleteCfg(GameRules);
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
	
	DeleteCfg(GameRules);
	
	#if defined DEBUG_GAMERULES
	PrintToServer("//////////////////////////////////////////////");
	PrintToServer("CHAOS FORTRESS GAME_RULES DEBUG MESSAGES ABOVE");
	PrintToServer("//////////////////////////////////////////////");
	#endif
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
 
 public void UnmakeAfterDelay(int id)
 {
 	int victim = GetClientOfUserId(id);
 	if (IsValidClient(victim))
 	{
 		CF_UnmakeCharacter(victim, false);
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
 	i_CFRoundState = state;
 	
 	if (state == 0)
 	{
 		for (int i = 1; i <= MaxClients; i++)
 		{
 			CF_SetKillstreak(i, 0, 0, false);
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
	return i_CFRoundState;
}

public void OnGameFrame()
{
	#if defined USE_PREVIEWS
	CFC_OGF();
	#endif
}