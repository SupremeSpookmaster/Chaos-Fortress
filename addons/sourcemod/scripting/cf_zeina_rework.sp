/**
 * READ THIS IF YOU ARE ARTVIN (or just interested in knowing what this plugin does)
 * 
 * This plugin manages all abilities for the Zeina rework.
 * It ALSO manages the rework to the Barrier effect. 
 * Thus, all of the abilities designed for Barrier - granting allies Barrier, granting yourself Barrier, spawning with additional Barrier, etc - are rewritten in here.
 * Sensal has been changed to use these new Barrier abilities as well.
 */

#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define ZEINA		"cf_zeina_rework"
#define BULLET		"zeina_barrier_bullet"

public void OnMapStart()
{
}

public void OnPluginStart()
{
}

public void Bullet_Activate(int client, char abilityName[255])
{

}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, ZEINA))
		return;
	
	if (StrContains(abilityName, BULLET) != -1)
	{
		Bullet_Activate(client, abilityName);
	}
}

public void CF_OnCharacterCreated(int client)
{
}

public void CF_OnCharacterRemoved(int client)
{
}