#define MODEL_PREVIEW_DOORS		"models/vgui/versus_doors_win.mdl"
#define MODEL_PREVIEW_STAGE		"models/props_ui/competitive_stage.mdl"
#define MODEL_PREVIEW_UNKNOWN	"models/class_menu/random_class_icon.mdl"

#define SOUND_CHARACTER_PREVIEW	"ui/quest_status_tick_advanced_pda.wav"

public const char s_PreviewParticles[][] =
{
	"drg_wrenchmotron_teleport",
	"wrenchmotron_teleport_beam",
	"wrenchmotron_teleport_flash",
	"wrenchmotron_teleport_glow_big",
	"wrenchmotron_teleport_sparks"
};

public const char s_ModelFileExtensions[][] =
{
	".dx80.vtx",
	".dx90.vtx",
	".mdl",
	".phy",
	".sw.vtx",
	".vvd"
};

//Store configs and names in two separate arrays so we aren't reading every single character's config every single time someone opens the !characters menu:
Handle CF_Characters_Configs;
Handle CF_Characters_Names;

Menu CF_CharactersMenu;
Menu CF_ClientMenu[MAXPLAYERS + 1] = { null, ... };

int i_CFPreviewModel[MAXPLAYERS + 1] = { -1, ... };
int i_PreviewOwner[2049] = { -1, ... };
int i_CFPreviewProp[MAXPLAYERS + 1] = { -1, ... };
int i_CFPreviewWeapon[MAXPLAYERS + 1] = { -1, ... };

float f_CFPreviewRotation[MAXPLAYERS + 1] = { 0.0, ... };
//These would have been so damn cool but there are too many situations in which it just wouldn't look good...
//int i_CFPreviewStage[MAXPLAYERS + 1] = { -1, ... };
//int i_CFPreviewCam[MAXPLAYERS + 1] = { -1, ... };

bool b_DisplayRole = true;
bool b_CharacterApplied[MAXPLAYERS + 1] = { false, ... }; //Whether or not the client's character has been applied to them already. If true: skip MakeCharacter for that client. Set to false automatically on death, round end, disconnect, and if the player changes their character selection.
bool b_SpawnPreviewParticleNextFrame[MAXPLAYERS + 1] = { false, ... };

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
	
	PrecacheModel(MODEL_PREVIEW_DOORS);
	PrecacheModel(MODEL_PREVIEW_STAGE);
	PrecacheModel(MODEL_PREVIEW_UNKNOWN);
	PrecacheSound(SOUND_CHARACTER_PREVIEW);
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
 	
 	if (CF_Characters_Configs != null)
 	{
 		delete CF_Characters_Configs;
 		CF_Characters_Configs = CreateArray(255);
 	}
 	
 	if (CF_Characters_Names != null)
 	{
 		delete CF_Characters_Names;
 		CF_Characters_Names = CreateArray(255);
 	}
 	
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
		
		#if defined DEBUG_CHARACTER_CREATION
		PrintToServer("CREATING CHARACTER MENU: ADDED ITEM ''%s''", name);
		#endif
		
		CF_CharactersMenu.AddItem("Character", name);
	}
 }
 
public CFC_Menu(Menu CFC_Menu, MenuAction action, int client, int param)
{	
	if (!IsValidClient(client))
	return;
	
	if (action == MenuAction_Select)
	{
		char conf[255];
		GetArrayString(CF_Characters_Configs, param, conf, 255);
		
		CFC_BuildInfoMenu(client, conf);		
	}
	else if (action == MenuAction_End || action == MenuAction_Cancel)
	{
		if (CF_ClientMenu[client] != null)
			delete CF_ClientMenu[client];
			
		CF_DeletePreviewModel(client);
	}
}

