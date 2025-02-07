/*
This basic plugin template exists to provide devs with an easy starting point for their character plugins, to get all of the annoying tedious work out of the way.
To use this template, just replace the placeholder text (THIS_PLUGIN_NAME, ORBITAL_DEATH_RAY, cf_plugin_template, etc) with whatever you need. Then, you can add any missing
forwards your plugin needs as you work.
*/

#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define MAXTF2PLAYERS			36
#define MAXENTITIES				2048

//replace with actual grenade models. the iron bomber ones
#define BEACON_MODEL_RED	"models/props_moonbase/moon_gravel_crystal_red.mdl"
#define BEACON_MODEL_BLUE	"models/props_moonbase/moon_gravel_crystal_blue.mdl"

#define THIS_PLUGIN_NAME		"cf_herlven"

#define ORBITAL_DEATH_RAY		"herlven_orbital_deathray"
#define SUPER_SHOTGUN			"herlven_super_shotgun"

//Precache all of your plugin-specific sounds and models here.
public void OnMapStart()
{
	PrecacheModel(BEACON_MODEL_RED, true);
	PrecacheModel(BEACON_MODEL_BLUE, true);
}

//Hook your events in here.
public void OnPluginStart()
{
}

//This forward is called when an ability is activated. It is best used to check if the ability being activated is
//one of our plugin's abilities, so that our plugin can read that ability's variables and act as such.
public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	//The activated ability's plugin is not this plugin, don't do anything.
	if (!StrEqual(pluginName, THIS_PLUGIN_NAME))
		return;
	
	//The activated ability belongs to our plugin, check to see which ability it is.	
	if (StrContains(abilityName, ORBITAL_DEATH_RAY) != -1)
	{
		Orbital_Death_Ray_Activate(client, abilityName);
	}
	//The activated ability belongs to our plugin, check to see which ability it is.	
	if (StrContains(abilityName, SUPER_SHOTGUN) != -1)
	{
		SuperShotgunFire_Activate(client, abilityName);
	}
}

//This is a custom ability activation method, used by this plugin. In a real character plugin, this is where you would
//read the ability's variables via the "CF_GetArg" natives and apply its special effects. For example, if our ability
//shoots a rocket with customizable damage, this is where we would read the ability's args from the config to get the
//rocket's damage and then shoot it.
enum struct DeathRay_Data
{
	float Duration;
	float Timer;

	float Speed;
	float Damage;
	float Radius;

	float Throttle;

	float Location[3];		//the location the beam is at.

