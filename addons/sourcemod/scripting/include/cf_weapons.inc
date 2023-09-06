#include <cf_viewchange>

public void CFW_OnPluginStart()
{
	ViewChange_PluginStart();
}

public void CFW_MapStart()
{
	ViewChange_MapStart();
}

public void CFW_MakeNatives()
{
	CreateNative("CF_SpawnWeapon", Native_CF_SpawnWeapon);
}

public Native_CF_SpawnWeapon(Handle plugin, int numParams)
{
 	int client = GetNativeCell(1);
 	if (!IsValidClient(client))
 		return -1;
 		
 	char name[255];
 	GetNativeString(2, name, sizeof(name));
 	
 	int index = GetNativeCell(3);
 	int level = GetNativeCell(4);
 	int qual = GetNativeCell(5);
 	int slot = GetNativeCell(6);
 	int reserve = GetNativeCell(7);
 	int clip = GetNativeCell(8);
 	
 	char att[255];
 	GetNativeString(9, att, sizeof(att));
 	
 	char override[255];
 	GetNativeString(10, override, sizeof(override));
 	
 	bool visible = GetNativeCell(11) != 0;
 	bool unequip = GetNativeCell(12) != 0;
 	bool useVC = CF_GetCharacterUsingViewChange(client);
 	int ForceClass = GetNativeCell(13);
 	bool spawn = GetNativeCell(14);
 	
 	return SpawnWeapon_Special(client, name, index, level, qual, slot, reserve, clip, att, override, visible, unequip, useVC, ForceClass, spawn);
 }

