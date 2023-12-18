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

public const float f_ClassBaseSpeed[] =
{
	400.0,
	240.0,
	300.0,
	280.0,
	230.0,
	300.0,
	320.0,
	300.0,
	320.0
};

//TODO: Populate this with every other value a character's config can have (done if we ignore optional bits).
//Possible future values include:
//		- All variables associated with the character's Ultimate Ability (optional, the plugin works as intended without this but it would be a nice QOL change).
//		- All variables associated with the character's special resource (optional, the plugin works as intended without this but it would be a nice QOL change).
enum struct CFCharacter
{
	float Speed;
	float MaxHP;
	float Scale;
	
	char Model[255];
	char Name[255];
	char MapPath[255];
	
	TFClassType Class;
	
	bool Exists;
	
	//ConfigMap Map;
	
	void Create(float newSpeed, float newMaxHP, TFClassType newClass, char newModel[255], char newName[255], float newScale, char newMapPath[255])
	{
		this.Speed = newSpeed;
		this.MaxHP = newMaxHP;
		this.Class = newClass;
		this.Model = newModel;
		this.Name = newName;
		this.Scale = newScale;
		
		//DeleteCfg(this.Map);
		//delete this.Map;
			
		//this.Map = new ConfigMap(newMapPath);
		this.MapPath = newMapPath;
		
		this.Exists = true;
	}
	
	void Destroy()
	{
		this.Exists = false;
		//DeleteCfg(this.Map);
		//delete this.Map;
	}
}

CFCharacter g_Characters[MAXPLAYERS + 1];

//Store configs and names in two separate arrays so we aren't reading every single character's config every single time someone opens the !characters menu:
Handle CF_Characters_Configs;
Handle CF_Characters_Names;
Handle CF_CharacterParticles[MAXPLAYERS + 1] = { null, ... };

ConfigMap Characters;

Menu CF_CharactersMenu;
Menu CF_ClientMenu[MAXPLAYERS + 1] = { null, ... };

#if defined USE_PREVIEWS
int i_CFPreviewModel[MAXPLAYERS + 1] = { -1, ... };
int i_PreviewOwner[2049] = { -1, ... };
int i_CFPreviewProp[MAXPLAYERS + 1] = { -1, ... };
int i_CFPreviewWeapon[MAXPLAYERS + 1] = { -1, ... };
float f_CFPreviewRotation[MAXPLAYERS + 1] = { 0.0, ... };
bool b_SpawnPreviewParticleNextFrame[MAXPLAYERS + 1] = { false, ... };
#endif

int i_CharacterParticleOwner[2049] = { -1, ... };

bool b_DisplayRole = true;
bool b_CharacterApplied[MAXPLAYERS + 1] = { false, ... }; //Whether or not the client's character has been applied to them already. If true: skip MakeCharacter for that client. Set to false automatically on death, round end, disconnect, and if the player changes their character selection.
bool b_ReadingLore[MAXPLAYERS + 1] = { false, ... };
bool b_IsDead[MAXPLAYERS + 1] = { false, ... };
bool b_CharacterParticlePreserved[2049] = { false, ... };
bool b_WearableIsPreserved[2049] = { false, ... };
bool b_FirstSpawn[MAXPLAYERS + 1] = { true, ... };

char s_CharacterConfig[MAXPLAYERS+1][255];	//The config currently used for this player's character. If empty: that player is not a character.
char s_CharacterConfigInMenu[MAXPLAYERS+1][255];	//The config currently used this player's info menu.
char s_PreviousCharacter[MAXPLAYERS+1][255];
//char s_DesiredCharacterConfig[MAXPLAYERS+1][255];	//The config of the character this player will become next time they spawn.
char s_DefaultCharacter[255];

Handle c_DesiredCharacter;

//Queue CF_CharacterParticles[MAXPLAYERS + 1];

public void CFC_Disconnect(int client)
{
	b_FirstSpawn[client] = true;
}

public void CFC_MakeNatives()
{
	CreateNative("CF_GetRoundState", Native_CF_GetRoundState);
	
	CreateNative("CF_GetPlayerConfig", Native_CF_GetPlayerConfig);
	CreateNative("CF_SetPlayerConfig", Native_CF_SetPlayerConfig);
	
	CreateNative("CF_IsPlayerCharacter", Native_CF_IsPlayerCharacter);
	
	CreateNative("CF_GetCharacterClass", Native_CF_GetCharacterClass);
	CreateNative("CF_SetCharacterClass", Native_CF_SetCharacterClass);
	
	CreateNative("CF_GetCharacterMaxHealth", Native_CF_GetCharacterMaxHealth);
	CreateNative("CF_SetCharacterMaxHealth", Native_CF_SetCharacterMaxHealth);
	
	CreateNative("CF_GetCharacterName", Native_CF_GetCharacterName);
	CreateNative("CF_SetCharacterName", Native_CF_SetCharacterName);
	
	CreateNative("CF_GetCharacterModel", Native_CF_GetCharacterModel);
	CreateNative("CF_SetCharacterModel", Native_CF_SetCharacterModel);
	
	CreateNative("CF_GetCharacterSpeed", Native_CF_GetCharacterSpeed);
	CreateNative("CF_SetCharacterSpeed", Native_CF_SetCharacterSpeed);
	
	CreateNative("CF_GetCharacterScale", Native_CF_GetCharacterScale);
	CreateNative("CF_SetCharacterScale", Native_CF_SetCharacterScale);
	
	CreateNative("CF_AttachParticle", Native_CF_AttachParticle);
	CreateNative("CF_AttachWearable", Native_CF_AttachWearable);
}

