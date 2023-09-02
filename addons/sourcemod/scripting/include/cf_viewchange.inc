//MOST OF THE CONTENT in this include file was originally written by Artvin and Batfoxkid for TF2 Zombie Riot. The vast majority of the credit goes to them.
//I DID make heavy edits in porting it to Chaos Fortress, but I am NOT the original author.

static Handle SDKEquipWearable;
static Handle g_hRecalculatePlayerBodygroups;

static const char HandModels[][] =
{
	"models/empty.mdl",
	"models/weapons/c_models/c_scout_arms.mdl",
	"models/weapons/c_models/c_sniper_arms.mdl",
	"models/weapons/c_models/c_soldier_arms.mdl",
	"models/weapons/c_models/c_demo_arms.mdl",
	"models/weapons/c_models/c_medic_arms.mdl",
	"models/weapons/c_models/c_heavy_arms.mdl",
	"models/weapons/c_models/c_pyro_arms.mdl",
	"models/weapons/c_models/c_spy_arms.mdl",
	"models/weapons/c_models/c_engineer_arms.mdl",
};

static const char PlayerModels[][] =
{
	"models/player/scout.mdl",
	"models/player/scout.mdl",
	"models/player/sniper.mdl",
	"models/player/soldier.mdl",
	"models/player/demo.mdl",
	"models/player/medic.mdl",
	"models/player/heavy.mdl",
	"models/player/pyro.mdl",
	"models/player/spy.mdl",
	"models/player/engineer.mdl"
};

static const char RobotModels[][] =
{
	"models/bots/scout/bot_scout.mdl",
	"models/bots/scout/bot_scout.mdl",
	"models/bots/sniper/bot_sniper.mdl",
	"models/bots/soldier/bot_soldier.mdl",
	"models/bots/demo/bot_demo.mdl",
	"models/bots/medic/bot_medic.mdl",
	"models/bots/heavy/bot_heavy.mdl",
	"models/bots/pyro/bot_pyro.mdl",
	"models/bots/spy/bot_spy.mdl",
	"models/bots/engineer/bot_engineer.mdl"
};


static int HandIndex[11];
static int PlayerIndex[10];
static int RobotIndex[10];
static int HandRef[MAXPLAYERS+1];
static int WeaponRef[MAXPLAYERS+1];
static int i_Viewmodel_PlayerModel[MAXPLAYERS + 1];
static int i_Viewmodel_WeaponModel[MAXPLAYERS + 1];
static int i_nm_body_client[MAXPLAYERS + 1];
static TFClassType WeaponClass[MAXPLAYERS + 1];
static int i_WeaponModelIndexOverride[2049];
static int i_WeaponForceClass[2049];

public void ViewChange_OnEntityDestroyed(int entity)
{
	i_WeaponForceClass[entity] = 0;
	i_WeaponModelIndexOverride[entity] = -1;
}

