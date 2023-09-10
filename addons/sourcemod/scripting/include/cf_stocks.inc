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
#include <clientprefs>
#include <tf_econ_data>

#define EF_NODRAW	32

float OFF_THE_MAP[3] = {1182792704.0, 1182792704.0, -964690944.0};

float PhysProp_CurrentSpeed[2049] = { 0.0, ... };

enum ViewmodelSequence
{
	VMS_Melee_Swing_1 = 8,
	VMS_Melee_Swing_2,
	VMS_Melee_Swing_3,
	VMS_Melee_Idle,
	VMS_Melee_Draw,
	VMS_Melee_Swing_4,
	VMS_Melee_Swing_5,
	VMS_Melee_Swing_6,
	VMS_Jarate_Draw,
	VMS_Jarate_Idle,
	VMS_Jarate_Throw
};

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

/**
 * Returns a KeyValues object from a given file path.
 *
 * @param path				The file path (EX: data/chaos_fortress/game_rules.cfg)
 * @param throwError		Do we want to throw an error if the kv does not exist?
 * @param error				The error to throw if throwError == true.
 *
 * @return					A KeyValues object created from the given path, null if invalid and throwError is not true.
 */
stock KeyValues GetKeyValuesFromPath(char path[255], bool throwError, char error[255])
{
	char file[255];
	BuildPath(Path_SM, file, PLATFORM_MAX_PATH, path);
	KeyValues kv = new KeyValues("");
	FileToKeyValues(kv, file);
 	
 	if (!kv.GotoFirstSubKey())
 	{
 		delete kv;
 		
 		if (throwError)
 		{
 			ThrowError(error);
 		}
 		else
 		{
 			return null;
 		}
 	}
 	
 	return kv;
}

/**
 * Returns a KeyValues object from a given file path, at a given section.
 *
 * @param path				The file path (EX: data/chaos_fortress/game_rules.cfg)
 * @param section			The section to go to.
 * @param throwError		Do we want to throw an error if the kv or section does not exist?
 * @param error				The error to throw if throwError == true.
 *
 * @return					A KeyValues object created from the given path, pre-navigated to the given section, null if invalid and throwError is not true.
 */
stock KeyValues GetKeyValuesAtSection(char path[255], char section[255], bool throwError, char error[255])
{
	char file[255];
	BuildPath(Path_SM, file, PLATFORM_MAX_PATH, path);
	KeyValues kv = new KeyValues("");
	FileToKeyValues(kv, file);
 	
 	if (!kv.JumpToKey(section))
 	{
 		delete kv;
 		
 		if (throwError)
 		{
 			ThrowError(error);
 		}
 		else
 		{
 			return null;
 		}
 	}
 	
 	return kv;
}

/**
 * Checks if a file exists.
 *
 * @param client			The file to check.
 *
 * @return					True if it exists, false otherwise.
 */
stock bool CheckFile(char path[255])
{
	bool exists = false;
	
	if (FileExists(path))
	{
		exists = true;
	}
	else
	{
		if (FileExists(path, true))
		{
			exists = true;
		}
	}
	
	return exists;
}

stock void CopyMenu(Menu &dest, Menu source)
{
	char title[255];
	source.GetTitle(title, 255);
	dest.SetTitle(title);
	
	int items = GetMenuItemCount(source);
	
	char item[255]; char info[255];
	int style;
	for (int i = 0; i < items; i++)
	{
		GetMenuItem(source, i, info, 255, style, item, 255);
		
		AddMenuItem(dest, info, item, style);
	}
}

/**
  * Creates a model entity and forces an animation on it.
  *
  * @param model		The model to be used.
  * @param animation	Name of the animation sequence to force.
  * @param spawnLoc		The location to spawn the model at.
  * @param spawnAng		The model's starting angles.
  * @param skin			The skin to be used for the model.
  * @param rate			Animation playback rate.
  * @param life		    How long should the model exist for? (0.0 or below = infinite)
  *
  * @return				The entity index of the created model, -1 if invalid.
  */
