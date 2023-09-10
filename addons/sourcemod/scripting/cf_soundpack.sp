#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define SNDPACK				"cf_soundpack"

#define SOUNDLEVEL			"soundpack_level"

int Level_Level[MAXPLAYERS + 1] = { 100, ... };

float Level_Volume[MAXPLAYERS + 1] = { 1.0, ... };

char Level_Sound[MAXPLAYERS + 1][255];

public void CF_OnCharacterCreated(int client)
{
	if (CF_HasAbility(client, SNDPACK, SOUNDLEVEL))
	{
		CF_GetArgS(client, SNDPACK, SOUNDLEVEL, "sound", Level_Sound[client], 255);
		Level_Level[client] = CF_GetArgI(client, SNDPACK, SOUNDLEVEL, "level");
		Level_Volume[client] = CF_GetArgF(client, SNDPACK, SOUNDLEVEL, "volume");
	}
}

public Action CF_SoundHook(char strSound[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	int entCopy = entity;
	if (!IsValidEntity(entCopy))
		return Plugin_Continue;
		
	if (!IsValidClient(entCopy) && !HasEntProp(entCopy, Prop_Data, "m_hOwner"))
		return Plugin_Continue;
		
	if (!IsValidClient(entCopy))
		entCopy = GetEntPropEnt(entCopy, Prop_Data, "m_hOwner");
	if (!IsValidClient(entCopy))
		return Plugin_Continue;
		
	if (StrContains(strSound, Level_Sound[entCopy]) != -1)
	{
		level = Level_Level[entCopy];
		volume = Level_Volume[entCopy];
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}