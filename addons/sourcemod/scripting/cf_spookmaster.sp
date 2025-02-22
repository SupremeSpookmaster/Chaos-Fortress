#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define SPOOKMASTER		"cf_spookmaster"
#define HARVESTER		"soul_harvester"
#define ABSORB			"soul_absorption"
#define DISCARD			"soul_discard"
#define CALCIUM			"calcium_cataclysm"

#define PARTICLE_DISCARD_RED		"spell_fireball_small_red"
#define PARTICLE_DISCARD_BLUE		"spell_fireball_small_blue"
#define PARTICLE_DISCARD_EXPLODE_RED	"spell_fireball_tendril_parent_red"
#define PARTICLE_DISCARD_EXPLODE2_RED	"spell_batball_impact_red"
#define PARTICLE_DISCARD_EXPLODE_BLUE	"spell_fireball_tendril_parent_blue"
#define PARTICLE_DISCARD_EXPLODE2_BLUE	"spell_batball_impact_blue"
#define PARTICLE_CALCIUM_SPARKS_RED			"drg_cow_explosion_sparkles_charged"
#define PARTICLE_CALCIUM_SPARKS_BLUE		"drg_cow_explosion_sparkles_charged_blue"
#define PARTICLE_CALCIUM_CHAIN_RED		"dxhr_lightningball_hit_zap_red"
#define PARTICLE_CALCIUM_CHAIN_BLUE		"dxhr_lightningball_hit_zap_blue"
#define PARTICLE_ABSORB_1				"eye_powerup_green_lvl_1"
#define PARTICLE_ABSORB_2				"eye_powerup_green_lvl_2"
#define PARTICLE_ABSORB_3				"eye_powerup_green_lvl_3"
#define PARTICLE_ABSORB_4				"eye_powerup_green_lvl_4"

#define SOUND_DISCARD_EXPLODE		")misc/halloween/spell_fireball_impact.wav"

#define MODEL_DISCARD				"models/props_mvm/mvm_human_skull_collide.mdl"

int lgtModel;
int glowModel;

public void OnMapStart()
{
	PrecacheSound(SOUND_DISCARD_EXPLODE, true);
	
	PrecacheModel(MODEL_DISCARD, true);
	
	lgtModel = PrecacheModel("materials/sprites/lgtning.vmt");
	glowModel = PrecacheModel("materials/sprites/glow02.vmt");
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, SPOOKMASTER))
		return;
		
	if (StrEqual(abilityName, ABSORB))
		Absorb_Activate(client, abilityName);
		
	if (StrContains(abilityName, DISCARD) != -1)
		Discard_Activate(client, abilityName);
		
	if (StrContains(abilityName, CALCIUM) != -1)
		Calcium_Activate(client, abilityName);
}

int Harvester_LeftParticle[MAXPLAYERS + 1] = { -1, ... };
int Harvester_RightParticle[MAXPLAYERS + 1] = { -1, ... };

float Harvester_Min[MAXPLAYERS + 1] = { 0.0, ... };

float Discard_Bonus[MAXPLAYERS + 1] = { 0.0, ... };

public Action CF_OnSpecialResourceApplied(int client, float current, float &amt)
{
	if (!CF_HasAbility(client, SPOOKMASTER, HARVESTER))
		return Plugin_Continue;
		
	if (amt >= Harvester_Min[client])
	{
		int L = EntRefToEntIndex(Harvester_LeftParticle[client]);
		int R = EntRefToEntIndex(Harvester_RightParticle[client]);
			
		char LName[255], RName[255];
		if (TF2_GetClientTeam(client) == TFTeam_Red)
		{
			CF_GetArgS(client, SPOOKMASTER, HARVESTER, "left_red", LName, sizeof(LName));
			CF_GetArgS(client, SPOOKMASTER, HARVESTER, "right_red", RName, sizeof(RName));
		}
		else
		{
			CF_GetArgS(client, SPOOKMASTER, HARVESTER, "left_blue", LName, sizeof(LName));
			CF_GetArgS(client, SPOOKMASTER, HARVESTER, "right_blue", RName, sizeof(RName));
		}
		
		if (!IsValidEntity(L))
			Harvester_LeftParticle[client] = EntIndexToEntRef(CF_AttachParticle(client, LName, "effect_hand_L", true));
			
		if (!IsValidEntity(R))
			Harvester_RightParticle[client] = EntIndexToEntRef(CF_AttachParticle(client, RName, "effect_hand_R", true));
	}
	else
	{
		Harvester_DeleteParticles(client);
	}
	
	return Plugin_Continue;
}

