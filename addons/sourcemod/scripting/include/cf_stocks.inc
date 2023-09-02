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
		
		//TODO: Make these have no collision
		
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

void GetAngleToPoint(int ent, float TargetLoc[3], float DummyAngles[3], const float Output[3], float xOff = 0.0, float yOff = 0.0, float zOff = 0.0)
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