#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define KRANZ				"cf_kranz"
#define PRIMARY_FIRE		"kranz_primary_fire"
#define SOLVER				"kranz_problem_solver"

#define PARTICLE_SOLVER_BLAST		"ExplosionCore_MidAir"

public void OnMapStart()
{
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

public void PrimaryFire_Hit(int attacker, int victim, float &baseDamage, bool &allowFalloff, bool &isHeadshot, int &hsEffect, bool &crit)
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

	float ang[3], pos[3], vel[3];
	GetClientEyeAngles(client, ang);
	GetClientAbsOrigin(client, pos);
	pos[2] += 60.0 * CF_GetCharacterScale(client);
	GetPointInDirection(pos, ang, 20.0, pos);
	SpawnParticle(pos, PARTICLE_SOLVER_BLAST, 2.0);

	for (int i = 0; i < numBullets; i++)
		CF_FireGenericBullet(client, ang, damage, hsMult, spread, KRANZ, Solver_Hit, falloffStart, falloffEnd, falloffMax, pierce, grabEnemyTeam(client));

	Solver_KBAng = ang;
	if (Solver_KBAng[0] > -15.0)
		Solver_KBAng[0] = -15.0;

	RequestFrame(Solver_DoKnockback);

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

public void Solver_Hit(int attacker, int victim, float &baseDamage, bool &allowFalloff, bool &isHeadshot, int &hsEffect, bool &crit)
{
	if (isHeadshot)
	{
		allowFalloff = PrimaryFire_HSFalloff;
	}

	hsEffect = PrimaryFire_HSEffect;

	Solver_TotalKB[victim] += Solver_KB;
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