public void Harvester_DeleteParticles(int client)
{
	int L = EntRefToEntIndex(Harvester_LeftParticle[client]);
	int R = EntRefToEntIndex(Harvester_RightParticle[client]);
	
	if (IsValidEntity(L))
		RemoveEntity(L);
		
	if (IsValidEntity(R))
		RemoveEntity(R);
		
	Harvester_LeftParticle[client] = -1;
	Harvester_RightParticle[client] = -1;
}

int Absorb_Uses[MAXPLAYERS + 1] = { 0, ... };
float Absorb_Health[MAXPLAYERS + 1] = { 0.0, ... };
float Absorb_Speed[MAXPLAYERS + 1] = { 0.0, ... };
float Absorb_Heal[MAXPLAYERS + 1] = { 0.0, ... };
float Absorb_Swing[MAXPLAYERS + 1] = { 0.0, ... };
float Absorb_Melee[MAXPLAYERS + 1] = { 0.0, ... };
int Absorb_Left[MAXPLAYERS + 1] = { -1, ... };
int Absorb_Right[MAXPLAYERS + 1] = { -1, ... };

public void Absorb_Activate(int client, char abilityName[255])
{
	Discard_Bonus[client] += CF_GetArgF(client, SPOOKMASTER, abilityName, "discard_bonus");
	
	float bonusHP = CF_GetArgF(client, SPOOKMASTER, abilityName, "health_bonus");
	float currentHP = GetAttributeValue(client, 26, 0.0);
	Absorb_Health[client] = bonusHP + currentHP;
	
	float bonusSpeed = CF_GetArgF(client, SPOOKMASTER, abilityName, "speed_bonus");
	float currentSpeed = GetAttributeValue(client, 107, 0.0);
	Absorb_Speed[client] = bonusSpeed + currentSpeed;
	
	Absorb_Heal[client] = CF_GetArgF(client, SPOOKMASTER, abilityName, "heal");
	
	int weapon = GetPlayerWeaponSlot(client, 2);
	if (!IsValidEntity(weapon))
		return;
		
	float bonusSwing = CF_GetArgF(client, SPOOKMASTER, abilityName, "swing_bonus");
	float currentSwing = GetAttributeValue(weapon, 396, 1.0);
	Absorb_Swing[client] = currentSwing - bonusSwing;
	
	float bonusDmg = CF_GetArgF(client, SPOOKMASTER, abilityName, "melee_bonus");
	float currentDmg = GetAttributeValue(weapon, 2, 1.0);
	Absorb_Melee[client] = bonusDmg + currentDmg;
	
	Absorb_SetStats(client);
	Absorb_Uses[client]++;
}

void Absorb_DestroyEyeParticles(int client)
{
	int left = EntRefToEntIndex(Absorb_Left[client]);
	int right = EntRefToEntIndex(Absorb_Right[client]);
	
	if (IsValidEntity(left))
		RemoveEntity(left);
	if (IsValidEntity(right))
		RemoveEntity(right);
		
	Absorb_Left[client] = -1;
	Absorb_Right[client] = -1;
}

void Absorb_SetStats(int client, float NumTimes = 0.0)
{
	TF2Attrib_SetByDefIndex(client, 26, Absorb_Health[client]);
	TF2Attrib_SetByDefIndex(client, 107, Absorb_Speed[client]);
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
	
	DataPack pack = new DataPack();
	RequestFrame(Absorb_HealOnDelay, pack);
	WritePackCell(pack, GetClientUserId(client));
	WritePackFloat(pack, NumTimes > 0.0 ? Absorb_Heal[client] * NumTimes : Absorb_Heal[client])
	
	int weapon = GetPlayerWeaponSlot(client, 2);
	if (!IsValidEntity(weapon))
		return;
		
	TF2Attrib_SetByDefIndex(weapon, 396, Absorb_Swing[client]);
	TF2Attrib_SetByDefIndex(weapon, 2, Absorb_Melee[client]);
	CF_SetCharacterScale(client, NumTimes > 0.0 ? 1.0 + (0.03 * NumTimes) : CF_GetCharacterScale(client) + 0.03, CF_StuckMethod_DelayResize);
	
	Absorb_DestroyEyeParticles(client);
	
	RequestFrame(Absorb_AttachEyeParticles, GetClientUserId(client));
}

