#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>
#include <fakeparticles>

//This is the name of our plugin, in this case "cf_gordon".
#define GORDON			"cf_gordon"

//These are all of your ability names, as specified in the character CFG.
#define SPAWN_PROP		"gordon_spawn_prop"
#define GRAB_PROP		"gordon_grab_prop"
#define PUSH_PROP		"gordon_push_prop"
#define Physcharge		"gordon_ult"
#define YOINK			"gordon_grab_target"
#define RELEASE			"gordon_drop_target"

#define THROW_FORCE 1000.0



//Models, sounds, etc can be defined here:
#define MODEL_VENDINGMACHINE	"models/props_interiors/vendingmachinesoda01a.mdl"
#define MODEL_BALL				"models/roller.mdl"
#define MODEL_TV				"models/props_c17/tv_monitor01.mdl"
#define MODEL_Prop				"models/props_junk/wood_crate001a.mdl"
#define MODEL_DOOR			"models/props_combine/breendesk.mdl"

#define SOUND_GRAB_TF "ui/item_default_pickup.wav"      // grab
#define SOUND_TOSS_TF "ui/item_default_drop.wav"        // throw
#define SOUND_PROP_LOOP					")weapons/cow_mangler_idle.wav"

#define PARTICLE_MINE_DESTROYED			"sapper_debris"


#define SOUND_GRAB_OM "buttons/combine_button5.wav"     // grab
#define SOUND_TOSS_OM "buttons/combine_button5.wav"     // throw



#define SOUND_MINE_DESTROYED				"passtime/ball_smack.wav"
#define BALL_HIT				"passtime/ball_smack.wav"


int i_GordonPropOwner[2048] = { -1, ... };
int i_GrabbedProp[MAXPLAYERS + 1] = { -1, ... };
float f_MineRadius[2048] = { 0.0, ... };
float f_MineDMG[2048] = { 0.0, ... };
float f_MineBlastRadius[2048] = { 0.0, ... };
float f_MineFalloffStart[2048] = { 0.0, ... };
float f_MineFalloffMax[2048] = { 0.0, ... };
float f_MineNextThink[2048] = { 0.0, ... };
float f_PropHP[2048] = { 0.0, ... };


ArrayList g_Mines[MAXPLAYERS + 1] = { null, ... };


//Precache all of your plugin-specific sounds and models here.




public void OnPluginStart()
{
}

public void OnMapStart()
{
	PrecacheModel(MODEL_VENDINGMACHINE);
	PrecacheModel(MODEL_BALL);
	PrecacheModel(MODEL_TV);
	PrecacheModel(MODEL_DOOR);
	PrecacheModel(MODEL_Prop);
	PrecacheSound(SOUND_GRAB_TF, true);
	PrecacheSound(SOUND_TOSS_TF, true);
	PrecacheSound(SOUND_MINE_DESTROYED);
	PrecacheSound(BALL_HIT);
	PrecacheSound(SOUND_PROP_LOOP);
	PrecacheModel("materials/sprites/laserbeam.vmt");

	for (int i = 0; i <= MaxClients; i++)
	{
	}
}




//////////////////////////////////////////////////////////////////////
/////////////                  Basic Prop stuff             /////////////
//////////////////////////////////////////////////////////////////////


