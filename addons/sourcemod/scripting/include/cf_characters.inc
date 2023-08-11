//Store configs and names in two separate arrays so we aren't reading every single character's config every single time someone opens the !characters menu:

public const char s_ModelFileExtensions[][] =
{
	".dx80.vtx",
	".dx90.vtx",
	".mdl",
	".phy",
	".sw.vtx",
	".vvd"
};

Handle CF_Characters_Configs;
Handle CF_Characters_Names;

Menu CF_CharactersMenu;
Menu CF_ClientMenu[MAXPLAYERS + 1] = { null, ... };

bool b_DisplayRole = true;
bool b_CharacterApplied[MAXPLAYERS + 1] = { false, ... }; //Whether or not the client's character has been applied to them already. If true: skip MakeCharacter for that client. Set to false automatically on death, round end, disconnect, and if the player changes their character selection.

char s_CharacterConfig[MAXPLAYERS+1][255];	//The config currently used for this player's character. If empty: that player is not a character.
char s_CharacterConfigInMenu[MAXPLAYERS+1][255];	//The config currently used this player's info menu.
char s_DesiredCharacterConfig[MAXPLAYERS+1][255];	//The config of the character this player will become next time they spawn.
char s_DefaultCharacter[255];

public void CFC_MakeNatives()
{
	CreateNative("CF_GetRoundState", Native_CF_GetRoundState);
	CreateNative("CF_GetPlayerConfig", Native_CF_GetPlayerConfig);
	CreateNative("CF_SetPlayerConfig", Native_CF_SetPlayerConfig);
	CreateNative("CF_IsPlayerCharacter", Native_CF_IsPlayerCharacter);
}

public void CFC_MakeForwards()
{
	CF_Characters_Configs = CreateArray(255);
	CF_Characters_Names = CreateArray(255);
	
	RegConsoleCmd("characters", CFC_OpenMenu, "Opens the Chaos Fortress character selection menu.");
}

/**
 * Loads all of the characters from data/chaos_fortress/characters.cfg.
 *
 * @param admin		The client index of the admin who reloaded characters.cfg. If valid: prints the new character list to that admin's console.
 */
 public void CF_LoadCharacters(int admin)
 {
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
					CF_LoadCharacterPack(value, false);
				}
 			}
 		}
 		
 		if (StrEqual(section, "Download Character Packs"))
 		{
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
	    			PrintToServer("\nLocated character pack to download files for: %s", value);
	   				#endif
					CF_LoadCharacterPack(value, true);
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
 	else
 	{
 		CF_BuildCharactersMenu();
 	}
 }
 
 public void CF_LoadCharacterPack(char pack[255], bool JustDownload)
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
 		ThrowError("FATAL ERROR: ''Enabled Character Packs'' in characters.cfg states that there should be a character pack titled ''%s'', but no such pack exists.", pack, section);
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

			CF_LoadSpecificCharacter(value, JustDownload);
			
			if (!JustDownload)
			{
				PushArrayString(CF_Characters_Configs, value);
			}
			
			#if defined DEBUG_CHARACTER_CREATION
		    PrintToServer("\nLocated character: %s", value);
		    #endif
		}
 	}
 	
 	delete kv;
 }
 
 public void CF_LoadSpecificCharacter(char path[255], bool JustDownload)
 {
 	char str[255];
 	Format(str, sizeof(str), "FATAL ERROR: COULD NOT READ FILE ''%s''", str);
 	
 	KeyValues kv = GetKeyValuesFromPath(path, true, str);
 	
 	kv.GoBack();
 	
 	kv.GetString("name", str, 255);
 	
 	if (b_DisplayRole)
 	{
 		kv.JumpToKey("menu_display");
 		char role[255];
 		kv.GetString("role", role, 255);
 		Format(str, sizeof(str), "[%s] %s", role, str);
 		kv.GoBack();
 	}
 	
 	if (!JustDownload)
 	{
 		PushArrayString(CF_Characters_Names, str);
 	
 		#if defined DEBUG_CHARACTER_CREATION
		PrintToServer("\nConfig ''%s'' has a character name of ''%s''.", path, str);
 		#endif
 	}
 
 	CF_ManageCharacterFiles(kv);
 }
 
 public void CF_BuildCharactersMenu()
 {
 	CF_CharactersMenu = new Menu(CFC_Menu);
	CF_CharactersMenu.SetTitle("Welcome to Chaos Fortress!\nWhich character would you like to spawn as?");
	
	char name[255];
	for (int i = 0; i < GetArraySize(CF_Characters_Names); i++)
	{
		GetArrayString(CF_Characters_Names, i, name, 255);
		PrintToServer("CREATING CHARACTER MENU: ADDED ITEM ''%s''", name);
		CF_CharactersMenu.AddItem("Character", name);
	}
 }
 
