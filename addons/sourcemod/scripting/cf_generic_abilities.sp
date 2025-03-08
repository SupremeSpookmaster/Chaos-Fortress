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
#define ARCHETYPE			"generic_archetype_modifiers"
#define RESOURCE_VFX		"generic_resource_particles"
#define SELF_HEAL			"generic_self_heal"
#define ATKSPEED			"generic_attackspeed"

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
	char fireSlot[255];
	
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
		CF_GetWeaponAbilitySlot(weapon, this.fireSlot, 255);
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
			ReturnValue = CF_SpawnWeapon(client, this.classname, this.itemIndex, this.itemLevel, this.quality, this.slot, this.reserve, this.clip, this.atts, this.fireSlot, this.visible, true, -1, false, this.fireAbility, this.firePlugin, this.fireSound, false);
			
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
bool b_WeaponForceFired[MAXPLAYERS + 1] = { false, ... };
bool b_WeaponRevertWhenFired[2049] = { false, ... };
int i_ForceFireSlot[MAXPLAYERS + 1] = { 0, ... };
float f_ForceFireDelay[MAXPLAYERS + 1] = { 0.0, ... };
float ATKSpeed_EndTime[MAXPLAYERS + 1] = { 0.0, ... };

public void CF_OnCharacterCreated(int client)
{
	Generic_DeleteTimers(client);
	b_WeaponForceFired[client] = false;
	ATKSpeed_EndTime[client] = 0.0;
	SetForceButtonState(client, false, IN_ATTACK);
	Conds_ClearAll(client);

	if (CF_HasAbility(client, GENERIC, RESOURCE_VFX))
		RVFX_Prepare(client);
}

enum struct ResourceParticle
{
	float minResource; 
	float maxResource;
	float xOff;
	float yOff;
	float zOff;
	float lifespan;

	bool active;
	bool ignoreActiveState;
	bool isUlt;

	char effect_Red[255];
	char effect_Blue[255];
	char point[255];

	int index;

	void CreateFromArgs(ConfigMap path)
	{
		this.minResource = GetFloatFromConfigMap(path, "min_resource", 0.0);
		this.maxResource = GetFloatFromConfigMap(path, "max_resource", 0.0);
		this.xOff = GetFloatFromConfigMap(path, "x_offset", 0.0);
		this.yOff = GetFloatFromConfigMap(path, "y_offset", 0.0);
		this.zOff = GetFloatFromConfigMap(path, "z_offset", 0.0);
		this.lifespan = GetFloatFromConfigMap(path, "lifespan", 0.0);
		this.ignoreActiveState = GetBoolFromConfigMap(path, "multiple", false);
		this.isUlt = GetBoolFromConfigMap(path, "use_ult", false);
		path.Get("effect_red", this.effect_Red, 255);
		path.Get("effect_blue", this.effect_Blue, 255);
		path.Get("point", this.point, 255);
	}

	void CheckAttach(int client, float amt, bool isUlt)
	{
		if (isUlt != this.isUlt)
			return;

		if (amt >= this.minResource && (amt < this.maxResource || this.maxResource <= 0.0) && (!this.active || this.ignoreActiveState))
		{
			this.AttachParticle(client);
		}
	}

	void CheckDetach(int client, float amt, bool isUlt)
	{
		if (isUlt != this.isUlt)
			return;

		if ((amt >= this.maxResource && this.maxResource > 0.0) || amt < this.minResource)
		{
			this.RemoveParticle();
		}
	}

	void AttachParticle(int client)
	{
		this.index = EntIndexToEntRef(CF_AttachParticle(client, TF2_GetClientTeam(client) == TFTeam_Red ? this.effect_Red : this.effect_Blue, this.point, true, this.lifespan, this.xOff, this.yOff, this.zOff));
		this.active = true;
	}

	void RemoveParticle()
	{
		int effect = this.GetParticle();
		if (IsValidEntity(effect))
			RemoveEntity(effect);

		this.index = -1;
		this.active = false;
	}

	int GetParticle() { if (this.index == 0) { return -1; } return EntRefToEntIndex(this.index); }
}

ResourceParticle RVFX_Particles[MAXPLAYERS + 1][32];
int RVFX_NumParticles[MAXPLAYERS + 1] = { 0, ... };

