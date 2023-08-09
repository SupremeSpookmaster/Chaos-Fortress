#if defined _cf_included_
  #endinput
#endif
#define _cf_included_

#include <cf_stocks>
#include <cf_killstreak>
#include <cf_damage>
#include <cf_buttons>
#include <cf_include>

int i_CFRoundState = 0;						//The current round state.

float f_ChargeRetain = 0.0;

bool b_CharacterApplied[MAXPLAYERS + 1] = { false, ... };		//Whether or not the client's character has been applied to them already. If true: skip MakeCharacter for that client. Set to false automatically on death, round end, disconnect, and if the player changes their character selection.
bool b_IgnoreCharacterDefaults = false;

char s_CharacterConfig[MAXPLAYERS+1][255];	//The config currently used for this player's character. If empty: that player is not a character.
char s_DefaultCharacter[255];

/**
 * Retrieves the current round state.
 *
 * @return The current round state. 0: pre-game/waiting for players/setup, 1: round in progress, 2: round has ended.
 */
native CF_GetRoundState();

/**
 * Retrieves the client's current character config.
 *
 * @param client		The client whose config to retrieve.
 * @param buffer		Output buffer.
 * @param size			Output buffer size.
 *
 * @return The config used by the client's current character, stored in the buffer. Returns an empty string is the client is invalid, or not currently a character. 
 */
native CF_GetPlayerConfig(int client, char[] buffer, int size);

/**
 * Sets the client's current character config.
 *
 * @param client		The client whose config to set.
 * @param confName		The new config.
 */
native CF_SetPlayerConfig(int client, char[] confName);

/**
 * Determines whether or not the chosen client is a character.
 *
 * @param client		The client to check.
 *
 * @return True if the client is a character, false if they are invalid or not a character.
 */
native bool CF_IsPlayerCharacter(int client);

/**
 * Creates all of Chaos Fortress' natives.
 */
public void CF_MakeNatives()
{
	RegPluginLibrary("chaos_fortress");
	
	CreateNative("CF_GetRoundState", Native_CF_GetRoundState);
	CreateNative("CF_GetPlayerConfig", Native_CF_GetPlayerConfig);
	CreateNative("CF_SetPlayerConfig", Native_CF_SetPlayerConfig);
	CreateNative("CF_IsPlayerCharacter", Native_CF_IsPlayerCharacter);
	
	CFKS_MakeNatives();
	CFB_MakeNatives();
}

/**
 * Creates all of Chaos Fortress forwards.
 */
public void CF_MakeForwards()
{
	CFDMG_MakeForwards();
	CFB_MakeForwards();
	CFKS_MakeForwards();
}

/**
 * Called when the map starts.
 */
 public void CF_MapStart()
 {
 	CF_SetRoundState(0);

 	CF_SetGameRules();
 	
 	CF_LoadCharacters();
 	
 	CF_PrecacheAnnouncerDialogue();
 }
 
 /**
 * Precaches the dialogue used for announcers.
 */
 public void CF_PrecacheAnnouncerDialogue()
 {
 	//TODO: After reading game_rules, add a check here to only precache files which will be needed.
 }
 