//We activated "gordon_spawn_prop", so spawn a prop.
//See "CF_OnAbility" to see how this is triggered.
public void SpawnProp_Activate(int client, char abilityName[255])
{
	//Step 1: Get the position and angles of the prop.
	//We do this by getting the angles and position of the client's eyes, then we move that position forward a bit so the prop doesn't spawn inside of the player.
	float radius = CF_GetArgF(client, GORDON, abilityName, "detection_radius", 80.0);
	float pos[3], ang[3], vel[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	GetPointInDirection(pos, ang, 40.0, pos);


	//Step 2: Choose our prop.
	//Say, for instance, we have 3 props we wish to choose from at random.
	//We could determine which prop to use by grabbing a random number between 1-3.
	//Then, we just check which number was chosen, and apply the proper variables as needed.

	//There are better ways of making this specific ability, which would allow it to be expanded upon via the CFG and would offer greater customization overall.
	//Those methods are a bit on the advanced side, so for now, we'll stick to hard-coding each individual prop.
	float durability, force, dammage;
	char model[255];

	int selection = GetRandomInt(1, 5);
	switch(selection)
	{
		case 1:	//Prop 1 was selected, let's make it a Combine Ball with low health, but gets launched with huge force.
		{
			durability = 20.0;
			force = 1200.0;
			model = MODEL_BALL;
			dammage = 175.0;
			radius = 75.0;
		}
		case 2:	//Prop 1 was selected, let's make it a Vending Machine with very high health, that gets launched with very little force.
		{
			durability = 150.0;
			force = 40.0;
			model = MODEL_VENDINGMACHINE;
			dammage = 150.0;
			radius = 175.0;
		}
		case 3:	//Prop 1 was selected, let's make it a Vending Machine with very high health, that gets launched with very little force.
		{
			durability = 500.0;
			force = 40.0;
			model = MODEL_DOOR;
			dammage = 100.0;
			radius = 100.0;
		}

		case 4:	//Prop 1 was selected, let's make it a Vending Machine with very high health, that gets launched with very little force.
		{
			durability = 70.0;
			force = 40.0;
			model = MODEL_Prop;
			dammage = 100.0;
			radius = 65.0;
		}

		default: //"default" in switch statements is used to handle all situations in which the variable we are checking (in this case, "selection") is not caught by the other cases. It's not always necessary to use a "default", but it's a nice layer of added safety.
				 //In this case, we'll have the default be a tire with moderate health and force.
		{
			durability = 100.0;
			force = 200.0;
			model = MODEL_TV;
			dammage = 125.0;
			radius = 175.0;
		}
	}
	
	GetVelocityInDirection(ang, force, vel);

	//Step 3: Spawn the prop, and assign an owner to it.
	int prop = SpawnPhysProp(client, model, pos, ang, vel, _, durability, false);
	if (IsValidEntity(prop))
		i_GordonPropOwner[prop] = GetClientUserId(client);
		f_MineRadius[prop] = radius;
		f_MineDMG[prop] = CF_GetArgF(client, GORDON, abilityName, "damage", dammage);
		f_MineBlastRadius[prop] = CF_GetArgF(client, GORDON, abilityName, "radius", radius);
		f_MineFalloffStart[prop] = CF_GetArgF(client, GORDON, abilityName, "falloff_start", 9999.0);
		f_MineFalloffMax[prop] = CF_GetArgF(client, GORDON, abilityName, "falloff_max", 0.0);
		RequestFrame(Mine_CheckVictims, EntIndexToEntRef(prop));
		SDKHook(prop, SDKHook_OnTakeDamage, Supplies_PropDamaged);
		f_PropHP[prop] = durability;
		Mine_AddToList(prop, client, CF_GetArgI(client, GORDON, abilityName, "max_mines", 1));
}





public void Prop_DealDamage(int prop, float damage)
{
	f_PropHP[prop] -= damage;
	if (f_PropHP[prop] <= 0.0)
		Prop_Destroy(prop, true);
}


public Action Supplies_PropDamaged(int prop, int &attacker, int &inflictor, float &damage, int &damagetype)
{	
	float originalDamage = damage;
	damage = 0.0;
	
	if (GetEntProp(prop, Prop_Send, "m_iTeamNum") == GetEntProp(attacker, Prop_Send, "m_iTeamNum"))
		return Plugin_Changed;
	
	if (IsValidClient(attacker))
	{
		if (originalDamage >= f_PropHP[prop])
			ClientCommand(attacker, "playgamesound ui/killsound.wav");
		else
		{
			ClientCommand(attacker, "playgamesound ui/hitsound.wav");
		}
			
		float pos[3];
		CF_WorldSpaceCenter(prop, pos);
		pos[2] += 10.0;
	}
	
	Prop_DealDamage(prop, originalDamage);
	
	return Plugin_Changed;
}


public void Mine_AddToList(int prop, int client, int maxMines)
{
	if (g_Mines[client] == null)
		g_Mines[client] = CreateArray(32);

	PushArrayCell(g_Mines[client], EntIndexToEntRef(prop));
	if (maxMines > 1)
	{
		while (GetArraySize(g_Mines[client]) > maxMines)
		{
			prop = EntRefToEntIndex(GetArrayCell(g_Mines[client], 0));
			if (IsValidEntity(prop))
				RemoveEntity(prop);
			else
				RemoveFromArray(g_Mines[client], 0);
		}

		PrintCenterText(client, "Placed %i/%i prop(s)", GetArraySize(g_Mines[client]), maxMines);
	}
}

public void Mine_RemoveFromList(int prop, int client)
{
	if (g_Mines[client] == null)
		return;

	for (int i = 0; i < GetArraySize(g_Mines[client]); i++)
	{
		int ref = GetArrayCell(g_Mines[client], i);
		if (ref == EntIndexToEntRef(prop))
		{
			RemoveFromArray(g_Mines[client], i);
			break;
		}
	}

	if (GetArraySize(g_Mines[client]) < 1)
	{
		delete g_Mines[client];
		g_Mines[client] = null;
	}
}

public void Mine_DestroyAll(int client)
{
	if (g_Mines[client] == null)
		return;

	for (int i = 0; i < GetArraySize(g_Mines[client]); i++)
	{
		int prop = EntRefToEntIndex(GetArrayCell(g_Mines[client], i));
		if (IsValidEntity(prop))
			Prop_Destroy(prop, true);
	}

	delete g_Mines[client];
	g_Mines[client] = null;
}


public void Mine_DestroyNextFrame(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEntity(ent))
		Prop_Destroy(ent);
}