GlobalForward g_OnCharacterCreated;
GlobalForward g_OnCharacterRemoved;

public void CFC_MakeForwards()
{
	CF_Characters_Configs = CreateArray(255);
	CF_Characters_Names = CreateArray(255);
	
	RegConsoleCmd("characters", CFC_OpenMenu, "Opens the Chaos Fortress character selection menu.");
	RegConsoleCmd("character", CFC_OpenMenu, "Opens the Chaos Fortress character selection menu.");
	RegConsoleCmd("setcharacter", CFC_OpenMenu, "Opens the Chaos Fortress character selection menu.");
	RegConsoleCmd("changecharacter", CFC_OpenMenu, "Opens the Chaos Fortress character selection menu.");
	
	c_DesiredCharacter = RegClientCookie("DesiredCharacter", "The character this player has chosen to spawn as. If blank: reverts to the default character.", CookieAccess_Private);
	
	#if defined USE_PREVIEWS
	PrecacheModel(MODEL_PREVIEW_DOORS);
	PrecacheModel(MODEL_PREVIEW_STAGE);
	PrecacheModel(MODEL_PREVIEW_UNKNOWN);
	PrecacheSound(SOUND_CHARACTER_PREVIEW);
	#endif
	
	g_OnCharacterCreated = new GlobalForward("CF_OnCharacterCreated", ET_Ignore, Param_Cell);
	g_OnCharacterRemoved = new GlobalForward("CF_OnCharacterRemoved", ET_Ignore, Param_Cell);
}

public void CFC_OnEntityDestroyed(int entity)
{
	b_CharacterParticlePreserved[entity] = false;
	b_WearableIsPreserved[entity] = false;
}

/**
 * Loads all of the characters from data/chaos_fortress/characters.cfg.
 *
 * @param admin		The client index of the admin who reloaded characters.cfg. If valid: prints the new character list to that admin's console.
 */
 public void CF_LoadCharacters(int admin)
 {
 	DeleteCfg(Characters);
 		
 	Characters = new ConfigMap("data/chaos_fortress/characters.cfg");
 	
 	if (Characters == null)
 		ThrowError("FATAL ERROR: FAILED TO LOAD data/chaos_fortress/characters.cfg!");
 		
 	bool FoundEnabled = false;
 	
 	#if defined DEBUG_CHARACTER_CREATION
	PrintToServer("//////////////////////////////////////////////////");
	PrintToServer("CHAOS FORTRESS CHARACTERS.CFG DEBUG MESSAGES BELOW");
	PrintToServer("//////////////////////////////////////////////////");
	#endif
 	
 	delete CF_Characters_Configs;
 	CF_Characters_Configs = CreateArray(255);
 	
 	delete CF_Characters_Names;
 	CF_Characters_Names = CreateArray(255);
 	
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
 		
 		DeleteCfg(subsection);
 		
 		return true;
 	}
	
	DeleteCfg(subsection);
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
			
		//#if defined DEBUG_CHARACTER_CREATION
		PrintToServer("\nLocated character: %s", value);
		//#endif
	}
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
 	
 		#if defined DEBUG_CHARACTER_CREATION
		PrintToServer("\nConfig ''%s'' has a character name of ''%s''.", path, str);
 		#endif
 	}
 
 	CF_ManageCharacterFiles(Character);
 	DeleteCfg(Character);
 }
 
 public void CF_BuildCharactersMenu()
 {
 	delete CF_CharactersMenu;
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
		delete CF_ClientMenu[client];
			
		#if defined USE_PREVIEWS
		CF_DeletePreviewModel(client);
		#endif
	}
}

#if defined USE_PREVIEWS
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
#endif

