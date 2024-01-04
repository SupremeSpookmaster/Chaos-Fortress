//TODO: Make this a standalone plugin with its own GitHub page eventually.
#include <sourcemod>
#include <tf_player_collisions>
#include <SetCollisionGroup>

//The distance in which collisions will be checked.
#define RANGE	100.0

float f_EndBlockCollisions[MAXPLAYERS + 1] = { 0.0, ... };
bool b_CollisionsAreBlocked[MAXPLAYERS + 1] = { false, ... };

GlobalForward g_OnCheckCollisions;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	return APLRes_Success;
}

public void OnPluginStart()
{
	g_OnCheckCollisions = new GlobalForward("PlayerCollisions_OnCheckCollision", ET_Event, Param_Cell, Param_Cell, Param_CellByRef);
}

public void OnGameFrame()
{
	float gt = GetGameTime();
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidMulti(i))
		{
			CheckCollisions(i, gt);
			
			if (f_EndBlockCollisions[i] >= gt)
			{
				SetEntProp(i, Prop_Send, "m_CollisionGroup", view_as<int>(COLLISION_GROUP_DEBRIS_TRIGGER));
			}
			else if (b_CollisionsAreBlocked[i])
			{
				SetEntProp(i, Prop_Send, "m_CollisionGroup", view_as<int>(COLLISION_GROUP_PLAYER));
				b_CollisionsAreBlocked[i] = false;
			}
		}
	}
}

public void CheckCollisions(int client, float gt)
{
	float userLoc[3];
	GetClientAbsOrigin(client, userLoc);
	
	float dist = RANGE * GetEntPropFloat(client, Prop_Send, "m_flModelScale");
	
	bool AtLeastOne = false;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidMulti(i, true, true, true, GetOppositeTeam(client)))
		{
			if (GetDistanceFromPoint(i, userLoc) <= dist)
			{
				bool shouldCollide;
				Action result;
				
				Call_StartForward(g_OnCheckCollisions);
				
				Call_PushCell(client);
				Call_PushCell(i);
				Call_PushCellRef(shouldCollide);
				
				Call_Finish(result);
				
				if (result == Plugin_Changed && !shouldCollide)
				{
					f_EndBlockCollisions[i] = gt + 0.2;
					AtLeastOne = true;
					b_CollisionsAreBlocked[i] = true;
				}
			}
		}
	}
	
	if (AtLeastOne)
	{
		f_EndBlockCollisions[client] = gt + 0.2;
		b_CollisionsAreBlocked[client] = true;
	}
}

bool IsValidMulti(int client, bool checkAlive = true, bool isAlive = true, bool checkTeam = false, int targetTeam = 0)
{
	if(client <= 0 || client > MaxClients)
		return false;
		
	if(!IsClientInGame(client))
		return false;
		
	if (checkAlive && IsPlayerAlive(client) != isAlive)
		return false;
		
	if (checkTeam && GetClientTeam(client) != targetTeam)
		return false;
		
	return true;
}

float GetDistanceFromPoint(int client, float pos[3])
{
	float loc[3];
	GetClientAbsOrigin(client, loc);
	
	return GetVectorDistance(pos, loc);
}

int GetOppositeTeam(int client) { return (GetClientTeam(client) == 2 ? 3 : 2); }