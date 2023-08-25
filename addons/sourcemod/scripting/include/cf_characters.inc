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

public const TFClassType Classes[] = 
{
	TFClass_Scout,
	TFClass_Soldier,
	TFClass_Pyro,
	TFClass_DemoMan,
	TFClass_Heavy,
	TFClass_Engineer,
	TFClass_Medic,
	TFClass_Sniper,
	TFClass_Spy
};

public const float f_ClassBaseHP[] =
{
	125.0,
	200.0,
	175.0,
	175.0,
	300.0,
	125.0,
	150.0,
	125.0,
	125.0
};

//Store configs and names in two separate arrays so we aren't reading every single character's config every single time someone opens the !characters menu:
Handle CF_Characters_Configs;
Handle CF_Characters_Names;

ConfigMap Characters;

Menu CF_CharactersMenu;
Menu CF_ClientMenu[MAXPLAYERS + 1] = { null, ... };

int i_CFPreviewModel[MAXPLAYERS + 1] = { -1, ... };
int i_PreviewOwner[2049] = { -1, ... };
int i_CFPreviewProp[MAXPLAYERS + 1] = { -1, ... };
int i_CFPreviewWeapon[MAXPLAYERS + 1] = { -1, ... };
int i_CharacterModelIndex[MAXPLAYERS+1];

float f_CFPreviewRotation[MAXPLAYERS + 1] = { 0.0, ... };
//These would have been so damn cool but there are too many situations in which it just wouldn't look good...
//int i_CFPreviewStage[MAXPLAYERS + 1] = { -1, ... };
//int i_CFPreviewCam[MAXPLAYERS + 1] = { -1, ... };

bool b_DisplayRole = true;
bool b_CharacterApplied[MAXPLAYERS + 1] = { false, ... }; //Whether or not the client's character has been applied to them already. If true: skip MakeCharacter for that client. Set to false automatically on death, round end, disconnect, and if the player changes their character selection.
bool b_SpawnPreviewParticleNextFrame[MAXPLAYERS + 1] = { false, ... };
bool b_ReadingLore[MAXPLAYERS + 1] = { false, ... };
bool b_IsDead[MAXPLAYERS + 1] = { false, ... };

char s_CharacterConfig[MAXPLAYERS+1][255];	//The config currently used for this player's character. If empty: that player is not a character.
char s_CharacterConfigInMenu[MAXPLAYERS+1][255];	//The config currently used this player's info menu.
//char s_DesiredCharacterConfig[MAXPLAYERS+1][255];	//The config of the character this player will become next time they spawn.
char s_DefaultCharacter[255];

Handle c_DesiredCharacter;

public void CFC_MakeNatives()
{
	CreateNative("CF_GetRoundState", Native_CF_GetRoundState);
	CreateNative("CF_GetPlayerConfig", Native_CF_GetPlayerConfig);
	CreateNative("CF_SetPlayerConfig", Native_CF_SetPlayerConfig);
	CreateNative("CF_IsPlayerCharacter", Native_CF_IsPlayerCharacter);
	CreateNative("CF_GetCharacterClass", Native_CF_GetCharacterClass);
}