public Action CFC_OpenMenu(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Continue;
		
	delete CF_ClientMenu[client];
		
	CF_ClientMenu[client] = new Menu(CFC_Menu);
	CopyMenu(CF_ClientMenu[client], CF_CharactersMenu);
	CF_ClientMenu[client].Display(client, MENU_TIME_FOREVER);
	b_ReadingLore[client] = false;
	
	#if defined USE_PREVIEWS
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
			SetEdictFlags(text, GetEdictFlags(text)&(~FL_EDICT_ALWAYS));
			SDKHook(text, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		}
		
		i_PreviewOwner[preview] = GetClientUserId(client);
		
		SetEdictFlags(preview, GetEdictFlags(preview)&(~FL_EDICT_ALWAYS));
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
	#endif
	
	return Plugin_Continue;
}
 
 #if defined USE_PREVIEWS
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
			SetEdictFlags(part, GetEdictFlags(part)&(~FL_EDICT_ALWAYS));
			SDKHook(part, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		}
		else
		{
			int part = SpawnParticle(aimLoc, "teleportedin_blue", 2.0);
			i_PreviewOwner[part] = GetClientUserId(client);
			SetEdictFlags(part, GetEdictFlags(part)&(~FL_EDICT_ALWAYS));
			SDKHook(part, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		}
		
		CF_PlayRandomSound(client, s_CharacterConfigInMenu[client], "sound_selection_preview");
		
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
 	SetEdictFlags(entity, GetEdictFlags(entity)&(~FL_EDICT_ALWAYS));
 	if (client != GetClientOfUserId(i_PreviewOwner[entity]))
 	{
 		return Plugin_Handled;
 	}
 		
 	return Plugin_Continue;
 }
 #endif
 
 public Action CFC_ParticleTransmit(int entity, int client)
 {
 	SetEdictFlags(entity, GetEdictFlags(entity)&(~FL_EDICT_ALWAYS));
 	
 	int owner = GetClientOfUserId(i_CharacterParticleOwner[entity]);
 	/*if (!IsValidClient(owner))	//This should never happen so I've removed it for the sake of optimization, if it throws error we know what to re-enable.
 		return Plugin_Handled;*/
 		
 	if (IsPlayerInvis(owner))	//Block the particle if the user is invisible, for obvious reasons...
 		return Plugin_Handled;
 		
 	if (client != owner || (client == owner && (GetEntProp(client, Prop_Send, "m_nForceTauntCam") || TF2_IsPlayerInCondition(client, TFCond_Taunting))))
 		return Plugin_Continue;
 		
 	return Plugin_Handled;
 }
 
 #if defined USE_PREVIEWS
 bool CF_PreviewModelActive(int client)
 {
 	if (!IsValidClient(client))
 		return false;
 		
 	return IsValidEntity(EntRefToEntIndex(i_CFPreviewModel[client])) && IsValidEntity(EntRefToEntIndex(i_CFPreviewProp[client]));
 }
 #endif
 
 public void CFC_BuildInfoMenu(int client, char config[255], bool isLore, bool justReading)
 {
 	if (!IsValidClient(client))
		return;
		
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
 		ConfigMap rules = new ConfigMap("data/chaos_fortress/game_rules.cfg");
 		
 		if (rules == null)		//Don't bother printing an error to the console because this should get thrown in SetGameRules if it's going to get thrown here, unless someone is deliberately deleting server files in which case that's their own fault.
 			return;
 		
 		section = rules.GetSection("game_rules.character_defaults.menu_display");
 		
 		if (section == null)
 		{
 			PrintToServer("ERROR: Character config ''%s'' does not have default menu information, and neither does your game_rules.cfg.");
 			return;
 		}
 		
 		DeleteCfg(rules);
 	}
 	
 	//Should be impossible to reach this code without a valid section ConfigMap so don't bother doing security checks:
 	section.Get("related_class", related, sizeof(related));
 	section.Get("role", role, sizeof(role));
 	section.Get("description", desc, sizeof(desc));
 	section.Get("preview_weapon", weapon, sizeof(weapon));
 	section.Get("preview_attachment", attachment, sizeof(attachment));
 	section.Get("preview_sequence", sequence, sizeof(sequence));
 	section.Get("lore_description", lore, sizeof(lore));
 	
 	#if defined USE_PREVIEWS
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
 		
 		section = Character.GetSection("character.particles");
 		if (section != null)
 		{
 			CFC_DummyParticles(client, preview, section);
 		}
 		
 		section = Character.GetSection("character.wearables");
 		if (section != null)
 		{
 			CFC_DummyWearables(client, preview, section);
 		}
 	}
 	#endif
 	
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
 	
 	DeleteCfg(Character);
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
				
				delete CF_ClientMenu[client];
					
				#if defined USE_PREVIEWS
				CF_DeletePreviewModel(client);
				#endif
			}
			else if (param == 1)
			{
				CFC_BuildInfoMenu(client, s_CharacterConfigInMenu[client], !b_ReadingLore[client], true);
			}
			
			DeleteCfg(Character);
		}
		else
		{
			CFC_OpenMenu(client, 0);
		}		
	}
	else if (action == MenuAction_End || action == MenuAction_Cancel)
	{
		delete CF_ClientMenu[client];
				
		#if defined USE_PREVIEWS
		CF_DeletePreviewModel(client);
		#endif
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
 	}
 	
 	section = Character.GetSection("character.downloads");
 	if (section != null)
 	{
 		CF_DownloadFiles(section);
 	}
 	
 	section = Character.GetSection("character.precache");
 	if (section != null)
 	{
 		CF_PrecacheFiles(section);
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
 void CF_MakeCharacter(int client, bool callForward = true, bool ForceNewCharStatus = false)
 {
 	if (!IsValidClient(client))
 		return;

	EndHeldM2(client, true, true);
	EndHeldM3(client, true, true);
	EndHeldReload(client, true, true);

	char conf[255];
	GetClientCookie(client, c_DesiredCharacter, conf, sizeof(conf));
	if (!CF_CharacterExists(conf) || IsFakeClient(client))
	{
		if (!CF_CharacterExists(s_DefaultCharacter) || IsFakeClient(client))	//Choose a random character if the default character does not exist, or the client is a bot
		{
			GetArrayString(CF_Characters_Configs, GetRandomInt(0, GetArraySize(CF_Characters_Configs) - 1), conf, sizeof(conf));
		}
		else
		{
			conf = s_DefaultCharacter;
		}
	}
	
	ConfigMap map = new ConfigMap(conf);
	if (map == null)
		return;
		
	bool IsNewCharacter = !StrEqual(conf, s_PreviousCharacter[client]) || b_IsDead[client] || b_FirstSpawn[client] || ForceNewCharStatus;
	if (IsNewCharacter)
		CF_UnmakeCharacter(client, true);
		
	CF_SetPlayerConfig(client, conf);
	SetClientCookie(client, c_DesiredCharacter, conf);
		
	char model[255], name[255];
	map.Get("character.model", model, sizeof(model));
	map.Get("character.name", name, sizeof(name));
	float speed = GetFloatFromConfigMap(map, "character.speed", 300.0);
	float health = GetFloatFromConfigMap(map, "character.health", 250.0);
	int class = GetIntFromConfigMap(map, "character.class", 1) - 1;
	float scale = GetFloatFromConfigMap(map, "character.scale", 1.0);
	
	g_Characters[client].Create(speed, health, Classes[class], model, name, scale, conf);
		
	ConfigMap GameRules = new ConfigMap("data/chaos_fortress/game_rules.cfg");
	
	int entity;
	while((entity = FindEntityByClassname(entity, "tf_wearable")) != -1)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if (owner == client)
		{
			TF2_RemoveWearable(owner, entity);
		}
	}
	
	entity = -1;
	while((entity = FindEntityByClassname(entity, "tf_wearable_*")) != -1)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if (owner == client)
		{
			TF2_RemoveWearable(owner, entity);
		}
	}
	
	if (CheckFile(model))
	{
		SetVariantString(model);
		AcceptEntityInput(client, "SetCustomModelWithClassAnimations");
	}
	
	CF_SetCharacterScale(client, scale, CF_StuckMethod_DelayResize, "");
	
	ConfigMap wearables = map.GetSection("character.wearables");
	if (wearables == null)
	{
		wearables = GameRules.GetSection("game_rules.character_defaults.wearables");
	}
		
	if (wearables != null)
	{
		CFC_GiveWearables(client, wearables);
	}
	
	ConfigMap weapons = map.GetSection("character.weapons");
	if (weapons == null)
	{
		weapons = GameRules.GetSection("game_rules.character_defaults.weapons");
	}
	
	if (weapons != null)
	{
		CFC_GiveWeapons(client, weapons);
	}
	
	TF2_SetPlayerClass(client, g_Characters[client].Class);
	CF_UpdateCharacterHP(client, g_Characters[client].Class, true);
	CF_UpdateCharacterSpeed(client, TF2_GetPlayerClass(client));
	
	ConfigMap particles = map.GetSection("character.particles");
	if (particles != null)
	{
		CFC_AttachParticles(client, particles, IsNewCharacter);
	}
 	
 	if (!StrEqual(conf, s_PreviousCharacter[client]))	//We are respawning as a new character, default to spawn_intro
 	{
 		bool played = CF_PlayRandomSound(client, conf, "sound_spawn_intro");
 		if (!played)
 			CF_PlayRandomSound(client, "", "sound_spawn_neutral");
 		
 		CFA_ReduceUltCharge_CharacterSwitch(client);
 	}
 	else if (b_IsDead[client])
 	{
 		bool played = false;
 		
 		switch(CF_GetCharacterEmotion(client))
 		{
 			case CF_Emotion_Angry:
 			{
 				played = CF_PlayRandomSound(client, "", "sound_spawn_angry");
 			}
 			case CF_Emotion_Happy:
 			{
 				played = CF_PlayRandomSound(client, "", "sound_spawn_happy");
 			}
 		}
 		
 		if (!played)
 			CF_PlayRandomSound(client, "", "sound_spawn_neutral");
 	}
 	
 	int r = 255;
 	int b = 120;
 	if (TF2_GetClientTeam(client) == TFTeam_Blue)
 	{
 		b = 255;
 		r = 120;
 	}
 	
 	SetHudTextParams(-1.0, 0.33, 5.0, r, 120, b, 255, 0, 5.0, 0.8, 0.4);
 	ShowHudText(client, -1, "You spawned as: %s", name);
 	
 	bool hasUlt = CFA_InitializeUltimate(client, map);
 	bool hasAbilities = CFA_InitializeAbilities(client, map, IsNewCharacter);
 	
 	CFA_ToggleHUD(client, hasUlt || hasAbilities);
 	
 	b_CharacterApplied[client] = true;
 	b_IsDead[client] = false;
 	s_PreviousCharacter[client] = conf;
 	
 	DeleteCfg(GameRules);
 	DeleteCfg(map);
 	
 	SDKUnhook(client, SDKHook_OnTakeDamageAlive, CFDMG_OnTakeDamageAlive);
 	SDKHook(client, SDKHook_OnTakeDamageAlive, CFDMG_OnTakeDamageAlive);
 	
 	b_FirstSpawn[client] = false;
 	
 	if (callForward)
 	{
	 	Call_StartForward(g_OnCharacterCreated);
	 	
	 	Call_PushCell(client);
	 	
	 	Call_Finish();
	 }
 }
 
 public bool CF_CharacterExists(char conf[255])
 {
 	if (StrEqual(conf, ""))
 		return false;
 		
 	for (int i = 0; i < GetArraySize(CF_Characters_Configs); i++)
 	{
 		char item[255];
 		GetArrayString(CF_Characters_Configs, i, item, sizeof(item));
 		
 		if (StrEqual(item, conf))
 			return true;
 	}
 	
 	return false;
 }
 
 #if defined USE_PREVIEWS
 public void CFC_DummyWearables(int client, int entity, ConfigMap wearables)
 {
	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "wearable_%i", i);
		
	ConfigMap subsection = wearables.GetSection(secName);
	while (subsection != null)
	{
		char classname[255], atts[255];
		
		subsection.Get("classname", classname, sizeof(classname));
		int index = GetIntFromConfigMap(subsection, "index", 0);
		subsection.Get("attributes", atts, sizeof(atts));
		bool visible = GetBoolFromConfigMap(subsection, "visible", true);
		int paint = GetIntFromConfigMap(subsection, "paint", -1);
		//TODO: Maybe add support for wearable scale?
		
		int hat = CreateWearable(client, index, atts, paint, visible, 0.0, true);
		int wearable = CreateEntityByName("prop_dynamic_override");
		if (IsValidEntity(hat) && IsValidEntity(wearable))
		{
       	 	SetEntProp(wearable, Prop_Send, "m_nModelIndex", GetEntProp(hat, Prop_Send, "m_nModelIndex"));
			RemoveEntity(hat);
			DispatchSpawn(wearable);
			
			SetEntProp(wearable, Prop_Send, "m_fEffects", 1|512);
			SetEntityMoveType(wearable, MOVETYPE_NONE);
			SetEntProp(wearable, Prop_Data, "m_nNextThinkTick", -1.0);
			SetEntityCollisionGroup(wearable, 0);
			
			if (TF2_GetClientTeam(client) == TFTeam_Blue)
			{
				DispatchKeyValue(wearable, "skin", "1");
			}
			else
			{
				DispatchKeyValue(wearable, "skin", "0");
			}
			
			SetVariantString("!activator");
			AcceptEntityInput(wearable, "SetParent", entity);
		
			i_PreviewOwner[wearable] = GetClientUserId(client);
			//SetEdictFlags(wearable, GetEdictFlags(wearable)&(~FL_EDICT_ALWAYS));
			SDKHook(wearable, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		}
		
		i++;
		Format(secName, sizeof(secName), "wearable_%i", i);
		delete subsection;
		subsection = wearables.GetSection(secName);
	}
 }
 #endif
 
 public void CFC_GiveWearables(int client, ConfigMap wearables)
 {
	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "wearable_%i", i);
		
	ConfigMap subsection = wearables.GetSection(secName);
	while (subsection != null)
	{
		char classname[255], atts[255];
		
		subsection.Get("classname", classname, sizeof(classname));
		int index = GetIntFromConfigMap(subsection, "index", 0);
		subsection.Get("attributes", atts, sizeof(atts));
		bool visible = GetBoolFromConfigMap(subsection, "visible", true);
		int paint = GetIntFromConfigMap(subsection, "paint", -1);
		int style = GetIntFromConfigMap(subsection, "style", 0);
		//TODO: Maybe add support for wearable scale?
		
		CF_AttachWearable(client, index, classname, visible, paint, style, false, atts, 0.0);
		
		i++;
		Format(secName, sizeof(secName), "wearable_%i", i);
		subsection = wearables.GetSection(secName);
	}
 }
 
 public void CFC_GiveWeapons(int client, ConfigMap weapons)
 {
 	TF2_RemoveAllWeapons(client);
 	
 	for (int i = 1; i <= 5; i++)	//Extra security measure. Also guarantees items like engineer's PDAs and spy's sapper get removed, which TF2_RemoveAllWeapons does not do.
 	{
 		TF2_RemoveWeaponSlot(client, i);
 	}
 	
		
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
			
		char fireAbility[255], firePlugin[255], fireSound[255];
		subsection.Get("fire_ability", fireAbility, 255);
		subsection.Get("fire_plugin", firePlugin, 255);
		subsection.Get("fire_sound", fireSound, 255);	
			
		int weapon = CF_SpawnWeapon(client, classname, index, level, quality, slot, reserve, clip, attributes, override, visible, unequip, ForceClass, true, fireAbility, firePlugin, fireSound);
		if (IsValidEntity(weapon))
		{
			ConfigMap custAtts = subsection.GetSection("custom_attributes");
			if (custAtts != null)
			{
				StringMapSnapshot snap = custAtts.Snapshot();
				
				for (int j = 0; j < snap.Length; j++)
				{
					char custAtt[255], custVal[255];
					snap.GetKey(j, custAtt, sizeof(custAtt));
					custAtts.Get(custAtt, custVal, sizeof(custVal));
					
					TF2CustAttr_SetString(weapon, custAtt, custVal);
					TF2Attrib_SetFromStringValue(weapon, custAtt, custVal);
				}
				
				delete snap;
			}
		}
		
		i++;
		Format(secName, sizeof(secName), "weapon_%i", i);
		subsection = weapons.GetSection(secName);
	}
 }
 
 void CFC_DeleteParticles(int client, bool IgnorePreserve = false)
 {
 	if (!IsValidClient(client))
 		return;
 		
 	if (CF_CharacterParticles[client] == null)
		return;
 		
 	for (int i = 0; i < GetArraySize(CF_CharacterParticles[client]); i++)
 	{
 		int part = EntRefToEntIndex(GetArrayCell(CF_CharacterParticles[client], i));
 		bool RemoveIt = false;
 		
 		if (IsValidEntity(part))
 		{
 			if (IgnorePreserve || !b_CharacterParticlePreserved[part])
 			{
 				RemoveIt = true;
 				RemoveEntity(part);
 			}
 		}
 		else
 			RemoveIt = true;
 			
 		if (RemoveIt)
 		{
 			RemoveFromArray(CF_CharacterParticles[client], i);
 			i--;
 		}
 	}
 	
 	if (GetArraySize(CF_CharacterParticles[client]) < 1)
 		delete CF_CharacterParticles[client];
 }
 
 #if defined USE_PREVIEWS
 public void CFC_DummyParticles(int client, int entity, ConfigMap particles)
 {
 	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "particle_%i", i);
		
	ConfigMap subsection = particles.GetSection(secName);
	while (subsection != null)
	{
		char partName[255]; char point[255];
		if (TF2_GetClientTeam(client) == TFTeam_Red)
		{
			subsection.Get("name_red", partName, sizeof(partName));
		}
		else
		{
			subsection.Get("name_blue", partName, sizeof(partName));
		}
		
		subsection.Get("point", point, sizeof(point));
		
		float xOff = GetFloatFromConfigMap(subsection, "x_offset", 0.0);
		float yOff = GetFloatFromConfigMap(subsection, "y_offset", 0.0);
		float zOff = GetFloatFromConfigMap(subsection, "z_offset", 0.0);
		
		int part = AttachParticleToEntity(entity, partName, point, 0.0, xOff, yOff, zOff);
		i_PreviewOwner[part] = GetClientUserId(client);
		SetEdictFlags(part, GetEdictFlags(part)&(~FL_EDICT_ALWAYS));
		SDKHook(part, SDKHook_SetTransmit, CF_PreviewModelTransmit);
		
		i++;
		Format(secName, sizeof(secName), "particle_%i", i);
		delete subsection;
		subsection = particles.GetSection(secName);
	}
 }
 #endif
 
 public void CFC_AttachParticles(int client, ConfigMap particles, bool IgnorePreserve)
 {
 	CFC_DeleteParticles(client, IgnorePreserve);
 	
 	if (CF_CharacterParticles[client] == null)
 		CF_CharacterParticles[client] = CreateArray(16);
 	
 	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "particle_%i", i);
		
	ConfigMap subsection = particles.GetSection(secName);
	while (subsection != null)
	{
		char partName[255]; char point[255];
		if (TF2_GetClientTeam(client) == TFTeam_Red)
		{
			subsection.Get("name_red", partName, sizeof(partName));
		}
		else
		{
			subsection.Get("name_blue", partName, sizeof(partName));
		}
		
		subsection.Get("point", point, sizeof(point));
		
		float xOff = GetFloatFromConfigMap(subsection, "x_offset", 0.0);
		float yOff = GetFloatFromConfigMap(subsection, "y_offset", 0.0);
		float zOff = GetFloatFromConfigMap(subsection, "z_offset", 0.0);
		
		CF_AttachParticle(client, partName, point, false, 0.0, xOff, yOff, zOff);
		
		i++;
		Format(secName, sizeof(secName), "particle_%i", i);
		subsection = particles.GetSection(secName);
	}
 }
 
 public void CF_OnPlayerKilled(int victim, int inflictor, int attacker, int deadRinger)
 {
 	if (victim > 0 && victim <= MaxClients && !deadRinger)
 	{
 		b_IsDead[victim] = true;
 	}
 }
 
 public void CF_UpdateCharacterHP(int client, TFClassType class, bool spawn)
 {
 	if (!IsValidClient(client))
 		return;
 	
 	int num = 0;
 	while (Classes[num] != class)
 	{
 		num++;
 	}
 	
 	if (num > 8)
 		return;
 	
 	float maxHP = CF_GetCharacterMaxHealth(client);
 	float deduction = f_ClassBaseHP[num];
 	float health = maxHP - deduction;
 	
 	TF2Attrib_RemoveByDefIndex(client, 125);
 	TF2Attrib_RemoveByDefIndex(client, 26);
 	
	if (health < 0.0)
	{
		TF2Attrib_SetByDefIndex(client, 125, -health);
	}
	else
	{
		TF2Attrib_SetByDefIndex(client, 26, health);
	}
	
	if (spawn)
	{
		DataPack pack = new DataPack();
		RequestFrame(CF_GiveMaxHP, pack);
		WritePackCell(pack, client);
		WritePackCell(pack, RoundFloat(maxHP));
	}
 }
 
 public void CF_UpdateCharacterSpeed(int client, TFClassType class)
 {
 	if (!IsValidClient(client))
 		return;
 	
 	int num = 0;
 	while (Classes[num] != class)
 	{
 		num++;
 	}
 	
 	if (num > 8)
 		return;
 		
 	float targSpd = g_Characters[client].Speed;
 	float baseSpd = f_ClassBaseSpeed[num];
 	float speed = targSpd / baseSpd;
 	
 	TF2Attrib_RemoveByDefIndex(client, 54);
 	TF2Attrib_RemoveByDefIndex(client, 107);
 	
	if (speed < 1.0)
	{
		TF2Attrib_SetByDefIndex(client, 54, speed);
	}
	else
	{
		TF2Attrib_SetByDefIndex(client, 107, speed);
	}
 }
 
 public void CF_GiveMaxHP(DataPack pack)
 {
 	ResetPack(pack);
 	int client = ReadPackCell(pack);
 	int hp = ReadPackCell(pack);
 	delete pack;
 	
 	SetEntProp(client, Prop_Send, "m_iHealth", hp);
 }
 
 public any Native_CF_GetCharacterMaxHealth(Handle plugin, int numParams)
 {
 	int client = GetNativeCell(1);
 	
 	if (!CF_IsPlayerCharacter(client))
 		return 0.0;
 		
 	return g_Characters[client].MaxHP;
 }
 
 public Native_CF_SetCharacterMaxHealth(Handle plugin, int numParams)
 {
 	int client = GetNativeCell(1);
 	float NewMax = GetNativeCell(2);

 	if (CF_IsPlayerCharacter(client))
 	{
 		g_Characters[client].MaxHP = NewMax;
 		CF_UpdateCharacterHP(client, g_Characters[client].Class, false);
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
 	Call_StartForward(g_OnCharacterRemoved);
 	
 	Call_PushCell(client);
 	
 	Call_Finish();
 	
 	CF_UnblockAbilitySlot(client, CF_AbilityType_Ult);
 	CF_UnblockAbilitySlot(client, CF_AbilityType_M2);
 	CF_UnblockAbilitySlot(client, CF_AbilityType_M3);
 	CF_UnblockAbilitySlot(client, CF_AbilityType_Reload);
 	//CF_GetPlayerConfig(client, s_PreviousCharacter[client], 255);
 	CF_SetPlayerConfig(client, "");
 	SDKUnhook(client, SDKHook_OnTakeDamageAlive, CFDMG_OnTakeDamageAlive);
 	b_CharacterApplied[client] = false;
 	g_Characters[client].Destroy();
 	
 	CFC_DeleteParticles(client, true);
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
	
	return;
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
		ReturnValue = g_Characters[client].Exists;
	}
	
	return ReturnValue;
}

