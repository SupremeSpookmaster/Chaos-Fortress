#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define GENERIC				"cf_generic_abilities"

#define WEAPON				"generic_weapon"
#define CONDS				"generic_conditions"

int Weapon_OriginalWeapon[MAXPLAYERS + 1][5];

float Weapon_EndTime[2049] = { 0.0, ... };

Handle g_hSDKSetItem;

public void OnPluginStart()
{
	/*GameData gamedata = LoadGameConfigFile("tf2.attributes");
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetVirtual(gamedata.GetOffset("CEconItemView::operator=") - 1);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hSDKSetItem = EndPrepSDKCall();
	if(!g_hSDKSetItem)
		LogError("[Gamedata] Could not find CEconItemView::operator=");*/
}

public void OnEntityDestroyed(int entity)
{
	if (entity > 0 && entity < 2049)
	{
		Weapon_EndTime[entity] = 0.0;
	}
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (StrContains(abilityName, WEAPON) != -1)
	{
		Weapon_Activate(client, abilityName);
	}
	
	if (StrContains(abilityName, CONDS) != -1)
	{
		Conds_Activate(client, abilityName);
	}
}

public void Weapon_Activate(int client, char abilityName[255])
{
	char classname[255], atts[255], fireAbility[255], firePlugin[255], fireSound[255];
	
	CF_GetArgS(client, GENERIC, abilityName, "classname", classname, sizeof(classname));
	CF_GetArgS(client, GENERIC, abilityName, "fire_ability", fireAbility, sizeof(fireAbility));
	CF_GetArgS(client, GENERIC, abilityName, "fire_plugin", firePlugin, sizeof(firePlugin));
	CF_GetArgS(client, GENERIC, abilityName, "fire_sound", fireSound, sizeof(fireSound));
	CF_GetArgS(client, GENERIC, abilityName, "attributes", atts, sizeof(atts));
	
	int index = CF_GetArgI(client, GENERIC, abilityName, "index");
	int level = CF_GetArgI(client, GENERIC, abilityName, "level");
	int quality = CF_GetArgI(client, GENERIC, abilityName, "quality");
	int weaponSlot = CF_GetArgI(client, GENERIC, abilityName, "weapon_slot");
	int reserve = CF_GetArgI(client, GENERIC, abilityName, "reserve");
	int clip = CF_GetArgI(client, GENERIC, abilityName, "clip");
	
	bool visible = CF_GetArgI(client, GENERIC, abilityName, "visible") != 0;
	bool unequip = CF_GetArgI(client, GENERIC, abilityName, "unequip") != 0;
	bool forceSwitch = CF_GetArgI(client, GENERIC, abilityName, "force_switch") != 0;
	
	float duration = CF_GetArgF(client, GENERIC, abilityName, "duration");
	
	int weapon = CF_SpawnWeapon(client, classname, index, level, quality, weaponSlot, reserve, clip, atts, "", visible, unequip, -1, false, fireAbility, firePlugin, fireSound);
	if (IsValidEntity(weapon))
	{
		char conf[255], path[255];
		CF_GetPlayerConfig(client, conf, sizeof(conf));
		ConfigMap map = new ConfigMap(conf);
		if (map == null)
			return;
			
		CF_GetAbilityConfigMapPath(client, GENERIC, abilityName, "custom_attributes", path, sizeof(path));
		ConfigMap custAtts = map.GetSection(path);
		if (custAtts != null)
		{
			StringMapSnapshot snap = custAtts.Snapshot();
				
			for (int j = 0; j < snap.Length; j++)
			{
				char custAtt[255], custVal[255];
				snap.GetKey(j, custAtt, sizeof(custAtt));
				custAtts.Get(custAtt, custVal, sizeof(custVal));
					
				TF2Attrib_SetFromStringValue(weapon, custAtt, custVal);
			}
			
			delete snap;
		}
		
		DeleteCfg(map);
		
		if (duration > 0.0)
		{
			int current = GetPlayerWeaponSlot(client, weaponSlot);
			if (IsValidEntity(current))
			{
				if (Weapon_EndTime[current] == 0.0)	//Make sure it is not also a timed weapon
				{
					//TODO: Store the client's current weapon
					//int m_ItemOffset = FindSendPropInfo("CTFWearable", "m_Item");
					//SDKCall(g_hSDKSetItem, GetEntityAddress(Weapon_OriginalWeapon[client][weaponSlot]) + view_as<Address>(m_ItemOffset), GetEntityAddress(current) + view_as<Address>(m_ItemOffset));
				}
			}
			
			Weapon_EndTime[weapon] = GetGameTime() + duration;
			
			SDKUnhook(client, SDKHook_PreThink, Weapon_PreThink);
			SDKHook(client, SDKHook_PreThink, Weapon_PreThink);
		}
		
		if (forceSwitch)
		{
			Weapon_SwitchToWeapon(client, weapon);
		}
	}
}

