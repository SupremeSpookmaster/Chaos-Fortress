#include <cf_include.inc>
#include <sdkhooks>

public Action CF_OnTakeDamageAlive_Bonus(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	damage *= 999.0;
	damagetype += DMG_CRIT;
	return Plugin_Changed;
}