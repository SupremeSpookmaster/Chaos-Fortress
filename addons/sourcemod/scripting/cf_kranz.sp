#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define KRANZ				"cf_kranz"
#define PRIMARY_FIRE		"kranz_primary_fire"

#define PARTICLE_RAILGUN_RED			"sniper_dxhr_rail_red"
#define PARTICLE_RAILGUN_BLUE			"sniper_dxhr_rail_blue"

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
}

public void PrimaryFire_Activate(int client, char abilityName[255])
{
	float startPos[3], endPos[3], shootPos[3], hitPos[3], ang[3];
	GetClientEyePosition(client, startPos);
	GetClientEyeAngles(client, ang);

	GetPointInDirection(startPos, ang, 20.0, shootPos);
	shootPos[2] -= 20.0;
	GetPointInDirection(startPos, ang, 9999.0, endPos);

	ArrayList victims = CF_DoBulletTrace(client, startPos, endPos, 1, grabEnemyTeam(client), _, _, hitPos);
	SpawnParticle_ControlPoints(shootPos, hitPos, PARTICLE_RAILGUN_BLUE, 2.0);

	for (int i = 0; i < GetArraySize(victims); i++)
	{
		int vic = GetArrayCell(victims, i);

		bool hs;
		CF_TraceShot(client, vic, startPos, endPos, hs, _, hitPos);

		if (hs)
			SDKHooks_TakeDamage(vic, client, client, 100.0, DMG_BULLET, _, _, hitPos);
		else
			SDKHooks_TakeDamage(vic, client, client, 20.0, DMG_BULLET, _, _, hitPos);

		//SpawnParticle_ControlPoints(shootPos, hitPos, PARTICLE_RAILGUN_RED, 2.0);
	}

	delete victims;
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