void Prop_Destroy(int prop, bool nextFrame = false)
{
	if (nextFrame)
	{
		RequestFrame(Mine_DestroyNextFrame, EntIndexToEntRef(prop));
		return;
	}

	float pos[3];
	GetEntPropVector(prop, Prop_Send, "m_vecOrigin", pos);
	SpawnParticle(pos, PARTICLE_MINE_DESTROYED, 0.2);
	EmitSoundToAll(SOUND_MINE_DESTROYED, prop);
	RemoveEntity(prop);
}

public bool Mine_CheckVictim(int victim) { return IsValidClient(victim) || IsABuilding(victim) || PNPC_IsNPC(victim); }

public void Mine_CheckVictims(int ref)
{
	float gt = GetGameTime();
	int prop = EntRefToEntIndex(ref);
	if (!IsValidEntity(prop))
		return;

	int owner = GetClientOfUserId(i_GordonPropOwner[prop]);
	if (!IsValidClient(owner))
	{
		RemoveEntity(prop);
		return;
	}


	float pos[3];
	GetEntPropVector(prop, Prop_Send, "m_vecOrigin", pos);

	float dist;
	int victim = CF_GetClosestTarget(pos, true, dist, f_MineRadius[prop], grabEnemyTeam(owner), GORDON, Mine_CheckVictim, true);


	if (IsValidEntity(victim))
	{

		CF_GenericAOEDamage(owner, prop, 0, f_MineDMG[prop], DMG_BLAST, f_MineBlastRadius[prop], pos, f_MineFalloffStart[prop], f_MineFalloffMax[prop], _, false);
		EmitSoundToAll(BALL_HIT, prop);
		RemoveEntity(prop);

		return;
	}

	f_MineNextThink[prop] = gt + 0.1;
	RequestFrame(Mine_CheckVictims, ref);
}











//////////////////////////////////////////////////////////////////////
/////////////                  Physgun grab (mmmm soup)               /////////////
//////////////////////////////////////////////////////////////////////