stock int SpawnDummyModel(char model[255], char animation[255], float spawnLoc[3], float spawnAng[3], char skin[255], float rate = 1.0, float life = 0.0)
{
	int ReturnValue = -1;
	
	ReturnValue = CreateEntityByName("prop_dynamic_override");
	
	if(IsValidEntity(ReturnValue))
	{
		TeleportEntity(ReturnValue, spawnLoc, NULL_VECTOR, NULL_VECTOR);
	
		DispatchKeyValue(ReturnValue, "skin", skin);
		DispatchKeyValue(ReturnValue, "model", model);	
		
		DispatchKeyValueVector(ReturnValue, "angles", spawnAng);
		
		DispatchSpawn(ReturnValue);
		ActivateEntity(ReturnValue);
		
		SetVariantString(animation);
		AcceptEntityInput(ReturnValue, "SetAnimation");
		DispatchKeyValueFloat(ReturnValue, "playbackrate", rate);
		
		if (life > 0.0)
		{
			CreateTimer(life, Timer_RemoveEntity, EntIndexToEntRef(ReturnValue), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else
	{
		ReturnValue = -1;
	}
	
	return ReturnValue;
}

stock void ChangeModelAnimation(int model, char animation[255], float rate)
{
	if (IsValidEntity(model))
	{
		SetVariantString(animation);
		AcceptEntityInput(model, "SetAnimation");
		DispatchKeyValueFloat(model, "playbackrate", rate);
	}
}

stock void ChangeModelSkin(int model, char skin[255])
{
	if (IsValidEntity(model))
	{
		DispatchKeyValue(model, "skin", skin);
	}
}

public Action Timer_RemoveEntity(Handle Timer_RemoveEntity, int entityId)
{
	int entity = EntRefToEntIndex(entityId);
	if (IsValidEntity(entity) && entity > MaxClients)
	{
		TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(entity, "Kill");
		RemoveEntity(entity);
	}
	return Plugin_Continue;
}

//int GAT_User = -1;
stock Handle getAimTrace(int client, bool obstructions = false)
{
	if (!IsValidClient(client))
	{
		return null;
	}
	
	float eyePos[3];
	float eyeAng[3];
	GetClientEyePosition(client, eyePos);
	GetClientEyeAngles(client, eyeAng);
	
	Handle trace;
	
	//GAT_User = client;
	trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer_GAT);
	
	return trace;
}

public bool TraceEntityFilterPlayer_GAT(entity, contentsMask)
{
	return entity > MaxClients;
}

stock void GetAngleToPoint(int ent, float TargetLoc[3], float DummyAngles[3], const float Output[3], float xOff = 0.0, float yOff = 0.0, float zOff = 0.0)
{
	float ang[3], pos[3], fVecFinal[3], fFinalPos[3];

	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	GetEntPropVector(ent, Prop_Send, "m_angRotation", ang);	

	pos[0] += xOff;
	pos[1] += yOff;
	pos[2] += zOff;

	AddInFrontOf(TargetLoc, DummyAngles, 7.0, fVecFinal);
	MakeVectorFromPoints(pos, fVecFinal, fFinalPos);

	GetVectorAngles(fFinalPos, ang);

	Output = ang;
}

stock void AddInFrontOf(float fVecOrigin[3], float fVecAngle[3], float fUnits, float fOutPut[3])
{
	float fVecView[3]; GetViewVector(fVecAngle, fVecView);
	
	fOutPut[0] = fVecView[0] * fUnits + fVecOrigin[0];
	fOutPut[1] = fVecView[1] * fUnits + fVecOrigin[1];
	fOutPut[2] = fVecView[2] * fUnits + fVecOrigin[2];
}

stock void GetViewVector(float fVecAngle[3], float fOutPut[3])
{
	fOutPut[0] = Cosine(fVecAngle[1] / (180 / FLOAT_PI));
	fOutPut[1] = Sine(fVecAngle[1] / (180 / FLOAT_PI));
	fOutPut[2] = -Sine(fVecAngle[0] / (180 / FLOAT_PI));
}

/**
 * Gives an entity an outline.
 *
 * @param iEnt		Entity to outline.
 * @param team		Entity's team.
 
 * @error Invalid entity index.
 
 * @return The entity index of the outline itself.
 */
stock int TF2_CreateGlow(int iEnt, int team)
{
	char oldEntName[64];
	GetEntPropString(iEnt, Prop_Data, "m_iName", oldEntName, sizeof(oldEntName));
	
	char strName[126], strClass[64];
	GetEntityClassname(iEnt, strClass, sizeof(strClass));
	Format(strName, sizeof(strName), "%s%i", strClass, iEnt);
	DispatchKeyValue(iEnt, "targetname", strName);
	
	int ent = CreateEntityByName("tf_glow");
	DispatchKeyValue(ent, "targetname", "RainbowGlow");
	DispatchKeyValue(ent, "target", strName);
	DispatchKeyValue(ent, "Mode", "0");
	DispatchSpawn(ent);
	
	AcceptEntityInput(ent, "Enable");
	
	SetEntPropString(iEnt, Prop_Data, "m_iName", oldEntName);
	
	switch(team)
	{
		case 0:
		SetVariantColor(view_as<int>({200, 200, 200, 255}));
		
		case 1:
		SetVariantColor(view_as<int>({0, 255, 0, 205}));
		
		case 2:
		SetVariantColor(view_as<int>({184, 56, 59, 255}));
		
		default:
		SetVariantColor(view_as<int>({88, 133, 162, 255}));
	}
	AcceptEntityInput(ent, "SetGlowColor");
	
	return ent;
}


stock int AttachWorldTextToEntity(int entity, char message[255], char point[255], float duration = 0.0, float xOff = 0.0, float yOff = 0.0, float zOff = 0.0)
{
	int ReturnValue = -1;
	
	if (IsValidEntity(entity))
	{
		int part1 = CreateEntityByName("point_worldtext");
		if (IsValidEdict(part1))
		{
			ReturnValue = part1;
			
			float pos[3];
			if (HasEntProp(entity, Prop_Data, "m_vecAbsOrigin"))
			{
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
			}
			else if (HasEntProp(entity, Prop_Send, "m_vecOrigin"))
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
			}
			
			pos[0] += xOff;
			pos[1] += yOff;
			pos[2] += zOff;
			
			TeleportEntity(part1, pos, NULL_VECTOR, NULL_VECTOR);
			
			DispatchKeyValue(part1, "message", "Character Preview");
	
			static char sColor[32];
			FormatEx(sColor, sizeof(sColor), "255 255 255 255"); //TODO: make this customizable
			DispatchKeyValue(part1, "color", sColor);
			DispatchSpawn(part1);
			SetEdictFlags(part1, (GetEdictFlags(part1) & ~FL_EDICT_ALWAYS));  
			DispatchKeyValue(part1, "targetname", "parented_text");
			DispatchKeyValue(part1, "orientation", "1");
			DispatchKeyValue(part1, "textsize", "10");
			
			SetVariantString("!activator");
			AcceptEntityInput(part1, "SetParent", entity, part1);
			SetVariantString(point);
			AcceptEntityInput(part1, "SetParentAttachmentMaintainOffset", part1, part1);
			DispatchKeyValue(part1, "targetname", "present");
			DispatchSpawn(part1);
			ActivateEntity(part1);
			AcceptEntityInput(part1, "Start");
			
			if (duration > 0.0)
			{
				CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(part1), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	
	return ReturnValue;
}

stock int AttachModelToEntity(char model[255], char point[255], int parent, float life = 0.0, char skin[255] = "0", float xOff = 0.0, float yOff = 0.0, float zOff = 0.0, float xRot = 0.0, float yRot = 0.0, float zRot = 0.0)
{
	int ReturnValue = -1;
	
	ReturnValue = CreateEntityByName("prop_dynamic_override");
	
	if(IsValidEntity(ReturnValue))
	{
		float pos[3], ang[3];
		if (HasEntProp(parent, Prop_Data, "m_vecAbsOrigin"))
		{
			GetEntPropVector(parent, Prop_Data, "m_vecAbsOrigin", pos);
		}
		else if (HasEntProp(parent, Prop_Send, "m_vecOrigin"))
		{
			GetEntPropVector(parent, Prop_Send, "m_vecOrigin", pos);
		}
		
		TeleportEntity(ReturnValue, pos, NULL_VECTOR, NULL_VECTOR);
	
		DispatchKeyValue(ReturnValue, "skin", skin);
		DispatchKeyValue(ReturnValue, "model", model);	
		
		SetVariantString("!activator");
		AcceptEntityInput(ReturnValue, "SetParent", parent, ReturnValue);
		SetVariantString(point);
		AcceptEntityInput(ReturnValue, "SetParentAttachmentMaintainOffset", ReturnValue, ReturnValue);
		DispatchKeyValue(ReturnValue, "targetname", "present");
		
		DispatchSpawn(ReturnValue);
		ActivateEntity(ReturnValue);
		
		GetEntPropVector(ReturnValue, Prop_Send, "m_vecOrigin", pos);
		
		pos[0] += xOff;
		pos[1] += yOff;
		pos[2] += zOff;
		
		GetEntPropVector(ReturnValue, Prop_Send, "m_angRotation", ang);
		
		ang[0] += xRot;
		ang[1] += yRot;
		ang[2] += zRot;
		
		TeleportEntity(ReturnValue, pos, ang, NULL_VECTOR);
		
		if (life > 0.0)
		{
			CreateTimer(life, Timer_RemoveEntity, EntIndexToEntRef(ReturnValue), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else
	{
		ReturnValue = -1;
	}
	
	return ReturnValue;
}

public void PhysProp_MoveToTargetPosition(int ent, float targPos[3], float angOverride[3])
{
	if (ent < MaxClients + 1 || ent > 2048)
	return;
	
	if (!IsValidEntity(ent))
	return;
	
	float DroneLoc[3], Velocity[3], Angles[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", DroneLoc);
	GetEntPropVector(ent, Prop_Send, "m_angRotation", Angles);
	 
	for (int vel = 0; vel < 3; vel++)
	{
		Velocity[vel] = 0.0;
	}
	
	float TargetSpeed = 900.0;
	
	PhysProp_ChangeSpeed(ent, 20.0, TargetSpeed);
	
	float dist = GetVectorDistance(DroneLoc, targPos);
	
	float fVecFinal[3], fFinalPos[3], DummyAngles[3];
	DummyAngles = Angles;
		
	AddInFrontOf(targPos, DummyAngles, 7.0, fVecFinal);
	MakeVectorFromPoints(DroneLoc, fVecFinal, fFinalPos);
		
	GetVectorAngles(fFinalPos, Angles);
		
	GetAngleVectors(Angles, Velocity, NULL_VECTOR, NULL_VECTOR);
	float mult = (dist/140.0);
	
	if (mult > 1.0)
	{
		mult = 1.0;
	}
		
	float FinalVelScale = PhysProp_CurrentSpeed[ent] * mult;
	ScaleVector(Velocity, FinalVelScale);
		
	TeleportEntity(ent, NULL_VECTOR, angOverride, Velocity);
}

public void PhysProp_ChangeSpeed(int ent, float mod, float maximum)
{
	if (ent < MaxClients + 1 || ent > 2048)
	return;
	
	if (!IsValidEntity(ent))
	return;
	
	if (PhysProp_CurrentSpeed[ent] > maximum)
	{
		PhysProp_CurrentSpeed[ent] += -mod;
	}
	else if (PhysProp_CurrentSpeed[ent] < maximum)
	{
		PhysProp_CurrentSpeed[ent] += mod;
	}
	
	
	if (PhysProp_CurrentSpeed[ent] < 0.0)
	{
		PhysProp_CurrentSpeed[ent] = 0.0;
	}
	
	if (PhysProp_CurrentSpeed[ent] > maximum)
	{
		PhysProp_CurrentSpeed[ent] = maximum;
	}
}

public void PhysProp_MoveToTargetPosition_Preview(int ent, int client, float angOverride[3], float maxDistance)
{
	if (ent < MaxClients + 1 || ent > 2048)
	return;
	
	if (!IsValidEntity(ent) || !IsValidClient(client))
	return;
	
	float vecView[3], vecFwd[3], vecPos[3], vecVel[3];
	GetClientEyeAngles(client, vecView);
	GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
	GetClientEyePosition(client, vecPos);
	vecPos[0]+=vecFwd[0] * 140.0;
	vecPos[1]+=vecFwd[1] * 140.0;
	vecPos[2]+=vecFwd[2] * 140.0;
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vecFwd);
	
	if (GetVectorDistance(vecFwd, vecPos) > maxDistance && maxDistance > 0.0)
	{
		TeleportEntity(ent, vecPos, angOverride, NULL_VECTOR);
	}
	else
	{
		SubtractVectors(vecPos, vecFwd, vecVel);
		ScaleVector(vecVel, 5.0);
		TeleportEntity(ent, NULL_VECTOR, angOverride, vecVel);
	}
}

stock int SpawnParticle(float origin[3], char particle[255], float duration = 0.0)
{
	int Effect = CreateEntityByName("info_particle_system");
	if (IsValidEdict(Effect))
	{
		TeleportEntity(Effect, origin, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(Effect, "effect_name", particle);
		SetVariantString("!activator");
		DispatchKeyValue(Effect, "targetname", "present");
		DispatchSpawn(Effect);
		ActivateEntity(Effect);
		AcceptEntityInput(Effect, "Start");
		
		if (duration > 0.0)
		{
			CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(Effect), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		return Effect;
	}
	
	return -1;
}

stock int GetIntFromConfigMap(ConfigMap map, char[] path, int defaultValue)
{
	char value[255];
	map.Get(path, value, sizeof(value));
	
	if (StrEqual(value, ""))
	{
		return defaultValue;
	}
	
	return StringToInt(value);
}

stock float GetFloatFromConfigMap(ConfigMap map, char[] path, float defaultValue)
{
	char value[255];
	map.Get(path, value, sizeof(value));
	
	if (StrEqual(value, ""))
	{
		return defaultValue;
	}
	
	return StringToFloat(value);
}

stock bool GetBoolFromConfigMap(ConfigMap map, char[] path, bool defaultValue)
{
	char value[255];
	map.Get(path, value, sizeof(value));
	
	if (StrEqual(value, ""))
	{
		return defaultValue;
	}
	
	return (StringToInt(value) != 0);
}

/**
 * Attaches a particle to an entity, and returns the entity index of the particle.
 *
 * @param entity      Entity index to attach the particle to.
 * @param type			Name of the particle to attach.
 * @param point 	The attachment point to attach the particle to.
 * @param duration	Optional particle lifespan. 0.0 or below: infinite.
 * @param xOff		Optional X-axis offset, in hammer units.
 * @param yOff		Optional Y-axis offset, in hammer units.
 * @param zOff		Optional Z-axis offset, in hammer units.
 *
 * @return			The entity index of the particle attached via this method.
 *
 * @error               Invalid entity index.
 */
stock int AttachParticleToEntity(int entity, char type[255], char point[255], float duration = 0.0, float xOff = 0.0, float yOff = 0.0, float zOff = 0.0)
{
	int ReturnValue = -1;
	
	if (IsValidEntity(entity))
	{
		int part1 = CreateEntityByName("info_particle_system");
		if (IsValidEdict(part1))
		{
			ReturnValue = part1;
			
			float pos[3];
			if (HasEntProp(entity, Prop_Data, "m_vecAbsOrigin"))
			{
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
			}
			else if (HasEntProp(entity, Prop_Send, "m_vecOrigin"))
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
			}
			
			pos[0] += xOff;
			pos[1] += yOff;
			pos[2] += zOff;
			
			TeleportEntity(part1, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(part1, "effect_name", type);
			SetVariantString("!activator");
			AcceptEntityInput(part1, "SetParent", entity, part1);
			SetVariantString(point);
			AcceptEntityInput(part1, "SetParentAttachmentMaintainOffset", part1, part1);
			DispatchKeyValue(part1, "targetname", "present");
			DispatchSpawn(part1);
			ActivateEntity(part1);
			AcceptEntityInput(part1, "Start");
			
			if (duration > 0.0)
			{
				CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(part1), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	
	return ReturnValue;
}

/**
 * Checks if a client is invisible. This includes the following checks:
 * The client's model is models/empty.mdl.
 * They have 0 alpha in their render color.
 * Their render mode is RENDER_NONE.
 * They are under one of the following TF2 conditions: TFCond_Cloaked, TFCond_Stealthed, or TFCond_StealthedUserBuffFade.
 *
 * @param client		The client to check.
 *
 * @return			True if the client is "invisible" by these tests, false otherwise.
 */
stock bool IsPlayerInvis(int client)
{
	if (!IsValidClient(client))
		return false;
		
	//Check for empty model:
	char model[255];
	GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
	
	if (StrContains(model, "empty.mdl") != -1)
		return true;
		
	//Check for zero alpha:
	int r, g, b, a;
	GetEntityRenderColor(client, r, g, b, a);
	if (a == 0)
		return true;
	
	//Check for RENDERFX_NONE and TF2's invisibility conditions:
	return GetEntityRenderMode(client) == RENDER_NONE || TF2_IsPlayerInCondition(client, TFCond_Cloaked) || TF2_IsPlayerInCondition(client, TFCond_Stealthed) || TF2_IsPlayerInCondition(client, TFCond_StealthedUserBuffFade);
}

/**
 * Borrowed from PC Gamer on AlliedMods and then *slightly* modified for Chaos Fortress. Credit goes to the original author.
 * Creates a wearable, given a set of inputs.
 *
 * @param client		The client to give the wearable to.
 * @param itemindex		The wearable's index.
 * @param atts			The wearable's item attributes.
 * @param paint			The wearable's paint, 1-29.
 * @param style			Optional style override parameter for cosmetic wearables.
 * @param visible		True for the wearable to be visible, false to hide it.
 * @param lifespan		Optional lifespan for the wearable, 0.0 or below for infinite.
 * @param item			Use tf_wearable_item instead.
 *
 * @return			The wearable's item index.
 */
stock int CreateWearable(int client, int itemindex, char atts[255] = "", int paint = 0, int style = 0, bool visible = true, float lifespan = 0.0, bool item = false)
{
	int hat = CreateEntityByName(item ? "tf_wearable_item" : "tf_wearable");
	
	if (!IsValidEntity(hat))
	{
		return -1;
	}
	
	char entclass[64];
	GetEntityNetClass(hat, entclass, sizeof(entclass));
	SetEntData(hat, FindSendPropInfo(entclass, "m_iItemDefinitionIndex"), itemindex);
	SetEntData(hat, FindSendPropInfo(entclass, "m_bInitialized"), 1); 	
	SetEntData(hat, FindSendPropInfo(entclass, "m_iEntityLevel"), 77);
	SetEntData(hat, FindSendPropInfo(entclass, "m_iEntityQuality"), 7);
	SetEntProp(hat, Prop_Send, "m_bValidatedAttachedEntity", 1);
	
	if (paint > 0 && visible)
	{
		switch(paint)
		{
		case 1:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 3100495.0); //A color similar to slate
				TF2Attrib_SetByDefIndex(hat, 261, 3100495.0);
			}
		case 2:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 8208497.0); //A deep commitment to purple
				TF2Attrib_SetByDefIndex(hat, 261, 8208497.0);
			}
		case 3:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 1315860.0); //A distinctive lack of hue
				TF2Attrib_SetByDefIndex(hat, 261, 1315860.0);
			}
		case 4:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 12377523.0); //A mann's mint
				TF2Attrib_SetByDefIndex(hat, 261, 12377523.0);
			}
		case 5:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 2960676.0); //After eight
				TF2Attrib_SetByDefIndex(hat, 261, 2960676.0);
			}
		case 6:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 8289918.0); //Aged Moustache Grey
				TF2Attrib_SetByDefIndex(hat, 261, 8289918.0);
			}
		case 7:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 15132390.0); //An Extraordinary abundance of tinge
				TF2Attrib_SetByDefIndex(hat, 261, 15132390.0);
			}
		case 8:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 15185211.0); //Australium gold
				TF2Attrib_SetByDefIndex(hat, 261, 15185211.0);
			}
		case 9:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 14204632.0); //Color no 216-190-216
				TF2Attrib_SetByDefIndex(hat, 261, 14204632.0);
			}
		case 10:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 15308410.0); //Dark salmon injustice
				TF2Attrib_SetByDefIndex(hat, 261, 15308410.0);
			}
		case 11:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 8421376.0); //Drably olive
				TF2Attrib_SetByDefIndex(hat, 261, 8421376.0);
			}
		case 12:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 7511618.0); //Indubitably green
				TF2Attrib_SetByDefIndex(hat, 261, 7511618.0);
			}
		case 13:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 13595446.0); //Mann co orange
				TF2Attrib_SetByDefIndex(hat, 261, 13595446.0);
			}
		case 14:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 10843461.0); //Muskelmannbraun
				TF2Attrib_SetByDefIndex(hat, 261, 10843461.0);
			}
		case 15:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 5322826.0); //Noble hatters violet
				TF2Attrib_SetByDefIndex(hat, 261, 5322826.0);
			}
		case 16:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 12955537.0); //Peculiarly drab tincture
				TF2Attrib_SetByDefIndex(hat, 261, 12955537.0);
			}
		case 17:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 16738740.0); //Pink as hell
				TF2Attrib_SetByDefIndex(hat, 261, 16738740.0);
			}
		case 18:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 6901050.0); //Radigan conagher brown
				TF2Attrib_SetByDefIndex(hat, 261, 6901050.0);
			}
		case 19:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 3329330.0); //A bitter taste of defeat and lime
				TF2Attrib_SetByDefIndex(hat, 261, 3329330.0);
			}
		case 20:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 15787660.0); //The color of a gentlemanns business pants
				TF2Attrib_SetByDefIndex(hat, 261, 15787660.0);
			}
		case 21:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 8154199.0); //Ye olde rustic colour
				TF2Attrib_SetByDefIndex(hat, 261, 8154199.0);
			}
		case 22:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 4345659.0); //Zepheniahs greed
				TF2Attrib_SetByDefIndex(hat, 261, 4345659.0);
			}
		case 23:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 6637376.0); //An air of debonair
				TF2Attrib_SetByDefIndex(hat, 261, 2636109.0);
			}
		case 24:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 3874595.0); //Balaclavas are forever
				TF2Attrib_SetByDefIndex(hat, 261, 1581885.0);
			}
		case 25:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 12807213.0); //Cream spirit
				TF2Attrib_SetByDefIndex(hat, 261, 12091445.0);
			}
		case 26:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 4732984.0); //Operators overalls
				TF2Attrib_SetByDefIndex(hat, 261, 3686984.0);
			}
		case 27:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 12073019.0); //Team spirit
				TF2Attrib_SetByDefIndex(hat, 261, 5801378.0);
			}
		case 28:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 8400928.0); //The value of teamwork
				TF2Attrib_SetByDefIndex(hat, 261, 2452877.0);
			}
		case 29:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 11049612.0); //Waterlogged lab coat
				TF2Attrib_SetByDefIndex(hat, 261, 8626083.0);
			}
		}
	}
	
	char attribs[32][32];
	int count = ExplodeString(atts, ";", attribs, 32, 32);

	if(count % 2)
		--count;
		
	for(int i; i < count; i += 2)
	{
		int attrib = StringToInt(attribs[i]);
		if(attrib)
		{
			TF2Attrib_SetByDefIndex(hat, attrib, StringToFloat(attribs[i + 1]));
		}
	}
	
	if (style > 0)
	{
		TF2Attrib_SetByDefIndex(hat, 542, float(style));
	}
	
	DispatchSpawn(hat);
	
	if (!visible)
	{
		SetEntityRenderMode(hat, RENDER_NONE);
		DispatchKeyValue(hat, "modelscale", "0.00001");
	}
	
	if (lifespan > 0.0)
	{
		CreateTimer(lifespan, Timer_RemoveEntity, EntIndexToEntRef(hat), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	return hat;
} 

bool SpookPack_Casting[MAXPLAYERS+1] = {false, ...};

stock void SpookPack_CastEffect(int client)
{
	if (!IsValidMulti(client, true, true, false))
		return;
		
	TF2_RemoveWeaponSlot(client, 5);
	int spellbook = CF_SpawnWeapon(client, "tf_weapon_spellbook", 1070, 100, 5, 5, 0, 0, "178 ; 0.0");
	SpookPack_Casting[client] = true;
	FakeClientCommand(client, "use tf_weapon_spellbook");
			
	SetEntProp(spellbook, Prop_Send, "m_iSpellCharges", 1);
	SetEntProp(spellbook, Prop_Send, "m_iSelectedSpellIndex", 0);	
	CreateTimer(0.3, delete_spellbook, client, TIMER_FLAG_NO_MAPCHANGE);
}

public void SpookPack_OnEntityCreated(int entity, const char[] classname)
{
	if (StrContains(classname, "fireball") != -1)
	{
		SDKHook(entity, SDKHook_SpawnPost, DeleteFireball);
	}
}

public Action DeleteFireball(int ent)
{
	if (!IsValidEdict(ent))
		return Plugin_Continue;
		
	int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if (SpookPack_Casting[owner])
	{
		TeleportEntity(ent, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(ent, "Kill");
		RemoveEntity(ent);
		SpookPack_Casting[owner] = false;
	}
	
	return Plugin_Continue;
}

public Action delete_spellbook(Handle Fusion_delete_spellbook_handle, int client)
{
	if (IsValidClient(client))
	{
		int melee = GetPlayerWeaponSlot(client, 2);
		if (IsValidEdict(melee))
		{
			char weapon[255], command[255];
			GetEntityClassname(melee, weapon, 255);
			Format(command, sizeof(command), "use %s", weapon);
			FakeClientCommand(client, command);
			TF2_RemoveWeaponSlot(client, 5);
		}
	}	
	
	return Plugin_Continue;
}

stock void ForceViewmodelAnimation(int client, int sequence)
{
    int ent = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
    if (!IsValidEdict(ent)) 
    	return;
    
    SetEntProp(ent, Prop_Send, "m_nSequence", sequence);
}

stock void HidePlayerWeapon(int client, float duration)
{
	int ent = TF2_GetActiveWeapon(client);
	if (!IsValidEdict(ent))
		return;
		
	SetEntProp(ent, Prop_Send, "m_bBeingRepurposedForTaunt", 1);
	SetEntityRenderMode(ent, RENDER_TRANSALPHA);
	SetEntityRenderColor(ent, 0, 0, 0, 0);
	if (duration > 0.0)
	{
		CreateTimer(duration, UnhideWeapon, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);
	}
} 

public Action UnhideWeapon(Handle unhide, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEdict(ent))
	{
		SetEntProp(ent, Prop_Send, "m_bBeingRepurposedForTaunt", 0);
		SetEntityRenderMode(ent, RENDER_TRANSALPHA);
		SetEntityRenderColor(ent, 255, 255, 255, 255);
	}
	
	return Plugin_Continue;
}

stock int TF2_GetActiveWeapon(int client)
{
	return GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
}

stock void StringToLower(char input[255])
{
	for (int i = 0; i < sizeof(input); i++)
	{
		input[i] = CharToLower(input[i]);
	}
}