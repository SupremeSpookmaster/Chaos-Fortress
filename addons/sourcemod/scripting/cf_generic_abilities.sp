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
#define SENTRY_PROJECTILES	"generic_sentry_projectiles"
#define NOJUMP				"generic_nojump"
#define FORCETAUNT			"generic_force_taunt"
#define FORCETAUNT_WEAPON	"generic_force_weapon_taunt"
#define CLOAK_BLOCK			"generic_block_cloak"
#define RESOURCES			"generic_give_resources"
#define BULLET				"generic_bullets"

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
	char killIcon[255];
	
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
		CF_GetWeaponKillIcon(weapon, this.killIcon, 255);
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
				CF_SetWeaponKillIcon(ReturnValue, this.killIcon);
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
float f_SpeedEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_HealthEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_OldMaxHP[MAXPLAYERS + 1] = { 0.0, ... };
float f_ScaleEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_OldScale[MAXPLAYERS + 1] = { 0.0, ... };

bool b_WearablesHidden[MAXPLAYERS + 1] = { false, ... };
bool b_BlockTaunt[MAXPLAYERS + 1] = { false, ... };

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

bool b_SentryProjectiles[MAXPLAYERS + 1] = { false, ... };

#define MODEL_SENTRY_PROJECTILE			"models/weapons/w_models/w_drg_ball.mdl"

char g_SPImpactSounds[][] = {
	"physics/surfaces/sand_impact_bullet1.wav",
	"physics/surfaces/sand_impact_bullet2.wav",
	"physics/surfaces/sand_impact_bullet3.wav",
	"physics/surfaces/sand_impact_bullet4.wav"
};

char g_SPBlastSounds[][] = {
	")weapons/explode1.wav",
	")weapons/explode2.wav",
	")weapons/explode3.wav"
};

#define PARTICLE_SENTRY_PROJECTILE_RED		"raygun_projectile_red"
#define PARTICLE_SENTRY_PROJECTILE_BLUE		"raygun_projectile_blue"
#define PARTICLE_SENTRY_PROJECTILE_IMPACT	"impact_concrete_child_puff"
#define PARTICLE_SENTRY_PROJECTILE_EXPLODE	"ExplosionCore_MidAir"

public void OnMapStart()
{
	PrecacheModel(MODEL_SENTRY_PROJECTILE);

	for (int i = 0; i < sizeof(g_SPImpactSounds); i++) { PrecacheSound(g_SPImpactSounds[i]); }
	for (int i = 0; i < sizeof(g_SPBlastSounds); i++) { PrecacheSound(g_SPBlastSounds[i]); }
}

bool b_NoJump[MAXPLAYERS + 1];
bool Cloak_Active[MAXPLAYERS + 1];

public void CF_OnCharacterCreated(int client)
{
	Generic_DeleteTimers(client);
	b_WeaponForceFired[client] = false;
	ATKSpeed_EndTime[client] = 0.0;
	SetForceButtonState(client, false, IN_ATTACK);

	if (CF_HasAbility(client, GENERIC, RESOURCE_VFX))
		RVFX_Prepare(client);

	b_NoJump[client] = CF_HasAbility(client, GENERIC, NOJUMP);
	if (b_NoJump[client])
		RequestFrame(NoJump_SetState, GetClientUserId(client));

	Cloak_Active[client] = CF_HasAbility(client, GENERIC, CLOAK_BLOCK);
	if (Cloak_Active[client])
		CloakBlock_Prepare(client);

	b_SentryProjectiles[client] = CF_HasAbility(client, GENERIC, SENTRY_PROJECTILES);
	if (b_SentryProjectiles[client])
		SentryProjectiles_Prepare(client);
}

float Cloak_Duration[MAXPLAYERS + 1];

float Cloak_EndTime[MAXPLAYERS + 1];
bool Cloak_Blocks[MAXPLAYERS + 1][4];

public void CloakBlock_Prepare(int client)
{
	Cloak_Duration[client] = CF_GetArgF(client, GENERIC, CLOAK_BLOCK, "duration");
	Cloak_Blocks[client][0] = CF_GetArgI(client, GENERIC, CLOAK_BLOCK, "block_ult") != 0;
	Cloak_Blocks[client][1] = CF_GetArgI(client, GENERIC, CLOAK_BLOCK, "block_m2") != 0;
	Cloak_Blocks[client][2] = CF_GetArgI(client, GENERIC, CLOAK_BLOCK, "block_m3") != 0;
	Cloak_Blocks[client][3] = CF_GetArgI(client, GENERIC, CLOAK_BLOCK, "block_reload") != 0;
}

