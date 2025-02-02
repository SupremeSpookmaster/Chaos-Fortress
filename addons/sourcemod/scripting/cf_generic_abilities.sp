#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define GENERIC				"cf_generic_abilities"

#define WEAPON				"generic_weapon"
#define CONDS				"generic_conditions"
#define COOLDOWN			"generic_cooldown"
#define PARTICLE			"generic_particle"
#define WEARABLE			"generic_wearable"
#define BLOCK				"generic_block"
#define UNBLOCK				"generic_unblock"
#define TOGGLE				"generic_toggle"
#define LIMIT				"generic_limit"
#define DELAY				"generic_delay"
#define MODEL				"generic_model"
#define SPEED				"generic_speed"
#define HEALTH				"generic_health"
#define SCALE				"generic_scale_ability"
#define SHAKE				"generic_shake"

float Weapon_EndTime[2049] = { 0.0, ... };

enum struct OldWeapon
{
	int itemIndex; 		
	int itemLevel; 		
	int quality; 	
	int reserve;	
	int clip; 		
	int slot;	
	
	char classname[255]; 	
	char atts[255]; 		
	char fireAbility[255]
	char firePlugin[255]; 
	char fireSound[255];
	
	bool visible;
	
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
			ReturnValue = CF_SpawnWeapon(client, this.classname, this.itemIndex, this.itemLevel, this.quality, this.slot, this.reserve, this.clip, this.atts, "", this.visible, true, -1, false, this.fireAbility, this.firePlugin, this.fireSound, false);
			
			if (IsValidEntity(ReturnValue))
			{
				if (this.CustAtts)
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
				
				EquipPlayerWeapon(client, ReturnValue);
			}
		
			this.Delete();
		}
		
		return ReturnValue;
	}
}

OldWeapon ClientOldWeapons[MAXPLAYERS + 1][5];

int Limit_NumUses[MAXPLAYERS + 1][4];
int i_HPToSet[MAXPLAYERS + 1] = { 0, ... };

char s_OldModel[MAXPLAYERS + 1][255];

float f_ModelEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_OldSpeed[MAXPLAYERS + 1] = { 0.0, ... };
float f_SpeedEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_HealthEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_OldMaxHP[MAXPLAYERS + 1] = { 0.0, ... };
float f_ScaleEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_OldScale[MAXPLAYERS + 1] = { 0.0, ... };

bool b_WearablesHidden[MAXPLAYERS + 1] = { false, ... };

Handle g_ModelTimer[MAXPLAYERS + 1] = { null, ... };
Handle g_SpeedTimer[MAXPLAYERS + 1] = { null, ... };
Handle g_HealthTimer[MAXPLAYERS + 1] = { null, ... };
Handle g_ScaleTimer[MAXPLAYERS + 1] = { null, ... };
Handle g_BlockTimers[MAXPLAYERS+1][4];

CF_StuckMethod g_StuckMethod[MAXPLAYERS + 1] = { CF_StuckMethod_None, ... };
char s_OnResizeFailure[MAXPLAYERS + 1][255];
char s_OnResizeSuccess[MAXPLAYERS + 1][255];

public void CF_OnCharacterCreated(int client)
{
	for (int i = 0; i < 4; i++)
	{
		if (g_BlockTimers[client][i] != null && g_BlockTimers[client][i] != INVALID_HANDLE)	//I know SM already checks if the handle isn't null, but if I don't put this check here I get error spam.
		{
			delete g_BlockTimers[client][i];
			g_BlockTimers[client][i] = null;
		}
	}
	
	delete g_ModelTimer[client];
	delete g_SpeedTimer[client];
	delete g_HealthTimer[client];
	delete g_ScaleTimer[client];
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
	if (!StrEqual(pluginName, GENERIC))
		return;
		
	if (StrContains(abilityName, WEAPON) != -1)
	{
		Weapon_Activate(client, abilityName);
	}
	
	if (StrContains(abilityName, CONDS) != -1)
	{
		Conds_Activate(client, abilityName);
	}
	
	if (StrContains(abilityName, COOLDOWN) != -1)
	{
		Cooldown_Activate(client, abilityName);
	}
	
	if (StrContains(abilityName, PARTICLE) != -1)
	{
		Particle_Activate(client, abilityName);
	}
	
	if (StrContains(abilityName, WEARABLE) != -1)
	{
		Wearable_Activate(client, abilityName);
	}
	
	if (StrContains(abilityName, BLOCK) != -1)
	{
		Block_Activate(client, abilityName);
	}
	
	if (StrContains(abilityName, UNBLOCK) != -1)
	{
		Unblock_Activate(client, abilityName);
	}
	
	if (StrContains(abilityName, TOGGLE) != -1)
	{
		Toggle_Activate(client, abilityName);
	}
	
	if (StrContains(abilityName, LIMIT) != -1)
	{
		Limit_Activate(client, abilityName);
	}
	
	if (StrContains(abilityName, DELAY) != -1)
	{
		Delay_Activate(client, abilityName);
	}
	
	if (StrContains(abilityName, MODEL) != -1)
	{
		Model_Activate(client, abilityName);
	}
	
	if (StrContains(abilityName, SPEED) != -1)
	{
		Speed_Activate(client, abilityName);
	}
	
	if (StrContains(abilityName, HEALTH) != -1)
	{
		Health_Activate(client, abilityName);
	}
	
	if (StrContains(abilityName, SCALE) != -1)
	{
		Scale_Activate(client, abilityName);
	}
	
	if (StrContains(abilityName, SHAKE) != -1)
	{
		Shake_Activate(client, abilityName);
	}
}

