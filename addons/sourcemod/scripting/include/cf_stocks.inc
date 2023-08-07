#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <entity>
#include <tf2attributes>
#include <tf2items>
#include <morecolors>
#include <tf2_stocks>
#include <cfgmap>
#include <queue>

/**
 * Checks if a client is valid.
 *
 * @param client			The client to check.
 *
 * @return					True if the client is valid, false otherwise.
 */
stock bool IsValidClient(int client)
{
	if(client <= 0 || client > MaxClients)
	{
		return false;
	}
	
	if(!IsClientInGame(client))
	{
		return false;
	}

	return true;
}

/**
 * Checks if a client is valid and meets various given criteria.
 *
 * @param client			The client to check.
 * @param checkAlive		Do we need to check if the client is alive?
 * @param isAlive			If checkAlive is true: do we need the client to be alive?
 * @param checkTeam			Do we need to check the client's team?
 * @param targetTeam		If checkTeam is true: which team do we need the client to be on?
 *
 * @return					True if the client is valid and meets all given criteria, false otherwise.
 */
stock bool IsValidMulti(int client, bool checkAlive = true, bool isAlive = true, bool checkTeam = false, TFTeam targetTeam = TFTeam_Red)
{
	if(!IsValidClient(client))
	{
		return false;
	}
	
	if(checkAlive)
	{
		if (isAlive != IsPlayerAlive(client))
		{
			return false;
		}
	}
	
	if (checkTeam)
	{
		if (targetTeam != TF2_GetClientTeam(client))
		{
			return false;
		}
	}

	return true;
}