void ViewChange_PluginStart()
{
	GameData gamedata = LoadGameConfigFile("sm-tf2.games");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetVirtual(gamedata.GetOffset("RemoveWearable") - 1);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	SDKEquipWearable = EndPrepSDKCall();
	if(!SDKEquipWearable)
		LogError("[Gamedata] Could not find RemoveWearable");
		
	gamedata = LoadGameConfigFile("zombie_riot");	//TODO: Put this in a new file called chaos_fortress
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CTFPlayerShared::RecalculatePlayerBodygroups");
	if((g_hRecalculatePlayerBodygroups = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CTFPlayerShared::RecalculatePlayerBodygroups");
}

void ViewChange_MapStart()
{
	for(int i; i < sizeof(HandModels); i++)
	{
		HandIndex[i] = PrecacheModel(HandModels[i], true);
	}

	for(int i; i < sizeof(PlayerModels); i++)
	{
		PlayerIndex[i] = PrecacheModel(PlayerModels[i], true);
	}

	for(int i; i < sizeof(RobotModels); i++)
	{
		RobotIndex[i] = PrecacheModel(RobotModels[i], true);
	}
}

void ViewChange_SetForceClass(int entity, int ForceClass)
{
	i_WeaponForceClass[entity] = ForceClass;
}

void ViewChange_SetOverrideIndex(int entity, int override)
{
	if (IsValidEntity(entity))
	{
		i_WeaponModelIndexOverride[entity] = override;
	}
}

void ViewChange_PlayerModel(int client)
{
	int team = GetClientTeam(client);
	int entity = CreateEntityByName("tf_wearable");
	if(entity > MaxClients)	// Weapon viewmodel
	{
		SetEntProp(entity, Prop_Send, "m_nModelIndex", i_CharacterModelIndex[client]);
			
		UpdatePlayerFakeModel(client);
				
		SetEntProp(entity, Prop_Send, "m_fEffects", 129);
		SetEntProp(entity, Prop_Send, "m_iTeamNum", team);
		SetEntProp(entity, Prop_Send, "m_nSkin", team-2);
		SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4);
		SetEntityCollisionGroup(entity, 11);
		SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
		DispatchSpawn(entity);
		SetVariantString("!activator");
		ActivateEntity(entity);
		
		SDKCall_EquipWearable(client, entity);
		SetEntProp(client, Prop_Send, "m_nRenderFX", 6);
				
		i_Viewmodel_PlayerModel[client] = EntIndexToEntRef(entity);
	}
}

void ViewChange_DeleteAll(int client)
{
	if (!IsValidClient(client))
		return;
		
	ViewChange_DeletePlayerModel(client);
	ViewChange_DeleteWeaponModel(client);
	ViewChange_DeleteHands(client);
	UnHidePlayerWeaponModel(client);
}

void ViewChange_DeletePlayerModel(int client)
{
	if (!IsValidClient(client))
		return;
		
	int entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if (entity > MaxClients)
	{
		TF2_RemoveWearable(client, entity);
		//RemoveEntity(entity);
		i_Viewmodel_PlayerModel[client] = -1;
		
		SetEntProp(client, Prop_Send, "m_nRenderFX", RENDERFX_MAX);
	}
}

void ViewChange_DeleteWeaponModel(int client)
{
	if (!IsValidClient(client))
		return;
		
	int entity = EntRefToEntIndex(i_Viewmodel_WeaponModel[client]);
	if (entity > MaxClients)
	{
		SetEntProp(entity, Prop_Send, "m_nRenderFX", RENDERFX_NONE);
		TF2_RemoveWearable(client, entity);
		i_Viewmodel_WeaponModel[client] = -1;
	}
	
	entity = EntRefToEntIndex(WeaponRef[client]);
	if (entity > MaxClients)
	{
		SetEntProp(entity, Prop_Send, "m_nRenderFX", RENDERFX_NONE);
		TF2_RemoveWearable(client, entity);
		WeaponRef[client] = -1;
	}
}

void ViewChange_Switch(int client, int active, const char[] buffer = "")
{
	int entity = EntRefToEntIndex(WeaponRef[client]);
	if(entity > MaxClients)
		TF2_RemoveWearable(client, entity);
	
	entity = EntRefToEntIndex(i_Viewmodel_WeaponModel[client]);
	if(entity > MaxClients)
		TF2_RemoveWearable(client, entity);

	entity = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if(entity > MaxClients)
	{
		if(active > MaxClients)
		{
			int itemdefindex = GetEntProp(active, Prop_Send, "m_iItemDefinitionIndex");
			TFClassType class = TF2_GetWeaponClass(itemdefindex, CF_GetCharacterClass(client), TF2_GetClassnameSlot(buffer, true));
			
			if(i_WeaponForceClass[active] > 0)
			{
				if(i_WeaponForceClass[active] > 9) //it is an allclass weapon, we want to force the weapon into the class the person holds
				//some weapons for engi or spy just don do this and take pyro and look ugly as fuck.
				{
					//exception for engineer, hes always bugged, force medic.
					class = CF_GetCharacterClass(client);
					if(class == TFClass_Engineer)
					{
						class = TFClass_Medic;
					}
				}
				else
				{
					class = Classes[i_WeaponForceClass[active] - 1];
				}
			}
			
			SetEntProp(entity, Prop_Send, "m_nModelIndex", HandIndex[class]);

			entity = CreateEntityByName("tf_wearable_vm");
			if(entity > MaxClients)	// Weapon viewmodel
			{
				int team = GetClientTeam(client);
				if(i_WeaponModelIndexOverride[active] > 0)
					SetEntProp(entity, Prop_Send, "m_nModelIndex", i_WeaponModelIndexOverride[active]);
				else
					SetEntProp(entity, Prop_Send, "m_nModelIndex", GetEntProp(active, Prop_Send, "m_iWorldModelIndex"));
				
				SetEntProp(entity, Prop_Send, "m_fEffects", 129);
				SetEntProp(entity, Prop_Send, "m_iTeamNum", team);
				SetEntProp(entity, Prop_Send, "m_nSkin", team-2);
				SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4);
				SetEntityCollisionGroup(entity, 11);
				SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
				
				DispatchSpawn(entity);
				SetVariantString("!activator");
				ActivateEntity(entity);

				WeaponRef[client] = EntIndexToEntRef(entity);
				SetEntPropFloat(entity, Prop_Send, "m_flPoseParameter", GetEntPropFloat(active, Prop_Send, "m_flPoseParameter"));

				SDKCall_EquipWearable(client, entity);
			}

			entity = CreateEntityByName("tf_wearable");
			if(entity > MaxClients)	// Weapon worldmodel
			{
				int team = GetClientTeam(client);
				if(i_WeaponModelIndexOverride[active] > 0)
					SetEntProp(entity, Prop_Send, "m_nModelIndex", i_WeaponModelIndexOverride[active]);
				else
					SetEntProp(entity, Prop_Send, "m_nModelIndex", GetEntProp(active, Prop_Send, "m_iWorldModelIndex"));
				
				SetEntProp(entity, Prop_Send, "m_fEffects", 129);
				SetEntProp(entity, Prop_Send, "m_iTeamNum", team);
				SetEntProp(entity, Prop_Send, "m_nSkin", team-2);
				SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4);
				SetEntityCollisionGroup(entity, 11);
				SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
				
				DispatchSpawn(entity);
				SetVariantString("!activator");
				ActivateEntity(entity);

				i_Viewmodel_WeaponModel[client] = EntIndexToEntRef(entity);
				SetEntPropFloat(entity, Prop_Send, "m_flPoseParameter", GetEntPropFloat(active, Prop_Send, "m_flPoseParameter"));

				SDKCall_EquipWearable(client, entity);
			}
			
			HidePlayerWeaponModel(client, active);
			
			TF2_SetPlayerClass(client, class, _, false);
			CF_UpdateCharacterHP(client, class, false);
				
			ViewChange_UpdateHands(client, CF_GetCharacterClass(client));

			UpdatePlayerFakeModel(client);
			return;
		}
	}
	
	ViewChange_DeleteHands(client);
	WeaponClass[client] = TFClass_Unknown;
	WeaponRef[client] = INVALID_ENT_REFERENCE;
	i_Viewmodel_WeaponModel[client] = INVALID_ENT_REFERENCE;
}