public CFC_Menu(Menu CFC_Menu, MenuAction action, int client, int param)
{	
	if (!IsValidClient(client))
	return;
	
	if (action == MenuAction_Select)
	{
		//TODO: Make a menu which displays character info of CF_Characters_Configs[param]
		char conf[255];
		GetArrayString(CF_Characters_Configs, param, conf, 255);
		
		CFC_BuildInfoMenu(client, conf);		
	}
	else if (action == MenuAction_End || action == MenuAction_Cancel)
	{
		//TODO: Delete this client's character preview model
		if (CF_ClientMenu[client] != null)
			delete CF_ClientMenu[client];
	}
}

public Action CFC_OpenMenu(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Continue;
		
	if (CF_ClientMenu[client] != null)
		delete CF_ClientMenu[client];
		
	CF_ClientMenu[client] = new Menu(CFC_Menu);
	CopyMenu(CF_ClientMenu[client], CF_CharactersMenu);
	CF_ClientMenu[client].Display(client, MENU_TIME_FOREVER);
	
	//TODO: Character preview menu
	
	return Plugin_Continue;
}
 
 public void CFC_BuildInfoMenu(int client, char config[255])
 {
 	if (!IsValidClient(client))
		return;
		
	if (CF_ClientMenu[client] != null)
		delete CF_ClientMenu[client];
	
	KeyValues kv = GetKeyValuesFromPath(config, false, "Error: Could not load character config.");
 	
 	kv.GoBack();
 	
 	char name[255]; char title[255]; char related[255]; char role[255]; char desc[255];
 	kv.GetString("name", name, 255);
 	
 	if (kv.JumpToKey("menu_display"))
 	{
 		kv.GetString("related_class", related, 255);
 		kv.GetString("role", role, 255);
 		kv.GetString("description", desc, 255);
 	}
 	else
 	{
 		kv = GetKeyValuesFromPath("data/chaos_fortress/game_rules.cfg", false, "Error: Could not load game_rules.cfg.");
 		kv.GoBack();
 		
 		if (kv.JumpToKey("character_defaults"))
 		{
 			if (kv.JumpToKey("menu_display"))
 			{
 				kv.GetString("related_class", related, 255);
		 		kv.GetString("role", role, 255);
		 		kv.GetString("description", desc, 255);
 			}
 		}
 	}
 	
 	Format(title, sizeof(title), "%s\n\nSimilar TF2 Class: %s\nRole: %s\n\n%s", name, related, role, desc);
 	
 	s_CharacterConfigInMenu[client] = config;
 	
 	CF_ClientMenu[client] = new Menu(CFC_InfoMenu);
 	CF_ClientMenu[client].SetTitle(title);
 	
 	Format(name, sizeof(name), "Spawn As %s", name);
 	CF_ClientMenu[client].AddItem("Select", name);
 	CF_ClientMenu[client].AddItem("Back", "Go Back");
 	CF_ClientMenu[client].ExitButton = false;
 	CF_ClientMenu[client].Display(client, MENU_TIME_FOREVER);
 	
 	delete kv;
 }
 
 public CFC_InfoMenu(Menu CFC_Menu, MenuAction action, int client, int param)
{	
	if (!IsValidClient(client))
	return;
	
	if (action == MenuAction_Select)
	{
		if (param == 0)
		{
			KeyValues kv = GetKeyValuesFromPath(s_CharacterConfigInMenu[client], false, "Error: Could not load character config.");
			kv.GoBack();
			
			char name[255];
			kv.GetString("name", name, 255);
			Format(name, sizeof(name), "{indigo}[Chaos Fortress] {default}You will respawn as {olive}%s{default}.", name);
			CPrintToChat(client, name);
			
			s_DesiredCharacterConfig[client] = s_CharacterConfigInMenu[client];
			delete kv;
			
			//TODO: Delete this client's character preview model
			if (CF_ClientMenu[client] != null)
				delete CF_ClientMenu[client];
		}
		else
		{
			CFC_OpenMenu(client, 0);
		}		
	}
}

 
/**
 * Precaches all of the files in the "downloads", "model_download", and "precache" sections of a given CFG, and adds all files in the former two to the downloads table.
 */
 public void CF_ManageCharacterFiles(KeyValues kv)
 {
 	if (kv.JumpToKey("model_download"))
 	{
 		//TODO: I REALLY need to find a way to abstract this...
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
				char file[255];
				
				for (int i = 0; i < sizeof(s_ModelFileExtensions); i++)
				{
					Format(file, sizeof(file), "%s%s", value, s_ModelFileExtensions[i]);
					if (CheckFile(file))
					{
						PrecacheModel(file);
						AddFileToDownloadsTable(file);
						
						#if defined DEBUG_CHARACTER_CREATION
					    PrintToServer("Successfully added model file ''%s'' to the downloads table.", file);
					    #endif
					}
					else
					{
						#if defined DEBUG_CHARACTER_CREATION
					    PrintToServer("ERROR: Failed to find model file ''%s''.", file);
					    #endif
					}
				}
			}
	 	}
	 	
	 	kv.GoBack();
 	}
 	
 	if (kv.JumpToKey("downloads"))
 	{
 		//TODO: I REALLY need to find a way to abstract this...
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
				if (CheckFile(value))
				{
					AddFileToDownloadsTable(value);
						
					#if defined DEBUG_CHARACTER_CREATION
					 PrintToServer("Successfully added file ''%s'' to the downloads table.", value);
					 #endif
				}
				else
				{
					#if defined DEBUG_CHARACTER_CREATION
					PrintToServer("ERROR: Failed to find file ''%s''.", value);
					#endif
				}
			}
	 	}
	 	
	 	kv.GoBack();
 	}
 	
 	if (kv.JumpToKey("precache"))
 	{
 		//TODO: I REALLY need to find a way to abstract this...
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
				char file[255];
				
				bool exists = false;
				
				Format(file, sizeof(file), "models/%s", value);
				
				
				if (CheckFile(file))
				{
					PrecacheModel(file);
					exists = true;
					
					#if defined DEBUG_CHARACTER_CREATION
					PrintToServer("Successfully precached file ''%s''.", file);
					#endif
				}
				else
				{
					Format(file, sizeof(file), "sound/%s", value);
					
					if (CheckFile(file))
					{
						PrecacheSound(file);
						exists = true;
					
						#if defined DEBUG_CHARACTER_CREATION
						PrintToServer("Successfully precached file ''%s''.", file);
						#endif
					}
				}
				
				if (!exists)
				{
					#if defined DEBUG_CHARACTER_CREATION
					PrintToServer("Failed to find file ''%s''.", file);
					#endif
				}
			}
	 	}
	 	
	 	kv.GoBack();
 	}
 	
 	delete kv;
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

	//TODO: Apply s_DesiredCharacterConfig to a cookie and read that cookie to determine which character to spawn as.
	//If the cookie is empty: use the default character config specified in game_rules.

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