public any Native_CF_GetCharacterClass(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return TFClass_Unknown;
		
	return g_Characters[client].Class;
}

public Native_CF_SetCharacterClass(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	TFClassType NewClass = GetNativeCell(2);
	
	if (CF_IsPlayerCharacter(client))
	{
		g_Characters[client].Class = NewClass;
		
		TF2_SetPlayerClass(client, g_Characters[client].Class);
		CF_UpdateCharacterHP(client, g_Characters[client].Class, false);
		CF_UpdateCharacterSpeed(client, TF2_GetPlayerClass(client));
	}
}

public Native_CF_AttachParticle(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return -1;
		
	if (CF_CharacterParticles[client] == null)
		CF_CharacterParticles[client] = CreateArray(16);
		
	char partName[255], point[255];
	GetNativeString(2, partName, sizeof(partName));
	GetNativeString(3, point, sizeof(point));
	bool preserve = GetNativeCell(4);
	float lifespan = GetNativeCell(5);
	float xOff = GetNativeCell(6);
	float yOff = GetNativeCell(7);
	float zOff = GetNativeCell(8);
		
	int particle = AttachParticleToEntity(client, partName, point, lifespan, xOff, yOff, zOff);
	
	if (IsValidEntity(particle))
	{
		SetEdictFlags(particle, GetEdictFlags(particle)&(~FL_EDICT_ALWAYS));
			
		i_CharacterParticleOwner[particle] = GetClientUserId(client);
		b_CharacterParticlePreserved[particle] = preserve;
		SDKHook(particle, SDKHook_SetTransmit, CFC_ParticleTransmit);
		PushArrayCell(CF_CharacterParticles[client], EntIndexToEntRef(particle));
		
		return particle;
	}
	
	return -1;
}