void ViewChange_DeleteHands(int client)
{
	int entity = EntRefToEntIndex(HandRef[client]);
	if(entity > MaxClients)
		TF2_RemoveWearable(client, entity);

	HandRef[client] = INVALID_ENT_REFERENCE;
}

int ViewChange_UpdateHands(int client, TFClassType class)
{
	ViewChange_DeleteHands(client);
	
	int entity = EntRefToEntIndex(HandRef[client]);
	if(entity <= MaxClients)
	{
		entity = CreateEntityByName("tf_wearable_vm");
		if(entity > MaxClients)
		{
			int hand_index = view_as<int>(class);
			
			//TODO: Support for custom hand models would go here
			SetEntProp(entity, Prop_Send, "m_nModelIndex", HandIndex[hand_index]);
			SetEntProp(entity, Prop_Send, "m_fEffects", 129);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", GetClientTeam(client));
			SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4);
			SetEntityCollisionGroup(entity, 11);
			SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
			DispatchSpawn(entity);
			SetVariantString("!activator");
			ActivateEntity(entity);
			SDKCall_EquipWearable(client, entity);
			HandRef[client] = EntIndexToEntRef(entity);
		}
	}
	return entity;
}

void HidePlayerWeaponModel(int client, int entity)
{
	SetEntityRenderMode(entity, RENDER_TRANSALPHA);
	SetEntityRenderColor(entity, 0, 0, 0, 0);
//	SetEntProp(entity, Prop_Send, "m_bBeingRepurposedForTaunt", 1);
//	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.001);
	SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW);
	SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", 0.0);
	SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", 0.00001);
	//int EntityWeaponModel = EntRefToEntIndex(i_Viewmodel_WeaponModel[client]);
	/*if(IsValidEntity(EntityWeaponModel))
	{
		SetEntPropFloat(EntityWeaponModel, Prop_Send, "m_flModelScale", f_WeaponSizeOverride[entity]);
	}*/
	//EntityWeaponModel = EntRefToEntIndex(WeaponRef[client]); TODO: Model scale support
	/*if(IsValidEntity(EntityWeaponModel))
	{
		SetEntPropFloat(EntityWeaponModel, Prop_Send, "m_flModelScale", f_WeaponSizeOverrideViewmodel[entity]);
	}*/
}