public void TF2_OnConditionAdded(int client, TFCond cond)
{
	if (cond == TFCond_Taunting && b_BlockTaunt[client])
	{
		TF2_RemoveCondition(client, cond);
	}
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
	if (!Cloak_Active[client])
		return;
	
	if (condition == TFCond_Cloaked)
		Cloak_EndTime[client] = GetGameTime() + Cloak_Duration[client];
}

public Action CF_OnAbilityCheckCanUse(int client, char plugin[255], char ability[255], CF_AbilityType type, bool &result)
{
	if (!Cloak_Active[client] || (Cloak_EndTime[client] < GetGameTime() && !TF2_IsPlayerInCondition(client, TFCond_Cloaked)))
		return Plugin_Continue;
		
	int slot = view_as<int>(type);
	
	if (Cloak_Blocks[client][slot])
	{
		result = false;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public void NoJump_SetState(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client) || !b_NoJump[client])
		return;

	SetEntProp(client, Prop_Send, "m_bJumping", false);
	RequestFrame(NoJump_SetState, id);
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
		this.minResource = GetFloatFromCFGMap(path, "min_resource", 0.0);
		this.maxResource = GetFloatFromCFGMap(path, "max_resource", 0.0);
		this.xOff = GetFloatFromCFGMap(path, "x_offset", 0.0);
		this.yOff = GetFloatFromCFGMap(path, "y_offset", 0.0);
		this.zOff = GetFloatFromCFGMap(path, "z_offset", 0.0);
		this.lifespan = GetFloatFromCFGMap(path, "lifespan", 0.0);
		this.ignoreActiveState = GetBoolFromCFGMap(path, "multiple", false);
		this.isUlt = GetBoolFromCFGMap(path, "use_ult", false);
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

	if (StrContains(abilityName, FORCETAUNT) != -1)
	{
		ForceTaunt_Activate(client, abilityName);
	}

	if (StrContains(abilityName, FORCETAUNT_WEAPON) != -1)
	{
		ForceTauntWeapon_Activate(client, abilityName);
	}

	if (StrContains(abilityName, RESOURCES) != -1)
	{
		Resources_Activate(client, abilityName);
	}

	if (StrContains(abilityName, BULLET) != -1)
	{
		Bullet_Activate(client, abilityName);
	}
}

bool PrimaryFire_HSFalloff = false;
int PrimaryFire_HSEffect = 1;

public void Bullet_Activate(int client, char abilityName[255])
{
	float damage = CF_GetArgF(client, GENERIC, abilityName, "damage");
	int numBullets = CF_GetArgI(client, GENERIC, abilityName, "bullets");
	float hsMult = CF_GetArgF(client, GENERIC, abilityName, "hs_mult");
	PrimaryFire_HSEffect = CF_GetArgI(client, GENERIC, abilityName, "hs_fx");
	PrimaryFire_HSFalloff = CF_GetArgI(client, GENERIC, abilityName, "hs_falloff") > 0;
	float falloffStart = CF_GetArgF(client, GENERIC, abilityName, "falloff_start");
	float falloffEnd = CF_GetArgF(client, GENERIC, abilityName, "falloff_end");
	float falloffMax = CF_GetArgF(client, GENERIC, abilityName, "falloff_max");
	int pierce = CF_GetArgI(client, GENERIC, abilityName, "pierce");
	float spread = CF_GetArgF(client, GENERIC, abilityName, "spread");
	float width = CF_GetArgF(client, GENERIC, abilityName, "width", 0.0);
	char tracer[255];
	if (TF2_GetClientTeam(client) == TFTeam_Red)
		CF_GetArgS(client, GENERIC, abilityName, "tracer_red", tracer, 255, "bullet_pistol_tracer01_red");
	if (TF2_GetClientTeam(client) == TFTeam_Red)
		CF_GetArgS(client, GENERIC, abilityName, "tracer_blue", tracer, 255, "bullet_pistol_tracer01_blue");

	float ang[3];
	GetClientEyeAngles(client, ang);

	for (int i = 0; i < numBullets; i++)
		CF_FireGenericBullet(client, ang, damage, hsMult, spread, GENERIC, Bullet_Hit, falloffStart, falloffEnd, falloffMax, pierce, grabEnemyTeam(client), _, _, tracer, width);
}

