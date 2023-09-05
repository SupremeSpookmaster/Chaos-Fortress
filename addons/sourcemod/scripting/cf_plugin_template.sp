#include <cf_include.inc>
#include <sdkhooks>
#include <tf2_stocks>

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (StrContains(abilityName, "test_held") != -1)
	{
		TF2_AddCondition(client, TFCond_CritHype);
	}
}

public void CF_OnHeldEnd_Ability(int client, char pluginName[255], char abilityName[255])
{
	if (StrContains(abilityName, "test_held") != -1)
	{
		TF2_RemoveCondition(client, TFCond_CritHype);
	}
}