void UnHidePlayerWeaponModel(int client, int entity = -1)
{
	if (!IsValidEntity(entity))
	{
		entity = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	}
	
	if (entity > MaxClients)
	{
		SetEntityRenderColor(entity);
		SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") & ~EF_NODRAW);
		SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", 100000.0);
		SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", 100000.01);
	}
}

void UpdatePlayerFakeModel(int client)
{
	int PlayerModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(PlayerModel > 0)
	{
		SDKCall_RecalculatePlayerBodygroups(client);
		i_nm_body_client[client] = GetEntProp(client, Prop_Data, "m_nBody");
		SetEntProp(PlayerModel, Prop_Send, "m_nBody", i_nm_body_client[client]);
	}
}

stock TFClassType TF2_GetWeaponClass(int index, TFClassType defaul=TFClass_Unknown, int checkSlot=-1)
{
	switch(index)
	{
		case 25, 26:
			return TFClass_Engineer;
		
		case 735, 736, 810, 831, 933, 1080, 1102:
			return TFClass_Spy;
	}
	
	if(defaul != TFClass_Unknown)
	{
		int slot = TF2Econ_GetItemLoadoutSlot(index, defaul);
		if(checkSlot != -1)
		{
			if(slot == checkSlot)
				return defaul;
		}
		else if(slot>=0 && slot<6)
		{
			return defaul;
		}
	}

	TFClassType backup;
	for(TFClassType class=TFClass_Engineer; class>TFClass_Unknown; class--)
	{
		if(defaul == class)
			continue;

		int slot = TF2Econ_GetItemLoadoutSlot(index, class);
		if(checkSlot != -1)
		{
			if(slot == checkSlot)
				return class;
			
			if(!backup && slot >= 0 && slot < 6)
				backup = class;
		}
		else if(slot >= 0 && slot < 6)
		{
			return class;
		}
	}

	if(checkSlot != -1 && backup)
		return backup;
	
	return defaul;
}

void SDKCall_EquipWearable(int client, int entity)
{
	if(SDKEquipWearable)
		SDKCall(SDKEquipWearable, client, entity);
}

