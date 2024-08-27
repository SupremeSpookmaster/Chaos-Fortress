//TODO: Make this a standalone plugin with its own GitHub page eventually.
#include <sourcemod>
#include <tf_player_collisions>
#include <sdktools>

//The distance in which collisions will be checked.
#define RANGE	100.0

enum g_Collision_Group
{
    COLLISION_GROUP_NONE  = 0,
    COLLISION_GROUP_DEBRIS,            // Collides with nothing but world and static stuff
    COLLISION_GROUP_DEBRIS_TRIGGER,        // Same as debris, but hits triggers
    COLLISION_GROUP_INTERACTIVE_DEBRIS,    // Collides with everything except other interactive debris or debris
    COLLISION_GROUP_INTERACTIVE,        // Collides with everything except interactive debris or debris    Can be hit by bullets, explosions, players, projectiles, melee
    COLLISION_GROUP_PLAYER,            // Can be hit by bullets, explosions, players, projectiles, melee
    COLLISION_GROUP_BREAKABLE_GLASS,
    COLLISION_GROUP_VEHICLE,
    COLLISION_GROUP_PLAYER_MOVEMENT,    // For HL2, same as Collision_Group_Player, for TF2, this filters out other players and CBaseObjects

    COLLISION_GROUP_NPC,        // Generic NPC group
    COLLISION_GROUP_IN_VEHICLE,    // for any entity inside a vehicle    Can be hit by explosions. Melee unknown.
    COLLISION_GROUP_WEAPON,        // for any weapons that need collision detection
    COLLISION_GROUP_VEHICLE_CLIP,    // vehicle clip brush to restrict vehicle movement
    COLLISION_GROUP_PROJECTILE,    // Projectiles!
    COLLISION_GROUP_DOOR_BLOCKER,    // Blocks entities not permitted to get near moving doors
    COLLISION_GROUP_PASSABLE_DOOR,    // ** sarysa TF2 note: Must be scripted, not passable on physics prop (Doors that the player shouldn't collide with)
    COLLISION_GROUP_DISSOLVING,    // Things that are dissolving are in this group
    COLLISION_GROUP_PUSHAWAY,    // ** sarysa TF2 note: I could swear the collision detection is better for this than NONE. (Nonsolid on client and server, pushaway in player code) // Can be hit by bullets, explosions, projectiles, melee
    COLLISION_GROUP_NPC_ACTOR,        // Used so NPCs in scripts ignore the player.
    COLLISION_GROUP_NPC_SCRIPTED = 19,    // Used for NPCs in scripts that should not collide with each other.

    LAST_SHARED_COLLISION_GROUP,

    TF_COLLISIONGROUP_GRENADE = 20,
    TFCOLLISION_GROUP_OBJECT,
    TFCOLLISION_GROUP_OBJECT_SOLIDTOPLAYERMOVEMENT,
    TFCOLLISION_GROUP_COMBATOBJECT,
    TFCOLLISION_GROUP_ROCKETS,        // Solid to players, but not player movement. ensures touch calls are originating from rocket
    TFCOLLISION_GROUP_RESPAWNROOMS,
    TFCOLLISION_GROUP_TANK,
    TFCOLLISION_GROUP_ROCKET_BUT_NOT_WITH_OTHER_ROCKETS
	
};

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
				SetEntityCollisionGroup(i, COLLISION_GROUP_DEBRIS_TRIGGER);
			}
			else if (b_CollisionsAreBlocked[i])
			{
				SetEntityCollisionGroup(i, COLLISION_GROUP_PLAYER);
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