public void RVFX_Prepare(int client)
{
	char conf[255], slot[255], path[255];
	CF_GetPlayerConfig(client, conf, sizeof(conf));
	ConfigMap map = new ConfigMap(conf);
	if (map == null)
		return;

	Format(slot, sizeof(slot), "effect_1");
	int cell = 0;
	RVFX_NumParticles[client] = 0;
	CF_GetAbilityConfigMapPath(client, GENERIC, RESOURCE_VFX, slot, path, sizeof(path));
	ConfigMap effectMap = map.GetSection(path);
	while (effectMap != null)
	{
		RVFX_Particles[client][cell].CreateFromArgs(effectMap);

		cell++;
		RVFX_NumParticles[client]++;

		Format(slot, sizeof(slot), "effect_%i", cell + 1);
		CF_GetAbilityConfigMapPath(client, GENERIC, RESOURCE_VFX, slot, path, sizeof(path));
		effectMap = map.GetSection(path);
	}

	DeleteCfg(map);
}

public void RVFX_DeleteAll(int client)
{
	for (int i = 0; i < RVFX_NumParticles[client]; i++)
	{
		RVFX_Particles[client][i].RemoveParticle();
	}
	RVFX_NumParticles[client] = 0;
}

public Action CF_OnSpecialResourceApplied(int client, float current, float &amt)
{
	if (!CF_HasAbility(client, GENERIC, RESOURCE_VFX))
		return Plugin_Continue;

	for (int i = 0; i < RVFX_NumParticles[client]; i++)
	{
		RVFX_Particles[client][i].CheckAttach(client, amt, false);
		RVFX_Particles[client][i].CheckDetach(client, amt, false);
	}

	return Plugin_Continue;
}

public Action CF_OnUltChargeApplied(int client, float current, float &amt)
{
	if (!CF_HasAbility(client, GENERIC, RESOURCE_VFX))
		return Plugin_Continue;

	for (int i = 0; i < RVFX_NumParticles[client]; i++)
	{
		RVFX_Particles[client][i].CheckAttach(client, amt, true);
		RVFX_Particles[client][i].CheckDetach(client, amt, true);
	}

	return Plugin_Continue;
}

public void Generic_DeleteTimers(int client)
{
	for (int i = 0; i < 4; i++)
	{
		if (g_BlockTimers[client][i] != null && g_BlockTimers[client][i] != INVALID_HANDLE)	//I know SM already checks if the handle isn't null, but if I don't put this check here I get error spam.
		{
			delete g_BlockTimers[client][i];
			g_BlockTimers[client][i] = null;
			CF_UnblockAbilitySlot(client, view_as<CF_AbilityType>(i));
		}
	}
	
	if (g_ModelTimer[client] != null && g_ModelTimer[client] != INVALID_HANDLE)
	{
		delete g_ModelTimer[client];
		g_ModelTimer[client] = null;
	}
	if (g_SpeedTimer[client] != null && g_SpeedTimer[client] != INVALID_HANDLE)
	{
		delete g_SpeedTimer[client];
		g_SpeedTimer[client] = null;
	}
	if (g_HealthTimer[client] != null && g_HealthTimer[client] != INVALID_HANDLE)
	{
		delete g_HealthTimer[client];
		g_HealthTimer[client] = null;
	}
	if (g_ScaleTimer[client] != null && g_ScaleTimer[client] != INVALID_HANDLE)
	{
		delete g_ScaleTimer[client];
		g_ScaleTimer[client] = null;
	}
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

public void OnMapEnd()
{
	for (int i = 0; i < 2049; i++)
		b_WeaponRevertWhenFired[i] = false;
}

public void OnEntityDestroyed(int entity)
{
	if (entity > 0 && entity < 2049)
	{
		Weapon_EndTime[entity] = 0.0;
		b_WeaponRevertWhenFired[entity] = false;
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

	if (StrContains(abilityName, SELF_HEAL) != -1)
	{
		SelfHeal_Activate(client, abilityName);
	}

	if (StrContains(abilityName, ATKSPEED) != -1)
	{
		ATKSpeed_Activate(client, abilityName);
	}
}

float ATKSpeed_Amt[MAXPLAYERS + 1][3];

public void ATKSpeed_Activate(int client, char abilityName[255])
{
	ATKSpeed_Amt[client][0] = CF_GetArgF(client, GENERIC, abilityName, "primary", 1.0);
	ATKSpeed_Amt[client][1] = CF_GetArgF(client, GENERIC, abilityName, "secondary", 1.0);
	ATKSpeed_Amt[client][2] = CF_GetArgF(client, GENERIC, abilityName, "melee", 1.0);
	ATKSpeed_EndTime[client] = GetGameTime() + CF_GetArgF(client, GENERIC, abilityName, "duration");
}

public Action CF_OnCalcAttackInterval(int client, int weapon, int slot, char classname[255], float &rate)
{
	if (GetGameTime() > ATKSpeed_EndTime[client] || slot < 0 || slot > 2)
		return Plugin_Continue;
		
	rate *= ATKSpeed_Amt[client][slot];
	return Plugin_Changed;
}

public void SelfHeal_Activate(int client, char abilityName[255])
{
	float amt = CF_GetArgF(client, GENERIC, abilityName, "amt");
	if (CF_GetArgI(client, GENERIC, abilityName, "mode", 0) > 0)
		amt *= CF_GetCharacterMaxHealth(client);

	float mult = CF_GetArgF(client, GENERIC, abilityName, "overheal", 1.0);

	CF_HealPlayer(client, client, RoundFloat(amt), mult);
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
		DataPack pack = new DataPack();
		g_ScaleTimer[client] = CreateDataTimer(duration, Scale_Revert, pack);
		WritePackCell(pack, GetClientUserId(client));
		WritePackCell(pack, client);
	}
}

public Action Scale_Revert(Handle revert, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int idx = ReadPackCell(pack);
	g_ScaleTimer[idx] = null;

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
		DataPack pack = new DataPack();
		g_HealthTimer[client] = CreateDataTimer(duration, Health_Revert, pack);
		WritePackCell(pack, GetClientUserId(client));
		WritePackCell(pack, client);
	}
}