public Action Weapon_PreThink(int client)
{
	bool AtLeastOne = false;
	
	for (int i = 0; i < 5; i++)
	{
		int wep = GetPlayerWeaponSlot(client, i);
		if (IsValidEntity(wep))
		{
			if (Weapon_EndTime[wep] > 0.0)
			{	
				AtLeastOne = true;
					
				if (GetGameTime() >= Weapon_EndTime[wep])
				{
					bool switchBack = TF2_GetActiveWeapon(client) == wep;
					
					char classname[255];
					GetEntityClassname(wep, classname, sizeof(classname));
					Format(classname, sizeof(classname), "sound_timed_weapon_removed_%s", classname);
					CF_PlayRandomSound(client, "", classname);
					
					TF2_RemoveWeaponSlot(client, i);
					RemoveEntity(wep);
					
					if (IsValidEntity(Weapon_OriginalWeapon[client][i]) && Weapon_OriginalWeapon[client][i] > 0)
					{
						EquipPlayerWeapon(client, Weapon_OriginalWeapon[client][i]);
						if (switchBack)
						{
							Weapon_SwitchToWeapon(client, Weapon_OriginalWeapon[client][i]);
						}
						Weapon_OriginalWeapon[client][i] = -1;
					}
					else if (switchBack)
					{
						//RequestFrame(Weapon_SwitchBackOnDelay, client);
						Weapon_SwitchBackOnDelay(client);
					}
					/*if (Weapon_OriginalWeapon[client][i] != null)
					{
						int entity = TF2Items_GiveNamedItem(client, Weapon_OriginalWeapon[client][i]);
						delete Weapon_OriginalWeapon[client][i];
						
						if(entity != -1)
							EquipPlayerWeapon(client, entity);
					}*/
				}
			}
		}
	}
	
	if (!AtLeastOne)
		SDKUnhook(client, SDKHook_PreThink, Weapon_PreThink);
		
	return Plugin_Continue;
}

void Weapon_SwitchBackOnDelay(int client)
{
	int valid = Weapon_FindFirstValidWeapon(client);
	if (IsValidEntity(valid))
	{
		Weapon_SwitchToWeapon(client, valid);
	}
}

int Weapon_FindFirstValidWeapon(int client)
{
	int ReturnValue = -1;
	
	for (int i = 0; i < 5; i++)
	{
		ReturnValue = GetPlayerWeaponSlot(client, i);
		if (ReturnValue != -1)
			break;
	}
	
	return ReturnValue;
}

void Weapon_SwitchToWeapon(int client, int weapon)
{
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
	
	char classname[255];
	GetEntityClassname(weapon, classname, sizeof(classname));
	FakeClientCommandEx(client, "use %s", classname);
}

public void Conds_Activate(int client, char abilityName[255])
{
	char condStr[255];
	CF_GetArgS(client, GENERIC, abilityName, "conds", condStr, sizeof(condStr));
	
	char conds[32][32];
	int num = ExplodeString(condStr, ";", conds, 32, 32);
	
	for(int i = 0; i < num; i += 2)
	{
		TFCond cond = view_as<TFCond>(StringToInt(conds[i]));
		if(cond)
		{
			TF2_AddCondition(client, cond, StringToFloat(conds[i + 1]));
		}
	}
}