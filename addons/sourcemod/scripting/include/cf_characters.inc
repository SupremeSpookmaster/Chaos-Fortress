//Store configs and names in two separate arrays so we aren't reading every single character's config every single time someone opens the !characters menu:

Handle CF_Characters_Configs;
Handle CF_Characters_Names;

bool b_CharacterApplied[MAXPLAYERS + 1] = { false, ... }; //Whether or not the client's character has been applied to them already. If true: skip MakeCharacter for that client. Set to false automatically on death, round end, disconnect, and if the player changes their character selection.

char s_CharacterConfig[MAXPLAYERS+1][255];	//The config currently used for this player's character. If empty: that player is not a character.

public void CFC_MakeNatives()
{
	CreateNative("CF_GetRoundState", Native_CF_GetRoundState);
	CreateNative("CF_GetPlayerConfig", Native_CF_GetPlayerConfig);
	CreateNative("CF_SetPlayerConfig", Native_CF_SetPlayerConfig);
	CreateNative("CF_IsPlayerCharacter", Native_CF_IsPlayerCharacter);
}

public void CFC_MakeForwards()
{
	CF_Characters_Configs = CreateArray();
	CF_Characters_Names = CreateArray();
}

/**
 * Loads all of the characters from data/chaos_fortress/characters.cfg.
 *
 * @param admin		The client index of the admin who reloaded game_rules. If valid: prints the new rules to that admin's console.
 */
 public void CF_LoadCharacters(int admin)
 {
 	//TODO: And now comes the hard part... I'll do this tomorrow when I have my caffeine boost.
 	
 	KeyValues kv = GetKeyValuesFromPath("data/chaos_fortress/characters.cfg", true, "FATAL ERROR: COULD NOT READ FILE ''data/chaos_fortress/characters.cfg''.");
 	bool FoundEnabled = false;
 	
 	#if defined DEBUG_CHARACTER_CREATION
	PrintToServer("//////////////////////////////////////////////////");
	PrintToServer("CHAOS FORTRESS CHARACTERS.CFG DEBUG MESSAGES BELOW");
	PrintToServer("//////////////////////////////////////////////////");
	#endif
 	
 	do 
 	{
 		char section[255];
 		kv.GetSectionName(section, 255);
 		
 		#if defined DEBUG_CHARACTER_CREATION
	    PrintToServer("\nNow reading %s...", section);
	    #endif
 		
 		if (StrEqual(section, "Enabled Character Packs"))
 		{
 			FoundEnabled = true;
 			
 			bool breakOut = false;
 			for (int keyNum = 1; !breakOut; keyNum++)
 			{
 				char keyNumToChar[128];
				IntToString(keyNum, keyNumToChar, sizeof(keyNumToChar));
				
				char value[255];
				kv.GetString(keyNumToChar, value, sizeof(value));
				
				if (StrEqual(value, ""))
				{
					breakOut = true;
				}
				else
				{
					#if defined DEBUG_CHARACTER_CREATION
	    			PrintToServer("\nLocated character pack: %s", value);
	   				#endif
					CF_LoadCharacterPack(value);
				}
 			}
 		}
 	} 
 	while (kv.GotoNextKey());
 	
 	delete kv;
 	
 	if (!FoundEnabled)
 	{
 		PrintToServer("WARNING: Chaos Fortress was able to locate your characters.cfg file, but it is missing the ''Enabled Character Packs'' block. As a result, your installation of Chaos Fortress has no characters...");
 	}
 }
 
 public void CF_LoadCharacterPack(char pack[255])
 {
 	KeyValues kv = GetKeyValuesFromPath("data/chaos_fortress/characters.cfg", true, "FATAL ERROR: COULD NOT READ FILE ''data/chaos_fortress/characters.cfg''.");
 	
 	#if defined DEBUG_CHARACTER_CREATION
	PrintToServer("\nNow searching character pack ''%s''...", pack);
	#endif
 	
 	kv.GoBack();
 	if (!kv.JumpToKey(pack))
 	{
 		char section[255];
 		kv.GetSectionName(section, 255);
 		ThrowError("FATAL ERROR: ''Enabled Character Packs'' in characters.cfg states that there should be a character pack titled ''%s'', but no such pack exists. Current section is ''%s''.", pack, section);
 	}
 	
 	bool breakOut = false;
 	for (int keyNum = 1; !breakOut; keyNum++)
 	{
 		char keyNumToChar[128];
		IntToString(keyNum, keyNumToChar, sizeof(keyNumToChar));
				
		char value[255];
		kv.GetString(keyNumToChar, value, sizeof(value));
				
		if (StrEqual(value, ""))
		{
			breakOut = true;
		}
		else
		{
			Format(value, sizeof(value), "configs/chaos_fortress/%s.cfg", value);

			CF_LoadSpecificCharacter(value);
			
			PushArrayString(CF_Characters_Configs, value);
			
			#if defined DEBUG_CHARACTER_CREATION
		    PrintToServer("\nLocated character: %s", value);
		    #endif
		}
 	}
 	
 	delete kv;
 }
 
 public void CF_LoadSpecificCharacter(char path[255])
 {
 	char str[255];
 	Format(str, sizeof(str), "FATAL ERROR: COULD NOT READ FILE ''%s''", str);
 	
 	KeyValues kv = GetKeyValuesFromPath(path, true, str);
 	
 	kv.GoBack();
 	
 	kv.GetString("name", str, 255);
 	
 	PushArrayString(CF_Characters_Names, str);
 	
 	#if defined DEBUG_CHARACTER_CREATION
	PrintToServer("\nConfig ''%s'' has a character name of ''%s''.", path, str);
 	#endif
 
 	//CF_ManageCharacterFiles(path);
 }
 
/**
 * Precaches all of the files in the "downloads" and "precache" sections of a given CFG, and adds all files in the former section to the downloads table.
 */
 public void CF_ManageCharacterFiles(char path[255])
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