public void Bullet_Hit(int attacker, int victim, float &baseDamage, bool &allowFalloff, bool &isHeadshot, int &hsEffect, bool &crit, float hitPos[3])
{
	if (isHeadshot)
	{
		allowFalloff = PrimaryFire_HSFalloff;
	}

	hsEffect = PrimaryFire_HSEffect;
}

public void Resources_Activate(int client, char abilityName[255])
{
	int type = CF_GetArgI(client, GENERIC, abilityName, "mode", 0);
	if (type < 0)
		type = 0;
	if (type > 8)
		type = 8;

	CF_GiveSpecialResource(client, CF_GetArgF(client, GENERIC, abilityName, "amt"), view_as<CF_ResourceType>(type));
}

float ATKSpeed_Amt[MAXPLAYERS + 1][3];

public void ATKSpeed_Activate(int client, char abilityName[255])
{
	ATKSpeed_Amt[client][0] = CF_GetArgF(client, GENERIC, abilityName, "primary", 1.0);
	ATKSpeed_Amt[client][1] = CF_GetArgF(client, GENERIC, abilityName, "secondary", 1.0);
	ATKSpeed_Amt[client][2] = CF_GetArgF(client, GENERIC, abilityName, "melee", 1.0);
	ATKSpeed_EndTime[client] = GetGameTime() + CF_GetArgF(client, GENERIC, abilityName, "duration");
}

public void ForceTaunt_Activate(int client, char abilityName[255])
{
	int index = CF_GetArgI(client, GENERIC, abilityName, "index");
	float rate = CF_GetArgF(client, GENERIC, abilityName, "rate", 1.0);
	bool interrupt = CF_GetArgI(client, GENERIC, abilityName, "interrupt", 1) > 0;

	CF_ForceTaunt(client, index, rate, interrupt);
}

public void ForceTauntWeapon_Activate(int client, char abilityName[255])
{
	int index = CF_GetArgI(client, GENERIC, abilityName, "index");
	int slot = CF_GetArgI(client, GENERIC, abilityName, "weapon_slot");
	float rate = CF_GetArgF(client, GENERIC, abilityName, "rate", 1.0);
	bool interrupt = CF_GetArgI(client, GENERIC, abilityName, "interrupt", 1) > 0;
	bool visible = CF_GetArgI(client, GENERIC, abilityName, "visible", 1) > 0;
	char classname[255];
	CF_GetArgS(client, GENERIC, abilityName, "classname", classname, 255);

	CF_ForceWeaponTaunt(client, index, classname, slot, rate, interrupt, visible);
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
		
	CF_SetCharacterSpeed(client, CF_GetCharacterBaseSpeed(client));
	
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
	CF_PlayRandomSound(client, client, snd);
	
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
	char classname[255], atts[255], fireAbility[255], firePlugin[255], fireSound[255], fireSlot[255], deploySound[255], icon[255];
	
	CF_GetArgS(client, GENERIC, abilityName, "classname", classname, sizeof(classname));
	CF_GetArgS(client, GENERIC, abilityName, "fire_ability", fireAbility, sizeof(fireAbility));
	CF_GetArgS(client, GENERIC, abilityName, "fire_plugin", firePlugin, sizeof(firePlugin));
	CF_GetArgS(client, GENERIC, abilityName, "fire_sound", fireSound, sizeof(fireSound));
	CF_GetArgS(client, GENERIC, abilityName, "fire_slot", fireSlot, sizeof(fireSlot));
	CF_GetArgS(client, GENERIC, abilityName, "attributes", atts, sizeof(atts));
	CF_GetArgS(client, GENERIC, abilityName, "sound_deployed", deploySound, sizeof(deploySound));
	CF_GetArgS(client, GENERIC, abilityName, "kill_icon", icon, sizeof(icon));
	
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
		CF_SetWeaponKillIcon(weapon, icon);
		
		if (deploySound[0])
			CF_PlayRandomSound(client, client, deploySound);
			
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
			
			b_BlockTaunt[client] = CF_GetArgI(client, GENERIC, abilityName, "timed_weapon_blocks_taunt", 1) != 0;
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
			Weapon_EndTime[weapon] = 0.0;
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
					CF_PlayRandomSound(client, client, classname);
					
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
	
	b_BlockTaunt[client] = AtLeastOne && b_BlockTaunt[client];
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
	
	for(int i = 0; i < num; i += 2)
	{
		TFCond cond = view_as<TFCond>(StringToInt(conds[i]));
		if(cond)
		{
			float duration = StringToFloat(conds[i + 1]);
			CF_AddCondition(client, cond, duration, _, reset);
		}
	}
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
	}
	Generic_DeleteTimers(client);
	
	b_WearablesHidden[client] = false;
	b_BlockTaunt[client] = false;
	
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

			damage *= GetFloatFromCFGMap(interactions, "damage_dealt", 1.0);

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

			damage *= GetFloatFromCFGMap(interactions, "damage_taken", 1.0);

			DeleteCfg(map);

			return Plugin_Changed;
		}

		DeleteCfg(map);
	}

	return Plugin_Continue;
}

