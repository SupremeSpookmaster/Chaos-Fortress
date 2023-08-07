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