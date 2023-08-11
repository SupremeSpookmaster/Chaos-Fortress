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

int i_CFRoundState = 0;						//The current round state.

float f_ChargeRetain = 0.0;

GlobalForward g_OnPlayerKilled;
GlobalForward g_OnRoundStateChanged;

/**
 * Creates all of Chaos Fortress' natives.
 */
public void CF_MakeNatives()
{
	RegPluginLibrary("chaos_fortress");
	
	CFKS_MakeNatives();
	CFB_MakeNatives();
	CFC_MakeNatives();
}

/**
 * Creates all of Chaos Fortress forwards.
 */
public void CF_MakeForwards()
{
	CFDMG_MakeForwards();
	CFB_MakeForwards();
	CFKS_MakeForwards();
	CFC_MakeForwards();
	
	g_OnPlayerKilled = new GlobalForward("CF_OnPlayerKilled", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_OnRoundStateChanged = new GlobalForward("CF_OnRoundStateChanged", ET_Ignore, Param_Cell);
}

/**
 * Called when the map starts.
 */
 public void CF_MapStart()
 {
 	CF_SetRoundState(0);

 	CF_SetGameRules(-1);
 	
 	CF_LoadCharacters(-1);
 	
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
 	KeyValues kv = GetKeyValuesFromPath("data/chaos_fortress/game_rules.cfg", true, "FATAL ERROR: COULD NOT READ FILE ''data/chaos_fortress/game_rules.cfg''.");

	char intStr[255];

	#if defined DEBUG_GAMERULES
	PrintToServer("//////////////////////////////////////////////");
	PrintToServer("CHAOS FORTRESS GAME_RULES DEBUG MESSAGES BELOW");
	PrintToServer("//////////////////////////////////////////////");
	#endif

	do //TODO: Probably a good idea to abstract this to a method instead of copy/pasting it every time and making small changes...
	{
		char section[255];
		kv.GetSectionName(section, 255);
		
		if (IsValidClient(admin))
	    {
	    	PrintToConsole(admin, "\nNew game rules under section ''%s'' are as follows:", section);
	    }
		
		#if defined DEBUG_GAMERULES
	    PrintToServer("\nNow reading %s...", section);
	    #endif
		
		if (StrEqual(section, "general_rules"))
		{
	        kv.GetString("default_character", s_DefaultCharacter, 255);
	        f_ChargeRetain = kv.GetFloat("charge_retain");
	        kv.GetString("display_role", intStr, 255);
	        b_DisplayRole = !(StringToInt(intStr) == 0);
	        
	        if (IsValidClient(admin))
	        {
	        	PrintToConsole(admin, "\nDefault Character: %s", s_DefaultCharacter);
	        	PrintToConsole(admin, "Ult Charge Retained On Character Switch: %.2f", f_ChargeRetain);
	        	PrintToConsole(admin, "Display Role: %i", view_as<int>(b_DisplayRole));
	        }
	        
	        #if defined DEBUG_GAMERULES
	        PrintToServer("\nDefault Character: %s", s_DefaultCharacter);
	        PrintToServer("Ult Charge Retained On Character Switch: %.2f", f_ChargeRetain);
	        PrintToServer("Display Role: %i", view_as<int>(b_DisplayRole));
	        #endif
		}
		
		if (StrEqual(section, "killstreak_settings"))
		{
	        kv.GetString("killstreak_announcements", intStr, 255);
	        int announcer = StringToInt(intStr);
	        kv.GetString("killstreak_interval", intStr, 255);
	        int interval = StringToInt(intStr);
	        kv.GetString("killstreak_ended", intStr, 255);
	        int ended = StringToInt(intStr);
	        kv.GetString("killstreak_godlike", intStr, 255);
	        int godlike = StringToInt(intStr);
	        
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
		
		if (StrEqual(section, "character_defaults"))
		{
			if (IsValidClient(admin))
		    {
		        PrintToConsole(admin, "\nCharacter defaults are ignored due to current settings, skipping.");
		    }
		        
		    #if defined DEBUG_GAMERULES
	        PrintToServer("\nCharacter defaults are ignored due to current settings, skipping.");
	        #endif
		}
		
	} while (kv.GotoNextKey());
	
	#if defined DEBUG_GAMERULES
	PrintToServer("//////////////////////////////////////////////");
	PrintToServer("CHAOS FORTRESS GAME_RULES DEBUG MESSAGES ABOVE");
	PrintToServer("//////////////////////////////////////////////");
	#endif
	
    delete kv;
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
 	if (!deadRinger)
 	{
 		CF_UnmakeCharacter(victim, false);
 	}
 	
 	CFKS_PlayerKilled(victim, attacker, deadRinger);
 	
 	Call_StartForward(g_OnPlayerKilled);
 	
 	Call_PushCell(victim);
 	Call_PushCell(inflictor);
 	Call_PushCell(attacker);
 	Call_PushCell(view_as<int>(deadRinger));
 	
 	Call_Finish();
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