float f_SPVel[2049][3];
float f_SPLifespan[2049][3];
float f_SPDMG[2049][3];
float f_SPHAmt[2049][3];
float f_SPHAng[2049][3];
float f_SPRadius[2049][3];
float f_SPFalloffStart[2049][3];
float f_SPFalloffMax[2049][3];

int i_SPLevel[2049] = { -1, ... };
int i_SPSentry[2049] = { -1, ... };

//TODO: Expand on this to allow for customizable model, particle, and blast args
public void SentryProjectiles_Prepare(int client)
{
	char argName[255];
	for (int i = 0; i < 3; i++)
	{
		Format(argName, sizeof(argName), "velocity_%i", i + 1);
		f_SPVel[client][i] = CF_GetArgF(client, GENERIC, SENTRY_PROJECTILES, argName, 900.0);

		Format(argName, sizeof(argName), "lifespan_%i", i + 1);
		f_SPLifespan[client][i] = CF_GetArgF(client, GENERIC, SENTRY_PROJECTILES, argName, 1.2);

		Format(argName, sizeof(argName), "damage_%i", i + 1);
		f_SPDMG[client][i] = CF_GetArgF(client, GENERIC, SENTRY_PROJECTILES, argName, 20.0);

		Format(argName, sizeof(argName), "homing_amount_%i", i + 1);
		f_SPHAmt[client][i] = CF_GetArgF(client, GENERIC, SENTRY_PROJECTILES, argName, 8.0);

		Format(argName, sizeof(argName), "homing_angle_%i", i + 1);
		f_SPHAng[client][i] = CF_GetArgF(client, GENERIC, SENTRY_PROJECTILES, argName, 60.0);

		Format(argName, sizeof(argName), "blast_radius_%i", i + 1);
		f_SPRadius[client][i] = CF_GetArgF(client, GENERIC, SENTRY_PROJECTILES, argName, 0.0);

		Format(argName, sizeof(argName), "blast_falloff_start_%i", i + 1);
		f_SPFalloffStart[client][i] = CF_GetArgF(client, GENERIC, SENTRY_PROJECTILES, argName, 0.0);

		Format(argName, sizeof(argName), "blast_falloff_max_%i", i + 1);
		f_SPFalloffMax[client][i] = CF_GetArgF(client, GENERIC, SENTRY_PROJECTILES, argName, 0.0);
	}
}

public void CF_OnSentryFire(int sentry, int owner, int target, int level, float muzzlePos_1[3], float muzzleAng_1[3], float muzzlePos_2[3], float muzzleAng_2[3], bool &result)
{
	if (!IsValidClient(owner))
		return;

	if (!b_SentryProjectiles[owner])
		return;

	SentryProjectiles_Shoot(sentry, owner, target, level, muzzlePos_1, muzzleAng_1);
	if (level > 1)
		SentryProjectiles_Shoot(sentry, owner, target, level, muzzlePos_2, muzzleAng_2);

	result = false;
}