public void Absorb_AttachEyeParticles(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return;
		
	char particle[255];
	switch(Absorb_Uses[client])
	{
		case 0:
		{
			particle = PARTICLE_ABSORB_1;
		}
		case 1:
		{
			particle = PARTICLE_ABSORB_2;
		}
		case 2:
		{
			particle = PARTICLE_ABSORB_3;
		}
		default:
		{
			particle = PARTICLE_ABSORB_4;
		}
	}
	
	Absorb_Left[client] = EntIndexToEntRef(CF_AttachParticle(client, particle, "lefteye", true));
	Absorb_Right[client] = EntIndexToEntRef(CF_AttachParticle(client, particle, "righteye", true));	
}

public void Absorb_HealOnDelay(DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	float amt = ReadPackFloat(pack);
	delete pack;
	
	CF_HealPlayer(client, client, RoundFloat(amt), 1.0);
}

bool Discard_VMAnim[MAXPLAYERS + 1] = { false, ... };
bool Discard_isSkull[2049] = { false, ... };

int Discard_Particle[2049] = { -1, ... };

float Discard_BaseDMG[2049] = { 0.0, ... };
float Discard_Radius[2049] = { 0.0, ... };
float Discard_FalloffStart[2049] = { 0.0, ... };
float Discard_FalloffMax[2049] = { 0.0, ... };
float Discard_DecayStart[2049] = { 0.0, ... };
float Discard_DecayAmt[2049] = { 0.0, ... };
float Discard_DecayMax[2049] = { 0.0, ... };
float Discard_BurnTime[2049] = { 0.0, ... };

public void Discard_Activate(int client, char abilityName[255])
{
	float velocity = CF_GetArgF(client, SPOOKMASTER, abilityName, "velocity");
	
	int skull = CF_FireGenericRocket(client, 0.0, velocity, false, false, SPOOKMASTER, Discard_ExplodePre);
	if (IsValidEntity(skull))
	{
		Discard_BaseDMG[skull] = CF_GetArgF(client, SPOOKMASTER, abilityName, "damage");
		Discard_BaseDMG[skull] += Discard_Bonus[client];
		Discard_Radius[skull] = CF_GetArgF(client, SPOOKMASTER, abilityName, "radius");
		Discard_FalloffStart[skull] = CF_GetArgF(client, SPOOKMASTER, abilityName, "falloff_start");
		Discard_FalloffMax[skull] = CF_GetArgF(client, SPOOKMASTER, abilityName, "falloff_max");
		
		float time = CF_GetArgF(client, SPOOKMASTER, abilityName, "decay_start");
		if (time > 0.0)
		{
			CreateTimer(time, Discard_StartDecay, EntIndexToEntRef(skull), TIMER_FLAG_NO_MAPCHANGE);
			Discard_DecayStart[skull] = 0.0;
		}
		else
		{
			Discard_DecayStart[skull] = GetGameTime();
		}
			
		Discard_DecayAmt[skull] = CF_GetArgF(client, SPOOKMASTER, abilityName, "decay");
		Discard_DecayMax[skull] = CF_GetArgF(client, SPOOKMASTER, abilityName, "decay_max");
		Discard_BurnTime[skull] = CF_GetArgF(client, SPOOKMASTER, abilityName, "afterburn");
		Discard_isSkull[skull] = true;
		
		SetEntityModel(skull, MODEL_DISCARD);
		DispatchKeyValue(skull, "modelscale", "1.45");
		Discard_Particle[skull] = EntIndexToEntRef(AttachParticleToEntity(skull, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_DISCARD_RED : PARTICLE_DISCARD_BLUE, "", _, _, _, 5.0));
		SetEntityRenderColor(skull, TF2_GetClientTeam(client) == TFTeam_Red ? 255 : 0, 120, TF2_GetClientTeam(client) == TFTeam_Blue ? 255 : 0, 255);
		SetEntityRenderFx(skull, RENDERFX_GLOWSHELL);
		
		char snd[255], conf[255];
		CF_GetPlayerConfig(client, conf, sizeof(conf));
		if (CF_GetRandomSound(conf, "sound_discard_skull", snd, sizeof(snd)) != KeyValType_Null)
		{
			EmitSoundToAll(snd, skull, _, 110);
		}
		
		CF_SimulateSpellbookCast(client, _, CF_Spell_MeteorShower);
		CF_ForceViewmodelAnimation(client, "spell_fire");
		Discard_VMAnim[client] = true;
	}
}