//We activated "gordon_grab_prop", so spawn a prop.
//See "CF_OnAbility" to see how this is triggered.
public void GrabProp_Activate(int client, char abilityName[255])
{
	//Step 0: If we're already grabbing a prop, drop it.
	//You might also use this as an easy way to let the user launch props.
	int current = EntRefToEntIndex(i_GrabbedProp[client]);
	if (IsValidEntity(current))
	{
		i_GrabbedProp[client] = -1;
		StopSound(client, SNDCHAN_AUTO, SOUND_PROP_LOOP);
		return;
	}

	//Step 1: Get the position of the client's eyes, as well as the position of their crosshair.
	float pos[3], endPos[3], ang[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);

	//We add this so that the maximum distance at which props can be grabbed is customizable via the CFG.
	float maxDist = CF_GetArgF(client, GORDON, abilityName, "max_distance", 180.0);
	GetPointInDirection(pos, ang, maxDist, endPos);

	//We add this so that the user can't grab props through walls.
	CF_HasLineOfSight(pos, endPos, _, endPos, client);

	//Step 2: Call our special trace to see if there are any grabbable props.
	TR_TraceRayFilter(pos, endPos, MASK_SHOT, RayType_EndPoint, Trace_OnlyGordonProps, client);

	if (TR_DidHit())  //TR_DidHit() with this filter should only return true if the trace hits a prop that the user can grab.
	{
		int prop = TR_GetEntityIndex();  //TR_GetEntityIndex() will grab the prop that was hit by the trace.

		if (IsValidEntity(prop))
		{
			i_GrabbedProp[client] = EntIndexToEntRef(prop);
			RequestFrame(GrabProp_Hold, GetClientUserId(client));
			CF_PlayRandomSound(client, client, "prop_prepare");
			EmitSoundToClient(client, SOUND_PROP_LOOP);
		}
	}
}



public void GrabProp_Hold(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client) || i_GrabbedProp[client] == -1)
		return;

	int prop = EntRefToEntIndex(i_GrabbedProp[client]);
	if (!IsValidEntity(prop))
	{
		i_GrabbedProp[client] = -1;
		return;
	}
	
	float targPos[3], ang[3], currentLoc[3], targVel[3], currentAng[3];
	GetClientEyePosition(client, targPos);
	GetEntPropVector(prop, Prop_Send, "m_vecOrigin", currentLoc);

	//Don't allow the user to hold props through walls:
	if (!CF_HasLineOfSight(targPos, currentLoc, _, _, client))
	{
		i_GrabbedProp[client] = -1;
		return;
	}

	//Get a point which is 80 HU in the direction the user is aiming. This is the distance we want to hold our prop at.
	GetClientEyeAngles(client, ang);
	GetPointInDirection(targPos, ang, 90.0, targPos);

	//Set the prop's velocity so that it flies towards the grab position.
	SubtractVectors(targPos, currentLoc, targVel);
	ScaleVector(targVel, 75.0);
	TeleportEntity(prop, NULL_VECTOR, currentAng, targVel);

	RequestFrame(GrabProp_Hold, id);
}


//////////////////////////////////////////////////////////////////////
/////////////                  Toss Prop  stuff                  /////////////
//////////////////////////////////////////////////////////////////////

public void PushProp_Activate(int client, char abilityName[255])
{
	//Step 0: If we're already grabbing a prop, drop it.
	//You might also use this as an easy way to let the user launch props.
	int current = EntRefToEntIndex(i_GrabbedProp[client]);
	if (IsValidEntity(current))
	{
		i_GrabbedProp[client] = -1;
		return;
	}


	//Step 1: Get the position of the client's eyes, as well as the position of their crosshair.
	float pos[3], endPos[3], ang[3],vel[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);

	//We add this so that the maximum distance at which props can be grabbed is customizable via the CFG.
	float maxDist = CF_GetArgF(client, GORDON, abilityName, "max_distance", 180.0);
	GetPointInDirection(pos, ang, maxDist, endPos);

	//We add this so that the user can't grab props through walls.
	CF_HasLineOfSight(pos, endPos, _, endPos, client);

	//Step 2: Call our special trace to see if there are any grabbable props.
	TR_TraceRayFilter(pos, endPos, MASK_SHOT, RayType_EndPoint, Trace_OnlyGordonProps, client);

	if (TR_DidHit())  //TR_DidHit() with this filter should only return true if the trace hits a prop that the user can grab.
	{
		int prop = TR_GetEntityIndex();  //TR_GetEntityIndex() will grab the prop that was hit by the trace.

		if (IsValidEntity(prop))
		{
			i_GrabbedProp[client] = EntIndexToEntRef(prop);
			RequestFrame(pushProp, GetClientUserId(client));
		}
	}
}


