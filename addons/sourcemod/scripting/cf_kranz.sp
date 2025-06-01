#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define KRANZ				"cf_kranz"
#define PRIMARY_FIRE		"kranz_primary_fire"
#define SOLVER				"kranz_problem_solver"
#define OBLITERATOR			"kranz_obliterator"
#define VFX					"kranz_ult_vfx"
#define RUSH				"kranz_bayonet"

#define PARTICLE_SOLVER_MUZZLE				"ExplosionCore_MidAir"
#define PARTICLE_OBLITERATOR_TRACER_RED		"sniper_dxhr_rail_red"
#define PARTICLE_OBLITERATOR_TRACER_BLUE	"sniper_dxhr_rail_blue"
#define PARTICLE_OBLITERATOR_EXPLODE_RED	"powerup_supernova_explode_red"
#define PARTICLE_OBLITERATOR_EXPLODE_BLUE	"powerup_supernova_explode_blue"
#define PARTICLE_OBLITERATOR_MUZZLE_RED		"drg_cow_explosioncore_normal"
#define PARTICLE_OBLITERATOR_MUZZLE_BLUE	"drg_cow_explosioncore_normal_blue"
#define PARTICLE_RUSH_COLLIDE				"target_break_initial_dust"

#define SND_OBLITERATOR_EXPLODE				")weapons/cow_mangler_explode.wav"
#define SND_OBLITERATOR_LOOP				"weapons/rocket_pack_boosters_loop.wav"
#define SND_OBLITERATOR_EXPIRED				"weapons/rocket_pack_boosters_shutdown.wav"
#define SND_RUSH_COLLIDE					")weapons/bumper_car_hit_ball.wav"
#define SND_RUSH_END						"weapons/discipline_device_power_down.wav"

public void OnMapStart()
{
	PrecacheSound(SND_OBLITERATOR_EXPLODE);
	PrecacheSound(SND_OBLITERATOR_LOOP);
	PrecacheSound(SND_OBLITERATOR_EXPIRED);
	PrecacheSound(SND_RUSH_COLLIDE);
	PrecacheSound(SND_RUSH_END);
}

public void OnPluginStart()
{
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, KRANZ))
		return;
	
	if (StrContains(abilityName, PRIMARY_FIRE) != -1)
	{
		PrimaryFire_Activate(client, abilityName);
	}

	if (StrContains(abilityName, SOLVER) != -1)
	{
		Solver_Activate(client, abilityName);
	}

	if (StrContains(abilityName, OBLITERATOR) != -1)
	{
		Obliterator_Activate(client, abilityName);
	}

	if (StrContains(abilityName, VFX) != -1)
	{
		VFX_Activate(client, abilityName);
	}

	if (StrContains(abilityName, RUSH) != -1)
	{
		Rush_Activate(client, abilityName);
	}
}

bool PrimaryFire_HSFalloff = false;
int PrimaryFire_HSEffect = 1;

public void PrimaryFire_Activate(int client, char abilityName[255])
{
	float damage = CF_GetArgF(client, KRANZ, abilityName, "damage");
	float hsMult = CF_GetArgF(client, KRANZ, abilityName, "hs_mult");
	PrimaryFire_HSEffect = CF_GetArgI(client, KRANZ, abilityName, "hs_fx");
	PrimaryFire_HSFalloff = CF_GetArgI(client, KRANZ, abilityName, "hs_falloff") > 0;
	float falloffStart = CF_GetArgF(client, KRANZ, abilityName, "falloff_start");
	float falloffEnd = CF_GetArgF(client, KRANZ, abilityName, "falloff_end");
	float falloffMax = CF_GetArgF(client, KRANZ, abilityName, "falloff_max");
	int pierce = CF_GetArgI(client, KRANZ, abilityName, "pierce");
	float spread = CF_GetArgF(client, KRANZ, abilityName, "spread");
	float width = CF_GetArgF(client, KRANZ, abilityName, "width", 5.0);

	float ang[3];
	GetClientEyeAngles(client, ang);
	CF_FireGenericBullet(client, ang, damage, hsMult, spread, KRANZ, PrimaryFire_Hit, falloffStart, falloffEnd, falloffMax, pierce, grabEnemyTeam(client), _, _, _, width);
}