//Credit to Artvin and Batfoxkid for this, I just took it from Zombie Riot and modified some things.
stock int SpawnWeapon_Special(int client, char[] name, int index, int level, int qual, int slot, int reserve, int clip, const char[] att, char override[255], bool visible, bool unequip, bool useVC, int ForceClass, bool spawn)
{
	if(StrEqual(name, "saxxy", false))	// if "saxxy" is specified as the name, replace with appropiate name
	{ 
		switch(TF2_GetPlayerClass(client))
		{
			case TFClass_Scout:	ReplaceString(name, 64, "saxxy", "tf_weapon_bat", false);
			case TFClass_Pyro:	ReplaceString(name, 64, "saxxy", "tf_weapon_fireaxe", false);
			case TFClass_DemoMan:	ReplaceString(name, 64, "saxxy", "tf_weapon_bottle", false);
			case TFClass_Heavy:	ReplaceString(name, 64, "saxxy", "tf_weapon_fists", false);
			case TFClass_Engineer:	ReplaceString(name, 64, "saxxy", "tf_weapon_wrench", false);
			case TFClass_Medic:	ReplaceString(name, 64, "saxxy", "tf_weapon_bonesaw", false);
			case TFClass_Sniper:	ReplaceString(name, 64, "saxxy", "tf_weapon_club", false);
			case TFClass_Spy:	ReplaceString(name, 64, "saxxy", "tf_weapon_knife", false);
			default:		ReplaceString(name, 64, "saxxy", "tf_weapon_shovel", false);
		}
	}
	else if(StrEqual(name, "tf_weapon_shotgun", false))	// If using tf_weapon_shotgun for Soldier/Pyro/Heavy/Engineer
	{
		switch(TF2_GetPlayerClass(client))
		{
			case TFClass_Pyro:	ReplaceString(name, 64, "tf_weapon_shotgun", "tf_weapon_shotgun_pyro", false);
			case TFClass_Heavy:	ReplaceString(name, 64, "tf_weapon_shotgun", "tf_weapon_shotgun_hwg", false);
			case TFClass_Engineer:	ReplaceString(name, 64, "tf_weapon_shotgun", "tf_weapon_shotgun_primary", false);
			default:		ReplaceString(name, 64, "tf_weapon_shotgun", "tf_weapon_shotgun_soldier", false);
		}
	}

	Handle hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if(hWeapon == INVALID_HANDLE)
		return -1;
	
	if (unequip)
	{
		TF2_RemoveWeaponSlot(client, slot);
	}

	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);

	char atts[32][32];
	int count = ExplodeString(att, ";", atts, 32, 32);

	if(count % 2)
		--count;
		
	TF2Items_SetNumAttributes(hWeapon, count);
	
	for(int i; i < count; i += 2)
	{
		int attrib = StringToInt(atts[i]);
		if(attrib)
		{
			TF2Items_SetAttribute(hWeapon, i == 0 ? 0 : i / 2, attrib, StringToFloat(atts[i + 1]));
		}
	}

	int entity = TF2Items_GiveNamedItem(client, hWeapon);
	delete hWeapon;
	if(entity == -1)
		return -1;

	if (useVC)
	{
		TFClassType wepClass = TF2_GetWeaponClass(index, CF_GetCharacterClass(client), TF2_GetClassnameSlot(name, true));
		TF2_SetPlayerClass(client, wepClass, _, false);
		EquipPlayerWeapon(client, entity);
		TF2_SetPlayerClass(client, CF_GetCharacterClass(client), _, false);
	}
	else
	{
		EquipPlayerWeapon(client, entity);
	}

	if(visible)
	{
		SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
		if (CheckFile(override) && useVC)
		{
			ViewChange_SetOverrideIndex(entity, PrecacheModel(override));
		}
		else if (!useVC)
		{
			UnHidePlayerWeaponModel(client, entity);
		}
	}
	else
	{
		SetEntProp(entity, Prop_Send, "m_iWorldModelIndex", -1);
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.001);
	}
	
	if (slot < 2)
	{
		#if defined TESTING
		
		SetAmmo(client, entity, reserve);
		SetClip(client, entity, clip);
		
		#else

		//The following functionality completely obliterates bots and makes them constantly swarm the resupply locker.
		//This causes them to constantly have their character recreated. For just one client? This is no issue.
		//20+ bots all doing it at the same time? Say goodbye to your server performance.
		//I don't intend to make CF work with bots, so I won't bother fixing this myself, but it DOES make testing very difficult, hence the #if defined TESTING.
		if (!spawn)
		{
			SetAmmo(client, entity, reserve);
			SetClip(client, entity, clip);
		}
		else
		{
			DataPack pack = new DataPack();
			RequestFrame(CFW_GiveAmmoOnDelay, pack);
			WritePackCell(pack, GetClientUserId(client));
			WritePackCell(pack, EntIndexToEntRef(entity));
			WritePackCell(pack, reserve);
			WritePackCell(pack, clip);
		}
		
		#endif
	}
	
	if (ForceClass > 0 && useVC)
	{
		ViewChange_SetForceClass(entity, ForceClass);
	}
	
	return entity;
}

public void CFW_GiveAmmoOnDelay(DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int weapon = EntRefToEntIndex(ReadPackCell(pack));
	int reserve = ReadPackCell(pack);
	int clip = ReadPackCell(pack);
	delete pack;
	
	if (!IsValidClient(client) || !IsValidEntity(weapon))
		return;
		
	SetAmmo(client, weapon, reserve);
	SetClip(client, weapon, clip);
}

//Below is borrowed from DarthNinja
stock void SetAmmo(int client, int weapon, int newAmmo)
{
	if (IsValidEntity(weapon))
	{
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(client, iAmmoTable+iOffset, newAmmo, 4, true);
	}
}

stock int GetAmmo(int client, int weapon)
{
	int value = -1;
	if (IsValidEntity(weapon))
	{
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		value = GetEntData(client, iAmmoTable+iOffset);
	}
	
	return value;
}

stock void SetClip(int client, int weapon, int newAmmo)
{
	if (IsValidEntity(weapon))
	{
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, newAmmo, 4, true);
	}
}
//Above is borrowed from DarthNinja

//Don't let characters who just happen to be spies or engineers have sappers or PDAs.
public Action TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
    switch (iItemDefinitionIndex)
    {    case 735, 736, 810, 831, 933, 1080, 1102, 25, 26, 28, 737: return Plugin_Handled;    }
    return Plugin_Continue;
}