/**
 * Sets the game rules for Chaos Fortress by reading game_rules.cfg.
 */
 public void CF_SetGameRules()
 {
 	//TODO: Make an admin command for this that lets people do this at any time.
 	
 	char filepath[255];
	BuildPath(Path_SM, filepath, PLATFORM_MAX_PATH, "data/chaos_fortress/game_rules.cfg");
	KeyValues kv = new KeyValues("");
	FileToKeyValues(kv, filepath);
 	
 	if (!kv.GotoFirstSubKey())
 	{
 		delete kv;
 		ThrowError("FATAL ERROR: COULD NOT READ FILE ''data/chaos_fortress/game_rules.cfg''.");
 		return;
 	}

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
		
		if (StrEqual(section, "general_rules"))
		{
			#if defined DEBUG_GAMERULES
	        PrintToServer("Now reading general_rules...");
	        #endif
	        
	        kv.GetString("default_character", s_DefaultCharacter, 255);
	        f_ChargeRetain = kv.GetFloat("charge_retain");
	        kv.GetString("ignore_defaults", intStr, 255);
	        b_IgnoreCharacterDefaults = !(StringToInt(intStr) == 0);
	        
	        #if defined DEBUG_GAMERULES
	        PrintToServer("Default Character: %s", s_DefaultCharacter);
	        PrintToServer("Charge Retain: %.2f", f_ChargeRetain);
	        PrintToServer("Ignore Defaults: %i", view_as<int>(b_IgnoreCharacterDefaults));
	        #endif
		}
		
		if (StrEqual(section, "killstreak_settings"))
		{
			#if defined DEBUG_GAMERULES
	        PrintToServer("Now reading killstreak_settings...");
	        #endif
	        
	        kv.GetString("killstreak_announcements", intStr, 255);
	        int announcer = StringToInt(intStr);
	        kv.GetString("killstreak_interval", intStr, 255);
	        int interval = StringToInt(intStr);
	        kv.GetString("killstreak_ended", intStr, 255);
	        int ended = StringToInt(intStr);
	        kv.GetString("killstreak_godlike", intStr, 255);
	        int godlike = StringToInt(intStr);
	        
	        CFKS_Prepare(announcer, interval, ended, godlike);
	        
	        #if defined DEBUG_GAMERULES
	        PrintToServer("Announcer: %i", announcer);
	        PrintToServer("Interval: %i", interval);
	        PrintToServer("Ended: %i", ended);
	        PrintToServer("Godlike: %i", godlike);
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
 * Loads all of the character packs from characters.cfg.
 */
 public void CF_LoadCharacters()
 {
 	//TODO: Load characters here. Also make an admin command for this that lets people do this at any time, if possible.
 }
 
/**
 * Precaches all of the files in the "downloads" and "precache" sections of a given CFG, and adds all files in the former section to the downloads table.
 */
 public void CF_ManageCharacterFiles(/* TODO: Will need to pass something to this */)
 {
 	//TODO: Write this code.
 }

/**
 * Turns a player into their selected Chaos Fortress character, or the default specified in game_rules if they haven't chosen.
 *
 * @param client			The client to convert.
 */
 public void CF_MakeCharacter(int client)
 {
 	if (!IsValidClient(client))
 		return;

	if (b_CharacterApplied[client])
		return;

 	//TODO: Write the code for this, also write a forward called CF_OnCharacterSpawned and have this call it.
 	//For now we have this temporary debug code.
 	CF_SetPlayerConfig(client, "Test Config");
 	b_CharacterApplied[client] = true;
 	
 	SDKUnhook(client, SDKHook_OnTakeDamageAlive, CFDMG_OnTakeDamageAlive);
 	SDKHook(client, SDKHook_OnTakeDamageAlive, CFDMG_OnTakeDamageAlive);
 }
 
/**
 * Disables the player's active Chaos Fortress character.
 *
 * @param client			The client to disable.
 * @param isCharacterChange			Is this just a character change? If true: reduce ultimate charge instead of completely removing it.
 */
 public void CF_UnmakeCharacter(int client, bool isCharacterChange)
 {
 	//TODO: Write the code for this, also write a forward called CF_OnCharacterUnmade and have this call it.
 	//For now we have this temporary debug code.
 	CF_SetPlayerConfig(client, "");
 	SDKUnhook(client, SDKHook_OnTakeDamageAlive, CFDMG_OnTakeDamageAlive);
 	b_CharacterApplied[client] = false;
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
 		//TODO: Write a forward called CF_OnPlayerKilled and call it here.
 	}
 	
 	CFKS_PlayerKilled(victim, attacker, deadRinger);
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
 	
 	#if defined DEBUG_ROUND_STATE
 	CPrintToChatAll("The current round state is %i.", i_CFRoundState);
 	#endif
 }
 
public Native_CF_GetRoundState(Handle plugin, int numParams)
{
	return i_CFRoundState;
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
		char buffer[255] = "";
		CF_GetPlayerConfig(client, buffer, 255);
		
		ReturnValue = !StrEqual(buffer, "");
		
		#if defined DEBUG_CHARACTER_CREATION
		CPrintToChatAll("%N's PlayerConfig was returned to CF_IsPlayerCharacter() as %s. Returning %i.", client, buffer, view_as<int>(ReturnValue));
		#endif
	}
	
	return ReturnValue;
}