stock int TF2_GetClassnameSlot(const char[] classname, bool econ=false)
{
	if(StrEqual(classname, "tf_weapon_scattergun") ||
	   StrEqual(classname, "tf_weapon_handgun_scout_primary") ||
	   StrEqual(classname, "tf_weapon_soda_popper") ||
	   StrEqual(classname, "tf_weapon_pep_brawler_blaster") ||
	  !StrContains(classname, "tf_weapon_rocketlauncher") ||
	   StrEqual(classname, "tf_weapon_particle_cannon") ||
	   StrEqual(classname, "tf_weapon_flamethrower") ||
	   StrEqual(classname, "tf_weapon_grenadelauncher") ||
	   StrEqual(classname, "tf_weapon_cannon") ||
	   StrEqual(classname, "tf_weapon_minigun") ||
	   StrEqual(classname, "tf_weapon_shotgun_primary") ||
	   StrEqual(classname, "tf_weapon_sentry_revenge") ||
	   StrEqual(classname, "tf_weapon_drg_pomson") ||
	   StrEqual(classname, "tf_weapon_shotgun_building_rescue") ||
	   StrEqual(classname, "tf_weapon_syringegun_medic") ||
	   StrEqual(classname, "tf_weapon_crossbow") ||
	  !StrContains(classname, "tf_weapon_sniperrifle") ||
	   StrEqual(classname, "tf_weapon_compound_bow"))
	{
		return TFWeaponSlot_Primary;
	}
	else if(!StrContains(classname, "tf_weapon_pistol") ||
	  !StrContains(classname, "tf_weapon_lunchbox") ||
	  !StrContains(classname, "tf_weapon_jar") ||
	   StrEqual(classname, "tf_weapon_handgun_scout_secondary") ||
	   StrEqual(classname, "tf_weapon_cleaver") ||
	  !StrContains(classname, "tf_weapon_shotgun") ||
	   StrEqual(classname, "tf_weapon_buff_item") ||
	   StrEqual(classname, "tf_weapon_raygun") ||
	  !StrContains(classname, "tf_weapon_flaregun") ||
	  !StrContains(classname, "tf_weapon_rocketpack") ||
	  !StrContains(classname, "tf_weapon_pipebomblauncher") ||
	   StrEqual(classname, "tf_weapon_laser_pointer") ||
	   StrEqual(classname, "tf_weapon_mechanical_arm") ||
	   StrEqual(classname, "tf_weapon_medigun") ||
	   StrEqual(classname, "tf_weapon_smg") ||
	   StrEqual(classname, "tf_weapon_charged_smg"))
	{
		return TFWeaponSlot_Secondary;
	}
	else if(!StrContains(classname, "tf_weapon_re"))	// Revolver
	{
		return econ ? TFWeaponSlot_Secondary : TFWeaponSlot_Primary;
	}
	else if(StrEqual(classname, "tf_weapon_sa"))	// Sapper
	{
		return econ ? TFWeaponSlot_Building : TFWeaponSlot_Secondary;
	}
	else if(!StrContains(classname, "tf_weapon_i") || !StrContains(classname, "tf_weapon_pda_engineer_d"))	// Invis & Destory PDA
	{
		return econ ? TFWeaponSlot_Item1 : TFWeaponSlot_Building;
	}
	else if(!StrContains(classname, "tf_weapon_p"))	// Disguise Kit & Build PDA
	{
		return econ ? TFWeaponSlot_PDA : TFWeaponSlot_Grenade;
	}
	else if(!StrContains(classname, "tf_weapon_bu"))	// Builder Box
	{
		return econ ? TFWeaponSlot_Building : TFWeaponSlot_PDA;
	}
	else if(!StrContains(classname, "tf_weapon_sp"))	 // Spellbook
	{
		return TFWeaponSlot_Item1;
	}
	return TFWeaponSlot_Melee;
}

void SDKCall_RecalculatePlayerBodygroups(int index)
{
	if(g_hRecalculatePlayerBodygroups)
	{
		SDKCall(g_hRecalculatePlayerBodygroups, GetPlayerSharedAddress(index));
	}
}

static Address GetPlayerSharedAddress(int client) {
	return GetEntityAddress(client)
			+ view_as<Address>(FindSendPropInfo("CTFPlayer", "m_Shared"));
}

static int i_PreviousWeapon[MAXPLAYERS+1];

public void ViewChange_WeaponSwitch(int client, int weapon)
{
	if (weapon != -1 && i_PreviousWeapon[client] != EntIndexToEntRef(weapon))
	{
		i_PreviousWeapon[client] = EntIndexToEntRef(weapon);
		DataPack Pack = new DataPack();
		RequestFrame(OnWeaponSwitchFrame, Pack);
		Pack.WriteCell(GetClientUserId(client));
		Pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public void OnWeaponSwitchFrame(DataPack pack)
{
	pack.Reset();
	
	int client = GetClientOfUserId(pack.ReadCell());
	if(client)
	{
		int weapon = EntRefToEntIndex(pack.ReadCell());
		if(weapon != -1)
		{
			char buffer[36];
			GetEntityClassname(weapon, buffer, sizeof(buffer));
			ViewChange_Switch(client, weapon, buffer);
		}
	}
	
	delete pack;
}

//MOST OF THE CONTENT in this include file was originally written by Artvin and Batfoxkid for TF2 Zombie Riot. The vast majority of the credit goes to them.
//I DID make heavy edits in porting it to Chaos Fortress, but I am NOT the original author.