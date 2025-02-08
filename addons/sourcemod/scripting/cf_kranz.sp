#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define KRANZ				"cf_kranz"
#define PRIMARY_FIRE		"kranz_primary_fire"
#define SOLVER				"kranz_problem_solver"
#define OBLITERATOR			"kranz_obliterator"

#define PARTICLE_SOLVER_MUZZLE				"ExplosionCore_MidAir"
#define PARTICLE_OBLITERATOR_TRACER_RED		"sniper_dxhr_rail_red"
#define PARTICLE_OBLITERATOR_TRACER_BLUE	"sniper_dxhr_rail_blue"
#define PARTICLE_OBLITERATOR_EXPLODE_RED	"powerup_supernova_explode_red"
#define PARTICLE_OBLITERATOR_EXPLODE_BLUE	"powerup_supernova_explode_blue"
#define PARTICLE_OBLITERATOR_MUZZLE_RED		"drg_cow_explosioncore_normal"
#define PARTICLE_OBLITERATOR_MUZZLE_BLUE	"drg_cow_explosioncore_normal_blue"

#define SND_OBLITERATOR_EXPLODE				")weapons/cow_mangler_explode.wav"

public void OnMapStart()
{
	PrecacheSound(SND_OBLITERATOR_EXPLODE);
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

	float ang[3];
	GetClientEyeAngles(client, ang);
	CF_FireGenericBullet(client, ang, damage, hsMult, spread, KRANZ, PrimaryFire_Hit, falloffStart, falloffEnd, falloffMax, pierce, grabEnemyTeam(client));
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

	DoMuzzleParticle(client, PARTICLE_SOLVER_MUZZLE);

	float ang[3];
	GetClientEyeAngles(client, ang);

	for (int i = 0; i < numBullets; i++)
		CF_FireGenericBullet(client, ang, damage, hsMult, spread, KRANZ, Solver_Hit, falloffStart, falloffEnd, falloffMax, pierce, grabEnemyTeam(client));

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

	Solver_TotalKB[victim] += Solver_KB;
}

float Obliterator_Radius, Obliterator_FalloffStart, Obliterator_FalloffMax, Obliterator_Damage;
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
	Obliterator_Radius = CF_GetArgF(client, KRANZ, abilityName, "blast_radius");
	Obliterator_FalloffStart = CF_GetArgF(client, KRANZ, abilityName, "blast_falloff_start");
	Obliterator_FalloffMax = CF_GetArgF(client, KRANZ, abilityName, "blast_falloff_max");
	Obliterator_Damage = CF_GetArgF(client, KRANZ, abilityName, "blast_damage");

	Obliterator_Team = TF2_GetClientTeam(client);
	DoMuzzleParticle(client, (Obliterator_Team == TFTeam_Red ? PARTICLE_OBLITERATOR_MUZZLE_RED : PARTICLE_OBLITERATOR_MUZZLE_BLUE));

	float ang[3];
	GetClientEyeAngles(client, ang);
	CF_FireGenericBullet(client, ang, damage, hsMult, spread, KRANZ, Obliterator_Hit, falloffStart, falloffEnd, falloffMax, pierce, grabEnemyTeam(client), _, _, (Obliterator_Team == TFTeam_Red ? PARTICLE_OBLITERATOR_TRACER_RED : PARTICLE_OBLITERATOR_TRACER_BLUE));
	CF_PlayRandomSound(client, "", "sound_obliterator_fired");
}

public void Obliterator_Hit(int attacker, int victim, float &baseDamage, bool &allowFalloff, bool &isHeadshot, int &hsEffect, bool &crit, float hitPos[3])
{
	if (isHeadshot)
	{
		allowFalloff = PrimaryFire_HSFalloff;
	}

	hsEffect = PrimaryFire_HSEffect;

	if (isHeadshot)
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

public void CF_OnCharacterCreated(int client)
{

}

public void CF_OnCharacterRemoved(int client)
{
	
}