public Native_CF_AttachWearable(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return -1;
		
	char atts[255], classname[255];
	int index = GetNativeCell(2);
	GetNativeString(3, classname, sizeof(classname));
	bool visible = GetNativeCell(4);
	int paint = GetNativeCell(5);
	int style = GetNativeCell(7);
	bool preserve = GetNativeCell(8);
	GetNativeString(8, atts, sizeof(atts));
	float lifespan = GetNativeCell(9);
		
	int wearable = CreateWearable(client, index, classname, atts, paint, style, visible, lifespan);
	if (IsValidEntity(wearable))
	{
		SDKCall_EquipWearable(client, wearable);
		b_WearableIsPreserved[wearable] = preserve;
		return wearable;
	}
	
	return -1;
}

public Native_CF_GetCharacterName(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int size = GetNativeCell(3);
	
	if (CF_IsPlayerCharacter(client))
	{
		SetNativeString(2, g_Characters[client].Name, size, false);
		
		#if defined DEBUG_CHARACTER_CREATION
		char debugStrGet[255];
		GetNativeString(2, debugStrGet, 255);
		
		CPrintToChatAll("%N's character's name is currently %s.", client, debugStrGet);
		#endif
	}
	else
	{
		SetNativeString(2, "", size + 1, false);
	}
	
	return;
}