public void pushProp(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client) || i_GrabbedProp[client] == -1)
		return;

	int prop = EntRefToEntIndex(i_GrabbedProp[client]);
	if (!IsValidEntity(prop))
	{
		return;
	}

	float targPos[3], currentLoc[3];
	GetClientEyePosition(client, targPos);

	//Don't allow the user to hold props through walls:
	
	//Get a point which is 80 HU in the direction the user is aiming. This is the distance we want to hold our prop at.
		new Float:vecView[3], Float:vecFwd[3], Float:vecPos[3], Float:vecVel[3];

	GetClientEyeAngles(client, vecView);
	GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
	GetClientEyePosition(client, vecPos);

	vecPos[0]+=vecFwd[0]*THROW_FORCE;
	vecPos[1]+=vecFwd[1]*THROW_FORCE;
	vecPos[2]+=vecFwd[2]*THROW_FORCE;

	GetEntPropVector(prop, Prop_Send, "m_vecOrigin", vecFwd);

	SubtractVectors(vecPos, vecFwd, vecVel);
	ScaleVector(vecVel, 10.0);
	StopSound(client, SNDCHAN_AUTO, SOUND_PROP_LOOP);
	CF_PlayRandomSound(client, client, "gordon_push_prop");
	TeleportEntity(prop, NULL_VECTOR, NULL_VECTOR, vecVel);
}



//////////////////////////////////////////////////////////////////////
/////////////                  Freeze Prop Commands                  /////////////
//////////////////////////////////////////////////////////////////////

public void resetProp(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client) || i_GrabbedProp[client] == -1)
		return;

	int prop = EntRefToEntIndex(i_GrabbedProp[client]);
	if (!IsValidEntity(prop))
	{
		i_GrabbedProp[client] = -1;
		return;
	}

	float targPos[3], ang[3], currentLoc[3], targVel[3], currentAng[3];
	GetClientEyePosition(client, targPos);
	GetEntPropVector(prop, Prop_Send, "m_vecOrigin", currentLoc);

	//Don't allow the user to hold props through walls:
	if (!CF_HasLineOfSight(targPos, currentLoc, _, _, client))
	{
		i_GrabbedProp[client] = -1;
		return;
	}

	//Get a point which is 80 HU in the direction the user is aiming. This is the distance we want to hold our prop at.
	GetClientEyeAngles(client, ang);
	GetPointInDirection(targPos, ang, 90.0, targPos);

	//Set the prop's velocity so that it flies towards the grab position.
	SubtractVectors(targPos, currentLoc, targVel);
	ScaleVector(targVel, 15.0);
	TeleportEntity(prop, NULL_VECTOR, currentAng);
	
	RequestFrame(GrabProp_Hold, id);
}




//////////////////////////////////////////////////////////////////////
/////////////                  Ult Commands made possibile by Zeina                 /////////////
//////////////////////////////////////////////////////////////////////
int i_YoinkTarget[MAXPLAYERS + 1] = { -1, ... };
int i_YoinkBeam[MAXPLAYERS + 1] = { -1, ... };
int i_YoinkStartEnt[MAXPLAYERS + 1] = { -1, ... };
int i_YoinkEndEnt[MAXPLAYERS + 1] = { -1, ... };

bool b_Yoinking[MAXPLAYERS + 1] = { false, ... };

