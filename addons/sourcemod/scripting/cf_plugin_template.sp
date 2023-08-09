#include <cf_include.inc>
#include <tf2_stocks>
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <entity>
#include <tf2attributes>
#include <tf2items>

public Action CF_OnTakeDamageAlive_Bonus(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	damage *= 999.0;
	damagetype += DMG_CRIT;
	return Plugin_Changed;
}