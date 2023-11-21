static Handle SDKEquipWearable;

void ViewChange_PluginStart()
{
	GameData gamedata = LoadGameConfigFile("sm-tf2.games");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetVirtual(gamedata.GetOffset("RemoveWearable") - 1);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	SDKEquipWearable = EndPrepSDKCall();
	if(!SDKEquipWearable)
		LogError("[Gamedata] Could not find RemoveWearable");
}

/*void HidePlayerWeaponModel(int client, int entity)
{
	SetEntityRenderMode(entity, RENDER_TRANSALPHA);
	SetEntityRenderColor(entity, 0, 0, 0, 0);
	SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW);
	SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", 0.0);
	SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", 0.00001);
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
}*/

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