public void Yoink_Activate(int client, char abilityName[255])
{
	b_Yoinking[client] = true;
	SDKHook(client, SDKHook_PreThink, Yoink_GrabLogic);

	int target = Yoink_GetTarget(client);

	float startPos[3], endPos[3];
	CF_WorldSpaceCenter(client, startPos);
	CF_WorldSpaceCenter(target, endPos);
	startPos[2] += 15.0 * CF_GetCharacterScale(client);
	endPos[2] += 15.0 * CF_GetCharacterScale(target);

	int start, end;
	int r = 255;
	int b = 120;
	if (TF2_GetClientTeam(client) == TFTeam_Blue)
	{
		r = 120;
		b = 255;
	}

	i_YoinkBeam[client] = EntIndexToEntRef(CreateEnvBeam(client, target, startPos, endPos, _, _, start, end, r, 120, b, 255, "sprites/laser.vmt"));
	if (IsValidEntity(start))
		i_YoinkStartEnt[client] = EntIndexToEntRef(start);
	if (IsValidEntity(end))
		i_YoinkEndEnt[client] = EntIndexToEntRef(end);

	CF_ChangeAbilityTitle(client, CF_AbilityType_M3, "Toss enemy");
	CF_ApplyAbilityCooldown(client, 0.5, CF_AbilityType_M3, true);
	CF_SetAbilityTypeSlot(client, CF_AbilityType_M3, -777);
}

public Action Yoink_GrabLogic(int client)
{
	if (!IsValidMulti(client))
		return Plugin_Stop;

	int target = Yoink_GetTarget(client);
	if (!IsValidMulti(target))
	{
		Yoink_Release(client, false, false, 2.0);
		return Plugin_Stop;
	}

	float vecView[3], vecFwd[3], vecPos[3], vecVel[3];
	GetClientEyeAngles(client, vecView);
	GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
	GetClientEyePosition(client, vecPos);
	vecPos[0]+=vecFwd[0] * 60.0;
	vecPos[1]+=vecFwd[1] * 60.0;
	vecPos[2]+=vecFwd[2] * 60.0;
	GetEntPropVector(target, Prop_Send, "m_vecOrigin", vecFwd);
	SubtractVectors(vecPos, vecFwd, vecVel);
	ScaleVector(vecVel, 10.0);
	TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, vecVel);

	return Plugin_Continue;
}

public void Yoink_Release(int client, bool ultOver, bool resupply, float cooldown)
{
	
	int target = Yoink_GetTarget(client);
	/// THIS IS THAT MF Above

	if (!b_Yoinking[client])
		return;

	SDKUnhook(client, SDKHook_PreThink, Yoink_GrabLogic);

	b_Yoinking[client] = false;
	i_YoinkTarget[client] = -1;

	int ent = EntRefToEntIndex(i_YoinkBeam[client]);
	if (IsValidEntity(ent))
		RemoveEntity(ent);
	ent = EntRefToEntIndex(i_YoinkStartEnt[client]);
	if (IsValidEntity(ent))
		RemoveEntity(ent);
	ent = EntRefToEntIndex(i_YoinkEndEnt[client]);
	if (IsValidEntity(ent))
		RemoveEntity(ent);
	
	if (resupply || ultOver)
	{
		CF_ChangeAbilityTitle(client, CF_AbilityType_M3, "deploy prop");
		if (cooldown > 0.0)
			CF_ApplyAbilityCooldown(client, cooldown, CF_AbilityType_M3, true);
		CF_SetAbilityTypeSlot(client, CF_AbilityType_M3, 3);
	}
	else
	{
		CF_ChangeAbilityTitle(client, CF_AbilityType_M3, "Grab Enemy");
		if (cooldown > 0.0)
			CF_ApplyAbilityCooldown(client, cooldown, CF_AbilityType_M3, true);
		CF_SetAbilityTypeSlot(client, CF_AbilityType_M3, -778);
	}
	new Float:vecView[3], Float:vecFwd[3], Float:vecPos[3], Float:vecVel[3];

	GetClientEyeAngles(client, vecView);
	GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
	GetClientEyePosition(client, vecPos);

	vecPos[0]+=vecFwd[0]*THROW_FORCE;
	vecPos[1]+=vecFwd[1]*THROW_FORCE;
	vecPos[2]+=vecFwd[2]*THROW_FORCE;

	GetEntPropVector(target, Prop_Send, "m_vecOrigin", vecFwd);

	SubtractVectors(vecPos, vecFwd, vecVel);
	ScaleVector(vecVel, 10.0);

	CF_PlayRandomSound(client, client, "gordon_push_prop");
	TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, vecVel);
}