public Action Health_Revert(Handle revert, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int idx = ReadPackCell(pack);
	g_HealthTimer[idx] = null;

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
		DataPack pack = new DataPack();
		g_SpeedTimer[client] = CreateDataTimer(duration, Speed_Revert, pack);
		WritePackCell(pack, GetClientUserId(client));
		WritePackCell(pack, client);
	}
}

public Action Speed_Revert(Handle revert, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int idx = ReadPackCell(pack);
	g_SpeedTimer[idx] = null;

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
		DataPack pack = new DataPack();
		g_ModelTimer[client] = CreateDataTimer(duration, Model_Revert, pack);
		WritePackCell(pack, GetClientUserId(client));
		WritePackCell(pack, client);
	}
	
	if (!b_WearablesHidden[client])
		b_WearablesHidden[client] = CF_GetArgI(client, GENERIC, abilityName, "hide_wearables") > 0;
	if (b_WearablesHidden[client])
	{
		Wearables_SetHidden(client, true);
	}
}

public Action Model_Revert(Handle revert, DataPack pack)
{
	ResetPack(pack);

	int client = GetClientOfUserId(ReadPackCell(pack));
	int idx = ReadPackCell(pack);
	g_ModelTimer[idx] = null;

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
		WritePackCell(pack, client);
	}
}