public void OnEntityDestroyed(int entity)
{
	if (entity > 0 && entity < 2049)
		Discard_isSkull[entity] = false;
}

public void CF_OnForcedVMAnimEnd(int client, char sequence[255])
{
	if (!Discard_VMAnim[client])
		return;
		
	CF_ForceViewmodelAnimation(client, "m_draw", false, false, false);
			
	Discard_VMAnim[client] = false;
}

public void CF_OnGenericProjectileTeamChanged(int entity, TFTeam newTeam)
{
	int oldParticle = EntRefToEntIndex(Discard_Particle[entity]);
	if (IsValidEntity(oldParticle))
		RemoveEntity(oldParticle);
		
	Discard_Particle[entity] = EntIndexToEntRef(AttachParticleToEntity(entity, newTeam == TFTeam_Red ? PARTICLE_DISCARD_RED : PARTICLE_DISCARD_BLUE, "bloodpoint"));
	SetEntData(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_nSkin"), view_as<int>(newTeam) - 2, 1, true);
	SetEntityRenderColor(entity, newTeam == TFTeam_Red ? 255 : 0, 120, newTeam == TFTeam_Blue ? 255 : 0, 255);
}

public Action Discard_StartDecay(Handle decay, int ref)
{
	int skull = EntRefToEntIndex(ref);
	if (!IsValidEntity(skull))
		return Plugin_Continue;
		
	Discard_DecayStart[skull] = GetGameTime();
	return Plugin_Continue;
}

public MRESReturn Discard_ExplodePre(int skull, int owner, int teamNum)
{
	TFTeam team = view_as<TFTeam>(teamNum);
	
	float dmg = Discard_BaseDMG[skull];
	if (Discard_DecayStart[skull] > 0.0)
	{
		float TotalDecay = (GetGameTime() - Discard_DecayStart[skull]) * Discard_DecayAmt[skull];
		if (TotalDecay > Discard_DecayMax[skull])
			TotalDecay = Discard_DecayMax[skull];
			
		dmg -= TotalDecay;
	}
	float pos[3];
	GetEntPropVector(skull, Prop_Send, "m_vecOrigin", pos);
	
	Handle victims = CF_GenericAOEDamage(owner, skull, -1, dmg, DMG_CLUB|DMG_BLAST|DMG_ALWAYSGIB, Discard_Radius[skull], pos, Discard_FalloffStart[skull],
										Discard_FalloffMax[skull]);
				
	for (int i = 0; i < GetArraySize(victims); i++)
	{
		int vic = GetArrayCell(victims, i);
		if (IsValidMulti(vic) && vic != owner)
			TF2_IgnitePlayer(vic, IsValidClient(owner) ? owner : 0, Discard_BurnTime[skull]);
	}
	
	delete victims;
	
	EmitSoundToAll(SOUND_DISCARD_EXPLODE, skull, SNDCHAN_STATIC, _, _, _, GetRandomInt(90, 110));
	SpawnParticle(pos, team == TFTeam_Red ? PARTICLE_DISCARD_EXPLODE_RED : PARTICLE_DISCARD_EXPLODE_BLUE, 3.0);
	SpawnParticle(pos, team == TFTeam_Red ? PARTICLE_DISCARD_EXPLODE2_RED : PARTICLE_DISCARD_EXPLODE2_BLUE, 3.0);
	
	RemoveEntity(skull);
	
	return MRES_Supercede;
}

float Calcium_Damage[MAXPLAYERS + 1] = { 0.0, ... };
float Calcium_Radius[MAXPLAYERS + 1] = { 0.0, ... };
float Calcium_ChainRadius[MAXPLAYERS + 1] = { 0.0, ... };
float Calcium_Ignite[MAXPLAYERS + 1] = { 0.0, ... };
float Calcium_EndTime[MAXPLAYERS + 1] = { 0.0, ... };
float Calcium_SkeleDamage[MAXPLAYERS + 1] = { 0.0, ... };

int Calcium_SkeleHealth[MAXPLAYERS + 1] = { 0, ... };

bool Calcium_HitByPlayer[MAXPLAYERS + 1][MAXPLAYERS + 1];
bool Calcium_SpawnMinions[MAXPLAYERS + 1] = { false, ... };

public void Calcium_Activate(int client, char abilityName[255])
{
	Calcium_EndTime[client] = GetGameTime() + CF_GetArgF(client, SPOOKMASTER, abilityName, "duration");
	Calcium_Damage[client] = CF_GetArgF(client, SPOOKMASTER, abilityName, "damage");
	Calcium_Radius[client] = CF_GetArgF(client, SPOOKMASTER, abilityName, "radius");
	Calcium_ChainRadius[client] = CF_GetArgF(client, SPOOKMASTER, abilityName, "chain_radius");
	Calcium_Ignite[client] = CF_GetArgF(client, SPOOKMASTER, abilityName, "ignite");
	Calcium_SkeleHealth[client] = CF_GetArgI(client, SPOOKMASTER, abilityName, "skele_health");
	Calcium_SkeleDamage[client] = CF_GetArgF(client, SPOOKMASTER, abilityName, "skele_damage");
	Calcium_SpawnMinions[client] = CF_GetArgI(client, SPOOKMASTER, abilityName, "skele_spawn") > 0;
	
	Calcium_ClearHitStatus(client);
}

public Action CF_OnTakeDamageAlive_Pre(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	if (!IsValidClient(attacker) || !IsValidClient(victim))
		return Plugin_Continue;
		
	Action ReturnValue = Plugin_Continue;
		
	if (GetGameTime() <= Calcium_EndTime[attacker] && weapon == GetPlayerWeaponSlot(attacker, 2))
	{
		Calcium_ShockPlayer(attacker, victim, Calcium_Radius[attacker], attacker);
		Calcium_ClearHitStatus(attacker);
	}
	
	if (IsValidEntity(inflictor) && Calcium_SkeleDamage[attacker] > 0.0)
	{
		char classname[255];
		GetEntityClassname(inflictor, classname, sizeof(classname));
		
		if (StrContains(classname, "spellbook_skeleton") != -1 || StrContains(classname, "tf_zombie") != -1)
		{
			damage = Calcium_SkeleDamage[attacker];
			ReturnValue = Plugin_Changed;
		}
	}
	
	return ReturnValue;
}

public void Calcium_ShockPlayer(int attacker, int victim, float radius, int previousVictim)
{
	TFTeam team = TF2_GetClientTeam(attacker);
	
	float pos[3];
	GetClientAbsOrigin(victim, pos);
	pos[2] += 40.0;
	
	if (IsValidClient(previousVictim))
	{
		float prevPos[3];
		GetClientAbsOrigin(previousVictim, prevPos);
		prevPos[2] += 40.0;
		
		SpawnBeam_Vectors(prevPos, pos, 0.5, team == TFTeam_Red ? 255 : 0, 120, team == TFTeam_Red ? 0 : 255, 255, lgtModel, 4.0, 4.1, 1, 4.0);
		SpawnBeam_Vectors(prevPos, pos, 0.5, team == TFTeam_Red ? 60 : 0, 255, team == TFTeam_Red ? 0 : 60, 150, lgtModel, 2.0, 2.1, 1, 2.0);
		SpawnBeam_Vectors(prevPos, pos, 0.5, team == TFTeam_Red ? 255 : 0, 120, team == TFTeam_Red ? 0 : 255, 255, lgtModel, 4.0, 4.1, 1, 12.0);
		SpawnBeam_Vectors(prevPos, pos, 0.5, team == TFTeam_Red ? 60 : 0, 255, team == TFTeam_Red ? 0 : 60, 150, lgtModel, 2.0, 2.1, 1, 8.0);
		SpawnBeam_Vectors(prevPos, pos, 0.5, team == TFTeam_Red ? 255 : 0, 120, team == TFTeam_Red ? 0 : 255, 255, glowModel, 4.0, 4.1, 1, 4.0);
		SpawnBeam_Vectors(prevPos, pos, 0.5, team == TFTeam_Red ? 255 : 0, 120, team == TFTeam_Red ? 0 : 255, 255, glowModel, 4.0, 4.1, 1, 12.0);
	}
	
	SDKHooks_TakeDamage(victim, attacker, attacker, Calcium_Damage[attacker], DMG_CLUB | DMG_BLAST | DMG_ALWAYSGIB);
	TF2_IgnitePlayer(victim, attacker, Calcium_Ignite[attacker]);
	SpawnParticle(pos, team == TFTeam_Red ? PARTICLE_CALCIUM_SPARKS_RED : PARTICLE_CALCIUM_SPARKS_BLUE, 3.0);
	Calcium_HitByPlayer[attacker][victim] = true;
	
	Handle victims = CF_GenericAOEDamage(attacker, attacker, attacker, 0.0, DMG_GENERIC, radius, pos, 0.0, 0.0, false, false, true);
	
	for (int i = 0; i < GetArraySize(victims); i++)
	{
		int vic = GetArrayCell(victims, i);
		if (IsValidClient(vic))
		{
			if (!Calcium_HitByPlayer[attacker][vic])
				Calcium_ShockPlayer(attacker, vic, Calcium_ChainRadius[attacker], victim);
		}
	}
	
	delete victims;
}

public void Calcium_ClearHitStatus(int client)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		Calcium_HitByPlayer[client][i] = false;
	}
}