public Native_CF_SetCharacterName(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char NewName[255];
	GetNativeString(2, NewName, sizeof(NewName));
	
	if (CF_IsPlayerCharacter(client))
	{
		g_Characters[client].Name = NewName;
	}
}

public Native_CF_GetCharacterModel(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int size = GetNativeCell(3);
	
	if (CF_IsPlayerCharacter(client))
	{
		SetNativeString(2, g_Characters[client].Model, size, false);
		
		#if defined DEBUG_CHARACTER_CREATION
		char debugStrGet[255];
		GetNativeString(2, debugStrGet, 255);
		
		CPrintToChatAll("%N's character's model is currently %s.", client, debugStrGet);
		#endif
	}
	else
	{
		SetNativeString(2, "", size + 1, false);
	}
	
	return;
}

public Native_CF_SetCharacterModel(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char NewModel[255];
	GetNativeString(2, NewModel, sizeof(NewModel));
	
	if (CF_IsPlayerCharacter(client) && CheckFile(NewModel))
	{
		g_Characters[client].Model = NewModel;
		PrecacheModel(NewModel);
		
		SetVariantString(NewModel);
		AcceptEntityInput(client, "SetCustomModelWithClassAnimations");
	}
}

public any Native_CF_GetCharacterSpeed(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	if (CF_IsPlayerCharacter(client))
	{
		return g_Characters[client].Speed;
	}
	
	return 0.0;
}

