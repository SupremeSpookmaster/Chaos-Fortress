#if defined _cf_included_
  #endinput
#endif
#define _cf_included_

#include <cf_stocks>

public int CF_RoundState = 0;

native CF_GetRoundState();

//Creates all of Chaos Fortress' natives.
public void CF_MakeNatives()
{
	CreateNative("CF_GetRoundState", Native_CF_GetRoundState);
}

/**
 * Called when the map starts.
 */
 public void CF_MapStart()
 {
 	CF_RoundState = 0;
 	CF_SetGameRules();
 	CF_LoadCharacters();
 }
 
/**
 * Sets the game rules for Chaos Fortress by reading game_rules.cfg.
 */
 public void CF_SetGameRules()
 {
 	//TODO: Read game_rules here and apply them to variables. Also make an admin command for this that lets people do this at any time.
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
 	//TODO: Write the code for this, also write a forward called CF_OnCharacterSpawned and have this call it.
 }
 
/**
 * Disables the player's active Chaos Fortress character.
 *
 * @param client			The client to disable.
 */
 public void CF_UnmakeCharacter(int client)
 {
 	//TODO: Write the code for this, also write a forward called CF_OnCharacterUnmade and have this call it.
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
 		CF_UnmakeCharacter(victim);
 		//TODO: Write a forward called CF_OnPlayerKilled and call it here.
 	}
 }
 
/**
 * Called when the round starts.
 */
 public void CF_RoundStart()
 {
 	CF_RoundState = 1;
 }
 
/**
 * Called when the round ends.
 */
 public void CF_RoundEnd()
 {
 	CF_RoundState = 2;
 }
 
/**
 * @return The current round state. 0: pre-game, 1: round in progress, 2: round has ended.
 */
public Native_CF_GetRoundState(Handle plugin, int numParams)
{
	return CF_RoundState;
}