public void Release_Activate(int client, char abilityName[255])
{
	Yoink_Release(client, false, false, CF_GetArgF(client, GORDON, abilityName, "cooldown", 2.0));
}

public bool Yoink_FindTarget(int client, char abilityName[255])
{
	float dist = CF_GetArgF(client, GORDON, abilityName, "range", 600.0);

	float startPos[3], endPos[3], ang[3], hullMin[3], hullMax[3];
	GetClientEyePosition(client, startPos);
	GetClientEyeAngles(client, ang);
	GetPointInDirection(startPos, ang, dist, endPos);
	CF_HasLineOfSight(startPos, endPos, _, endPos, client);

	hullMin[0] = -CF_GetArgF(client, GORDON, abilityName, "width", 5.0);
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	CF_StartLagCompensation(client);
	Handle trace = TR_TraceHullFilterEx(startPos, endPos, hullMin, hullMax, MASK_SHOT, Yoink_OnlyHumanAllies, client);
	CF_EndLagCompensation(client);

	bool success = false;
	if (TR_DidHit(trace))
	{
		int target = TR_GetEntityIndex(trace);
		if (IsValidClient(target))
		{
			i_YoinkTarget[client] = GetClientUserId(target);
			success = true;
		}
	}

	delete trace;

	return success;
}


public int Yoink_GetTarget(int client) { return GetClientOfUserId(i_YoinkTarget[client]); }




public bool Yoink_OnlyHumanAllies(entity, contentsMask, int client)
{
	if (!IsValidMulti(entity) || entity == client)
		return false;

	return CF_IsValidTarget(entity, TF2_GetClientTeam(entity));
}

float f_PhyschargeEndTime[MAXPLAYERS + 1] = { 0.0, ... };

bool b_energying[MAXPLAYERS + 1] = { false, ... };

public void Physcharge_Activate(int client, char abilityName[255])
{
	float ang[3], vel[3], pos[3];
	GetClientAbsOrigin(client, pos);
	GetClientEyeAngles(client, ang);

	TeleportEntity(client, _, _, vel);


	SDKUnhook(client, SDKHook_PreThink, Physcharge_PreThink);
	SDKHook(client, SDKHook_PreThink, Physcharge_PreThink);


	f_PhyschargeEndTime[client] = GetGameTime() + CF_GetArgF(client, GORDON, abilityName, "duration", 16.0);


	b_energying[client] = true;
}

public void Physcharge_Terminate(int client)
{
	if (!b_energying[client])
		return;

	b_energying[client] = false;


	SDKUnhook(client, SDKHook_PreThink, Physcharge_PreThink);
	SetEntityMoveType(client, MOVETYPE_WALK);
}

public Action Physcharge_PreThink(int client)
{
	if (!IsPlayerAlive(client) || GetGameTime() >= f_PhyschargeEndTime[client])
	{
		Yoink_Release(client, true, false, 4.0);
		CF_ChangeAbilityTitle(client, CF_AbilityType_M3, "Deploy Prop");
		CF_ApplyAbilityCooldown(client, 4.0, CF_AbilityType_M3, true);
		CF_SetAbilityTypeSlot(client, CF_AbilityType_M3, 3);
		Physcharge_Terminate(client);
		return Plugin_Stop;
	}


	
	int buttons = GetClientButtons(client);
	if (buttons & IN_DUCK != 0)

	if (buttons & IN_JUMP != 0)





	return Plugin_Continue;
}