public void CFC_MakeForwards()
{
	CF_Characters_Configs = CreateArray(255);
	CF_Characters_Names = CreateArray(255);
	
	RegConsoleCmd("characters", CFC_OpenMenu, "Opens the Chaos Fortress character selection menu.");
	
	c_DesiredCharacter = RegClientCookie("DesiredCharacter", "The character this player has chosen to spawn as. If blank: reverts to the default character.", CookieAccess_Private);
	
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
 	if (Characters != null)
 		delete Characters;
 		
 	Characters = new ConfigMap("data/chaos_fortress/characters.cfg");
 	
 	if (Characters == null)
 		ThrowError("FATAL ERROR: FAILED TO LOAD data/chaos_fortress/characters.cfg!");
 		
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
 	
 	FoundEnabled = CF_CheckPack("characters.Enabled Character Packs", false);
 	CF_CheckPack("characters.Download Character Packs", true);
 	
 	if (!FoundEnabled)
 	{
 		PrintToServer("WARNING: Chaos Fortress was able to locate your characters.cfg file, but it is missing the ''Enabled Character Packs'' block. As a result, your installation of Chaos Fortress has no characters...");
 	}
 	else
 	{
 		CF_BuildCharactersMenu();
 	}
 }
 
 public bool CF_CheckPack(char[] path, bool JustDownload)
 {
 	ConfigMap subsection = Characters.GetSection(path);
 	if (subsection != null)
 	{
 		char value[255];
 		for (int i = 1; i <= subsection.Size; i++)
 		{
 			subsection.GetIntKey(i, value, sizeof(value));
 			
 			#if defined DEBUG_CHARACTER_CREATION
 			if (JustDownload)
 			{
	    		PrintToServer("\nLocated download pack: %s", value);
			}
			else
	    	{
	    		PrintToServer("\nLocated character pack: %s", value);
	    	}
	   		#endif
	   		
	   		CF_LoadCharacterPack(value, JustDownload);
 		}
 		
 		delete subsection;
 		
 		return true;
 	}

 	return false;
 }
 
 public void CF_LoadCharacterPack(char pack[255], bool JustDownload)
 {
 	char packChar[255];
 	Format(packChar, sizeof(packChar), "characters.%s", pack);
 	
 	ConfigMap Pack = Characters.GetSection(packChar);
 	
 	if (Pack == null)
 	{
 		PrintToServer("WARNING: data/chaos_fortress/characters.cfg defines a character pack titled ''%s'', but no such pack exists inside of the config. Skipping character pack...", pack);
 		return;
 	}
 	
 	#if defined DEBUG_CHARACTER_CREATION
	PrintToServer("\nNow searching character pack ''%s''...", pack);
	#endif
 	
 	char value[255];
 	for (int i = 1; i <= Pack.Size; i++)
 	{
 		Pack.GetIntKey(i, value, sizeof(value));
 		
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
	
	delete Pack;
 }
 
 public void CF_LoadSpecificCharacter(char path[255], bool JustDownload)
 {
 	ConfigMap Character = new ConfigMap(path);
 	
 	if (Character == null)
 	{
 		PrintToServer("WARNING: One of your character packs enables a character with config ''%s'', but no such character exists in the configs/chaos_fortress directory. Skipping character...", path);
 		return;
 	}
 	
 	char str[255]; //TODO: Abstract this to a native titled CF_GetCharacterName. REMINDER: Would be easiest to just make a native called CF_GetCharacterKV and have this native use that to get the name.
 	Character.Get("character.name", str, sizeof(str));
 	
 	if (b_DisplayRole)
 	{
 		char role[255];		//TODO: Abstract this to a native titled CF_GetCharacterRole.
 		Character.Get("character.menu_display.role", role, sizeof(role));
 		
 		Format(str, sizeof(str), "[%s] %s", role, str);
 	}
 	
 	if (!JustDownload)
 	{
 		PushArrayString(CF_Characters_Names, str);
 		PushArrayString(CF_Characters_Configs, path);
 	
 		#if defined DEBUG_CHARACTER_CREATION
		PrintToServer("\nConfig ''%s'' has a character name of ''%s''.", path, str);
 		#endif
 	}
 
 	CF_ManageCharacterFiles(Character);
 	delete Character;
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
		
		CFC_BuildInfoMenu(client, conf, false, false);		
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
	b_ReadingLore[client] = false;
	
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
			SDKHook(text, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		}
		
		i_PreviewOwner[preview] = GetClientUserId(client);
		
		SDKHook(preview, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		
		i_CFPreviewModel[client] = EntIndexToEntRef(preview);
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
 
 public void CF_UpdatePreviewModel(int client)
 {
 	if (!IsValidClient(client))
 		return;
 	
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
			SDKHook(part, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		}
		else
		{
			int part = SpawnParticle(aimLoc, "teleportedin_blue", 2.0);
			i_PreviewOwner[part] = GetClientUserId(client);
			SDKHook(part, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		}
		
		//TODO: Switch this to CF_PlayRandomSound(?)
		char snd[255];
		CF_GetRandomSound(s_CharacterConfigInMenu[client], "sound_selection_preview", snd);
		EmitSoundToClient(client, snd);
		
		EmitSoundToClient(client, SOUND_CHARACTER_PREVIEW);
	}
	
	aimLoc[2] += 40.0;
	f_CFPreviewRotation[client] += 1.0;
	ang[1] += f_CFPreviewRotation[client];
	PhysProp_MoveToTargetPosition_Preview(prop, client, ang, 600.0);
	//TeleportEntity(preview, NULL_VECTOR, ang, NULL_VECTOR);
	ChangeModelSkin(preview, skin);
 }
 
 public void CFC_OGF()
 {
 	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if (CF_PreviewModelActive(i))
			{
				CF_UpdatePreviewModel(i);
			}
		}
	}
}
 
 public Action CF_PreviewModelTransmit(int entity, int client)
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
 
 public void CFC_BuildInfoMenu(int client, char config[255], bool isLore, bool justReading)
 {
 	if (!IsValidClient(client))
		return;
		
	if (CF_ClientMenu[client] != null)
		delete CF_ClientMenu[client];
	
	ConfigMap Character = new ConfigMap(config);
	
 	if (Character == null)
 	{
 		PrintToServer("ERROR: Failed to locate config ''%s'' in CFC_BuildInfoMenu.", config);
 		return;
 	}
 	
 	char name[255]; char title[255]; char related[255]; char role[255]; char desc[255]; char model[255] = ""; char lore[255] = ""; char weapon[255]; char attachment[255]; char sequence[255];
 	Character.Get("character.name", name, sizeof(name));
 	Character.Get("character.model", model, sizeof(model));
 	
 	ConfigMap section = Character.GetSection("character.menu_display");
 	if (section == null)
 	{
 		Character = new ConfigMap("data/chaos_fortress/game_rules.cfg");
 		
 		if (Character == null)		//Don't bother printing an error to the console because this should get thrown in SetGameRules if it's going to get thrown here, unless someone is deliberately deleting server files in which case that's their own fault.
 			return;
 		
 		section = Character.GetSection("game_rules.character_defaults.menu_display");
 		
 		if (section == null)
 		{
 			PrintToServer("ERROR: Character config ''%s'' does not have default menu information, and neither does your game_rules.cfg.");
 			return;
 		}
 	}
 	
 	//Should be impossible to reach this code without a valid section ConfigMap so don't bother doing security checks:
 	section.Get("related_class", related, sizeof(related));
 	section.Get("role", role, sizeof(role));
 	section.Get("description", desc, sizeof(desc));
 	section.Get("preview_weapon", weapon, sizeof(weapon));
 	section.Get("preview_attachment", attachment, sizeof(attachment));
 	section.Get("preview_sequence", sequence, sizeof(sequence));
 	section.Get("lore_description", lore, sizeof(lore));
 	
 	if (!StrEqual(model, "") && CheckFile(model) && CF_PreviewModelActive(client) && !justReading)
 	{
 		int preview = EntRefToEntIndex(i_CFPreviewModel[client]);
 		SetEntityModel(preview, model);
 		ChangeModelAnimation(preview, sequence, 1.0);
 		b_SpawnPreviewParticleNextFrame[client] = true;
 		
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
 			
 			float xOff = GetFloatFromConfigMap(section, "attachment_x_offset", 0.0);
 			float yOff = GetFloatFromConfigMap(section, "attachment_y_offset", 0.0);
 			float zOff = GetFloatFromConfigMap(section, "attachment_z_offset", 0.0);
 			float xRot = GetFloatFromConfigMap(section, "attachment_x_rotation", 0.0);
 			float yRot = GetFloatFromConfigMap(section, "attachment_y_rotation", 0.0);
 			float zRot = GetFloatFromConfigMap(section, "attachment_z_rotation", 0.0);
 			
 			int wep = AttachModelToEntity(weapon, attachment, preview, _, skin, xOff, yOff, zOff, xRot, yRot, zRot);
 			if (IsValidEntity(wep))
 			{
 				i_CFPreviewWeapon[client] = EntIndexToEntRef(wep);
 			}
 		}
 	}
 	
 	if (!isLore)
 	{
 		Format(title, sizeof(title), "%s\n\nSimilar TF2 Class: %s\nRole: %s\n\n%s", name, related, role, desc);
 	}
 	else
 	{
 		Format(title, sizeof(title), "%s\n\n%s", name, lore);
 	}
 	
 	s_CharacterConfigInMenu[client] = config;
 	
 	CF_ClientMenu[client] = new Menu(CFC_InfoMenu);
 	CF_ClientMenu[client].SetTitle(title);
 	
 	Format(name, sizeof(name), "Spawn As %s", name);
 	CF_ClientMenu[client].AddItem("Select", name);
 	
 	if (!isLore)
 	{
	 	if (StrEqual(lore, ""))
	 	{
	 		CF_ClientMenu[client].AddItem("Lore", "(No Lore)", ITEMDRAW_DISABLED);
	 	}
	 	else
	 	{
	 		CF_ClientMenu[client].AddItem("Lore", "View Lore");
	 	}
	 }
	 else
	 {
	 	CF_ClientMenu[client].AddItem("Lore", "View Gameplay Description");
	 }
 	
 	CF_ClientMenu[client].AddItem("Back", "Go Back");
 	
 	CF_ClientMenu[client].ExitButton = false;
 	CF_ClientMenu[client].Display(client, MENU_TIME_FOREVER);
 	b_ReadingLore[client] = isLore;
 	
 	delete section;
 	delete Character;
 }
 
 public CFC_InfoMenu(Menu CFC_Menu, MenuAction action, int client, int param)
{	
	if (!IsValidClient(client))
	return;
	
	if (action == MenuAction_Select)
	{
		if (param != 2)
		{
			ConfigMap Character = new ConfigMap(s_CharacterConfigInMenu[client]);
			
			if (Character == null)
			{
				PrintToServer("ERROR: Somehow, an invalid character config (%s) was added to the !characters menu.", s_CharacterConfigInMenu[client]);
				CPrintToChat(client, "{indigo}[Chaos Fortress] {crimson}ERROR: {default}Somehow, an invalid character config {olive}(%s){default} was added to the !characters menu. This should be impossible. Please inform your server's developer.", s_CharacterConfigInMenu[client]);
				return;
			}
			
			if (param == 0)
			{
				char name[255];
				Character.Get("character.name", name, sizeof(name));
				Format(name, sizeof(name), "{indigo}[Chaos Fortress] {default}You will respawn as {olive}%s{default}.", name);
				CPrintToChat(client, name);
				
				SetClientCookie(client, c_DesiredCharacter, s_CharacterConfigInMenu[client]);
				b_CharacterApplied[client] = false;
				
				if (CF_ClientMenu[client] != null)
					delete CF_ClientMenu[client];
					
				CF_DeletePreviewModel(client);
			}
			else if (param == 1)
			{
				CFC_BuildInfoMenu(client, s_CharacterConfigInMenu[client], !b_ReadingLore[client], true);
			}
			
			delete Character;
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
 public void CF_ManageCharacterFiles(ConfigMap Character)
 {
 	ConfigMap section = Character.GetSection("character.model_download");
 	if (section != null)
 	{
 		CF_DownloadAndPrecacheModels(section);
 		delete section;
 	}
 	
 	section = Character.GetSection("character.downloads");
 	if (section != null)
 	{
 		CF_DownloadFiles(section);
 		delete section;
 	}
 	
 	section = Character.GetSection("character.precache");
 	if (section != null)
 	{
 		CF_PrecacheFiles(section);
 		delete section;
 	}
 }
 
 public void CF_DownloadAndPrecacheModels(ConfigMap subsection)
 {
 	char value[255];
 	
 	for (int i = 1; i <= subsection.Size; i++)
 	{
 		subsection.GetIntKey(i, value, sizeof(value));
 			
 		char fileCheck[255], actualFile[255];
				
		for (int j = 0; j < sizeof(s_ModelFileExtensions); j++)
		{
			Format(fileCheck, sizeof(fileCheck), "models/%s%s", value, s_ModelFileExtensions[j]);
			Format(actualFile, sizeof(actualFile), "%s%s", value, s_ModelFileExtensions[j]);
			if (CheckFile(fileCheck))
			{
				if (StrEqual(s_ModelFileExtensions[j], ".mdl"))
				{
					#if defined DEBUG_CHARACTER_CREATION
					int check = PrecacheModel(fileCheck);
					
					if (check != 0)
					{
						PrintToServer("Successfully precached file ''%s''.", fileCheck);
					}
					else
					{
						PrintToServer("Failed to precache file ''%s''.", fileCheck);
					}
					#else
					PrecacheModel(fileCheck);
					#endif
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
 
 public void CF_DownloadFiles(ConfigMap subsection)
 {
 	char value[255];
 	
 	for (int i = 1; i <= subsection.Size; i++)
 	{
 		subsection.GetIntKey(i, value, sizeof(value));
 			
 		char actualFile[255];
 		
 		if (CheckFile(value))
		{
			AddFileToDownloadsTable(value);
			
			if (StrContains(value, "sound") == 0)
			{
				for (int j = 6; j < sizeof(value); j++)	//Write the path to the sound without the "sound/" to a new string so we can precache it.
				{
					actualFile[j - 6] = value[j];
				}

				#if defined DEBUG_CHARACTER_CREATION
				bool succeeded = PrecacheSound(actualFile);
				
				if (succeeded)
				{
					PrintToServer("Successfully precached file ''%s''.", actualFile);
				}
				else
				{
					PrintToServer("Failed to precache file ''%s''.", actualFile);
				}
				#else
				PrecacheSound(actualFile);
				#endif
			}
			
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

 public void CF_PrecacheFiles(ConfigMap subsection)
 {
 	char value[255];
 	
 	for (int i = 1; i <= subsection.Size; i++)
 	{
 		subsection.GetIntKey(i, value, sizeof(value));
 		
 		char file[255];
				
		bool exists = false;
				
		Format(file, sizeof(file), "models/%s", value);
				
				
		if (CheckFile(file))
		{
			exists = true;
					
			#if defined DEBUG_CHARACTER_CREATION
			int check = PrecacheModel(file);
			if (check != 0)
			{
				PrintToServer("Successfully precached file ''%s''.", file);
			}
			else
			{
				PrintToServer("Failed to precache file ''%s''.", file);
			}
			#else
			PrecacheModel(file);
			#endif
		}
		else
		{
			Format(file, sizeof(file), "sound/%s", value);
					
			if (CheckFile(file))
			{
				exists = true;
					
				#if defined DEBUG_CHARACTER_CREATION
				bool check = PrecacheSound(value);
				if (check)
				{
					PrintToServer("Successfully precached file ''%s''.", file);
				}
				else
				{
					PrintToServer("Failed to precache file ''%s''.", file);
				}
				#else
				PrecacheSound(value);
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

public void CF_OnRoundStateChanged(int state)
{
	if (state == 0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			b_CharacterApplied[i] = false;
		}
	}
}

public void CF_ResetMadeStatus(int client)
{
	if (client >= 1 && client <= MaxClients)
	{
		b_CharacterApplied[client] = false;
	}
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

	char conf[255], currentConf[255];
	CF_GetPlayerConfig(client, currentConf, sizeof(currentConf));
	GetClientCookie(client, c_DesiredCharacter, conf, sizeof(conf));
	if (StrEqual(conf, ""))
	{
		conf = s_DefaultCharacter;
	}
	
	ConfigMap map = new ConfigMap(conf);
	if (map == null)
		return;
		
	ConfigMap GameRules = new ConfigMap("data/chaos_fortress/game_rules.cfg");
		
	int class = GetIntFromConfigMap(map, "character.class", 1) - 1;
	TF2_SetPlayerClass(client, Classes[class]);
	
	int entity;
	while((entity = FindEntityByClassname(entity, "tf_wearable")) != -1)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if (owner == client)
		{
			TF2_RemoveWearable(owner, entity);
		}
	}
	
	ViewChange_DeleteHands(client);
	ViewChange_UpdateHands(client, CF_GetCharacterClass(client));
	
	char model[255];
	map.Get("character.model", model, sizeof(model));
	if (CheckFile(model))
	{
		SetVariantString(model);
		AcceptEntityInput(client, "SetCustomModelWithClassAnimations");
		i_CharacterModelIndex[client] = PrecacheModel(model);
		ViewChange_PlayerModel(client);
	}
	
	float health = GetFloatFromConfigMap(map, "character.health", 200.0) - f_ClassBaseHP[class];
	if (health < 0.0)
	{
		TF2Attrib_SetByDefIndex(client, 125, -health);
	}
	else
	{
		TF2Attrib_SetByDefIndex(client, 26, health);
	}
	
	ConfigMap wearables = map.GetSection("character.wearables");
	if (wearables == null)
	{
		wearables = GameRules.GetSection("game_rules.character_defaults.wearables");
	}
	
	if (wearables != null)
	{
		//TODO: Spawn wearables
		delete wearables;
	}
	
	ConfigMap weapons = map.GetSection("character.weapons");
	if (weapons == null)
	{
		weapons = GameRules.GetSection("game_rules.character_defaults.weapons");
	}
	
	if (weapons != null)
	{
		TF2_RemoveAllWeapons(client);
		
		int i = 1;
		char secName[255];
		Format(secName, sizeof(secName), "weapon_%i", i);
		
		ConfigMap subsection = weapons.GetSection(secName);
		while (subsection != null)
		{
			char classname[255], attributes[255], override[255];
			subsection.Get("classname", classname, sizeof(classname));
			
			int index = GetIntFromConfigMap(subsection, "index", 1);
			int level = GetIntFromConfigMap(subsection, "level", 77);
			int quality = GetIntFromConfigMap(subsection, "quality", 7);
			int slot = GetIntFromConfigMap(subsection, "slot", 0);
			int reserve = GetIntFromConfigMap(subsection, "reserve", 0);
			int clip = GetIntFromConfigMap(subsection, "clip", 0);
			int ForceClass = GetIntFromConfigMap(subsection, "force_class", 0);
			
			subsection.Get("attributes", attributes, sizeof(attributes));
			
			bool visible = GetBoolFromConfigMap(subsection, "visible", true);
			if (visible)
			{
				subsection.Get("model_override", override, sizeof(override));
			}
			bool unequip = GetBoolFromConfigMap(subsection, "unequip", true);
			bool useVC = GetBoolFromConfigMap(subsection, "use_viewchange", false);
			
			int wep = CF_SpawnWeapon(client, classname, index, level, quality, slot, reserve, clip, attributes, override, visible, unequip, useVC, ForceClass);
			
			if (i == 1)
			{
				ViewChange_Switch(client, wep, classname);
			}
			
			i++;
			Format(secName, sizeof(secName), "weapon_%i", i);
			subsection = weapons.GetSection(secName);
		}
		
		delete weapons;
		if (subsection != null)
			delete subsection;
	}
	
	ConfigMap particles = map.GetSection("character.particles");
	if (particles != null)
	{
		//TODO: Spawn particles
		delete particles;
	}
	
 	CF_SetPlayerConfig(client, conf);
 	b_CharacterApplied[client] = true;
 	
 	if (!StrEqual(conf, currentConf))
 	{
 		CF_PlayRandomSound(client, conf, "sound_spawn"); //This is sound_spawn_intro
 	}
 	else if (b_IsDead[client])
 	{
 		//TODO: sound_spawn_happy, sound_spawn_neutral, sound_spawn_angry
 		b_IsDead[client] = false;
 	}
 	
 	if (map != null)
 	{
 		delete map;
 	}
 	if (GameRules != null)
 	{
 		delete GameRules;
 	}
 	
 	SDKUnhook(client, SDKHook_WeaponSwitchPost, ViewChange_WeaponSwitch);
 	SDKHook(client, SDKHook_WeaponSwitchPost, ViewChange_WeaponSwitch);
 	SDKUnhook(client, SDKHook_OnTakeDamageAlive, CFDMG_OnTakeDamageAlive);
 	SDKHook(client, SDKHook_OnTakeDamageAlive, CFDMG_OnTakeDamageAlive);
 }
 
 public void CF_OnPlayerKilled(int victim, int inflictor, int attacker, int deadRinger)
 {
 	if (victim > 0 && victim <= MaxClients)
 	{
 		b_IsDead[victim] = true;
 	}
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
 	SDKUnhook(client, SDKHook_WeaponSwitchPost, CFDMG_OnTakeDamageAlive);
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

public Native_CF_GetCharacterClass(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return TFClass_Unknown;
		
	char conf[255];
	CF_GetPlayerConfig(client, conf, 255);
	ConfigMap map = new ConfigMap(conf);
	int num = GetIntFromConfigMap(map, "character.class", 0);
	if (num == 0)
	{
		return TFClass_Unknown;
	}
	else
	{
		TFClassType class = Classes[num - 1];
		delete map;
		return class;
	}
}