#include "chaos_fortress/cf_viewchange.sp"

char s_WeaponFireAbility[2049][255];
char s_WeaponFirePlugin[2049][255];
char s_WeaponFireSound[2049][255];

bool b_WeaponIsVisible[2049] = { false, ... };

public void CFW_OnEntityDestroyed(int entity)
{
	i_CharacterParticleOwner[entity] = -1;
	s_WeaponFireAbility[entity] = "";
	s_WeaponFirePlugin[entity] = "";
	s_WeaponFireSound[entity] = "";
	b_WeaponIsVisible[entity] = false;
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] classname, bool &result)
{
	if (!StrEqual(s_WeaponFireAbility[weapon], ""))
	{
		CF_DoAbility(client, s_WeaponFirePlugin[weapon], s_WeaponFireAbility[weapon]);
	}
	
	if (!StrEqual(s_WeaponFireSound[weapon], ""))
	{
		CF_PlayRandomSound(client, "", s_WeaponFireSound[weapon]);
	}
	
	return Plugin_Continue;
}

public void CFW_OnPluginStart()
{
	ViewChange_PluginStart();
}

public void CFW_MapStart()
{
	//ViewChange_MapStart();
}

public void CFW_MakeNatives()
{
	CreateNative("CF_SpawnWeapon", Native_CF_SpawnWeapon);
	CreateNative("CF_GetWeaponAbility", Native_CF_GetWeaponAbility);
	CreateNative("CF_GetWeaponSound", Native_CF_GetWeaponSound);
	CreateNative("CF_GetWeaponVisibility", Native_CF_GetWeaponVisibility);
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
 	int ForceClass = GetNativeCell(13);
 	bool spawn = GetNativeCell(14);
 	char fireAbility[255], firePlugin[255], fireSound[255];
 	GetNativeString(15, fireAbility, sizeof(fireAbility));
 	GetNativeString(16, firePlugin, sizeof(firePlugin));
 	GetNativeString(17, fireSound, sizeof(fireSound));
 	
 	return SpawnWeapon_Special(client, name, index, level, qual, slot, reserve, clip, att, override, visible, unequip, ForceClass, spawn, fireAbility, firePlugin, fireSound);
 }

//Credit to Artvin and Batfoxkid for this, I just took it from Zombie Riot and modified some things.
stock int SpawnWeapon_Special(int client, char[] name, int index, int level, int qual, int slot, int reserve, int clip, const char[] att, char override[255], bool visible, bool unequip, int ForceClass, bool spawn, char fireAbility[255], char firePlugin[255], char fireSound[255])
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
		
	EquipPlayerWeapon(client, entity);

	if(visible)
	{
		SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
	}
	else
	{
		SetEntProp(entity, Prop_Send, "m_iWorldModelIndex", -1);
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.001);
	}
	
	if (StrEqual(name, "tf_weapon_medigun"))
	{
		SDKUnhook(client, SDKHook_PreThink, Medigun_PreThink);
		SDKHook(client, SDKHook_PreThink, Medigun_PreThink);
	}
	
	if (slot < 2)
	{
		#if defined TESTING
		
		CFW_SetAmmo(client, entity, clip, reserve);
		
		#else

		//The following functionality completely obliterates bots and makes them constantly swarm the resupply locker.
		//This causes them to constantly have their character recreated. For just one client? This is no issue.
		//20+ bots all doing it at the same time? Say goodbye to your server performance.
		//I don't intend to make CF work with bots, so I won't bother fixing this myself, but it DOES make testing very difficult, hence the #if defined TESTING.
		if (!spawn)
		{
			CFW_SetAmmo(client, entity, clip, reserve);
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
	
	strcopy(s_WeaponFireAbility[entity], 255, fireAbility);
	strcopy(s_WeaponFirePlugin[entity], 255, firePlugin);
	strcopy(s_WeaponFireSound[entity], 255, fireSound);
	b_WeaponIsVisible[entity] = visible;
	
	return entity;
}

public void CFW_SetAmmo(int client, int weapon, int clip, int reserve)
{
	if (!IsValidClient(client) || !IsValidEntity(weapon))
		return;
		
	if (clip > 0)
		SetEntProp(weapon, Prop_Data, "m_iClip1", clip);
		
	int ammoType = (reserve > -1 ? GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType") : -1);
	if(ammoType!=-1)
	{
		SetEntProp(client, Prop_Data, "m_iAmmo", reserve, _, ammoType);
	}
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
		
	CFW_SetAmmo(client, weapon, clip, reserve);
}

//Don't let characters who just happen to be spies or engineers have sappers or PDAs.
public Action TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
    switch (iItemDefinitionIndex)
    {    case 735, 736, 810, 831, 933, 1080, 1102, 25, 26, 28, 737: return Plugin_Handled;    }
    return Plugin_Continue;
}

public Native_CF_GetWeaponAbility(Handle plugin, int numParams)
{
	int ent = GetNativeCell(1);
	int abLen = GetNativeCell(3);
	int plugLen = GetNativeCell(5);
	
	if (!IsValidEntity(ent))
	{
		SetNativeString(2, "", abLen);
		SetNativeString(4, "", plugLen);
		return;
	}
	
	SetNativeString(2, s_WeaponFireAbility[ent], abLen);
	SetNativeString(4, s_WeaponFirePlugin[ent], plugLen);
}

public Native_CF_GetWeaponSound(Handle plugin, int numParams)
{
	int ent = GetNativeCell(1);
	int len = GetNativeCell(3);
	
	if (!IsValidEntity(ent))
	{
		SetNativeString(2, "", len);
		return;
	}
	
	SetNativeString(2, s_WeaponFireSound[ent], len);
}

public any Native_CF_GetWeaponVisibility(Handle plugin, int numParams)
{
	int ent = GetNativeCell(1);
	
	if (!IsValidEntity(ent))
	{
		return false;
	}
	
	return b_WeaponIsVisible[ent];
}