public Action Block_Unblock(Handle unblock, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	CF_AbilityType type = ReadPackCell(pack);
	int idx = ReadPackCell(pack);

	int slot = view_as<int>(type);
	g_BlockTimers[idx][slot] = null;
	
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

public void Weapon_StoreOldWeapon(int client, int weaponSlot, float duration)
{
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
}

public void Weapon_Activate(int client, char abilityName[255])
{
	char classname[255], atts[255], fireAbility[255], firePlugin[255], fireSound[255], fireSlot[255], deploySound[255];
	
	CF_GetArgS(client, GENERIC, abilityName, "classname", classname, sizeof(classname));
	CF_GetArgS(client, GENERIC, abilityName, "fire_ability", fireAbility, sizeof(fireAbility));
	CF_GetArgS(client, GENERIC, abilityName, "fire_plugin", firePlugin, sizeof(firePlugin));
	CF_GetArgS(client, GENERIC, abilityName, "fire_sound", fireSound, sizeof(fireSound));
	CF_GetArgS(client, GENERIC, abilityName, "fire_slot", fireSlot, sizeof(fireSlot));
	CF_GetArgS(client, GENERIC, abilityName, "attributes", atts, sizeof(atts));
	CF_GetArgS(client, GENERIC, abilityName, "sound_deployed", deploySound, sizeof(deploySound));
	
	int index = CF_GetArgI(client, GENERIC, abilityName, "index");
	int level = CF_GetArgI(client, GENERIC, abilityName, "level");
	int quality = CF_GetArgI(client, GENERIC, abilityName, "quality");
	int weaponSlot = CF_GetArgI(client, GENERIC, abilityName, "weapon_slot");
	int reserve = CF_GetArgI(client, GENERIC, abilityName, "reserve");
	int clip = CF_GetArgI(client, GENERIC, abilityName, "clip");
	
	bool visible = CF_GetArgI(client, GENERIC, abilityName, "visible") != 0;
	bool unequip = CF_GetArgI(client, GENERIC, abilityName, "unequip") != 0;
	b_WeaponForceFired[client] = CF_GetArgI(client, GENERIC, abilityName, "force_fire", 0) != 0;
	bool forceSwitch = (b_WeaponForceFired[client] || CF_GetArgI(client, GENERIC, abilityName, "force_switch") != 0);
	f_ForceFireDelay[client] = CF_GetArgF(client, GENERIC, abilityName, "swap_delay");
	
	float duration = CF_GetArgF(client, GENERIC, abilityName, "duration");
	
	if (b_WeaponForceFired[client])
	{
		for (int i = 0; i < 5; i++)
		{
			if (IsWeaponActive(client, i))
				i_ForceFireSlot[client] = i;

			Weapon_StoreOldWeapon(client, i, duration);
		}

		TF2_RemoveAllWeapons(client);
	}
	else
		Weapon_StoreOldWeapon(client, weaponSlot, duration);
	
	int weapon = CF_SpawnWeapon(client, classname, index, level, quality, weaponSlot, reserve, clip, atts, fireSlot, visible, unequip, -1, false, fireAbility, firePlugin, fireSound, false);
	if (IsValidEntity(weapon))
	{
		if (deploySound[0])
			CF_PlayRandomSound(client, "", deploySound);
			
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
		b_WeaponRevertWhenFired[weapon] = CF_GetArgI(client, GENERIC, abilityName, "revert_when_fired") != 0;
		
		if (duration > 0.0 && !b_WeaponForceFired[client])
		{	
			Weapon_EndTime[weapon] = GetGameTime() + duration;
			
			SDKUnhook(client, SDKHook_PreThink, Weapon_PreThink);
			SDKHook(client, SDKHook_PreThink, Weapon_PreThink);
		}
		
		if (forceSwitch)
		{
			Weapon_SwitchToWeapon(client, weapon);
		}

		if (b_WeaponForceFired[client])
		{
			SetForceButtonState(client, true, IN_ATTACK);
			b_WeaponForceFired[client] = true;
		}
	}
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[]weaponname, bool &result)
{
	if (b_WeaponForceFired[client] || (IsValidEntity(weapon) && b_WeaponRevertWhenFired[weapon]))
	{
		if (b_WeaponForceFired[client])
			CreateTimer(f_ForceFireDelay[client], Weapon_GiveBackAll, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		else if (IsValidEntity(weapon) && b_WeaponRevertWhenFired[weapon])
		{
			DataPack pack = new DataPack();
			CreateDataTimer(f_ForceFireDelay[client], Weapon_GiveBackSpecific, pack, TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(pack, GetClientUserId(client));
			for (int i = 0; i < 5; i++)
			{
				if (GetPlayerWeaponSlot(client, i) == weapon)
				{
					WritePackCell(pack, i);
					break;
				}
			}
		}

		b_WeaponForceFired[client] = false;
		b_WeaponRevertWhenFired[client] = false;
		SetForceButtonState(client, false, IN_ATTACK);
	}

	return Plugin_Continue;
}

public Action Weapon_GiveBackSpecific(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int slot = ReadPackCell(pack);
	if (!IsValidMulti(client))
		return Plugin_Continue;

	TF2_RemoveWeaponSlot(client, slot);
	ClientOldWeapons[client][slot].GiveBack(client);

	return Plugin_Continue;
}

public Action Weapon_GiveBackAll(Handle timer, int id)
{
	int client = GetClientOfUserId(id);
	if (IsValidMulti(client))
	{
		for (int i = 0; i < 5; i++)
		{
			int wep = GetPlayerWeaponSlot(client, i);
			if (IsValidEntity(wep))
			{
				TF2_RemoveWeaponSlot(client, i);
				RemoveEntity(wep);
			}

			ClientOldWeapons[client][i].GiveBack(client);
		}

		int weapon = GetPlayerWeaponSlot(client, i_ForceFireSlot[client]);
		if (IsValidEntity(weapon))
		{
			char classname[255];
			GetEntityClassname(weapon, classname, sizeof(classname));
			Format(classname, sizeof(classname), "use %s", classname);

			FakeClientCommand(client, classname);
		}
	}

	return Plugin_Continue;
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
	bool reset = CF_GetArgI(client, GENERIC, abilityName, "reset", 0) > 0;
	
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
			
			if (gt > f_CondEndTime[client][condNum] || reset)
			{
				if (gt > f_CondEndTime[client][condNum])
				{
					TF2_AddCondition(client, cond);
					i_NumConds[client]++;
				}

				f_CondEndTime[client][condNum] = gt + duration;
			}
			else
			{
				f_CondEndTime[client][condNum] += duration;
			}
		}
	}
	
	RequestFrame(Conds_Check, GetClientUserId(client));
}

public void Conds_ClearAll(int client)
{
	if (!IsValidClient(client))
		return;

	for (int i = 0; i < 131; i++)
	{
		if (f_CondEndTime[client][i] <= 0.0)
			continue;
			
		if (IsPlayerAlive(client))
			TF2_RemoveCondition(client, view_as<TFCond>(i));

		f_CondEndTime[client][i] = 0.0;
	}
}

public void Conds_Check(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return;

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
		return;
		
	RequestFrame(Conds_Check, id);
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
	Conds_ClearAll(client);
	for (int i = 0; i < 4; i++)
	{
		Limit_NumUses[client][i] = 0;
	}
	Generic_DeleteTimers(client);
	
	b_WearablesHidden[client] = false;
	
	i_NumConds[client] = 0;
	
	for (int j = 0; j < 131; j++)
	{
		f_CondEndTime[client][j] = 0.0;
	}
	b_WeaponForceFired[client] = false;

	if (IsValidClient(client))
	{
		RVFX_DeleteAll(client);
		SetForceButtonState(client, false, IN_ATTACK);
	}
}

public Action CF_OnTakeDamageAlive_Bonus(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	if (!IsValidClient(victim))
		return Plugin_Continue;

	if (CF_HasAbility(attacker, GENERIC, ARCHETYPE) && !IsInvuln(victim))
	{
		char archetype[255];
		CF_GetCharacterArchetype(victim, archetype, sizeof(archetype));

		char conf[255], path[255];
		CF_GetPlayerConfig(attacker, conf, sizeof(conf));
		ConfigMap map = new ConfigMap(conf);
		if (map == null)
		{
			return Plugin_Continue;
		}
			
		CF_GetAbilityConfigMapPath(attacker, GENERIC, ARCHETYPE, archetype, path, sizeof(path));
		ConfigMap interactions = map.GetSection(path);
		if (interactions != null)
		{
			char sound[255];
			interactions.Get("dealt_sound", sound, sizeof(sound));
			if (sound[0])
			{
				PrecacheSound(sound);
				EmitSoundToClient(attacker, sound, _, _, _, _, _, GetRandomInt(80, 110));
				EmitSoundToClient(victim, sound, _, _, _, _, _, GetRandomInt(80, 110));
			}

			damage *= GetFloatFromConfigMap(interactions, "damage_dealt", 1.0);

			DeleteCfg(map);

			return Plugin_Changed;
		}

		DeleteCfg(map);
	}

	return Plugin_Continue;
}

public Action CF_OnTakeDamageAlive_Resistance(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	if (!IsValidClient(victim))
		return Plugin_Continue;
		
	if (CF_HasAbility(victim, GENERIC, ARCHETYPE) && !IsInvuln(victim))
	{
		char archetype[255];
		CF_GetCharacterArchetype(attacker, archetype, sizeof(archetype));

		char conf[255], path[255];
		CF_GetPlayerConfig(victim, conf, sizeof(conf));
		ConfigMap map = new ConfigMap(conf);
		if (map == null)
		{
			return Plugin_Continue;
		}
			
		CF_GetAbilityConfigMapPath(victim, GENERIC, ARCHETYPE, archetype, path, sizeof(path));
		ConfigMap interactions = map.GetSection(path);
		if (interactions != null)
		{
			char sound[255];
			interactions.Get("taken_sound", sound, sizeof(sound));
			if (sound[0])
			{
				PrecacheSound(sound);
				EmitSoundToClient(attacker, sound, _, _, _, _, _, GetRandomInt(80, 110));
				EmitSoundToClient(victim, sound, _, _, _, _, _, GetRandomInt(80, 110));
			}

			damage *= GetFloatFromConfigMap(interactions, "damage_taken", 1.0);

			DeleteCfg(map);

			return Plugin_Changed;
		}

		DeleteCfg(map);
	}

	return Plugin_Continue;
}