public void CF_OnPlayerKilled(int victim, int inflictor, int attacker, int deadRinger)
{
	if (GetGameTime() <= Calcium_EndTime[attacker] && Calcium_SpawnMinions[attacker])
	{
		float pos[3];
		GetClientAbsOrigin(victim, pos);
		
		int skeleton = CreateEntityByName("tf_zombie");
		if (IsValidEntity(skeleton))
		{
			int iTeam = GetClientTeam(attacker);
			
			SetEntPropEnt(skeleton, Prop_Send, "m_hOwnerEntity", attacker);
			SetEntProp(skeleton,    Prop_Send, "m_iTeamNum", iTeam, 1);
			SetEntProp(skeleton, Prop_Send, "m_nSkin", iTeam - 2);
			
			SetVariantInt(iTeam);
			AcceptEntityInput(skeleton, "TeamNum", -1, -1, 0);
			
			SetVariantInt(iTeam);
			AcceptEntityInput(skeleton, "SetTeam", -1, -1, 0); 
			
			SetVariantInt(Calcium_SkeleHealth[attacker]);
			AcceptEntityInput(skeleton, "SetHealth");
			
			DispatchSpawn(skeleton);
			TeleportEntity(skeleton, pos);
		}
	}
}

public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
	Discard_Bonus[client] = 0.0;
	Absorb_Uses[client] = 0;
	Calcium_EndTime[client] = 0.0;
	Absorb_DestroyEyeParticles(client);
	Discard_VMAnim[client] = false;
}

