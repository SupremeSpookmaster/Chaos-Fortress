bool b_CharacterApplied[MAXPLAYERS + 1] = { false, ... }; //Whether or not the client's character has been applied to them already. If true: skip MakeCharacter for that client. Set to false automatically on death, round end, disconnect, and if the player changes their character selection.

char s_CharacterConfig[MAXPLAYERS+1][255];	//The config currently used for this player's character. If empty: that player is not a character.

public void CFC_MakeNatives()
{
	CreateNative("CF_GetRoundState", Native_CF_GetRoundState);
	CreateNative("CF_GetPlayerConfig", Native_CF_GetPlayerConfig);
	CreateNative("CF_SetPlayerConfig", Native_CF_SetPlayerConfig);
	CreateNative("CF_IsPlayerCharacter", Native_CF_IsPlayerCharacter);
}

/**
 * Loads all of the characters from data/chaos_fortress/characters.cfg.
 *
 * @param admin		The client index of the admin who reloaded game_rules. If valid: prints the new rules to that admin's console.
 */
 public void CF_LoadCharacters(int admin)
 {
 	//TODO: And now comes the hard part... I'll do this tomorrow when I have my caffeine boost.
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