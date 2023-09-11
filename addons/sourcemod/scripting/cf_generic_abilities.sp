#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define GENERIC				"cf_generic_abilities"

#define WEAPON				"generic_weapon"
#define CONDS				"generic_conditions"

float Weapon_EndTime[2049] = { 0.0, ... };

Handle g_hSDKSetItem;

enum struct OldWeapon
{
	int itemIndex; 		//Done 
	int itemLevel; 		//Done 
	int quality; 	//Done 
	int reserve;	//Done 
	int clip; 		//Done
	int slot;		//Done
	
	char classname[255]; 	//Done
	char atts[255]; 		//Done
	char fireAbility[255]; 	//Done
	char firePlugin[255]; 	//Done
	char fireSound[255];	//Done
	
	bool visible;			//Done
	
	KeyValues CustAtts;

	void Delete()
	{
		this.itemIndex = -1;
		this.itemLevel = -1;
		this.quality = -1;
		this.reserve = -1;
		this.clip = -1;
		this.slot = -1;
		
		strcopy(this.classname, 255, "");
		strcopy(this.fireAbility, 255, "");
		strcopy(this.firePlugin, 255, "");
		strcopy(this.fireSound, 255, "");
		strcopy(this.atts, 255, "");

		this.visible = false;
		
		delete this.CustAtts;
		
		return;
	}
	
	void CopyFromWeapon(int weapon, int weaponSlot, int client)
	{
		if (!IsValidEntity(weapon) || !IsValidMulti(client))
			return;
		
		this.reserve = GetAmmo(client, weapon);
		this.clip = GetClip(weapon);
		this.itemIndex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		this.itemLevel = GetEntProp(weapon, Prop_Send, "m_iEntityLevel");
		this.quality = GetEntProp(weapon, Prop_Send, "m_iEntityQuality");
		
		GetEntityClassname(weapon, this.classname, 255);
		GetAttribStringFromWeapon(weapon, this.atts);
		CF_GetWeaponAbility(weapon, this.fireAbility, 255, this.firePlugin, 255);
		CF_GetWeaponSound(weapon, this.fireSound, 255);
		this.visible = CF_GetWeaponVisibility(weapon);
		
		this.slot = weaponSlot;
		
		this.CustAtts = TF2CustAttr_GetAttributeKeyValues(weapon);
			
		return;
	}
	
	int GiveBack(int client)
	{
		if (!IsValidMulti(client))
			return -1;
			
		int ReturnValue = -1;
		
		if (!StrEqual(this.classname, ""))
		{
			ReturnValue = CF_SpawnWeapon(client, this.classname, this.itemIndex, this.itemLevel, this.quality, this.slot, this.reserve, this.clip, this.atts, "", this.visible, true, -1, false, this.fireAbility, this.firePlugin, this.fireSound);
			
			if (IsValidEntity(ReturnValue) && this.CustAtts)
			{
				if (KvGotoFirstSubKey(this.CustAtts, false))
				{
					do
				    {
						char key[255], value[255];
						KvGetSectionName(this.CustAtts, key, sizeof(key));
						KvGetString(this.CustAtts, NULL_STRING, value, sizeof(value));
				        
						TF2CustAttr_SetString(ReturnValue, key, value);
						TF2Attrib_SetFromStringValue(ReturnValue, key, value);
				    } while (KvGotoNextKey(this.CustAtts, false));
				}
			}
		
			this.Delete();
		}
		
		return ReturnValue;
	}
}

OldWeapon ClientOldWeapons[MAXPLAYERS + 1][5];

public void CF_OnCharacterRemoved(int client)
{
	Weapon_ClearAllOldWeapons(client);
}

public void Weapon_ClearAllOldWeapons(int client)
{
	if (client > 0 && client < MaxClients + 1)
	{
		for (int i = 0; i < 5; i++)
		{
			ClientOldWeapons[client][i].Delete();
		}
	}
}

public void OnPluginStart()
{
	GameData gamedata = LoadGameConfigFile("tf2.attributes");
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CEconItemView::operator=");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_ByValue);
	g_hSDKSetItem = EndPrepSDKCall();
	if (g_hSDKSetItem == INVALID_HANDLE)
		LogError("Gamedata error: failed to locate CEconItemView::operator=");
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
	
	int current = GetPlayerWeaponSlot(client, weaponSlot);
	if (IsValidEntity(current) && duration > 0.0)
	{
		if (Weapon_EndTime[current] == 0.0)	//Make sure it is not also a timed weapon
		{
			ClientOldWeapons[client][weaponSlot].CopyFromWeapon(current, weaponSlot, client);
		}
	}
	
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
					
				TF2CustAttr_SetString(weapon, custAtt, custVal);
				TF2Attrib_SetFromStringValue(weapon, custAtt, custVal);
			}
			
			delete snap;
		}
		
		DeleteCfg(map);
		
		if (duration > 0.0)
		{	
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
					bool holdingRemovedWeapon = TF2_GetActiveWeapon(client) == wep;
					
					char classname[255];
					GetEntityClassname(wep, classname, sizeof(classname));
					Format(classname, sizeof(classname), "sound_timed_weapon_removed_%s", classname);
					CF_PlayRandomSound(client, "", classname);
					
					TF2_RemoveWeaponSlot(client, i);
					RemoveEntity(wep);
					
					int newWep = ClientOldWeapons[client][i].GiveBack(client);
					if (!IsValidEntity(newWep) && holdingRemovedWeapon)	//The new weapon failed to spawn meaning the client did not originally have a weapon in this slot, force-switch them to their first valid weapon.
					{
						Weapon_SwitchBackOnDelay(client);
						CPrintToChat(client, "Invalid weapon");
					}
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
	TF2Util_SetPlayerActiveWeapon(client, weapon);
	/*SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
	
	char classname[255];
	GetEntityClassname(weapon, classname, sizeof(classname));
	FakeClientCommandEx(client, "use %s", classname);*/
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