//////////////////////////////////////////////////////////////////////
/////////////                  effects Commands                  /////////////
//////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////
/////////////                  Triggers Commands                  /////////////
//////////////////////////////////////////////////////////////////////

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	//The activated ability's plugin is not this plugin, don't do anything.
	if (!StrEqual(pluginName, GORDON))
		return;
	
	//The activated ability belongs to our plugin, check to see which ability it is.	
	if (StrContains(abilityName, SPAWN_PROP) != -1)
	{
		//The ability which was activated was "gordon_spawn_prop", send the client's index and the ability's name to a separate method to apply the ability's effects.
		SpawnProp_Activate(client, abilityName);
	}

	if (StrContains(abilityName, GRAB_PROP) != -1)
	{
		GrabProp_Activate(client, abilityName);
	}


	if (StrContains(abilityName, PUSH_PROP) != -1)
	{
		PushProp_Activate(client, abilityName);
	}

	if (StrContains(abilityName, Physcharge) != -1)
	{
		Physcharge_Activate(client, abilityName);
	}

	if (StrContains(abilityName, YOINK) != -1)
	{
		Yoink_Activate(client, abilityName);
	}

	if (StrContains(abilityName, RELEASE) != -1)
	{
		Release_Activate(client, abilityName);
	}
}


//////////////////////////////////////////////////////////////////////
/////////////                  ETC Commands                  /////////////
//////////////////////////////////////////////////////////////////////



public Action CF_OnAbilityCheckCanUse(int client, char plugin[255], char ability[255], CF_AbilityType type, bool &result)
{
	if (!StrEqual(plugin, GORDON))
		return Plugin_Continue;
		

	if (StrContains(ability, YOINK) != -1 && (!b_Yoinking[client] && !Yoink_FindTarget(client, ability)))
	{
		result = false;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}





//When a player becomes a character, this forward is called. This forward is best used for passive abilities.
//For example, if our character plugin contains a passive ability that gives the character low gravity, we would
//read the passive ability's variables and apply them in here.
public void CF_OnCharacterCreated(int client)
{
	i_GrabbedProp[client] = -1;
}

//When a player's character is removed (typically when they die or leave the match), this forward is called.
//This forward is best for cleaning up variables used by your ability. For example, if our character plugin
//contains a passive ability that attaches a particle to the character, we would remove that particle in here
//to prevent it from following the player's spectator camera while they're dead.
public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
	i_GrabbedProp[client] = -1;
	Mine_DestroyAll(client);

	if (reason == CF_CRR_DEATH || reason == CF_CRR_DISCONNECT || reason == CF_CRR_ROUNDSTATE_CHANGED || reason == CF_CRR_SWITCHED_CHARACTER)
	{
		Yoink_Release(client, false, true, 0.0);		

		Physcharge_Terminate(client);
	}
	StopSound(client, SNDCHAN_AUTO, SOUND_PROP_LOOP);
}

public void OnEntityDestroyed(int entity)
{
	if (entity < 0 || entity > 2047)
		return;

	if (i_GordonPropOwner[entity] > 0)
	{
		int owner = GetClientOfUserId(i_GordonPropOwner[entity]);
		if (IsValidClient(owner))
			Mine_RemoveFromList(entity, owner);
	}


  i_GordonPropOwner[entity] = -1;
}



//"stock" is just a keyword that tells the compiler not to throw warnings if the function never gets used. 
//I've replaced it with "public" here to be cleaner, but leaving it as "stock" would not have caused any issues.
public bool Trace_OnlyGordonProps(int entity, int contentsmask, int user)
{
  	//If the owner is -1, that means this entity hasn't been assigned an owner yet, therefore ignore it:
  	if (i_GordonPropOwner[entity] == -1)
    	return false;
  
  	//Get the client index of the prop's owner:
  	int owner = GetClientOfUserId(i_GordonPropOwner[entity]);

 	//If the prop's owner is invalid, ignore the prop:
  	if (!IsValidClient(owner))
    	return false;

	//Make sure the prop isn't already being grabbed:
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
			continue;

		int grabbed = EntRefToEntIndex(i_GrabbedProp[i]);
		if (grabbed == entity)
			return false;
	}

  	//Allow the user to grab the prop if its owner is dead, or they are the owner:
  	return (!IsPlayerAlive(owner) || owner == user);
}