public void CF_DeletePreviewModel(int client)
{
	if (!IsValidClient(client))
		return;
		
	if (!CF_PreviewModelActive(client))
		return;
		
	CreateTimer(0.0, Timer_RemoveEntity, i_CFPreviewModel[client], TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.0, Timer_RemoveEntity, i_CFPreviewProp[client], TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.0, Timer_RemoveEntity, i_CFPreviewWeapon[client], TIMER_FLAG_NO_MAPCHANGE);
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
	
	if (!CF_PreviewModelActive(client))
	{
		float spawnLoc[3];
		GetClientEyePosition(client, spawnLoc);
			
		float aimLoc[3];
		Handle trace = getAimTrace(client);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(aimLoc, trace);
		}
		CloseHandle(trace);
		
		if (GetVectorDistance(spawnLoc, aimLoc, true) >= 140.0)
		{
			float constraint = 140.0/GetVectorDistance(spawnLoc, aimLoc);
			
			for (int i = 0; i < 3; i++)
			{
				aimLoc[i] = ((aimLoc[i] - spawnLoc[i]) * constraint) + spawnLoc[i];
			}
		}
		
		float ang[3];
		GetClientEyeAngles(client, ang);
		ang[0] = 0.0;
		ang[1] *= -1.0;
		ang[2] = 0.0;
		aimLoc[2] -= 40.0;
		
		char skin[255] = "0";
		if (TF2_GetClientTeam(client) == TFTeam_Blue)
		{
			skin = "1";
		}
		
		int preview = SpawnDummyModel(MODEL_PREVIEW_UNKNOWN, "selection", aimLoc, ang, skin);
		TF2_CreateGlow(preview, 0);
		int text = AttachWorldTextToEntity(preview, "Character Preview", "root", _, _, _, 100.0);
		
		int physProp = CreateEntityByName("prop_physics_override");
			
		if (IsValidEntity(physProp))
		{
			DispatchKeyValue(physProp, "targetname", "droneparent"); 
			DispatchKeyValue(physProp, "spawnflags", "4"); 
			DispatchKeyValue(physProp, "model", "models/props_c17/canister01a.mdl");
				
			DispatchSpawn(physProp);
				
			ActivateEntity(physProp);
			
			DispatchKeyValue(physProp, "Health", "9999999999");
			SetEntProp(physProp, Prop_Data, "m_takedamage", 0, 1);
					
			SetEntPropEnt(physProp, Prop_Data, "m_hOwnerEntity", client);
			SetEntProp(physProp, Prop_Send, "m_fEffects", 32); //EF_NODRAW
			
			aimLoc[2] += 40.0;
			TeleportEntity(physProp, aimLoc, ang, NULL_VECTOR);
			
			//SetEntityMoveType(physProp, MOVETYPE_NOCLIP);
			
			SetVariantString("!activator");
			AcceptEntityInput(preview, "SetParent", physProp);
		 
			SetEntityCollisionGroup(physProp, 0);
			SetEntProp(physProp, Prop_Send, "m_usSolidFlags", 12); 
			SetEntProp(physProp, Prop_Data, "m_nSolidType", 0x0004); 
			SetEntityGravity(physProp, 0.0);
			
			i_CFPreviewProp[client] = EntIndexToEntRef(physProp);
		}
		
		if (IsValidEntity(text))
		{
			i_PreviewOwner[text] = GetClientUserId(client);
			//SDKHook(text, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		}
		
		i_PreviewOwner[preview] = GetClientUserId(client);
		
		//SDKHook(preview, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		
		i_CFPreviewModel[client] = EntIndexToEntRef(preview);
		SDKHook(client, SDKHook_PreThink, CF_PreviewModelPreThink);
		f_CFPreviewRotation[client] = 0.0;
	}
	else
	{
		int preview = EntRefToEntIndex(i_CFPreviewModel[client]);
		SetEntityModel(preview, MODEL_PREVIEW_UNKNOWN);
		ChangeModelAnimation(preview, "selection", 1.0);
		int wep = EntRefToEntIndex(i_CFPreviewWeapon[client]);
		if (IsValidEntity(wep))
		{
			RemoveEntity(wep);
		}
	}
	
	return Plugin_Continue;
}
 
 public Action CF_PreviewModelPreThink(int client)
 {
 	if (!CF_PreviewModelActive(client))
 		return Plugin_Stop;
 	
	int preview = EntRefToEntIndex(i_CFPreviewModel[client]);
	int prop = EntRefToEntIndex(i_CFPreviewProp[client]);
	
	float spawnLoc[3];
	GetClientEyePosition(client, spawnLoc);
			
	float aimLoc[3];
	Handle trace = getAimTrace(client);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(aimLoc, trace);
	}
	CloseHandle(trace);
		
	if (GetVectorDistance(spawnLoc, aimLoc, true) >= 140.0)
	{
		float constraint = 140.0/GetVectorDistance(spawnLoc, aimLoc);
			
		for (int i = 0; i < 3; i++)
		{
			aimLoc[i] = ((aimLoc[i] - spawnLoc[i]) * constraint) + spawnLoc[i];
		}
	}
		
	float ang[3], DummyAng[3];
	GetClientEyeAngles(client, DummyAng);
	GetAngleToPoint(prop, spawnLoc, DummyAng, ang, 0.0, 0.0, 40.0);
	aimLoc[2] -= 40.0;
		
	char skin[255] = "0";
	if (TF2_GetClientTeam(client) == TFTeam_Blue)
	{
		skin = "1";
	}
	
	if (b_SpawnPreviewParticleNextFrame[client])
	{
		b_SpawnPreviewParticleNextFrame[client] = false;
		
		if (TF2_GetClientTeam(client) == TFTeam_Red)
		{
			int part = SpawnParticle(aimLoc, "teleportedin_red", 2.0);
			i_PreviewOwner[part] = GetClientUserId(client);
			//SDKHook(part, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		}
		else
		{
			int part = SpawnParticle(aimLoc, "teleportedin_blue", 2.0);
			i_PreviewOwner[part] = GetClientUserId(client);
			//SDKHook(part, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		}
		
		EmitSoundToClient(client, SOUND_CHARACTER_PREVIEW);
	}
	
	aimLoc[2] += 40.0;
	f_CFPreviewRotation[client] += 1.0;
	ang[1] += f_CFPreviewRotation[client];
	PhysProp_MoveToTargetPosition_Preview(prop, client, ang);
	//TeleportEntity(preview, NULL_VECTOR, ang, NULL_VECTOR);
	ChangeModelSkin(preview, skin);
 	
 	return Plugin_Continue;
 }
 
 public Action CF_PreviewModelTransmit(int client, int entity)
 {
 	if (client != GetClientOfUserId(i_PreviewOwner[entity]))
 	{
 		return Plugin_Handled;
 	}
 		
 	return Plugin_Continue;
 }
 
 bool CF_PreviewModelActive(int client)
 {
 	if (!IsValidClient(client))
 		return false;
 		
 	return IsValidEntity(EntRefToEntIndex(i_CFPreviewModel[client])) && IsValidEntity(EntRefToEntIndex(i_CFPreviewProp[client]));
 }
 
 public void CFC_BuildInfoMenu(int client, char config[255])
 {
 	if (!IsValidClient(client))
		return;
		
	if (CF_ClientMenu[client] != null)
		delete CF_ClientMenu[client];
	
	KeyValues kv = GetKeyValuesFromPath(config, false, "Error: Could not load character config.");
 	
 	kv.GoBack();
 	
 	char name[255]; char title[255]; char related[255]; char role[255]; char desc[255]; char model[255] = ""; char weapon[255]; char attachment[255]; char sequence[255];
 	kv.GetString("name", name, 255);
 	
 	if (kv.JumpToKey("menu_display"))
 	{
 		kv.GetString("related_class", related, 255);
 		kv.GetString("role", role, 255);
 		kv.GetString("description", desc, 255);
 		kv.GetString("preview_sequence", sequence, 255);
 		kv.GetString("preview_weapon", weapon, 255);
 		kv.GetString("preview_attachment", attachment, 255);
 		
 		kv.GoBack();
 		kv.GetString("model", model, 255);
 		kv.JumpToKey("menu_display");
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
		 		kv.GetString("preview_weapon", weapon, 255);
 				kv.GetString("preview_attachment", attachment, 255);
 			}
 		}
 	}
 	
 	if (!StrEqual(model, "") && CheckFile(model) && CF_PreviewModelActive(client))
 	{
 		int preview = EntRefToEntIndex(i_CFPreviewModel[client]);
 		SetEntityModel(preview, model);
 		ChangeModelAnimation(preview, sequence, 1.0);
 		
 		if (!StrEqual(weapon, "") && CheckFile(weapon))
 		{
 			PrecacheModel(weapon);
 			
 			if (StrEqual(attachment, ""))
 			{
 				attachment = "weapon_bone";
 			}
 			
 			char skin[255] = "0";
 			if (TF2_GetClientTeam(client) == TFTeam_Blue)
 			{
 				skin = "1";
 			}
 			
 			float xOff = kv.GetFloat("attachment_x_offset");
 			float yOff = kv.GetFloat("attachment_y_offset");
 			float zOff = kv.GetFloat("attachment_z_offset");
 			float xRot = kv.GetFloat("attachment_x_rotation");
 			float yRot = kv.GetFloat("attachment_y_rotation");
 			float zRot = kv.GetFloat("attachment_z_rotation");
 			
 			int wep = AttachModelToEntity(weapon, attachment, preview, _, skin, xOff, yOff, zOff, xRot, yRot, zRot);
 			if (IsValidEntity(wep))
 			{
 				i_CFPreviewWeapon[client] = EntIndexToEntRef(wep);
 			}
 			
 			b_SpawnPreviewParticleNextFrame[client] = true;
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
			
			if (CF_ClientMenu[client] != null)
				delete CF_ClientMenu[client];
				
			CF_DeletePreviewModel(client);
		}
		else
		{
			CFC_OpenMenu(client, 0);
		}		
	}
	else if (action == MenuAction_End || action == MenuAction_Cancel)
	{
		if (CF_ClientMenu[client] != null)
			delete CF_ClientMenu[client];
				
		CF_DeletePreviewModel(client);
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
				char fileCheck[255], actualFile[255];
				
				for (int i = 0; i < sizeof(s_ModelFileExtensions); i++)
				{
					Format(fileCheck, sizeof(fileCheck), "models/%s%s", value, s_ModelFileExtensions[i]);
					Format(actualFile, sizeof(actualFile), "%s%s", value, s_ModelFileExtensions[i]);
					if (CheckFile(fileCheck))
					{
						if (StrEqual(s_ModelFileExtensions[i], ".mdl"))
						{
							PrecacheModel(fileCheck);
						}

						AddFileToDownloadsTable(fileCheck);
						
						#if defined DEBUG_CHARACTER_CREATION
					    PrintToServer("Successfully added model file ''%s'' to the downloads table.", fileCheck);
					    #endif
					}
					else
					{
						#if defined DEBUG_CHARACTER_CREATION
					    PrintToServer("ERROR: Failed to find model file ''%s''.", fileCheck);
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