public void CF_OnCharacterCreated(int client)
{
	if (CF_HasAbility(client, SPOOKMASTER, ABSORB) && Absorb_Uses[client] > 0)
		Absorb_SetStats(client, float(Absorb_Uses[client]));
	if (CF_HasAbility(client, SPOOKMASTER, HARVESTER))
		Harvester_Min[client] = CF_GetArgF(client, SPOOKMASTER, HARVESTER, "min_resources", 0.0);
}

public void OnMapEnd()
{
	for (int i = 0; i <= MaxClients; i++)
		Calcium_EndTime[i] = 0.0;
}

public Action CF_OnPlayerKilled_Pre(int &victim, int &inflictor, int &attacker, char weapon[255], char console[255], int &custom, int deadRinger, int &critType, int &damagebits)
{
	if (IsValidEntity(inflictor) && Discard_isSkull[inflictor])
	{
		strcopy(console, sizeof(console), "Skull Servant");
		strcopy(weapon, sizeof(weapon), "spellbook_fireball");

		return Plugin_Changed;
	}
	else if (IsValidClient(attacker) && GetGameTime() <= Calcium_EndTime[attacker])
	{
		critType = 2;
		strcopy(console, sizeof(console), "CALCIUM CATACLYSM");

		if (StrContains(weapon, "tf_weapon_") != -1)
			strcopy(weapon, sizeof(weapon), "purgatory");
		else
			strcopy(weapon, sizeof(weapon), "spellbook_lightning");

		return Plugin_Changed;
	}

	return Plugin_Continue;
}