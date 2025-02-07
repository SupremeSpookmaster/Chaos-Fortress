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
	CPrintToChatAll("Kranz hit");
	if (isHeadshot)
	{
		allowFalloff = PrimaryFire_HSFalloff;
	}

	hsEffect = PrimaryFire_HSEffect;
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