	float Anchor_Loc[3];	//the sky location its anchored to.
}
static DeathRay_Data struct_DeathRayData[MAXTF2PLAYERS];
void Orbital_Death_Ray_Activate(int client, char abilityName[255])
{
	struct_DeathRayData[client].Damage = 10.0;
	struct_DeathRayData[client].Radius = 25.0;
	struct_DeathRayData[client].Speed = 10.0;
	struct_DeathRayData[client].Duration = 10.0;

	float Initiate_In = 3.0;

	int Ball = Beacon_CreateProp(client);

	float Throw_Velocity = 1000.0;

	float pos[3], vecAngles[3], vecVelocity[3];
	GetClientEyeAngles(client, vecAngles);
	GetClientEyePosition(client, pos);
	vecAngles[0] -= 8.0;
	
	vecVelocity[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*Throw_Velocity;
	vecVelocity[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*Throw_Velocity;
	vecVelocity[2] = Sine(DegToRad(vecAngles[0])) * Throw_Velocity;
	vecVelocity[2] *= -1;
	
	TeleportEntity(Ball, pos, vecAngles, vecVelocity);

	DataPack pack2 = new DataPack();
	CreateDataTimer(Initiate_In, OffSetDeathRay_Spawn, pack2, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack2, EntIndexToEntRef(client));
	WritePackCell(pack2, EntIndexToEntRef(Ball));
}
static Action OffSetDeathRay_Spawn(Handle Timer, DataPack pack)
{
	ResetPack(pack);
	int client = EntRefToEntIndex(ReadPackCell(pack));
	int Ball = EntRefToEntIndex(ReadPackCell(pack));

	if(!IsValidClient(client) || CF_GetRoundState() != 1)
	{
		if(IsValidEntity(Ball))
			RemoveEntity(Ball);

		return Plugin_Stop;
	}
	float Spawn_Loc[3];
	if(IsValidEntity(Ball))
	{
		GetEntPropVector(Ball, Prop_Data, "m_vecAbsOrigin", Spawn_Loc);
	}
	else
	{
		GetClientEyePosition(client, Spawn_Loc);
	}
	Invoke_DeathRay(client, Spawn_Loc);
	if(IsValidEntity(Ball))
		RemoveEntity(Ball);

	return Plugin_Handled;
}

static void Invoke_DeathRay(int client, float Loc[3])
{
	struct_DeathRayData[client].Throttle = 0.0;
	struct_DeathRayData[client].Timer = GetGameTime() + struct_DeathRayData[client].Duration;
	struct_DeathRayData[client].Location = Loc;

	//super earth's finest, in action!
	SDKUnhook(client, SDKHook_PreThink, OribtalDeathRay_Tick);
	SDKHook(client, SDKHook_PreThink, OribtalDeathRay_Tick);
}
static void OribtalDeathRay_Tick(int client)
{
	float GameTime = GetGameTime();

	if(struct_DeathRayData[client].Timer < GameTime || CF_GetRoundState() != 1)
	{
		SDKUnhook(client, SDKHook_PreThink, OribtalDeathRay_Tick);
		return;
	}
	bool update = true;
	if(struct_DeathRayData[client].Throttle > GameTime)
		update = false;

	float Location[3]; Location = struct_DeathRayData[client].Location;

	if(update)
	{
		struct_DeathRayData[client].Throttle = GameTime + 0.1;
		float Travel_Dist = 0.0;
		Location[2]+=25.0;
		int Target = CF_GetClosestTarget(Location, false, Travel_Dist, 0.0, TF2_GetClientTeam(client));
		Location[2]-=25.0;

		if(CF_IsValidTarget(Target, TF2_GetClientTeam(client)))
		{
			float Enemy_Loc[3];
			GetEntPropVector(Target, Prop_Data, "m_vecAbsOrigin", Enemy_Loc);
			float Speed = struct_DeathRayData[client].Speed;
			if(Travel_Dist < Speed)
			{
				Speed*= Travel_Dist/Speed;
			}

			Move_Vector_Towards_Target(Location, Enemy_Loc, struct_DeathRayData[client].Location, Speed);
		}
		
	}
		


}
void SuperShotgunFire_Activate(int client, char abilityName[255])
{
}

//When a player becomes a character, this forward is called. This forward is best used for passive abilities.
//For example, if our character plugin contains a passive ability that gives the character low gravity, we would
//read the passive ability's variables and apply them in here.
public void CF_OnCharacterCreated(int client)
{
}

//When a player's character is removed (typically when they die or leave the match), this forward is called.
//This forward is best for cleaning up variables used by your ability. For example, if our character plugin
//contains a passive ability that attaches a particle to the character, we would remove that particle in here
//to prevent it from following the player's spectator camera while they're dead.
public void CF_OnCharacterRemoved(int client)
{
	SDKUnhook(client, SDKHook_PreThink, OribtalDeathRay_Tick);
}

//Stocks and such.
/**
 *  @param Origin - Input
 *  @param Target - Input
 *  @param EndLoc - Output
 *  @param Speed - How far it goes, in HU.
 */
stock void Move_Vector_Towards_Target(float Origin[3], float Target[3], float EndLoc[3], float Speed)
{
	float Angles[3];
	MakeVectorFromPoints(Origin, Target, Angles);
	GetVectorAngles(Angles, Angles);

	Get_Fake_Forward_Vec(Speed, Angles, EndLoc, Origin);
}
/**
 *  @param Range - self explanitory.
 *  @param Angles - twoards where should it go
 *  @param Vec_Target - Output Vector.
 *  @param Pos - Input Vector
 */
stock void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}

//Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, cur_vec);
stock void Proper_To_Groud_Clip(float vecHull[3], float StepHeight = 300.0, float vecorigin[3])
{
	float originalPostionTrace[3];
	float startPostionTrace[3];
	float endPostionTrace[3];
	endPostionTrace = vecorigin;
	startPostionTrace = vecorigin;
	originalPostionTrace = vecorigin;
	startPostionTrace[2] += StepHeight;
	endPostionTrace[2] -= 5000.0;

	float vecHullMins[3];
	vecHullMins = vecHull;

	vecHullMins[0] *= -1.0;
	vecHullMins[1] *= -1.0;
	vecHullMins[2] *= -1.0;

	Handle trace;
	trace = TR_TraceHullFilterEx( startPostionTrace, endPostionTrace, vecHullMins, vecHull, MASK_PLAYERSOLID,HitOnlyWorld, 0);
	if ( TR_GetFraction(trace) < 1.0)
	{
		// This is the point on the actual surface (the hull could have hit space)
		TR_GetEndPosition(vecorigin, trace);	
	}
	vecorigin[0] = originalPostionTrace[0];
	vecorigin[1] = originalPostionTrace[1];

	float VecCalc = (vecorigin[2] - startPostionTrace[2]);
	if(VecCalc > (StepHeight - (vecHull[2] + 2.0)) || VecCalc > (StepHeight - (vecHull[2] + 2.0)) ) //This means it was inside something, in this case, we take the normal non traced position.
	{
		vecorigin[2] = originalPostionTrace[2];
	}

	delete trace;
	//if it doesnt hit anything, then it just does buisness as usual
}
static bool HitOnlyWorld(int entity, int contentsMask, any iExclude)
{
	return !entity;
}

//taken from zeina. modified
static int Beacon_CreateProp(int client)
{
	int prop = CreateEntityByName("prop_dynamic_override");
	if (IsValidEntity(prop))
	{
		TFTeam team = TF2_GetClientTeam(client);
		SetEntPropEnt(prop, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(prop, Prop_Send, "m_iTeamNum", team);
		
		int SaveTeam = GetEntProp(prop, Prop_Send, "m_iTeamNum");
		if(SaveTeam == 2)
		{
			SetEntityModel(prop, BEACON_MODEL_RED);
		}
		else
		{
			SetEntityModel(prop, BEACON_MODEL_BLUE);
		}
		
		DispatchSpawn(prop);
	
		AcceptEntityInput(prop, "Enable");
		
		float pos[3], ang[3];
		GetClientEyeAngles(client, ang);
		GetClientAbsOrigin(client, pos);
		pos[2] += 20.0;
		ang[0] = 0.0;
		ang[2] = 0.0; //if somehow.

		SetEntPropFloat(prop, Prop_Send, "m_flModelScale", 2.0); 


		TeleportEntity(prop, pos, ang, NULL_VECTOR);
	}
	return prop;
}