public void Shake_Activate(int client, char abilityName[255])
{
	float pos[3];
	GetClientAbsOrigin(client, pos);
	
	int amp = CF_GetArgI(client, GENERIC, abilityName, "amp");
	int radius = CF_GetArgI(client, GENERIC, abilityName, "radius");
	int duration = CF_GetArgI(client, GENERIC, abilityName, "duration");
	int frequency = CF_GetArgI(client, GENERIC, abilityName, "frequency");
	
	SpawnShaker(pos, amp, radius, duration, frequency, 4);
}

public void Scale_Activate(int client, char abilityName[255])
{
	float scale = CF_GetArgF(client, GENERIC, abilityName, "scale");
	
	if (GetGameTime() >= f_ScaleEndTime[client] + 0.1)
		f_OldScale[client] = CF_GetCharacterScale(client);
	
	char fail[255], success[255];
	CF_GetArgS(client, GENERIC, abilityName, "on_failure", fail, 255);
	CF_GetArgS(client, GENERIC, abilityName, "on_success", success, 255);
	
	int method = CF_GetArgI(client, GENERIC, abilityName, "stuck_method");
	if (method < 0 || method > 4)
		method = 0;
	
	CF_SetCharacterScale(client, scale, view_as<CF_StuckMethod>(method), fail, success);
	
	int method_end = CF_GetArgI(client, GENERIC, abilityName, "stuck_method_end");
	if (method_end < 0 || method > 4)
		method_end = 0;
	
	g_StuckMethod[client] = view_as<CF_StuckMethod>(method_end);
	
	CF_GetArgS(client, GENERIC, abilityName, "on_failure_end", s_OnResizeFailure[client], 255);
	CF_GetArgS(client, GENERIC, abilityName, "on_success_end", s_OnResizeSuccess[client], 255);
	
	float duration = CF_GetArgF(client, GENERIC, abilityName, "duration");
	if (duration > 0.0)
	{
		f_ScaleEndTime[client] = GetGameTime() + duration - 0.1;
		g_ScaleTimer[client] = CreateTimer(duration, Scale_Revert, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Scale_Revert(Handle revert, int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return Plugin_Continue;
		
	if (GetGameTime() < f_ScaleEndTime[client])
		return Plugin_Continue;
		
	CF_SetCharacterScale(client, f_OldScale[client], g_StuckMethod[client], s_OnResizeFailure[client], s_OnResizeSuccess[client]);
	
	return Plugin_Continue;
}

public void Health_Activate(int client, char abilityName[255])
{
	float maxHP = CF_GetArgF(client, GENERIC, abilityName, "max_health");
	
	if (GetGameTime() >= f_HealthEndTime[client] + 0.1)
		f_OldMaxHP[client] = CF_GetCharacterMaxHealth(client);
		
	CF_SetCharacterMaxHealth(client, maxHP);
	
	int current = RoundFloat(CF_GetArgF(client, GENERIC, abilityName, "active_health"));
	if (current > 0)
	{
		SetEntProp(client, Prop_Send, "m_iHealth", current);
	}
	
	i_HPToSet[client] = RoundFloat(CF_GetArgF(client, GENERIC, abilityName, "health_end"));
	
	float duration = CF_GetArgF(client, GENERIC, abilityName, "duration");
	if (duration > 0.0)
	{
		f_HealthEndTime[client] = GetGameTime() + duration - 0.1;
		g_HealthTimer[client] = CreateTimer(duration, Health_Revert, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Health_Revert(Handle revert, int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return Plugin_Continue;
		
	if (GetGameTime() < f_HealthEndTime[client])
		return Plugin_Continue;
		
	CF_SetCharacterMaxHealth(client, f_OldMaxHP[client]);
	if (i_HPToSet[client] > 0)
	{
		SetEntProp(client, Prop_Send, "m_iHealth", i_HPToSet[client]);
		i_HPToSet[client] = 0;
	}
	
	return Plugin_Continue;
}

public void Speed_Activate(int client, char abilityName[255])
{
	float speed = CF_GetArgF(client, GENERIC, abilityName, "speed");
	
	if (GetGameTime() >= f_SpeedEndTime[client] + 0.1)
		f_OldSpeed[client] = CF_GetCharacterSpeed(client);
		
	CF_SetCharacterSpeed(client, speed);
	
	float duration = CF_GetArgF(client, GENERIC, abilityName, "duration");
	if (duration > 0.0)
	{
		f_SpeedEndTime[client] = GetGameTime() + duration - 0.1;
		g_SpeedTimer[client] = CreateTimer(duration, Speed_Revert, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Speed_Revert(Handle revert, int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return Plugin_Continue;
		
	if (GetGameTime() < f_SpeedEndTime[client])
		return Plugin_Continue;
		
	CF_SetCharacterSpeed(client, f_OldSpeed[client]);
	
	return Plugin_Continue;
}

public void Model_Activate(int client, char abilityName[255])
{
	char model[255];
	CF_GetArgS(client, GENERIC, abilityName, "model", model, sizeof(model));
	Format(model, sizeof(model), "models/%s", model)
	if (!FileExists(model) && !FileExists(model, true))
		return;
		
	PrecacheModel(model);
	
	if (GetGameTime() >= f_ModelEndTime[client] + 0.1)
		CF_GetCharacterModel(client, s_OldModel[client], 255);
		
	CF_SetCharacterModel(client, model);
	
	float duration = CF_GetArgF(client, GENERIC, abilityName, "duration");
	if (duration > 0.0)
	{
		f_ModelEndTime[client] = GetGameTime() + duration - 0.1;
		g_ModelTimer[client] = CreateTimer(duration, Model_Revert, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	if (!b_WearablesHidden[client])
		b_WearablesHidden[client] = CF_GetArgI(client, GENERIC, abilityName, "hide_wearables") > 0;
	if (b_WearablesHidden[client])
	{
		Wearables_SetHidden(client, true);
	}
}

public Action Model_Revert(Handle revert, int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return Plugin_Continue;
		
	if (GetGameTime() < f_ModelEndTime[client])
		return Plugin_Continue;
		
	CF_SetCharacterModel(client, s_OldModel[client]);
	if (b_WearablesHidden[client])
	{
		b_WearablesHidden[client] = false;
		Wearables_SetHidden(client, false);
	}
	
	return Plugin_Continue;
}

public void Wearables_SetHidden(int client, bool hidden)
{
	int entity;
	while((entity = FindEntityByClassname(entity, "tf_wearable")) != -1)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if (owner == client)
		{
			SetEntityRenderMode(entity, hidden ? RENDER_NONE : RENDER_NORMAL);
			DispatchKeyValue(entity, "modelscale", hidden ? "0.00001" : "1.0");
		}
	}
}

public void Delay_Activate(int client, char abilityName[255])
{
	char ab[255], pl[255], snd[255];
	CF_GetArgS(client, GENERIC, abilityName, "ability", ab, sizeof(ab));
	CF_GetArgS(client, GENERIC, abilityName, "plugin", pl, sizeof(pl));
	float delay = CF_GetArgF(client, GENERIC, abilityName, "time");
	Format(snd, sizeof(snd), "sound_%s", abilityName);
	
	DataPack pack = new DataPack();
	CreateDataTimer(delay, Delay_ActivateAbility, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, GetClientUserId(client));
	WritePackString(pack, ab);
	WritePackString(pack, pl);
	WritePackString(pack, snd);
}

public Action Delay_ActivateAbility(Handle delayed, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	char ab[255], pl[255], snd[255];
	ReadPackString(pack, ab, sizeof(ab));
	ReadPackString(pack, pl, sizeof(pl));
	ReadPackString(pack, snd, sizeof(snd));
	delete pack;
	
	if (!IsValidMulti(client))
		return Plugin_Continue;
		
	CF_DoAbility(client, pl, ab);
	CF_PlayRandomSound(client, "", snd);
	
	return Plugin_Continue;
}

public void Block_Activate(int client, char abilityName[255])
{
	CF_AbilityType type = view_as<CF_AbilityType>(CF_GetArgI(client, GENERIC, abilityName, "target_slot") - 1);
	CF_BlockAbilitySlot(client, type);
	
	float duration = CF_GetArgF(client, GENERIC, abilityName, "duration");
	if (duration > 0.0)
	{
		int slot = view_as<int>(type);
		
		DataPack pack = new DataPack();
		g_BlockTimers[client][slot] = CreateDataTimer(duration, Block_Unblock, pack/*, TIMER_FLAG_NO_MAPCHANGE*/);
		WritePackCell(pack, GetClientUserId(client));
		WritePackCell(pack, type);
	}
}

public Action Block_Unblock(Handle unblock, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	CF_AbilityType type = ReadPackCell(pack);
	
	if (IsValidMulti(client))
		CF_UnblockAbilitySlot(client, type);
		
	return Plugin_Continue;
}

public void Unblock_Activate(int client, char abilityName[255])
{
	CF_AbilityType type = view_as<CF_AbilityType>(CF_GetArgI(client, GENERIC, abilityName, "target_slot") - 1);
	CF_UnblockAbilitySlot(client, type);
}

public void Toggle_Activate(int client, char abilityName[255])
{
	CF_AbilityType type = view_as<CF_AbilityType>(CF_GetArgI(client, GENERIC, abilityName, "target_slot") - 1);
	if (!CF_IsAbilitySlotBlocked(client, type))
		CF_BlockAbilitySlot(client, type);
	else
		CF_UnblockAbilitySlot(client, type);
}

public void Limit_Activate(int client, char abilityName[255])
{
	int slot = CF_GetArgI(client, GENERIC, abilityName, "target_slot") - 1;
	int limit = CF_GetArgI(client, GENERIC, abilityName, "max_uses");
	
	Limit_NumUses[client][slot]++;
	
	if (Limit_NumUses[client][slot] >= limit)
	{
		CF_AbilityType type = view_as<CF_AbilityType>(slot);
		CF_BlockAbilitySlot(client, type);
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
		else	//If it is a timed weapon, delete it so its custom attributes handle doesn't stick around and hog memory.
		{
			ClientOldWeapons[client][weaponSlot].Delete();
		}
	}
	
	int weapon = CF_SpawnWeapon(client, classname, index, level, quality, weaponSlot, reserve, clip, atts, "", visible, unequip, -1, false, fireAbility, firePlugin, fireSound, false);
	if (IsValidEntity(weapon))
	{
		char conf[255], path[255];
		CF_GetPlayerConfig(client, conf, sizeof(conf));
		ConfigMap map = new ConfigMap(conf);
		if (map == null)
		{
			EquipPlayerWeapon(client, weapon);
			return;
		}
			
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
		
		EquipPlayerWeapon(client, weapon);
		
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
}

float f_CondEndTime[MAXPLAYERS+1][255];
int i_NumConds[MAXPLAYERS+1] = {0, ...};

public void Conds_Activate(int client, char abilityName[255])
{
	char condStr[255];
	CF_GetArgS(client, GENERIC, abilityName, "conds", condStr, sizeof(condStr));
	
	char conds[32][32];
	int num = ExplodeString(condStr, ";", conds, 32, 32);
	
	float gt = GetGameTime();
	
	for(int i = 0; i < num; i += 2)
	{
		TFCond cond = view_as<TFCond>(StringToInt(conds[i]));
		if(cond)
		{
			float duration = StringToFloat(conds[i + 1]);
			int condNum = view_as<int>(cond);
			
			if (gt > f_CondEndTime[client][condNum])
			{
				TF2_AddCondition(client, cond);
				i_NumConds[client]++;
				f_CondEndTime[client][condNum] = gt + duration;
			}
			else
			{
				f_CondEndTime[client][condNum] += duration;
			}
		}
	}
	
	SDKUnhook(client, SDKHook_PreThink, Conds_PreThink);
	SDKHook(client, SDKHook_PreThink, Conds_PreThink);
}

public Action Conds_PreThink(int client)
{
	float gt = GetGameTime();
	
	for (int i = 0; i < 131; i++)
	{
		if (gt >= f_CondEndTime[client][i] && f_CondEndTime[client][i] > 0.0)
		{
			TF2_RemoveCondition(client, view_as<TFCond>(i));
			i_NumConds[client]--;
			f_CondEndTime[client][i] = 0.0;
		}
	}
	
	if (i_NumConds[client] < 1)
		return Plugin_Stop;
		
	return Plugin_Continue;
}

public void Cooldown_Activate(int client, char abilityName[255])
{
	CF_AbilityType type = CF_AbilityType_Custom;
	
	switch(CF_GetArgI(client, GENERIC, abilityName, "cd_slot"))
	{
		case 1:
		{
			type = CF_AbilityType_Ult;
		}
		case 2:
		{
			type = CF_AbilityType_M2;
		}
		case 3:
		{
			type = CF_AbilityType_M3;
		}
		case 4:
		{
			type = CF_AbilityType_Reload;
		}
	}
	
	CF_ApplyAbilityCooldown(client, CF_GetArgF(client, GENERIC, abilityName, "duration"), type, CF_GetArgI(client, GENERIC, abilityName, "override") != 0, CF_GetArgI(client, GENERIC, abilityName, "delay") != 0);
}

public void Particle_Activate(int client, char abilityName[255])
{
	char name[255], point[255];
	
	if (TF2_GetClientTeam(client) == TFTeam_Red)
	{
		CF_GetArgS(client, GENERIC, abilityName, "name_red", name, sizeof(name));
	}
	else
	{
		CF_GetArgS(client, GENERIC, abilityName, "name_blue", name, sizeof(name));
	}
	
	CF_GetArgS(client, GENERIC, abilityName, "attachment_point", point, sizeof(point));
	bool preserve = CF_GetArgI(client, GENERIC, abilityName, "preserve") != 0;
	float lifespan = CF_GetArgF(client, GENERIC, abilityName, "duration");
	float xOff = CF_GetArgF(client, GENERIC, abilityName, "x_offset");
	float yOff = CF_GetArgF(client, GENERIC, abilityName, "y_offset");
	float zOff = CF_GetArgF(client, GENERIC, abilityName, "z_offset");
	
	CF_AttachParticle(client, name, point, preserve, lifespan, xOff, yOff, zOff);
}

public void Wearable_Activate(int client, char abilityName[255])
{
	char classname[255];
	CF_GetArgS(client, GENERIC, abilityName, "classname", classname, sizeof(classname));
	int index = CF_GetArgI(client, GENERIC, abilityName, "index");
	bool visible = CF_GetArgI(client, GENERIC, abilityName, "visible") != 0;
	int paint = CF_GetArgI(client, GENERIC, abilityName, "paint");
	int style = CF_GetArgI(client, GENERIC, abilityName, "style");
	
	char atts[255];
	CF_GetArgS(client, GENERIC, abilityName, "attributes", atts, sizeof(atts));
	
	float lifespan = CF_GetArgF(client, GENERIC, abilityName, "duration");
	bool preserve = CF_GetArgI(client, GENERIC, abilityName, "preserve") != 0;
	
	if (StrEqual(classname, ""))
	{
		Format(classname, sizeof(classname), "tf_wearable");
	}
	
	CF_AttachWearable(client, index, classname, visible, paint, style, preserve, atts, lifespan);
}

public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
	Weapon_ClearAllOldWeapons(client);
	for (int i = 0; i < 4; i++)
	{
		Limit_NumUses[client][i] = 0;
		if (g_BlockTimers[client][i] != null && g_BlockTimers[client][i] != INVALID_HANDLE)	//I know SM already checks if the handle isn't null, but if I don't put this check here I get error spam.
		{
			delete g_BlockTimers[client][i];
			g_BlockTimers[client][i] = null;
		}
	}
	
	b_WearablesHidden[client] = false;
	
	delete g_ModelTimer[client];
	delete g_SpeedTimer[client];
	delete g_HealthTimer[client];
	delete g_ScaleTimer[client];
	
	i_NumConds[client] = 0;
	
	for (int j = 0; j < 131; j++)
	{
		f_CondEndTime[client][j] = 0.0;
	}
}