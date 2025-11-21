#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define KHOLDROZ		"cf_kholdroz"
#define BEAM		"kholdroz_aurora_beam"

public void OnMapStart()
{
}

public void OnPluginStart()
{
}

public void AuroraBeam_Fire(int client, char abilityName[255])
{
	//TODO
}

public void CF_OnCharacterCreated(int client)
{
}

public void CF_OnCharacterRemoved(int client)
{
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, KHOLDROZ))
		return;
	
	if (StrContains(abilityName, BEAM) != -1)
		AuroraBeam_Fire(client, abilityName);
}