public void SentryProjectiles_Shoot(int sentry, int owner, int target, int level, float pos[3], float ang[3])
{
	TFTeam team = TF2_GetClientTeam(owner);

	int projectile;
	if (f_SPRadius[owner][level - 1] > 0.0)
		projectile = CF_FireGenericRocket(owner, 0.0, f_SPVel[owner][level - 1], _, false, GENERIC, SentryProjectiles_Impact_Explode);
	else
		projectile = CF_FireGenericRocket(owner, 0.0, f_SPVel[owner][level - 1], _, false, GENERIC, SentryProjectiles_Impact);

	if (IsValidEntity(projectile))
	{
		SetEntityModel(projectile, MODEL_SENTRY_PROJECTILE);
		AttachParticleToEntity(projectile, team == TFTeam_Red ? PARTICLE_SENTRY_PROJECTILE_RED : PARTICLE_SENTRY_PROJECTILE_BLUE, "", f_SPLifespan[owner][level - 1]);

		if (f_SPLifespan[owner][level - 1] > 0.0)
			CreateTimer(f_SPLifespan[owner][level - 1], Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);

		float vel[3];
		GetVelocityInDirection(ang, f_SPVel[owner][level - 1], vel);
		TeleportEntity(projectile, pos, ang, vel);

		i_SPLevel[projectile] = level - 1;
		i_SPSentry[projectile] = EntIndexToEntRef(sentry);

		if (f_SPHAmt[owner][level - 1] > 0.0)
		{
			CF_InitiateHomingProjectile(projectile, target, f_SPHAng[owner][level - 1], f_SPHAmt[owner][level - 1]);
		}
	}
}

int SPKillType = -1;
public MRESReturn SentryProjectiles_Impact(int projectile, int owner, int teamNum, int other, float pos[3])
{
	int sentry = EntRefToEntIndex(i_SPSentry[projectile]);
	
	EmitSoundToAll(g_SPImpactSounds[GetRandomInt(0, sizeof(g_SPImpactSounds) - 1)], projectile, _, _, _, _, GetRandomInt(90, 110));
	SpawnParticle(pos, PARTICLE_SENTRY_PROJECTILE_IMPACT, 0.2);

	if (CF_IsValidTarget(other, grabEnemyTeam(owner)))
	{
		SPKillType = i_SPLevel[projectile];
		SDKHooks_TakeDamage(other, IsValidEntity(sentry) ? sentry : projectile, owner, f_SPDMG[owner][i_SPLevel[projectile]], DMG_BULLET, _, _, pos);
		SPKillType = -1;
	}

	RemoveEntity(projectile);
	return MRES_Supercede;
}

public MRESReturn SentryProjectiles_Impact_Explode(int projectile, int owner, int teamNum, int other, float pos[3])
{
	int sentry = EntRefToEntIndex(i_SPSentry[projectile]);
	
	EmitSoundToAll(g_SPBlastSounds[GetRandomInt(0, sizeof(g_SPBlastSounds) - 1)], projectile, _, _, _, _, GetRandomInt(90, 110));
	SpawnParticle(pos, PARTICLE_SENTRY_PROJECTILE_EXPLODE, 0.2);

	SPKillType = i_SPLevel[projectile];
	CF_GenericAOEDamage(owner, IsValidEntity(sentry) ? sentry : projectile, 0, f_SPDMG[owner][i_SPLevel[projectile]], DMG_BLAST|DMG_PREVENT_PHYSICS_FORCE, f_SPRadius[owner][i_SPLevel[projectile]], pos, f_SPFalloffStart[owner][i_SPLevel[projectile]], f_SPFalloffMax[owner][i_SPLevel[projectile]]);
	SPKillType = -1;

	RemoveEntity(projectile);
	return MRES_Supercede;
}

public Action CF_OnPlayerKilled_Pre(int &victim, int &inflictor, int &attacker, char weapon[255], char console[255], int &custom, int deadRinger, int &critType, int &damagebits)
{
	if (SPKillType > -1)
	{
		switch(SPKillType)
		{
			case 0:
				strcopy(weapon, sizeof(weapon), "obj_sentrygun");
			case 1:
				strcopy(weapon, sizeof(weapon), "obj_sentrygun2");
			case 2:
				strcopy(weapon, sizeof(weapon), "obj_sentrygun3");
			default:
				strcopy(weapon, sizeof(weapon), "obj_minisentry");
		}

		return Plugin_Changed;
	}

	return Plugin_Continue;
}