public any Native_CF_SetCharacterSpeed(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float NewSpeed = GetNativeCell(2);

	if (CF_IsPlayerCharacter(client))
	{
		g_Characters[client].Speed = NewSpeed;
		CF_UpdateCharacterSpeed(client, TF2_GetPlayerClass(client));
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.0001);
	}
	
	return 0.0;
}

public any Native_CF_GetCharacterScale(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);

	if (CF_IsPlayerCharacter(client))
	{
		return g_Characters[client].Scale;
	}
	
	return 0.0;
}

public any Native_CF_SetCharacterScale(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float NewScale = GetNativeCell(2);
	CF_StuckMethod StuckMethod = GetNativeCell(3);
	char message_failure[255], message_success[255];
	GetNativeString(4, message_failure, sizeof(message_failure));
	GetNativeString(5, message_success, sizeof(message_success));

	if (CF_IsPlayerCharacter(client))
	{
		bool success = StuckMethod == CF_StuckMethod_None || !CheckPlayerWouldGetStuck(client, NewScale);
		if (!success)
		{
			switch(StuckMethod)
			{
				case CF_StuckMethod_Kill:
				{
					FakeClientCommand(client, "explode");
				}
				case CF_StuckMethod_Respawn:
				{
					TF2_RespawnPlayer(client);
				}
				case CF_StuckMethod_DelayResize:
				{
					DataPack pack = new DataPack();
					WritePackCell(pack, GetClientUserId(client));
					WritePackFloat(pack, NewScale);
					WritePackString(pack, message_success);
					
					RequestFrame(SetScale_DelayResize, pack);
				}
			}
			
			if (!StrEqual(message_failure, ""))
				CPrintToChat(client, message_failure);
		}
		else
		{
			g_Characters[client].Scale = NewScale;
			
			SetEntPropFloat(client, Prop_Send, "m_flModelScale", NewScale);
			SetEntPropFloat(client, Prop_Send, "m_flStepSize", 18.0 * NewScale);
			if (!StrEqual(message_success, ""))
				CPrintToChat(client, message_success);
		}
	}
	
	return 0.0;
}

public void SetScale_DelayResize(DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	float NewScale = ReadPackFloat(pack);
	char message_success[255];
	ReadPackString(pack, message_success, 255);
	
	delete pack;
	
	if (!IsValidMulti(client))
		return;
		
	if (!CheckPlayerWouldGetStuck(client, NewScale))
	{
		g_Characters[client].Scale = NewScale;
			
		SetEntPropFloat(client, Prop_Send, "m_flModelScale", NewScale);
		SetEntPropFloat(client, Prop_Send, "m_flStepSize", 18.0 * NewScale);
		
		if (!StrEqual(message_success, ""))
			CPrintToChat(client, message_success);
		
		return;
	}
	
	DataPack pack2 = new DataPack();
	WritePackCell(pack2, GetClientUserId(client));
	WritePackFloat(pack2, NewScale);
	WritePackString(pack2, message_success);
					
	RequestFrame(SetScale_DelayResize, pack2);
}