public void PrimaryFire_Hit(int attacker, int victim, float &baseDamage, bool &allowFalloff, bool &isHeadshot, int &hsEffect, bool &crit, float hitPos[3])
{
	if (isHeadshot)
	{
		allowFalloff = PrimaryFire_HSFalloff;
	}

	hsEffect = PrimaryFire_HSEffect;
}

float Solver_TotalKB[MAXPLAYERS + 1] = { 0.0, ... };
float Solver_KB = 0.0;
float Solver_KBAng[3];

public void Solver_Activate(int client, char abilityName[255])
{
	float damage = CF_GetArgF(client, KRANZ, abilityName, "damage");
	int numBullets = CF_GetArgI(client, KRANZ, abilityName, "bullets");
	float hsMult = CF_GetArgF(client, KRANZ, abilityName, "hs_mult");
	PrimaryFire_HSEffect = CF_GetArgI(client, KRANZ, abilityName, "hs_fx");
	PrimaryFire_HSFalloff = CF_GetArgI(client, KRANZ, abilityName, "hs_falloff") > 0;
	float falloffStart = CF_GetArgF(client, KRANZ, abilityName, "falloff_start");
	float falloffEnd = CF_GetArgF(client, KRANZ, abilityName, "falloff_end");
	float falloffMax = CF_GetArgF(client, KRANZ, abilityName, "falloff_max");
	int pierce = CF_GetArgI(client, KRANZ, abilityName, "pierce");
	float spread = CF_GetArgF(client, KRANZ, abilityName, "spread");
	Solver_KB = CF_GetArgF(client, KRANZ, abilityName, "target_kb");
	float selfKB = CF_GetArgF(client, KRANZ, abilityName, "self_kb");
	float width = CF_GetArgF(client, KRANZ, abilityName, "width", 5.0);

	DoMuzzleParticle(client, PARTICLE_SOLVER_MUZZLE);

	float ang[3];
	GetClientEyeAngles(client, ang);

	for (int i = 0; i < numBullets; i++)
		CF_FireGenericBullet(client, ang, damage, hsMult, spread, KRANZ, Solver_Hit, falloffStart, falloffEnd, falloffMax, pierce, grabEnemyTeam(client), _, _, _, width);

	Solver_KBAng = ang;
	if (Solver_KBAng[0] > -15.0)
		Solver_KBAng[0] = -15.0;

	RequestFrame(Solver_DoKnockback);

	float vel[3];
	ang[0] += 180.0;
	GetAngleVectors(ang, vel, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(vel, selfKB);
	if (GetEntityFlags(client) & FL_ONGROUND != 0)
		vel[2] += 300.0;
		
	TeleportEntity(client, _, _, vel);
}

public void Solver_DoKnockback()
{
	for (int i = 0; i <= MaxClients; i++)
	{
		if (IsValidMulti(i))
		{
			CF_ApplyKnockback(i, Solver_TotalKB[i], Solver_KBAng, _, _, true);
		}

		Solver_TotalKB[i] = 0.0;
	}
}

public void Solver_Hit(int attacker, int victim, float &baseDamage, bool &allowFalloff, bool &isHeadshot, int &hsEffect, bool &crit, float hitPos[3])
{
	if (isHeadshot)
	{
		allowFalloff = PrimaryFire_HSFalloff;
	}

	hsEffect = PrimaryFire_HSEffect;

	if (IsValidClient(victim))
		Solver_TotalKB[victim] += Solver_KB;
}

float Obliterator_Radius, Obliterator_FalloffStart, Obliterator_FalloffMax, Obliterator_Damage;
bool Obliterator_AllowBodyShot;
TFTeam Obliterator_Team;

public void Obliterator_Activate(int client, char abilityName[255])
{
	float damage = CF_GetArgF(client, KRANZ, abilityName, "damage");
	float hsMult = CF_GetArgF(client, KRANZ, abilityName, "hs_mult");
	PrimaryFire_HSEffect = CF_GetArgI(client, KRANZ, abilityName, "hs_fx");
	PrimaryFire_HSFalloff = CF_GetArgI(client, KRANZ, abilityName, "hs_falloff") > 0;
	float falloffStart = CF_GetArgF(client, KRANZ, abilityName, "falloff_start");
	float falloffEnd = CF_GetArgF(client, KRANZ, abilityName, "falloff_end");
	float falloffMax = CF_GetArgF(client, KRANZ, abilityName, "falloff_max");
	int pierce = CF_GetArgI(client, KRANZ, abilityName, "pierce");
	float spread = CF_GetArgF(client, KRANZ, abilityName, "spread");
	float width = CF_GetArgF(client, KRANZ, abilityName, "width", 5.0);
	Obliterator_Radius = CF_GetArgF(client, KRANZ, abilityName, "blast_radius");
	Obliterator_FalloffStart = CF_GetArgF(client, KRANZ, abilityName, "blast_falloff_start");
	Obliterator_FalloffMax = CF_GetArgF(client, KRANZ, abilityName, "blast_falloff_max");
	Obliterator_Damage = CF_GetArgF(client, KRANZ, abilityName, "blast_damage");
	Obliterator_AllowBodyShot = CF_GetArgI(client, KRANZ, abilityName, "blast_bodyshots", 1) > 0;

	Obliterator_Team = TF2_GetClientTeam(client);
	DoMuzzleParticle(client, (Obliterator_Team == TFTeam_Red ? PARTICLE_OBLITERATOR_MUZZLE_RED : PARTICLE_OBLITERATOR_MUZZLE_BLUE));

	float ang[3];
	GetClientEyeAngles(client, ang);
	CF_FireGenericBullet(client, ang, damage, hsMult, spread, KRANZ, Obliterator_Hit, falloffStart, falloffEnd, falloffMax, pierce, grabEnemyTeam(client), _, _, (Obliterator_Team == TFTeam_Red ? PARTICLE_OBLITERATOR_TRACER_RED : PARTICLE_OBLITERATOR_TRACER_BLUE), width);
	CF_PlayRandomSound(client, client, "sound_obliterator_fired");
}

public void Obliterator_Hit(int attacker, int victim, float &baseDamage, bool &allowFalloff, bool &isHeadshot, int &hsEffect, bool &crit, float hitPos[3])
{
	if (isHeadshot)
	{
		allowFalloff = PrimaryFire_HSFalloff;
	}

	hsEffect = PrimaryFire_HSEffect;

	if (isHeadshot || Obliterator_AllowBodyShot)
	{
		EmitSoundToAll(SND_OBLITERATOR_EXPLODE, victim);
		SpawnParticle(hitPos, (Obliterator_Team == TFTeam_Red ? PARTICLE_OBLITERATOR_EXPLODE_RED : PARTICLE_OBLITERATOR_EXPLODE_BLUE), 2.0);

		int weapon = TF2_GetActiveWeapon(attacker);
		CF_GenericAOEDamage(attacker, attacker, (IsValidEntity(weapon) ? weapon : attacker), Obliterator_Damage, DMG_BLAST|DMG_ALWAYSGIB, Obliterator_Radius, hitPos, Obliterator_FalloffStart, Obliterator_FalloffMax, _, false);
	}
}

public bool PrimaryFire_Trace(entity, contentsMask, user)
{
	if (!Brush_Is_Solid(entity))
		return false;

	int team = GetEntProp(entity, Prop_Send, "m_iTeamNum");
	return team == view_as<int>(grabEnemyTeam(user));
}

float f_VFXEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltEndTime[MAXPLAYERS + 1] = { 0.0, ... };

public void VFX_Activate(int client, char abilityName[255])
{
	float duration = CF_GetArgF(client, KRANZ, abilityName, "duration");
	if (duration > 0.0)
	{
		TF2_AddCondition(client, TFCond_FocusBuff, duration);
		f_VFXEndTime[client] = GetGameTime() + duration + 0.2;
		EmitSoundToClient(client, SND_OBLITERATOR_LOOP);
	}
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[]weaponname, bool &result)
{
	if (f_VFXEndTime[client] >= GetGameTime())
	{
		f_VFXEndTime[client] = 0.0;
		TF2_RemoveCondition(client, TFCond_FocusBuff);
		EmitSoundToClient(client, SND_OBLITERATOR_EXPIRED);
		StopSound(client, SNDCHAN_AUTO, SND_OBLITERATOR_LOOP);
		f_UltEndTime[client] = GetGameTime() + 1.0;
	}

	return Plugin_Continue;
}

public void CF_OnCharacterCreated(int client)
{
	if (f_VFXEndTime[client] >= GetGameTime())
	{
		f_VFXEndTime[client] = 0.0;
		TF2_RemoveCondition(client, TFCond_FocusBuff);
		EmitSoundToClient(client, SND_OBLITERATOR_EXPIRED);
		StopSound(client, SNDCHAN_AUTO, SND_OBLITERATOR_LOOP);
	}

	Rush_DeleteTimer(client);
	f_UltEndTime[client] = 0.0;
}

public void CF_OnCharacterRemoved(int client)
{
	if (f_VFXEndTime[client] >= GetGameTime())
	{
		f_VFXEndTime[client] = 0.0;
		TF2_RemoveCondition(client, TFCond_FocusBuff);
		EmitSoundToClient(client, SND_OBLITERATOR_EXPIRED);
		StopSound(client, SNDCHAN_AUTO, SND_OBLITERATOR_LOOP);
	}

	Rush_DeleteTimer(client);
	f_UltEndTime[client] = 0.0;
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
	if (condition == TFCond_FocusBuff && CF_HasAbility(client, KRANZ, VFX))
	{
		if (f_VFXEndTime[client] >= GetGameTime())
		{
			EmitSoundToClient(client, SND_OBLITERATOR_EXPIRED);
			StopSound(client, SNDCHAN_AUTO, SND_OBLITERATOR_LOOP);
			CF_PlayRandomSound(client, client, "sound_obliterator_expired");
			f_UltEndTime[client] = GetGameTime() + 1.0;
		}
	}
}

float Rush_Speed[MAXPLAYERS + 1] = { 0.0, ... };
float Rush_DMG[MAXPLAYERS + 1] = { 0.0, ... };
float Rush_DMGMax[MAXPLAYERS + 1] = { 0.0, ... };
float Rush_Requirement[MAXPLAYERS + 1] = { 0.0, ... };
float Rush_KB[MAXPLAYERS + 1] = { 0.0, ... };
float Rush_MinSpeed[MAXPLAYERS + 1] = { 0.0, ... };
float Rush_HitboxScale[MAXPLAYERS + 1] = { 0.0, ... };
bool Rush_Active[MAXPLAYERS + 1] = { false, ... };

CF_SpeedModifier Rush_SpeedModifier[MAXPLAYERS + 1];

Handle Rush_Timer[MAXPLAYERS + 1] = { null, ... };

public void Rush_Activate(int client, char abilityName[255])
{
	float duration = CF_GetArgF(client, KRANZ, abilityName, "duration");
	if (duration > 0.0)
	{
		Rush_Speed[client] = CF_GetArgF(client, KRANZ, abilityName, "speed");
		Rush_DMG[client] = CF_GetArgF(client, KRANZ, abilityName, "damage_base");
		Rush_DMGMax[client] = CF_GetArgF(client, KRANZ, abilityName, "damage_max");
		Rush_Requirement[client] = CF_GetArgF(client, KRANZ, abilityName, "damage_speed");
		Rush_KB[client] = CF_GetArgF(client, KRANZ, abilityName, "knockback");
		Rush_MinSpeed[client] = CF_GetArgF(client, KRANZ, abilityName, "damage_min");
		Rush_HitboxScale[client] = CF_GetArgF(client, KRANZ, abilityName, "hitbox_scale", 3.0);

		Rush_SpeedModifier[client] = CF_ApplyTemporarySpeedChange(client, 0, Rush_Speed[client], 0.0, 0, 9999.0);
		
		Rush_Active[client] = true;
		RequestFrame(Rush_CheckBump, GetClientUserId(client));

		DataPack pack = new DataPack();
		Rush_Timer[client] = CreateDataTimer(duration, Rush_End, pack);
		WritePackCell(pack, GetClientUserId(client));
		WritePackCell(pack, client);
	}
}

bool b_RushIn;

public void Rush_CheckBump(int id)
{
	int client = GetClientOfUserId(id);

	if (!IsValidMulti(client))
		return;

	if (!Rush_Active[client])
		return;

	float vel[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vel);
	float current = GetVectorLength(vel);
	if (current >= Rush_MinSpeed[client])
	{
		float pos[3];
		CF_WorldSpaceCenter(client, pos);

		float dist;
		int other = CF_GetClosestTarget(pos, true, dist, Rush_HitboxScale[client], grabEnemyTeam(client));

		if (other > 0 && other < 2049 && dist <= Rush_HitboxScale[client])
		{
			float vicPos[3];
			CF_WorldSpaceCenter(other, vicPos);

			if (CF_HasLineOfSight(pos, vicPos))
			{
				pos = vicPos;
				SpawnShaker(pos, 14, 100, 2, 4, 4);
				SpawnParticle(pos, PARTICLE_RUSH_COLLIDE, 2.0);
				EmitSoundToAll(SND_RUSH_COLLIDE, client, _, _, _, _, GetRandomInt(80, 110));

				if (IsValidMulti(other))
				{
					float ang[3];
					GetClientAbsAngles(client, ang);
					CF_ApplyKnockback(other, Rush_KB[client], ang);
				}

				float damage = Rush_DMG[client];
				if (current >= Rush_Requirement[client])
					damage += Rush_DMGMax[client];
				else if (current > Rush_MinSpeed[client])
					damage += ((current - Rush_MinSpeed[client]) / (Rush_Requirement[client] - Rush_MinSpeed[client])) * Rush_DMGMax[client];

				b_RushIn = true;
				SDKHooks_TakeDamage(other, client, client, damage, DMG_CLUB);
				b_RushIn = false;
				
				if (Rush_SpeedModifier[client].b_Exists)
				{
					Rush_SpeedModifier[client].Destroy();
				}

				EmitSoundToClient(client, SND_RUSH_END);
				Rush_DeleteTimer(client);
				return;
			}
		}
	}

	RequestFrame(Rush_CheckBump, id);
}

public Action Rush_End(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int slot = ReadPackCell(pack);

	Rush_Timer[slot] = null;

	if (IsValidMulti(client))
	{
		if (Rush_SpeedModifier[client].b_Exists)
		{
			Rush_SpeedModifier[client].Destroy();
		}

		EmitSoundToClient(client, SND_RUSH_END);
		Rush_Active[client] = false;
	}

	return Plugin_Continue;
}

public void Rush_DeleteTimer(int client)
{
	if (Rush_Timer[client] != null)
	{
		delete Rush_Timer[client];
		Rush_Timer[client] = null;

		Rush_Active[client] = false;
	}
}

public Action CF_OnAbilityCheckCanUse(int client, char plugin[255], char ability[255], CF_AbilityType type, bool &result)
{
	if ((f_VFXEndTime[client] >= GetGameTime() && TF2_IsPlayerInCondition(client, TFCond_FocusBuff)) || f_UltEndTime[client] >= GetGameTime())
	{
		result = false;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

//Because the user can hold the OB1-TR-8R for as long as they want, don't let them gain ult charge until it has been fired:
public Action CF_OnUltChargeGiven(int client, float &amt)
{
	if (f_VFXEndTime[client] >= GetGameTime() && amt > 0.0)
	{
		amt = 0.0;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public void OnMapEnd()
{
	for (int i = 0; i <= MaxClients; i++)
	{
		Rush_DeleteTimer(i);
	}
}

public Action CF_OnPlayerKilled_Pre(int &victim, int &inflictor, int &attacker, char weapon[255], char console[255], int &custom, int deadRinger, int &critType, int &damagebits)
{
	Action ReturnValue = Plugin_Continue;

	if (b_RushIn)
	{
		ReturnValue = Plugin_Changed;
		strcopy(console, sizeof(console), "Rush In!");
		strcopy(weapon, sizeof(weapon), "demoshield");
	}

	return ReturnValue;
}