#define NPC_NAME	"cf_base_npc"

#define VFX_AFTERBURN_RED		"burningplayer_red"
#define VFX_AFTERBURN_BLUE		"burningplayer_blue"
#define VFX_AFTERBURN_HAUNTED	"halloween_burningplayer_flyingbits"
#define VFX_DEFAULT_BLEED		"blood_impact_red_01_goop"
#define VFX_MILK				"peejar_drips_milk"
#define VFX_JARATE				"peejar_drips"
#define VFX_GAS_RED				"gas_can_drips_red"
#define VFX_GAS_BLUE			"gas_can_drips_blue"

#define PARTICLE_JAR_EXPLODE_MILK		"peejar_impact_milk"
#define PARTICLE_JAR_EXPLODE_JARATE		"peejar_impact"
#define PARTICLE_JAR_EXPLODE_GAS_RED	"gas_can_impact_red"
#define PARTICLE_JAR_EXPLODE_GAS_BLUE	"gas_can_impact_blue"

#define SND_SANDMAN_HIT			")player/pl_impact_stun.wav"
#define SND_CLEAVER_HIT			")weapons/cleaver_hit_03.wav"
#define SND_JAR_EXPLODE			")weapons/jar_explode.wav"
#define SND_GAS_EXPLODE			")weapons/gas_can_explode.wav"

static float DEFAULT_MINS[3] = { -24.0, -24.0, 0.0 };
static float DEFAULT_MAXS[3] = { 24.0, 24.0, 82.0 };

Function CFNPC_Logic[2049] = { INVALID_FUNCTION, ... };
Handle CFNPC_LogicPlugin[2049] = { null, ... };

int i_TotalNPCs[2049] = { -1, ... };
int i_AfterburnAttacker[2049] = { -1, ... };
int i_BleedStacks[2049] = { 0, ... };

float CFNPC_Speed[2049] = { 0.0, ... };
float CFNPC_ThinkRate[2049] = { 0.0, ... };
float CFNPC_NextThinkTime[2049] = { 0.0, ... };
float CFNPC_EndTime[2049] = { 0.0, ... };
float f_AfterburnEndTime[2049] = { 0.0, ... };
float f_AfterburnDMG[2049] = { 0.0, ... };
float f_NextBurn[2049] = { 0.0, ... };
float f_NextFlinch[2049] = { 0.0, ... };
float f_PunchForce[2049][3];

bool IExist[2049] = { false, ... };
bool ForcedToGib[2049] = { false, ... };
bool b_AfterburnHaunted[2049] = { false, ... };
bool b_MiniCrit[2049] = { false, ... };
bool I_AM_DEAD[2049] = { false, ... };

char CFNPC_Model[2049][255];
char CFNPC_BleedParticle[2049][255];
char CFNPC_FlinchSequence[2049][255];

GlobalForward g_OnCFNPCCreated;
GlobalForward g_OnCFNPCDestroyed;
GlobalForward g_OnCFNPCHeadshot;
GlobalForward g_OnCFNPCDamaged;
GlobalForward g_OnCFNPCKilled;
GlobalForward g_OnCFNPCExtinguished;
GlobalForward g_OnCFNPCIgnited;
GlobalForward g_OnCFNPCBleed;

Handle g_hLookupActivity;
Handle SDK_Ragdoll;

PathFollower g_PathFollowers[2049];

ArrayList g_Gibs[2049];
ArrayList g_GibAttachments[2049];
ArrayList g_AttachedModels[2049];
ArrayList g_AttachedWeaponModels[2049];

enum //hitgroup_t
{
	HITGROUP_GENERIC,
	HITGROUP_HEAD,
	HITGROUP_CHEST,
	HITGROUP_STOMACH,
	HITGROUP_LEFTARM,
	HITGROUP_RIGHTARM,
	HITGROUP_LEFTLEG,
	HITGROUP_RIGHTLEG,
	
	NUM_HITGROUPS
};

void CFNPC_MapStart()
{
	for (int i = MaxClients + 1; i < 2049; i++)
		g_PathFollowers[i] = PathFollower(CFNPC_PathCost, Path_FilterIgnoreActors, Path_FilterOnlyActors);

	PrecacheParticleEffect(VFX_AFTERBURN_RED);
	PrecacheParticleEffect(VFX_AFTERBURN_BLUE);
	PrecacheParticleEffect(VFX_AFTERBURN_HAUNTED);
	PrecacheParticleEffect(VFX_DEFAULT_BLEED);

	PrecacheEffect("ParticleEffect");
	PrecacheEffect("ParticleEffectStop");

	PrecacheSound(SND_SANDMAN_HIT);
	PrecacheSound(SND_CLEAVER_HIT);
	PrecacheSound(SND_JAR_EXPLODE);
	PrecacheSound(SND_GAS_EXPLODE);
}

void CFNPC_MapEnd()
{
	for (int i = MaxClients + 1; i < 2049; i++)
	{
		if (g_PathFollowers[i].IsValid())
			g_PathFollowers[i].Destroy();

		delete g_Gibs[i];
		delete g_GibAttachments[i];
		delete g_AttachedModels[i];
		delete g_AttachedWeaponModels[i];
	}
}

public float CFNPC_PathCost(INextBot bot, CNavArea area, CNavArea from_area, CNavLadder ladder, int iElevator, float length)
{
	float dist;
	if (length != 0.0) 
	{
		dist = length;
	}
	else 
	{
		float vecCenter[3], vecFromCenter[3];
		area.GetCenter(vecCenter);
		from_area.GetCenter(vecFromCenter);
		
		float vecSubtracted[3];
		SubtractVectors(vecCenter, vecFromCenter, vecSubtracted);
		
		dist = GetVectorLength(vecSubtracted);
	}
	
	float cost = dist * ((1.0 + (GetRandomFloat(0.0, 1.0)) + 1.0) * 25.0);
	
	return from_area.GetCostSoFar() + cost;
}

void CFNPC_MakeForwards()
{
	g_OnCFNPCCreated = new GlobalForward("CF_OnCFNPCCreated", ET_Ignore, Param_Cell);
	g_OnCFNPCDestroyed = new GlobalForward("CF_OnCFNPCDestroyed", ET_Ignore, Param_Cell);
	g_OnCFNPCHeadshot = new GlobalForward("CF_OnCFNPCHeadshot", ET_Event, Param_Any, Param_Cell, Param_Cell, Param_Cell, Param_FloatByRef, Param_CellByRef);
	g_OnCFNPCDamaged = new GlobalForward("CF_OnCFNPCTakeDamage", ET_Event, Param_Any, Param_FloatByRef, Param_Cell, Param_Cell, Param_Cell, Param_CellByRef, Param_CellByRef);
	g_OnCFNPCKilled = new GlobalForward("CF_OnCFNPCKilled", ET_Event, Param_Any, Param_Float, Param_Cell, Param_Cell, Param_Cell, Param_CellByRef);
	g_OnCFNPCExtinguished = new GlobalForward("CF_OnCFNPCExtinguished", ET_Single, Param_Any);
	g_OnCFNPCIgnited = new GlobalForward("CF_OnCFNPCIgnited", ET_Event, Param_Any, Param_FloatByRef, Param_FloatByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_FloatByRef);
	g_OnCFNPCBleed = new GlobalForward("CF_OnCFNPCBleed", ET_Event, Param_Any, Param_FloatByRef, Param_FloatByRef, Param_CellByRef);

	/*NextBotActionFactory AcFac = new NextBotActionFactory("CFNPCMainAction");
	AcFac.SetEventCallback(EventResponderType_OnActorEmoted, PluginBot_OnActorEmoted);*/

	CEntityFactory CFNPC_Factory = new CEntityFactory(NPC_NAME, CFNPC_OnCreate, CFNPC_OnDestroy);
	CFNPC_Factory.DeriveFromNPC();
	//CFNPC_Factory.SetInitialActionFactory(AcFac);
	CFNPC_Factory.BeginDataMapDesc().DefineIntField("cf_pPath").EndDataMapDesc();
	CFNPC_Factory.Install();

	GameData gd = LoadGameConfigFile("chaos_fortress");

	//LookupActivity:
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "LookupActivity");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//pStudioHdr
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);		//label
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);	//return index
	if((g_hLookupActivity = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for LookupActivity.");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gd, SDKConf_Virtual, "CBaseAnimating::BecomeRagdollOnClient");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	SDK_Ragdoll = EndPrepSDKCall();
	if(!SDK_Ragdoll)
		LogError("[Gamedata] Could not find CBaseAnimating::BecomeRagdollOnClient");

	delete gd;
}

void CFNPC_MakeNatives()
{
	//Constructors:
	CreateNative("CFNPC.CFNPC", Native_CFNPCConstructor);

	//Index:
	CreateNative("CFNPC.Index.get", Native_CFNPCGetIndex);

	//Logic and LogicPlugin:
	CreateNative("CFNPC.g_Logic.set", Native_CFNPCSetLogic);
	CreateNative("CFNPC.g_LogicPlugin.get", Native_CFNPCGetLogicPlugin);
	CreateNative("CFNPC.g_LogicPlugin.set", Native_CFNPCSetLogicPlugin);

	//Team:
	CreateNative("CFNPC.i_Team.set", Native_CFNPCSetTeam);
	CreateNative("CFNPC.i_Team.get", Native_CFNPCGetTeam);

	//Skin:
	CreateNative("CFNPC.i_Skin.set", Native_CFNPCSetSkin);
	CreateNative("CFNPC.i_Skin.get", Native_CFNPCGetSkin);

	//Scale:
	CreateNative("CFNPC.f_Scale.set", Native_CFNPCSetScale);
	CreateNative("CFNPC.f_Scale.get", Native_CFNPCGetScale);
	CreateNative("CFNPC.SetBoundingBox", Native_CFNPCSetBoundingBox);

	//Speed:
	CreateNative("CFNPC.f_Speed.set", Native_CFNPCSetSpeed);
	CreateNative("CFNPC.f_Speed.get", Native_CFNPCGetSpeed);
	CreateNative("CFNPC.f_MaxSpeed.set", Native_CFNPCSetMaxSpeed);
	CreateNative("CFNPC.f_MaxSpeed.get", Native_CFNPCGetMaxSpeed);

	//Think Rate and Next Think Time:
	CreateNative("CFNPC.f_ThinkRate.set", Native_CFNPCSetThinkRate);
	CreateNative("CFNPC.f_ThinkRate.get", Native_CFNPCGetThinkRate);
	CreateNative("CFNPC.f_NextThinkTime.set", Native_CFNPCSetNextThinkTime);
	CreateNative("CFNPC.f_NextThinkTime.get", Native_CFNPCGetNextThinkTime);

	//End Time:
	CreateNative("CFNPC.f_EndTime.set", Native_CFNPCSetEndTime);
	CreateNative("CFNPC.f_EndTime.get", Native_CFNPCGetEndTime);

	//Model:
	CreateNative("CFNPC.SetModel", Native_CFNPCSetModel);
	CreateNative("CFNPC.GetModel", Native_CFNPCGetModel);

	//Health and Max Health:
	CreateNative("CFNPC.i_Health.set", Native_CFNPCSetHealth);
	CreateNative("CFNPC.i_Health.get", Native_CFNPCGetHealth);
	CreateNative("CFNPC.i_MaxHealth.set", Native_CFNPCSetMaxHealth);
	CreateNative("CFNPC.i_MaxHealth.get", Native_CFNPCGetMaxHealth);

	//Exists:
	CreateNative("CFNPC.b_Exists.set", Native_CFNPCSetExists);
	CreateNative("CFNPC.b_Exists.get", Native_CFNPCGetExists);

	//Locomotion:
	CreateNative("CFNPC.GetLocomotion", Native_CFNPCGetLocomotion);
	CreateNative("CFNPC.GetGroundMotionVector", Native_CFNPCGetGroundMotionVector);

	//CBaseNPC:
	CreateNative("CFNPC.GetBaseNPC", Native_CFNPCGetBaseNPC);

	//INextBot:
	CreateNative("CFNPC.GetBot", Native_CFNPCGetBot);

	//Sequences, Activities, Pose Parameters, and Gestures:
	CreateNative("CFNPC.SetSequence", Native_CFNPCSetSequence);
	CreateNative("CFNPC.LookupActivity", Native_CFNPCLookupActivity);
	CreateNative("CFNPC.SetActivity", Native_CFNPCSetActivity);
	CreateNative("CFNPC.SetCycle", Native_CFNPCSetCycle);
	CreateNative("CFNPC.SetPlaybackRate", Native_CFNPCSetPlaybackRate);
	CreateNative("CFNPC.AddGesture", Native_CFNPCAddGesture);
	CreateNative("CFNPC.RemoveGesture", Native_CFNPCRemoveGesture);
	CreateNative("CFNPC.i_PoseMoveX.get", Native_CFNPCGetPoseMoveX);
	CreateNative("CFNPC.i_PoseMoveY.get", Native_CFNPCGetPoseMoveY);

	//Pathing and Movement:
	CreateNative("CFNPC.GetPathFollower", Native_CFNPCGetPathFollower);
	CreateNative("CFNPC.StartPathing", Native_CFNPCStartPathing);
	CreateNative("CFNPC.StopPathing", Native_CFNPCStopPathing);
	CreateNative("CFNPC.SetGoalVector", Native_CFNPCSetGoalVector);
	CreateNative("CFNPC.GetGroundSpeed", Native_CFNPCGetGroundSpeed);
	CreateNative("CFNPC.ApplyTemporarySpeedChange", Native_CFNPCModifySpeed);

	//CBaseNPC Base Values:
	CreateNative("CFNPC.f_YawRate.get", Native_CFNPCGetYawRate);
	CreateNative("CFNPC.f_YawRate.set", Native_CFNPCSetYawRate);
	CreateNative("CFNPC.f_StepSize.get", Native_CFNPCGetStepSize);
	CreateNative("CFNPC.f_StepSize.set", Native_CFNPCSetStepSize);
	CreateNative("CFNPC.f_Gravity.get", Native_CFNPCGetGravity);
	CreateNative("CFNPC.f_Gravity.set", Native_CFNPCSetGravity);
	CreateNative("CFNPC.f_Acceleration.get", Native_CFNPCGetAcceleration);
	CreateNative("CFNPC.f_Acceleration.set", Native_CFNPCSetAcceleration);
	CreateNative("CFNPC.f_JumpHeight.get", Native_CFNPCGetJumpHeight);
	CreateNative("CFNPC.f_JumpHeight.set", Native_CFNPCSetJumpHeight);
	CreateNative("CFNPC.f_FrictionSideways.get", Native_CFNPCGetFrictionSideways);
	CreateNative("CFNPC.f_FrictionSideways.set", Native_CFNPCSetFrictionSideways);
	CreateNative("CFNPC.f_FrictionForwards.get", Native_CFNPCGetFrictionForwards);
	CreateNative("CFNPC.f_FrictionForwards.set", Native_CFNPCSetFrictionForwards);
	CreateNative("CFNPC.f_DeathDropHeight.get", Native_CFNPCGetDeathDropHeight);
	CreateNative("CFNPC.f_DeathDropHeight.set", Native_CFNPCSetDeathDropHeight);

	//Gibs and Ragdolls:
	CreateNative("CFNPC.Ragdoll", Native_CFNPCRagdoll);
	CreateNative("CFNPC.PunchForce", Native_CFNPCPunchForce);
	CreateNative("CFNPC.Gib", Native_CFNPCGib);
	CreateNative("CFNPC.AddGib", Native_CFNPCAddGib);
	CreateNative("CFNPC.b_GibsForced.get", Native_CFNPCGetForcedGib);
	CreateNative("CFNPC.b_GibsForced.set", Native_CFNPCSetForcedGib);

	//Damage VFX:
	CreateNative("CFNPC.SetBleedParticle", Native_CFNPCSetBleedEffect);
	CreateNative("CFNPC.GetBleedParticle", Native_CFNPCGetBleedEffect);
	CreateNative("CFNPC.SetFlinchSequence", Native_CFNPCSetFlinchSequence);
	CreateNative("CFNPC.GetFlinchSequence", Native_CFNPCGetFlinchSequence);
	CreateNative("CFNPC.SetDamagedVFX", Native_CFNPCSetDamageVFX);

	//Attachments:
	CreateNative("CFNPC.AttachModel", Native_CFNPCAttachModel);
	CreateNative("CFNPC.g_AttachedCosmetics.get", Native_CFNPCGetAttachedCosmetics);
	CreateNative("CFNPC.g_AttachedCosmetics.set", Native_CFNPCSetAttachedCosmetics);
	CreateNative("CFNPC.g_AttachedWeapons.get", Native_CFNPCGetAttachedWeapons);
	CreateNative("CFNPC.g_AttachedWeapons.set", Native_CFNPCSetAttachedWeapons);
	CreateNative("CFNPC.RemoveAttachments", Native_CFNPCRemoveAttachments);

	//Afterburn:
	CreateNative("CFNPC.b_Burning.get", Native_CFNPCGetBurning);
	CreateNative("CFNPC.f_AfterburnEndTime.get", Native_CFNPCGetAfterburnEndTime);
	CreateNative("CFNPC.f_AfterburnEndTime.set", Native_CFNPCSetAfterburnEndTime);
	CreateNative("CFNPC.f_AfterburnDMG.get", Native_CFNPCGetAfterburnDMG);
	CreateNative("CFNPC.f_AfterburnDMG.set", Native_CFNPCSetAfterburnDMG);
	CreateNative("CFNPC.i_AfterburnAttacker.get", Native_CFNPCGetAfterburnAttacker);
	CreateNative("CFNPC.i_AfterburnAttacker.set", Native_CFNPCSetAfterburnAttacker);
	CreateNative("CFNPC.b_AfterburnIsHaunted.get", Native_CFNPCGetAfterburnHaunted);
	CreateNative("CFNPC.b_AfterburnIsHaunted.set", Native_CFNPCSetAfterburnHaunted);
	CreateNative("CFNPC.Ignite", Native_CFNPCIgnite);
	CreateNative("CFNPC.Extinguish", Native_CFNPCExtinguish);

	//Bleed:
	CreateNative("CFNPC.Bleed", Native_CFNPCBleed);
	CreateNative("CFNPC.b_Bleeding.get", Native_CFNPCGetBleeding);

	//Global (not specific to the CFNPC methodmap) Natives:
	CreateNative("CFNPC_Explosion", Native_CFNPCExplosion);
	CreateNative("CFNPC_IsNPC", Native_CFNPCIsThisAnNPC);
}

public void CFNPC_OnEntityCreated(int entity, const char[] classname)
{
	//All projectiles that have any sort of explosion (not including wrap assassin) need to have custom explosion logic so that they work seamlessly with NPCs:
	if (StrContains(classname, "tf_projectile_jar") != -1)
	{
		SDKHook(entity, SDKHook_TouchPost, CFNPC_JarTouch);
	}
}

void CFNPC_OnCreate(int npc)
{
	CFNPC alive = view_as<CFNPC>(npc);

	for (int i = MaxClients + 1; i < 2049; i++)
	{
		int entity = EntRefToEntIndex(i_TotalNPCs[i]);
		if (!IsValidEntity(entity))
		{
			alive.SetProp(Prop_Data, "cf_pPath", view_as<int>(g_PathFollowers[i]));
			i_TotalNPCs[i] = EntIndexToEntRef(alive.Index);
			break;
		}
	}

	Call_StartForward(g_OnCFNPCCreated);
	Call_PushCell(npc);
	Call_Finish();

	alive.b_Exists = true;
	I_AM_DEAD[npc] = false;
}

void CFNPC_OnDestroy(int npc)
{
	Call_StartForward(g_OnCFNPCDestroyed);
	Call_PushCell(npc);
	Call_Finish();

	SDKUnhook(npc, SDKHook_OnTakeDamagePost, CFNPC_PostDamage);
	SDKUnhook(npc, SDKHook_OnTakeDamage, CFNPC_OnDamage);
	SDKUnhook(npc, SDKHook_ThinkPost, CFNPC_ThinkPost);
	SDKUnhook(npc, SDKHook_Think, CFNPC_Think);
	SDKUnhook(npc, SDKHook_TraceAttack, CFNPC_TraceAttack);
	SDKUnhook(npc, SDKHook_Touch, CFNPC_Touch);

	CFNPC dead = view_as<CFNPC>(npc);
	if(dead.GetPathFollower().IsValid())
	{
		dead.GetPathFollower().Invalidate(); //Remove its current path
	}
	dead.SetProp(Prop_Data, "cf_pPath", -1);

	CFNPC_RemoveFromPaths(dead);

	delete g_Gibs[npc];
	delete g_GibAttachments[npc];
	delete g_AttachedModels[npc];
	delete g_AttachedWeaponModels[npc];
	i_BleedStacks[npc] = 0;

	dead.b_Exists = false;
	I_AM_DEAD[npc] = true;
}

void CFNPC_RemoveFromPaths(CFNPC npc)
{
	for (int i = MaxClients + 1; i < 2049; i++)
	{
		int entity = EntRefToEntIndex(i_TotalNPCs[i]);
		if (entity == npc.Index)
		{
			npc.SetProp(Prop_Data, "cf_pPath", 0);
			i_TotalNPCs[i] = -1;
			break;
		}
	}
}

public int Native_CFNPCConstructor(Handle plugin, int numParams)
{
	char model[255], logicPlugin[255];
	float pos[3], ang[3];

	GetNativeString(1, model, sizeof(model));
	TFTeam team = GetNativeCell(2);
	int health = GetNativeCell(3);
	int maxHealth = GetNativeCell(4);
	int skin = GetNativeCell(5);
	float scale = GetNativeCell(6);
	float speed = GetNativeCell(7);
	Function logic = GetNativeFunction(8);
	GetNativeString(9, logicPlugin, sizeof(logicPlugin));
	float thinkRate = GetNativeCell(10);
	GetNativeArray(11, pos, sizeof(pos));
	GetNativeArray(12, ang, sizeof(ang));
	float lifespan = GetNativeCell(13);

	int ent = CreateEntityByName(NPC_NAME);
	if (IsValidEntity(ent))
	{
		CFNPC npc = view_as<CFNPC>(ent);
		CBaseNPC base = npc.GetBaseNPC();

		npc.g_Logic = logic;
		npc.g_LogicPlugin = GetPluginHandle(logicPlugin);
		npc.i_Team = team;
		npc.i_Health = health;
		npc.i_MaxHealth = maxHealth;
		npc.SetModel(model);
		npc.i_Skin = skin;
		npc.f_Scale = scale;
		npc.f_Speed = speed;
		npc.f_MaxSpeed = speed;
		npc.f_ThinkRate = thinkRate;
		npc.SetBleedParticle(VFX_DEFAULT_BLEED);
		npc.SetBoundingBox(DEFAULT_MINS, DEFAULT_MAXS);

		if (lifespan > 0.0)
			npc.f_EndTime = GetGameTime() + lifespan;
		else
			npc.f_EndTime = 0.0;

		DispatchSpawn(ent);
		ActivateEntity(ent);

		CBaseNPC_Locomotion loco = npc.GetLocomotion();
		loco.SetCallback(LocomotionCallback_ShouldCollideWith, CFNPC_ShouldCollide);
		loco.SetCallback(LocomotionCallback_IsEntityTraversable, CFNPC_IsTraversable);

		SetEntProp(ent, Prop_Data, "m_nSolidType", 2); 
		SetEntityFlags(ent, FL_NPC);
		SetEntProp(ent, Prop_Send, "m_bGlowEnabled", false);
		SetEntProp(ent, Prop_Data, "m_bSequenceLoops", true);
		SetEntProp(ent, Prop_Data, "m_bloodColor", -1);

		base.flStepSize = 17.0;
		base.flGravity = 800.0;
		base.flAcceleration = 6000.0;
		base.flJumpHeight = 250.0;
		base.flFrictionSideways = 5.0;
		base.flMaxYawRate = 225.0;
		base.flDeathDropHeight = 999999.0;

		TeleportEntity(ent, pos, ang);

		RequestFrame(CFNPC_InternalLogic, EntIndexToEntRef(ent));

		SDKHook(ent, SDKHook_OnTakeDamagePost, CFNPC_PostDamage);
		SDKHook(ent, SDKHook_OnTakeDamage, CFNPC_OnDamage);
		SDKHook(ent, SDKHook_Think, CFNPC_Think);
		SDKHook(ent, SDKHook_ThinkPost, CFNPC_ThinkPost);
		SDKHook(ent, SDKHook_TraceAttack, CFNPC_TraceAttack);
		SDKHook(ent, SDKHook_Touch, CFNPC_Touch);

		return ent;
	}

	return -1;
}

public void CFNPC_Touch(int entity, int other)
{
	if (!HasEntProp(other, Prop_Send, "m_iTeamNum"))
		return;

	if (GetEntProp(other, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		return;

	CFNPC npc = view_as<CFNPC>(entity);

	char classname[255];
	GetEntityClassname(other, classname, sizeof(classname));

	float pos[3];

	bool remove = false;
	if (StrEqual(classname, "tf_projectile_cleaver"))
	{
		bool live = view_as<bool>(GetEntProp(other, Prop_Send, "m_bTouched"));
		if (!live)
		{
			float dmg = 50.0;

			int owner = GetEntPropEnt(other, Prop_Send, "m_hThrower");
			int launcher = GetEntPropEnt(other, Prop_Send, "m_hOriginalLauncher");

			if (IsValidEntity(launcher))
				dmg *= GetAttributeValue(launcher, 1, 1.0) * GetAttributeValue(launcher, 2, 1.0);

			GetEntPropVector(other, Prop_Send, "m_vecOrigin", pos);

			SetEntProp(other, Prop_Send, "m_bTouched", 1);
			SDKHooks_TakeDamage(entity, other, owner, dmg, GetEntProp(other, Prop_Send, "m_bCritical") > 0 ? DMG_CLUB|DMG_ACID : DMG_CLUB, launcher, _, pos, false);

			if (IsValidClient(owner))
			{
				EmitSoundToClient(owner, SND_CLEAVER_HIT);
			}

			EmitSoundToAll(SND_CLEAVER_HIT, other);

			remove = true;
		}
	}
	else if (StrEqual(classname, "tf_projectile_stun_ball"))
	{
		bool live = view_as<bool>(GetEntProp(other, Prop_Send, "m_bTouched"));
		if (!live)
		{
			float dmg = 15.0;

			int launcher = GetEntPropEnt(other, Prop_Send, "m_hOriginalLauncher");
			int owner = GetEntPropEnt(other, Prop_Send, "m_hOwnerEntity");
			GetEntPropVector(other, Prop_Send, "m_vecOrigin", pos);

			if (IsValidEntity(launcher))
				dmg *= GetAttributeValue(launcher, 1, 1.0) * GetAttributeValue(launcher, 2, 1.0);

			SDKHooks_TakeDamage(entity, other, owner, dmg, GetEntProp(other, Prop_Send, "m_bCritical") > 0 ? DMG_CLUB|DMG_ACID : DMG_CLUB, launcher, _, pos, false);
			npc.ApplyTemporarySpeedChange(0.5, 1, 6.0);
			SetEntProp(other, Prop_Send, "m_bTouched", 1);

			if (IsValidClient(owner))
			{
				EmitSoundToClient(owner, SND_SANDMAN_HIT);
			}

			EmitSoundToAll(SND_SANDMAN_HIT, other);
		}
	}

	if (remove)
		RemoveEntity(other);
}

public Action CFNPC_JarTouch(int entity, int other)
{
	char classname[255];
	GetEntityClassname(entity, classname, sizeof(classname));

	int team = GetEntProp(entity, Prop_Send, "m_iTeamNum");
	bool isRed = team == view_as<int>(TFTeam_Red);

	if (HasEntProp(other, Prop_Send, "m_iTeamNum"))
	{
		if (GetEntProp(other, Prop_Send, "m_iTeamNum") == team)
			return Plugin_Handled;
	}

	int owner = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
	int launcher = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");

	float pos[3];

	if (StrEqual(classname, "tf_projectile_jar"))
	{
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);

		SpawnParticle(pos, PARTICLE_JAR_EXPLODE_JARATE, 2.0);
		EmitSoundToAll(SND_JAR_EXPLODE, entity);

		//TODO: Coat all surrounding valid enemies (not including buildings) in jarate
	}
	else if (StrEqual(classname, "tf_projectile_jar_milk"))
	{
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);

		SpawnParticle(pos, PARTICLE_JAR_EXPLODE_MILK, 2.0);
		EmitSoundToAll(SND_JAR_EXPLODE, entity);

		CFNPC_Explosion(pos, 80.0, 9999.0, -1.0, _, _, entity, launcher, owner, DMG_ACID);

		//TODO: Coat all surrounding valid enemies (not including buildings) in milk
	}
	else if (StrEqual(classname, "tf_projectile_jar_gas"))
	{
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);

		SpawnParticle(pos, isRed ? PARTICLE_JAR_EXPLODE_GAS_RED : PARTICLE_JAR_EXPLODE_GAS_BLUE, 2.0);
		EmitSoundToAll(SND_GAS_EXPLODE, entity);

		//TODO: Spawn gas cloud
	}

	CPrintToChatAll("A jar collided with something.");

	RemoveEntity(entity);

	return Plugin_Continue;
}

public Action CFNPC_TraceAttack(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	if (!IsValidEntity(inflictor) || !IsValidClient(attacker))
		return Plugin_Continue;

	int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");

	bool AllowHeadshot = true;
	if (IsValidEntity(weapon))
	{
		//Attribute 42: No Headshots
		AllowHeadshot = GetAttributeValue(weapon, 42, 0.0) == 0.0;

		//Attribute 306: Only Headshot at Full Charge
		if (AllowHeadshot && GetAttributeValue(weapon, 306, 0.0) != 0.0 && HasEntProp(weapon, Prop_Send, "m_flChargedDamage"))
		{
			AllowHeadshot = (GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") / 150.0) >= 1.0;
		}
	}

	bool CanHeadshot = false;
	if (AllowHeadshot && !CanHeadshot && IsValidEntity(weapon))
	{
		//Attribute 51: Allow Headshots
		CanHeadshot = GetAttributeValue(weapon, 51, 0.0) != 0.0

		//Check if the weapon is a sniper rifle or bow with any charge.
		if (!CanHeadshot && HasEntProp(weapon, Prop_Send, "m_flChargedDamage"))
		{
			char weaponName[255];
			GetEntityClassname(weapon, weaponName, sizeof(weaponName));
			if (StrContains(weaponName, "sniperrifle") != -1)
			{
				CanHeadshot = GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") > 0.0;
			}
		}
	}

	if (hitgroup == HITGROUP_HEAD && CanHeadshot)
	{
		float mult = 3.0;
		bool MiniCrit = false;

		if (IsValidEntity(weapon))
		{
			//Attribute 869: Crits Become Mini-Crits
			if (GetAttributeValue(weapon, 869, 0.0) != 0.0)
			{
				MiniCrit = true;
			}

			//Attribute 390: Increased Headshot Damage
			mult *= GetAttributeValue(weapon, 869, 1.0);
		}

		Action result = Plugin_Continue;
		Call_StartForward(g_OnCFNPCHeadshot);

		Call_PushCell(view_as<CFNPC>(victim));
		Call_PushCell(weapon);
		Call_PushCell(inflictor);
		Call_PushCell(attacker);
		Call_PushFloatRef(mult);
		Call_PushCellRef(MiniCrit);

		Call_Finish(result);

		if (result != Plugin_Handled && result != Plugin_Stop)
		{
			if (MiniCrit)
				mult *= 0.45;
			damage *= mult;

			if (MiniCrit)
				PlayMiniCritSound(attacker);
			else
				PlayCritSound(attacker);

			CFNPC_SpawnCritParticle(view_as<CFNPC>(victim), MiniCrit);
		}
	}

	return Plugin_Changed;
}

void CFNPC_SpawnCritParticle(CFNPC victim, bool MiniCrit, float pos[3] = NULL_VECTOR)
{
	if (Vector_Is_Null(pos))
	{
		GetEntPropVector(victim.Index, Prop_Send, "m_vecOrigin", pos);
		pos[2] += 80.0 * victim.f_Scale;
	}

	SpawnParticle(pos, MiniCrit ? "minicrit_text" : "crit_text", 3.0);
}

public void CFNPC_Think(int iNPC)
{
	CFNPC npc = view_as<CFNPC>(iNPC);

	npc.GetBaseNPC().flRunSpeed = npc.f_Speed;
	npc.GetBaseNPC().flWalkSpeed = npc.f_Speed;
}

public void CFNPC_ThinkPost(int iNPC)
{
	CBaseCombatCharacter(iNPC).SetNextThink(GetGameTime());
	SetEntPropFloat(iNPC, Prop_Data, "m_flSimulationTime",GetGameTime());
}

public bool CFNPC_ShouldCollide(CBaseNPC_Locomotion loco, int other)
{ 
	int bot = loco.GetBot().GetNextBotCombatCharacter();
	return CFNPC_CollisionCheck(bot, other);
}

//TODO: Expand on this if necessary.
public bool CFNPC_CollisionCheck(int bot, int other)
{
	return !IsAlly(bot, other);
}

public bool CFNPC_IsTraversable(CBaseNPC_Locomotion loco, int other, TraverseWhenType when)
{
	if (other < 1)
		return false;

	//int bot = loco.GetBot().GetNextBotCombatCharacter();

	if (Brush_Is_Solid(other))
		return false;

	return true;
}

public void CFNPC_OnKilled(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePos[3])
{
	Action result = Plugin_Continue;

	Call_StartForward(g_OnCFNPCKilled);

	Call_PushCell(view_as<CFNPC>(victim));
	Call_PushFloat(damage);
	Call_PushCell(weapon);
	Call_PushCell(inflictor);
	Call_PushCell(attacker);
	Call_PushCellRef(damagetype);

	Call_Finish(result);

	if (result == Plugin_Continue || result == Plugin_Changed)
	{
		CFNPC npc = view_as<CFNPC>(victim);

		npc.PunchForce(damageForce, true);

		bool shouldGib = npc.b_GibsForced;

		if (!shouldGib && (damagetype & DMG_NEVERGIB == 0))
		{
			shouldGib = (damagetype & DMG_BLAST != 0) || (damagetype & DMG_BLAST_SURFACE != 0) || (damagetype & DMG_ALWAYSGIB != 0);

			if (!shouldGib && IsValidEntity(weapon))
			{
				if (GetAttributeValue(weapon, 309, 0.0) != 0.0 && (damagetype & DMG_CRIT != 0 || damagetype & DMG_ACID == DMG_ACID))
					shouldGib = true;
			}
		}
		
		npc.Extinguish();
		I_AM_DEAD[victim] = true;

		if (shouldGib)
		{
			npc.Gib();
		}
		else
		{
			npc.Ragdoll();
		}
	}
}

public void CFNPC_PostDamage(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3])
{
	CFNPC npc = view_as<CFNPC>(victim);

	Event event = CreateEvent("npc_hurt");
	if(event != null) 
	{
		event.SetInt("entindex", victim);
		event.SetInt("health", view_as<CFNPC>(victim).i_Health);
		event.SetInt("damageamount", RoundToFloor(damage));
		event.SetBool("crit", (damagetype & DMG_ACID) == DMG_ACID);

		if(IsValidClient(attacker))
		{
			event.SetInt("attacker_player", GetClientUserId(attacker));
			event.SetInt("weaponid", 0);
		}

		event.Fire();
	}

	CFNPC_AttemptIgnite(victim, attacker, inflictor, weapon);
	CFNPC_AttemptBleed(victim, attacker, inflictor, weapon);

	if (!StrEqual(CFNPC_BleedParticle[victim], ""))
	{
		float dPos[3];
		dPos = damagePosition;

		if (Vector_Is_Null(dPos))
		{
			dPos = GetWorldSpaceCenter(victim);
			for (int i = 0; i < 3; i++)
				dPos[i] += GetRandomFloat(-20.0 * npc.f_Scale, 20.0 * npc.f_Scale);
		}

		SpawnParticle(dPos, CFNPC_BleedParticle[victim], 0.66);	//TODO: Make this a TE entity. Also do the same to crit text.
	}

	if (!StrEqual(CFNPC_FlinchSequence[victim], "") && GetGameTime() >= f_NextFlinch[victim])
	{
		npc.AddGesture(CFNPC_FlinchSequence[victim]);
		f_NextFlinch[victim] = GetGameTime() + 0.2;
	}

	if (view_as<CFNPC>(victim).i_Health < 1)
	{
		CFNPC_OnKilled(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
	}
}

public void CFNPC_AttemptIgnite(int victim, int attacker, int inflictor, int weapon)
{
	CFNPC npc = view_as<CFNPC>(victim);
	bool burn = false;
	float burnTime = 0.0;
	float minBurnTime = 0.0;
	float maxBurnTime = 0.0;
	float burnDMG = 0.0;
	bool haunted = false;

	char classname[255];
	if (IsValidEntity(weapon))
	{
		//Attributes 73, 74, 828, and 829 all affect afterburn duration.
		float timeMult = (GetAttributeValue(weapon, 73, 1.0) * GetAttributeValue(weapon, 74, 1.0) * GetAttributeValue(weapon, 828, 1.0) * GetAttributeValue(weapon, 829, 1.0));
		//Attributes 71 and 72 both affect afterburn damage.
		float dmgMult = (GetAttributeValue(weapon, 71, 1.0) * GetAttributeValue(weapon, 72, 1.0));

		GetEntityClassname(weapon, classname, sizeof(classname));
		if (StrEqual(classname, "tf_weapon_flamethrower"))
		{
			minBurnTime = 4.0 * timeMult;
			maxBurnTime = 10.0 * timeMult;
			burnTime = 0.4 * timeMult;
			burn = true;
		}
		else if (StrEqual(classname, "tf_weapon_rocketlauncher_fireball"))
		{
			minBurnTime = 2.5 * timeMult;
			maxBurnTime = 2.5 * timeMult;
			burnTime = 2.5 * timeMult;
			burn = true;
		}
		else if (StrContains(classname, "flaregun") != -1)
		{
			burnTime = 7.5 * timeMult;
			minBurnTime = burnTime;
			maxBurnTime = burnTime;
			burn = true;
		}
		else if (GetAttributeValue(weapon, 208, 0.0) != 0.0)
		{
			burnTime = GetAttributeValue(weapon, 208, 0.0) * timeMult;
			minBurnTime = burnTime;
			maxBurnTime = burnTime;
			burn = true;
		}

		burnDMG = 4.0 * dmgMult;
		haunted = GetAttributeValue(weapon, 1008, 0.0) != 0.0;
	}
	else if (IsValidEntity(inflictor))
	{
		GetEntityClassname(inflictor, classname, sizeof(classname));
		if (StrContains(classname, "tf_projectile_flare") != -1)
		{
			burnTime = 7.5;
			burn = true;
			burnDMG = 4.0;
		}
	}

	if (burn)
	{
		npc.Ignite(burnTime, minBurnTime, maxBurnTime, burnDMG, haunted, attacker);
	}
}

public void CFNPC_AttemptBleed(int victim, int attacker, int inflictor, int weapon)
{
	CFNPC npc = view_as<CFNPC>(victim);

	bool bleed = false;
	float bleedTime = 0.0;
	float bleedDMG = 4.0;

	if (IsValidEntity(weapon))
	{
		bleedTime = GetAttributeValue(weapon, 149, 0.0);

		if (bleedTime > 0.0)
			bleed = true;
	}

	if (IsValidEntity(inflictor) && !bleed)
	{
		char classname[255];
		GetEntityClassname(inflictor, classname, sizeof(classname));

		if (StrEqual(classname, "tf_projectile_ball_ornament") || StrEqual(classname, "tf_projectile_cleaver"))
		{
			bleedTime = 5.0;
			bleed = true;
		}
	}

	if (IsValidEntity(weapon))
		bleedDMG *= GetAttributeValue(weapon, 138, 1.0);

	if (bleed)
	{
		npc.Bleed(bleedTime, bleedDMG, attacker);
	}
}

public Action CFNPC_OnDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (IsAlly(victim, attacker))
	{
		damage = 0.0;
		return Plugin_Changed;
	}

	CFNPC npc = view_as<CFNPC>(victim);

	if (npc.b_Burning)
	{
		//Attributes 20 and 735: Crit VS Burning Targets
		if (GetAttributeValue(weapon, 20, 0.0) != 0.0 || GetAttributeValue(weapon, 735, 0.0) != 0.0)
			damagetype |= DMG_ACID;
		else if (GetAttributeValue(weapon, 638, 0.0) != 0.0)	//Attribute 638: Mini-Crit Burning Targets From Front, Full-Crit From Back
		{
			if (IsBehindAndFacingTarget(attacker, victim))
				damagetype |= DMG_ACID;
			else
				b_MiniCrit[victim] = true;
		}

		//Attribute 795: Damage Bonus VS Burning Targets
		damage *= GetAttributeValue(weapon, 795, 1.0);

		//Attribute 2063: Dragon's Fury Properties
		if (GetAttributeValue(weapon, 2063, 0.0) != 0.0)
		{
			damage *= 3.0;
			
			if (IsValidEntity(weapon))
			{
				float next = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack");
				if (next > GetGameTime())
				{
					float diff = next - GetGameTime();
					diff /= 2.0;
					SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + diff);
				}
			}
		}

		//Attribute 2067: Mini-Crit and Extinguish Burning Targets, Speed Boost on Kill
		if (GetAttributeValue(weapon, 2067, 0.0) != 0.0)
		{
			b_MiniCrit[victim] = true;
			if (damage * 1.35 > float(npc.i_Health) && IsValidClient(attacker))
				TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 4.0);

			npc.Extinguish();
		}
	}
	else
	{
		//Attribute 21: Damage Penalty VS Non-Burning Targets
		damage *= GetAttributeValue(weapon, 21, 1.0);

		//Attribute 22: No Crits VS Non-Burning Targets
		if (GetAttributeValue(weapon, 22, 0.0) != 0.0)
			damagetype &= ~DMG_ACID;

		//Attribute 408: Crit VS Non-Burning Targets
		if (GetAttributeValue(weapon, 408, 0.0) != 0.0)
			damagetype |= DMG_ACID;
	}

	bool crit = (damagetype & DMG_ACID) == DMG_ACID;
	if (crit && GetAttributeValue(weapon, 869, 0.0) == 0.0)
	{
		CFNPC_SpawnCritParticle(view_as<CFNPC>(victim), false, damagePosition);
		if (IsValidClient(attacker))
			PlayCritSound(attacker);

		damage *= 3.0;
	}
	else if (b_MiniCrit[victim] || GetAttributeValue(weapon, 869, 0.0) != 0.0)
	{
		CFNPC_SpawnCritParticle(view_as<CFNPC>(victim), true, damagePosition);
		if (IsValidClient(attacker))
			PlayMiniCritSound(attacker);

		damage *= 1.35;
	}

	b_MiniCrit[victim] = false;

	Action result;

	Call_StartForward(g_OnCFNPCDamaged);

	Call_PushCell(view_as<CFNPC>(victim));
	Call_PushFloatRef(damage);
	Call_PushCell(weapon);
	Call_PushCell(inflictor);
	Call_PushCell(attacker);
	Call_PushCellRef(damagetype);
	Call_PushCellRef(damagecustom);

	Call_Finish(result);

	if (result == Plugin_Handled || result == Plugin_Stop)
	{
		damage = 0.0;
		result = Plugin_Changed;
	}

	return Plugin_Changed;
}

public void CFNPC_InternalLogic(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return;

	CFNPC npc = view_as<CFNPC>(ent);

	if (!npc.b_Exists || I_AM_DEAD[ent])
		return;

	float gt = GetGameTime();
	if (CFNPC_Logic[ent] != INVALID_FUNCTION && npc.g_LogicPlugin != null && gt >= npc.f_NextThinkTime)
	{
		Call_StartFunction(npc.g_LogicPlugin, CFNPC_Logic[ent]);
		Call_PushCell(npc.Index);
		Call_Finish();

		npc.f_NextThinkTime = gt + npc.f_ThinkRate;
	}
	
	if (gt >= npc.f_EndTime && npc.f_EndTime > 0.0)
	{
		RemoveEntity(ent);
		return;
	}

	CFNPC_BurnLogic(npc, gt);
	CFNPC_SetMovePose(npc);
	CFNPC_CheckTriggerHurt(npc);

	npc.GetPathFollower().Update(npc.GetBot());

	RequestFrame(CFNPC_InternalLogic, ref);
}

public void CFNPC_CheckTriggerHurt(CFNPC npc)
{
	float pos[3];
	GetEntPropVector(npc.Index, Prop_Send, "m_vecOrigin", pos);
	if (IsPointHazard(pos))
	{
		npc.i_Health = 0;
		SetEntProp(npc.Index, Prop_Data, "m_takedamage", 1, 1);
		SDKHooks_TakeDamage(npc.Index, 0, 0, 9999999.0, _, _, _, _, false);
	}
}

public void CFNPC_BurnLogic(CFNPC npc, float gametime)
{
	if (npc.b_Burning)
	{
		if (gametime >= f_NextBurn[npc.Index])
		{
			SDKHooks_TakeDamage(npc.Index, npc.i_AfterburnAttacker, npc.i_AfterburnAttacker, npc.f_AfterburnDMG, DMG_BURN, _, _, _, false);
			if (gametime + 0.5 > npc.f_AfterburnEndTime)
			{
				npc.Extinguish();
			}
			else
			{
				f_NextBurn[npc.Index] = gametime + 0.5;
				if (npc.b_AfterburnIsHaunted)
				{
					AttachParticle_TE(npc.Index, VFX_AFTERBURN_HAUNTED);
				}
			}
		}
	}
}

public void CFNPC_SetMovePose(CFNPC npc)
{
	float groundSpeed = npc.GetGroundSpeed();

	if (groundSpeed < 0.01)
	{
		if (npc.i_PoseMoveX >= 0)
			npc.SetPoseParameter(npc.i_PoseMoveX, 0.0);
		if (npc.i_PoseMoveY >= 0)
			npc.SetPoseParameter(npc.i_PoseMoveY, 0.0);
	}
	else
	{
		float front[3], right[3], up[3];
		npc.GetVectors(front, right, up);

		float motion[3];
		npc.GetGroundMotionVector(motion);

		float mult = (1.66 * npc.f_Speed)/npc.f_MaxSpeed;
		if (mult < 0.0)
			mult = 0.0;
		if (mult > 1.0)
			mult = 1.0;

		if (npc.i_PoseMoveX >= 0)
			npc.SetPoseParameter(npc.i_PoseMoveX, GetVectorDotProduct(motion, front) * mult);
		if (npc.i_PoseMoveY >= 0)
			npc.SetPoseParameter(npc.i_PoseMoveY, GetVectorDotProduct(motion, right) * mult);
	}
}

public int Native_CFNPCGetIndex(Handle plugin, int numParams) { return GetNativeCell(1); }

public int Native_CFNPCSetLogic(Handle plugin, int numParams) 
{ 
	CFNPC_Logic[GetNativeCell(1)] = GetNativeFunction(2); 
	return 0; 
}

public any Native_CFNPCGetLogicPlugin(Handle plugin, int numParams) { return CFNPC_LogicPlugin[GetNativeCell(1)]; }
public int Native_CFNPCSetLogicPlugin(Handle plugin, int numParams) 
{ 
	CFNPC_LogicPlugin[GetNativeCell(1)] = GetNativeCell(2); 
	return 0; 
}

public any Native_CFNPCGetTeam(Handle plugin, int numParams) { return view_as<TFTeam>(GetEntProp(GetNativeCell(1), Prop_Send, "m_iTeamNum")); }
public int Native_CFNPCSetTeam(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	int team = GetNativeCell(2);

	if (team <= view_as<int>(TFTeam_Blue))
		SetEntProp(ent, Prop_Send, "m_iTeamNum", team);
	else
		SetEntProp(ent, Prop_Send, "m_iTeamNum", 4);

	return 0; 
}

public any Native_CFNPCGetSkin(Handle plugin, int numParams) { return GetEntProp(GetNativeCell(1), Prop_Send, "m_nSkin"); }
public int Native_CFNPCSetSkin(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	int skin = GetNativeCell(2);
	CFNPC npc = view_as<CFNPC>(ent);

	if (skin < 0)
	{
		if (npc.i_Team == TFTeam_Red || npc.i_Team == TFTeam_Blue)
			SetEntProp(ent, Prop_Send, "m_nSkin", view_as<int>(npc.i_Team) - 2);
		else
			SetEntProp(ent, Prop_Send, "m_nSkin", 0);
	}
	else
	{
		SetEntProp(ent, Prop_Send, "m_nSkin", skin);
	}

	return 0; 
}

public any Native_CFNPCGetScale(Handle plugin, int numParams) { return GetEntPropFloat(GetNativeCell(1), Prop_Send, "m_flModelScale"); }
public int Native_CFNPCSetScale(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	float scale = GetNativeCell(2);
	SetEntPropFloat(ent, Prop_Send, "m_flModelScale", scale);

	return 0; 
}

public any Native_CFNPCGetSpeed(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	return npc.GetBaseNPC().flRunSpeed;
}

public int Native_CFNPCSetSpeed(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	float speed = GetNativeCell(2);
	CFNPC npc = view_as<CFNPC>(ent);
	npc.GetBaseNPC().flRunSpeed = speed;
	npc.GetBaseNPC().flWalkSpeed = speed;

	return 0; 
}

public any Native_CFNPCGetMaxSpeed(Handle plugin, int numParams) { return CFNPC_Speed[GetNativeCell(1)]; }
public int Native_CFNPCSetMaxSpeed(Handle plugin, int numParams) 
{
	CFNPC_Speed[GetNativeCell(1)] = GetNativeCell(2);

	return 0; 
}

public any Native_CFNPCGetThinkRate(Handle plugin, int numParams) { return CFNPC_ThinkRate[GetNativeCell(1)]; }
public int Native_CFNPCSetThinkRate(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	float thinker = GetNativeCell(2);
	CFNPC_ThinkRate[ent] = thinker;

	return 0; 
}

public any Native_CFNPCGetNextThinkTime(Handle plugin, int numParams) { return CFNPC_NextThinkTime[GetNativeCell(1)]; }
public int Native_CFNPCSetNextThinkTime(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	float nextone = GetNativeCell(2);
	CFNPC_NextThinkTime[ent] = nextone;

	return 0; 
}

public any Native_CFNPCGetEndTime(Handle plugin, int numParams) { return CFNPC_EndTime[GetNativeCell(1)]; }
public int Native_CFNPCSetEndTime(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	float theend = GetNativeCell(2);
	CFNPC_EndTime[ent] = theend;

	return 0; 
}

public int Native_CFNPCGetModel(Handle plugin, int numParams) { SetNativeString(2, CFNPC_Model[GetNativeCell(1)], GetNativeCell(3)); return 0; }
public int Native_CFNPCSetModel(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	char newModel[255];
	GetNativeString(2, newModel, sizeof(newModel));
	if (CheckFile(newModel))
	{
		DispatchKeyValue(ent, "model", newModel);
		view_as<CBaseCombatCharacter>(ent).SetModel(newModel);
		
		strcopy(CFNPC_Model[ent], 255, newModel);
	}

	return 0; 
}

public int Native_CFNPCGetBleedEffect(Handle plugin, int numParams) { SetNativeString(2, CFNPC_BleedParticle[GetNativeCell(1)], GetNativeCell(3)); return 0; }
public int Native_CFNPCSetBleedEffect(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	char newBleed[255];
	GetNativeString(2, newBleed, sizeof(newBleed));

	strcopy(CFNPC_BleedParticle[ent], 255, newBleed);

	return 0; 
}

public int Native_CFNPCGetFlinchSequence(Handle plugin, int numParams) { SetNativeString(2, CFNPC_FlinchSequence[GetNativeCell(1)], GetNativeCell(3)); return 0; }
public int Native_CFNPCSetFlinchSequence(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	char newFlinch[255];
	GetNativeString(2, newFlinch, sizeof(newFlinch));

	strcopy(CFNPC_FlinchSequence[ent], 255, newFlinch);

	return 0; 
}

public int Native_CFNPCSetDamageVFX(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	char newBleed[255], newFlinch[255];
	GetNativeString(2, newBleed, sizeof(newBleed));
	GetNativeString(3, newFlinch, sizeof(newFlinch));

	npc.SetBleedParticle(newBleed);
	npc.SetFlinchSequence(newFlinch);

	return 0;
}

public int Native_CFNPCGetHealth(Handle plugin, int numParams) { return GetEntProp(GetNativeCell(1), Prop_Data, "m_iHealth"); }
public int Native_CFNPCSetHealth(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	int hp = GetNativeCell(2);
	SetEntProp(ent, Prop_Data, "m_iHealth", hp);

	return 0; 
}

public int Native_CFNPCGetMaxHealth(Handle plugin, int numParams) { return GetEntProp(GetNativeCell(1), Prop_Data, "m_iMaxHealth"); }
public int Native_CFNPCSetMaxHealth(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	int hp = GetNativeCell(2);
	SetEntProp(ent, Prop_Data, "m_iMaxHealth", hp);

	return 0; 
}

public any Native_CFNPCGetLocomotion(Handle plugin, int numParams)
{
	CBaseNPC npc = TheNPCs.FindNPCByEntIndex(GetNativeCell(1));
	return npc.GetLocomotion();
}

public any Native_CFNPCGetYawRate(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	return npc.GetBaseNPC().flMaxYawRate;
}

public int Native_CFNPCSetYawRate(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	npc.GetBaseNPC().flMaxYawRate = GetNativeCell(2);
	return 0;
}

public any Native_CFNPCGetStepSize(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	return npc.GetBaseNPC().flStepSize;
}

public int Native_CFNPCSetStepSize(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	npc.GetBaseNPC().flStepSize = GetNativeCell(2);
	return 0;
}

public any Native_CFNPCGetGravity(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	return npc.GetBaseNPC().flGravity;
}

public int Native_CFNPCSetGravity(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	npc.GetBaseNPC().flGravity = GetNativeCell(2);
	return 0;
}

public any Native_CFNPCGetAcceleration(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	return npc.GetBaseNPC().flAcceleration;
}

public int Native_CFNPCSetAcceleration(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	npc.GetBaseNPC().flAcceleration = GetNativeCell(2);
	return 0;
}

public any Native_CFNPCGetJumpHeight(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	return npc.GetBaseNPC().flJumpHeight;
}

public int Native_CFNPCSetJumpHeight(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	npc.GetBaseNPC().flJumpHeight = GetNativeCell(2);
	return 0;
}

public any Native_CFNPCGetFrictionSideways(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	return npc.GetBaseNPC().flFrictionSideways;
}

public int Native_CFNPCSetFrictionSideways(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	npc.GetBaseNPC().flFrictionSideways = GetNativeCell(2);
	return 0;
}

public any Native_CFNPCGetFrictionForwards(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	return npc.GetBaseNPC().flFrictionForward;
}

public int Native_CFNPCSetFrictionForwards(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	npc.GetBaseNPC().flFrictionForward = GetNativeCell(2);
	return 0;
}

public any Native_CFNPCGetDeathDropHeight(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	return npc.GetBaseNPC().flDeathDropHeight;
}

public int Native_CFNPCSetDeathDropHeight(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	npc.GetBaseNPC().flDeathDropHeight = GetNativeCell(2);
	return 0;
}

public any Native_CFNPCGetBaseNPC(Handle plugin, int numParams)
{
	return TheNPCs.FindNPCByEntIndex(GetNativeCell(1));
}

public any Native_CFNPCGetExists(Handle plugin, int numParams) { return IExist[GetNativeCell(1)]; }
public int Native_CFNPCSetExists(Handle plugin, int numParams) 
{
	IExist[GetNativeCell(1)] = GetNativeCell(2);

	return 0; 
}

public any Native_CFNPCGetForcedGib(Handle plugin, int numParams) { return ForcedToGib[GetNativeCell(1)]; }
public int Native_CFNPCSetForcedGib(Handle plugin, int numParams) 
{
	ForcedToGib[GetNativeCell(1)] = GetNativeCell(2);

	return 0; 
}

public any Native_CFNPCSetSequence(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	char sequence[255];
	GetNativeString(2, sequence, sizeof(sequence));

	int anim = npc.LookupSequence(sequence);
	if (anim > -1)
	{
		SetEntProp(npc.Index, Prop_Send, "m_nSequence", anim);
		return true;
	}

	return false;
}

public int Native_CFNPCLookupActivity(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	char activity[255];
	GetNativeString(2, activity, sizeof(activity));

	Address modelPtr = npc.GetModelPtr();
	if (modelPtr == Address_Null)
		return -1;

	return SDKCall(g_hLookupActivity, modelPtr, activity);
}

public any Native_CFNPCSetActivity(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	char activityStr[255];
	GetNativeString(2, activityStr, sizeof(activityStr));

	int activity = npc.LookupActivity(activityStr);
	if (activity > -1)
	{
		int sequence = npc.SelectWeightedSequence(view_as<Activity>(activity));
		if (sequence <= 0)
			return false;

		SetEntProp(npc.Index, Prop_Send, "m_nSequence", sequence);
		npc.SetCycle(0.0);
		npc.SetPlaybackRate(1.0);

		return true;
	}

	return false;
}

public int Native_CFNPCSetCycle(Handle plugin, int numParams)
{
	SetEntPropFloat(GetNativeCell(1), Prop_Send, "m_flCycle", GetNativeCell(2));
	return 0;
}

public int Native_CFNPCSetPlaybackRate(Handle plugin, int numParams)
{
	SetEntPropFloat(GetNativeCell(1), Prop_Send, "m_flPlaybackRate", GetNativeCell(2));
	return 0;
}

public int Native_CFNPCAddGesture(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	char gesture[255];
	GetNativeString(2, gesture, sizeof(gesture));
	bool cancel = GetNativeCell(3);
	float duration = GetNativeCell(4);
	bool autoKill = GetNativeCell(5);
	float rate = GetNativeCell(6);

	int activity = npc.LookupActivity(gesture);
	if (activity <= 0)
		return 0;

	if (cancel)
		view_as<CBaseCombatCharacter>(npc).RestartGesture(view_as<Activity>(activity), true, autoKill);
	else
		view_as<CBaseCombatCharacter>(npc).AddGesture(view_as<Activity>(activity), duration, autoKill);

	int layer = npc.FindGestureLayer(view_as<Activity>(activity));
	if (layer > -1)
		npc.SetLayerPlaybackRate(layer, rate);

	return 0;
}

public int Native_CFNPCRemoveGesture(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	char gesture[255];
	GetNativeString(2, gesture, sizeof(gesture));

	int activity = npc.LookupActivity(gesture);
	if (activity <= 0)
		return 0;

	int layer = npc.FindGestureLayer(view_as<Activity>(activity));
	if (layer > -1)
		npc.FastRemoveLayer(layer);

	return 0;
}

public any Native_CFNPCGetPathFollower(Handle plugin, int numParams)
{
	return view_as<PathFollower>(view_as<CFNPC>(GetNativeCell(1)).GetProp(Prop_Data, "cf_pPath"));
}

public int Native_CFNPCStartPathing(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	npc.GetPathFollower().SetMinLookAheadDistance(100.0);
	npc.GetLocomotion().Run();

	return 0;
}

public int Native_CFNPCStopPathing(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	npc.GetPathFollower().Invalidate();
	npc.GetLocomotion().Stop();

	return 0;
}

public int Native_CFNPCSetGoalVector(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	float pos[3];
	GetNativeArray(2, pos, sizeof(pos));
	npc.GetPathFollower().ComputeToPos(npc.GetBot(), pos);

	return 0;
}

public any Native_CFNPCGetBot(Handle plugin, int numParams)
{
	return view_as<CFNPC>(GetNativeCell(1)).MyNextBotPointer();
}

public any Native_CFNPCGetGroundSpeed(Handle plugin, int numParams)
{
	return view_as<CFNPC>(GetNativeCell(1)).GetLocomotion().GetGroundSpeed();
}

public int Native_CFNPCGetPoseMoveX(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	return npc.LookupPoseParameter("move_x");
}

public int Native_CFNPCGetPoseMoveY(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	return npc.LookupPoseParameter("move_y");
}

public int Native_CFNPCGetGroundMotionVector(Handle plugin, int numParams)
{
	float vec[3];
	CBaseNPC_Locomotion loco = view_as<CFNPC>(GetNativeCell(1)).GetLocomotion();
	loco.GetGroundMotionVector(vec);
	SetNativeArray(2, vec, 3);

	return 0;
}

public int Native_CFNPCRagdoll(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));

	float ragdollVel[3], override[3];
	GetNativeArray(2, override, sizeof(override));
	if (!Vector_Is_Null(override))
	{
		npc.PunchForce(override, true);
	}

	npc.PunchForce(ragdollVel, false);
	ScaleVector(ragdollVel, 2.0);

	if(ragdollVel[0] == 0.0 || ragdollVel[0] > 10000000.0 || ragdollVel[1] > 10000000.0 || ragdollVel[2] > 10000000.0 || ragdollVel[0] < -10000000.0 || ragdollVel[1] < -10000000.0 || ragdollVel[2] < -10000000.0) //knockback is way too huge. set to 0.
	{
		ragdollVel[0] = 1.0;
		ragdollVel[1] = 1.0;
		ragdollVel[2] = 1.0;
	}

	SDKCall_Ragdoll(npc.Index, ragdollVel);

	return 0;
}

public int Native_CFNPCGib(Handle plugin, int numParams)
{
	int ent = GetNativeCell(1);
	CFNPC npc = view_as<CFNPC>(ent);

	if (g_Gibs[ent] != null)
	{
		for (int i = 0; i < GetArraySize(g_Gibs[ent]); i++)
		{
			char model[255], attachment[255];
			GetArrayString(g_Gibs[ent], i, model, sizeof(model));
			GetArrayString(g_GibAttachments[ent], i, attachment, sizeof(attachment));

			float pos[3], ang[3], vel[3];

			int point;
			if (!StrEqual(attachment, "") && (point = npc.LookupAttachment(attachment)) != 0)
			{
				npc.GetAttachment(point, pos, ang);
			}
			else
			{
				CF_WorldSpaceCenter(ent, pos);
				GetEntPropVector(ent, Prop_Data, "m_angRotation", ang);
			}

			npc.PunchForce(vel, false);
			CFNPC_SpawnGib(model, npc.i_Skin, pos, ang, vel);
		}
	}

	RemoveEntity(ent);

	return 0;
}

public int Native_CFNPCAttachModel(Handle plugin, int numParams)
{
	int ent = GetNativeCell(1);
	CFNPC npc = view_as<CFNPC>(ent);

	char model[255], attachment[255], sequence[255];
	GetNativeString(2, model, sizeof(model));
	if (!CheckFile(model))
		return -1;
	PrecacheModel(model);

	GetNativeString(3, attachment, sizeof(attachment));
	GetNativeString(4, sequence, sizeof(sequence));
	int skin = GetNativeCell(5);
	float scale = GetNativeCell(6);
	bool bonemerge = GetNativeCell(7);
	bool weapon = GetNativeCell(8);

	int item = CreateEntityByName("prop_dynamic_override");
	if(!IsValidEntity(item))	//Infinitely loop this if it fails to spawn, because apparently TF2 has a very small reason to fail to spawn props.
	{
		return npc.AttachModel(model, attachment, sequence, skin, scale, bonemerge, weapon);
	}

	DispatchKeyValue(item, "model", model);

	if(scale == 1.0)
	{
		DispatchKeyValueFloat(item, "modelscale", GetEntPropFloat(ent, Prop_Send, "m_flModelScale"));
	}
	else
	{
		DispatchKeyValueFloat(item, "modelscale", scale);
	}

	DispatchSpawn(item);
	if (bonemerge)
		SetEntProp(item, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_PARENT_ANIMATES);

	SetEntityMoveType(item, MOVETYPE_NONE);
	SetEntProp(item, Prop_Data, "m_nNextThinkTick", -1.0);
	
	if(!StrEqual(sequence, ""))
	{
		SetVariantString(sequence);
		AcceptEntityInput(item, "SetAnimation");
	}

	SetVariantString("!activator");
	AcceptEntityInput(item, "SetParent", ent);

	if(attachment[0])
	{
		SetVariantString(attachment);
		AcceptEntityInput(item, "SetParentAttachmentMaintainOffset"); 
	}	

	if (skin < 0)
	{
		if (npc.i_Team == TFTeam_Red || npc.i_Team == TFTeam_Blue)
			SetEntProp(item, Prop_Send, "m_nSkin", view_as<int>(npc.i_Team) - 2);
		else
			SetEntProp(item, Prop_Send, "m_nSkin", 0);
	}
	else
	{
		SetEntProp(item, Prop_Send, "m_nSkin", skin);
	}

	if (weapon)
	{
		if (npc.g_AttachedWeapons == null)
			npc.g_AttachedWeapons = new ArrayList(255);

		PushArrayCell(npc.g_AttachedWeapons, EntIndexToEntRef(item));
	}
	else
	{
		if (npc.g_AttachedCosmetics == null)
			npc.g_AttachedCosmetics = new ArrayList(255);

		PushArrayCell(npc.g_AttachedCosmetics, EntIndexToEntRef(item));
	}
		
	PreventAllCollisions(item);

	return item;
}

public void CFNPC_SpawnGib(char model[255], int skin, float pos[3], float ang[3], float vel[3])
{
	char skinChar[16];
	IntToString(skin, skinChar, sizeof(skinChar));
	int gib = SpawnPhysicsProp(model, 0, skinChar, 99999.0, true, 1.0, pos, ang, vel, 10.0);
				
	if (IsValidEntity(gib))
	{
		SetEntityCollisionGroup(gib, 1);
		SetEntityRenderMode(gib, RENDER_TRANSALPHA);
		SetEntityCollisionGroup(gib, 1);
		SetEntProp(gib, Prop_Send, "m_iTeamNum", 0);

		CreateTimer(5.0, CFNPC_BeginGibFadeout, EntIndexToEntRef(gib), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action CFNPC_BeginGibFadeout(Handle timer, int ref)
{
	int gib = EntRefToEntIndex(ref);
	if (IsValidEntity(gib))
	{
		MakeEntityFadeOut(gib, 2);
	}

	return Plugin_Continue;
}

public int Native_CFNPCAddGib(Handle plugin, int numParams)
{
	int ent = GetNativeCell(1);

	char model[255], attachment[255];
	GetNativeString(2, model, sizeof(model));
	if (!CheckFile(model))
		return 0;

	GetNativeString(3, attachment, sizeof(attachment));

	if (g_Gibs[ent] == null)
		g_Gibs[ent] = new ArrayList(255);
	if (g_GibAttachments[ent] == null)
		g_GibAttachments[ent] = new ArrayList(255);

	g_Gibs[ent].PushString(model);
	g_GibAttachments[ent].PushString(attachment);

	return 0;
}
public int Native_CFNPCPunchForce(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	bool override = GetNativeCell(3);

	if (override)
	{
		float pos[3];
		GetNativeArray(2, pos, sizeof(pos));

		for (int i = 0; i < 3; i++)
			f_PunchForce[npc.Index][i] = pos[i];
	}
	else
	{
		SetNativeArray(2, f_PunchForce[npc.Index], 3);
	}

	return 0;
}

public void SDKCall_Ragdoll(int entity, float vel[3])
{
	view_as<CFNPC>(entity).RemoveAttachments();
	SDKCall(SDK_Ragdoll, entity, vel);
}

public any Native_CFNPCGetAttachedCosmetics(Handle plugin, int numParams) { return g_AttachedModels[GetNativeCell(1)]; }
public int Native_CFNPCSetAttachedCosmetics(Handle plugin, int numParams)
{
	g_AttachedModels[GetNativeCell(1)] = GetNativeCell(2);

	return 0;
}

public any Native_CFNPCGetAttachedWeapons(Handle plugin, int numParams) { return g_AttachedWeaponModels[GetNativeCell(1)]; }
public int Native_CFNPCSetAttachedWeapons(Handle plugin, int numParams)
{
	g_AttachedWeaponModels[GetNativeCell(1)] = GetNativeCell(2);

	return 0;
}

public int Native_CFNPCRemoveAttachments(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));

	if (GetNativeCell(2) && npc.g_AttachedCosmetics != null)
	{
		for (int i = 0; i < GetArraySize(npc.g_AttachedCosmetics); i++)
		{
			int ent = EntRefToEntIndex(GetArrayCell(npc.g_AttachedCosmetics, i));
			if (IsValidEntity(ent))
				RemoveEntity(ent);
		}

		delete npc.g_AttachedCosmetics;
	}

	if (GetNativeCell(3) && npc.g_AttachedWeapons != null)
	{
		for (int i = 0; i < GetArraySize(npc.g_AttachedWeapons); i++)
		{
			int ent = EntRefToEntIndex(GetArrayCell(npc.g_AttachedWeapons, i));
			if (IsValidEntity(ent))
				RemoveEntity(ent);
		}

		delete npc.g_AttachedWeapons;
	}

	return 0;
}

public any Native_CFNPCGetAfterburnEndTime(Handle plugin, int numParams) { return f_AfterburnEndTime[GetNativeCell(1)]; }
public int Native_CFNPCSetAfterburnEndTime(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	float endTime = GetNativeCell(2);

	if (endTime > GetGameTime())
	{
		if (!npc.b_Burning)
		{
			f_NextBurn[npc.Index] = GetGameTime() + 0.5;

			if (npc.b_AfterburnIsHaunted)
				AttachParticle_TE(npc.Index, VFX_AFTERBURN_HAUNTED);
			else
				AttachParticle_TE(npc.Index, npc.i_Team == TFTeam_Red ? VFX_AFTERBURN_RED : VFX_AFTERBURN_BLUE);
		}

		f_AfterburnEndTime[npc.Index] = endTime;
	}
	else
	{
		if (npc.b_Burning)
		{
			f_NextBurn[npc.Index] = 0.0;
			
			if (npc.b_AfterburnIsHaunted)
				RemoveParticle_TE(npc.Index, VFX_AFTERBURN_HAUNTED);
			else
				RemoveParticle_TE(npc.Index, npc.i_Team == TFTeam_Red ? VFX_AFTERBURN_RED : VFX_AFTERBURN_BLUE);
		}

		f_AfterburnEndTime[npc.Index] = 0.0;
	}

	return 0;
}

public any Native_CFNPCGetBurning(Handle plugin, int numParams) { return f_AfterburnEndTime[GetNativeCell(1)] >= GetGameTime(); }

public any Native_CFNPCGetAfterburnDMG(Handle plugin, int numParams) { return f_AfterburnDMG[GetNativeCell(1)]; }
public int Native_CFNPCSetAfterburnDMG(Handle plugin, int numParams) { f_AfterburnDMG[GetNativeCell(1)] = GetNativeCell(2); return 0; }

public int Native_CFNPCGetAfterburnAttacker(Handle plugin, int numParams) { return GetClientOfUserId(i_AfterburnAttacker[GetNativeCell(1)]); }
public int Native_CFNPCSetAfterburnAttacker(Handle plugin, int numParams)
{ 
	int client = GetNativeCell(2);
	if (!IsValidClient(client))
		i_AfterburnAttacker[GetNativeCell(1)] = -1;
	else
		i_AfterburnAttacker[GetNativeCell(1)] = GetClientUserId(client);

	return 0;
}

public any Native_CFNPCGetAfterburnHaunted(Handle plugin, int numParams) { return b_AfterburnHaunted[GetNativeCell(1)]; }
public int Native_CFNPCSetAfterburnHaunted(Handle plugin, int numParams)
{ 
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));

	if (npc.b_AfterburnIsHaunted)
		RemoveParticle_TE(npc.Index, VFX_AFTERBURN_HAUNTED);
	else
		RemoveParticle_TE(npc.Index, npc.i_Team == TFTeam_Red ? VFX_AFTERBURN_RED : VFX_AFTERBURN_BLUE);

	b_AfterburnHaunted[npc.Index] = GetNativeCell(2);

	if (npc.b_Burning)
	{
		if (npc.b_AfterburnIsHaunted)
			AttachParticle_TE(npc.Index, VFX_AFTERBURN_HAUNTED);
		else
			AttachParticle_TE(npc.Index, npc.i_Team == TFTeam_Red ? VFX_AFTERBURN_RED : VFX_AFTERBURN_BLUE);
	}

	return 0;
}

public any Native_CFNPCIgnite(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));

	float burnTime = GetNativeCell(2);
	float minBurnTime = GetNativeCell(3);
	float maxBurnTime = GetNativeCell(4);
	float burnDMG = GetNativeCell(5);
	bool haunted = GetNativeCell(6);
	int attacker = GetNativeCell(7);

	float gt = GetGameTime();

	Action result = Plugin_Continue;

	Call_StartForward(g_OnCFNPCIgnited);
	Call_PushCell(npc);
	Call_PushFloatRef(burnTime);
	Call_PushFloatRef(minBurnTime);
	Call_PushFloatRef(maxBurnTime);
	Call_PushCellRef(attacker);
	Call_PushCellRef(haunted);
	Call_PushFloatRef(burnDMG);
	Call_Finish(result);
		
	if (result != Plugin_Handled && result != Plugin_Stop)
	{
		bool AddDirectly = false;
		if (npc.b_Burning)
		{
			float current = npc.f_AfterburnEndTime - gt;

			if (current + burnTime >= maxBurnTime && maxBurnTime > 0.0)
			{
				current += burnTime;
				if (current > maxBurnTime)
				{
					burnTime = maxBurnTime;
				}
			}
			else if (current + burnTime < minBurnTime)
			{
				burnTime = (minBurnTime - current);
			}
			else
			{
				AddDirectly = true;
			}
		}
		else if (burnTime < minBurnTime)
		{
			burnTime = minBurnTime;
		}

		if (!AddDirectly)
			npc.f_AfterburnEndTime = gt + burnTime;
		else
			npc.f_AfterburnEndTime += burnTime;

		npc.i_AfterburnAttacker = attacker;
		npc.b_AfterburnIsHaunted = haunted;
		npc.f_AfterburnDMG = burnDMG;
	}

	return true;
}

public any Native_CFNPCExtinguish(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	bool forced = GetNativeCell(2);

	bool result = true;

	Call_StartForward(g_OnCFNPCExtinguished);
	Call_PushCell(npc);
	Call_Finish(result);

	if (result || forced)
	{
		npc.f_AfterburnEndTime = 0.0;
		npc.b_AfterburnIsHaunted = false;
		npc.i_AfterburnAttacker = 0;
		npc.f_AfterburnDMG = 0.0;
	}
	else
	{
		float gt = GetGameTime();

		npc.f_AfterburnEndTime = gt + 1.0;
		f_NextBurn[npc.Index] = gt + 0.5;
	}

	return result;
}

public any Native_CFNPCBleed(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));

	float bleedTime = GetNativeCell(2);
	float bleedDMG = GetNativeCell(3);
	int attacker = GetNativeCell(4);

	Call_StartForward(g_OnCFNPCBleed);

	Call_PushCell(npc);
	Call_PushFloatRef(bleedTime);
	Call_PushFloatRef(bleedDMG);
	Call_PushCellRef(attacker);

	Action result;
	Call_Finish(result);

	if (result != Plugin_Stop && result != Plugin_Handled)
	{
		DataPack pack = new DataPack();
		CreateDataTimer(0.5, CFNPC_BleedTimer, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, EntIndexToEntRef(npc.Index));
		WritePackFloat(pack, GetGameTime() + bleedTime + 0.1);
		WritePackFloat(pack, bleedDMG);
		WritePackCell(pack, EntIndexToEntRef(attacker));

		i_BleedStacks[npc.Index]++;

		return true;
	}

	return false;
}

public Action CFNPC_BleedTimer(Handle bleed, DataPack pack)
{
	ResetPack(pack);
	int npc = EntRefToEntIndex(ReadPackCell(pack));
	if (!IsValidEntity(npc))
		return Plugin_Stop;

	if (I_AM_DEAD[npc])
		return Plugin_Stop;

	float endTime = ReadPackFloat(pack);
	if (GetGameTime() >= endTime)
	{
		i_BleedStacks[npc]--;
		return Plugin_Stop;
	}

	float dmg = ReadPackFloat(pack);
	int attacker = EntRefToEntIndex(ReadPackCell(pack));

	SDKHooks_TakeDamage(npc, 0, IsValidEntity(attacker) ? attacker : 0, dmg, _, _, _, _, false);
	return Plugin_Continue;
}

public any Native_CFNPCGetBleeding(Handle plugin, int numParams) { return i_BleedStacks[GetNativeCell(1)] > 0; }

public int Native_CFNPCModifySpeed(Handle plugin, int numParams) 
{ 
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	float mod = GetNativeCell(2);
	int mode = GetNativeCell(3);
	float duration = GetNativeCell(4);

	float diff;
	if (mode <= 0)
	{
		float current = npc.f_MaxSpeed;
		current *= mod;
		diff = current - npc.f_MaxSpeed;
	}
	else
	{
		if (mode == 1)
		{
			float current = npc.f_Speed;
			current *= mod;
			diff = current - npc.f_Speed;
		}
		else
		{
			diff = mod;
		}
	}

	npc.f_Speed += diff;
	if (npc.f_Speed < 0.0)
	{
		diff += npc.f_Speed;
		npc.f_Speed = 0.0;
	}

	DataPack pack = new DataPack();
	CreateDataTimer(duration, CFNPC_RemoveTemporarySpeedChange, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntIndexToEntRef(npc.Index));
	WritePackFloat(pack, diff);

	return 0;
}

public Action CFNPC_RemoveTemporarySpeedChange(Handle timer, DataPack pack)
{
	ResetPack(pack);

	int ent = EntRefToEntIndex(ReadPackCell(pack));
	float diff = ReadPackFloat(pack);

	if (!IsValidEntity(ent))
		return Plugin_Continue;

	view_as<CFNPC>(ent).f_Speed -= diff;

	return Plugin_Continue;
}

public int Native_CFNPCSetBoundingBox(Handle plugin, int numParams)
{
	CFNPC npc = view_as<CFNPC>(GetNativeCell(1));
	float mins[3], maxs[3];
	GetNativeArray(2, mins, sizeof(mins));
	GetNativeArray(3, maxs, sizeof(maxs));

	float scale = 1.1;	//We always scale 10% bigger because otherwise certain projectiles (balls, cleavers, jars) harmlessly bounce off at certain angles.
	if (GetNativeCell(4))
	{
		scale *= npc.f_Scale;
	}

	ScaleVector(mins, scale);
	ScaleVector(maxs, scale);

	npc.GetBaseNPC().SetBodyMaxs(maxs);
	npc.GetBaseNPC().SetBodyMins(mins);

	SetEntPropVector(npc.Index, Prop_Data, "m_vecMaxs", maxs);
	SetEntPropVector(npc.Index, Prop_Data, "m_vecMins", mins);

	return 0;
}

Handle CFNPC_HitByBlast = null;

public int Native_CFNPCExplosion(Handle plugin, int numParams)
{
	float pos[3];
	GetNativeArray(1, pos, sizeof(pos));
	float radius = GetNativeCell(2);
	float damage = GetNativeCell(3);
	float falloffStartRange = GetNativeCell(4);
	float falloffEndRange = GetNativeCell(5);
	float falloffMax = GetNativeCell(6);
	int inflictor = GetNativeCell(7);
	int weapon = GetNativeCell(8);
	int attacker = GetNativeCell(9);
	int damageType = GetNativeCell(10);
	bool skipLOS = GetNativeCell(11);
	bool ignoreInvuln = GetNativeCell(12);
	bool hitAttacker = GetNativeCell(13);

	char filterPlugin[255], hitPlugin[255];
	Function filterFunction = GetNativeFunction(14);
	GetNativeString(15, filterPlugin, sizeof(filterPlugin));
	Function hitFunction = GetNativeFunction(16);
	GetNativeString(17, hitPlugin, sizeof(hitPlugin));

	delete CFNPC_HitByBlast;
	CFNPC_HitByBlast = CreateArray(255);
	
	TR_EnumerateEntitiesSphere(pos, radius, PARTITION_NON_STATIC_EDICTS, CFNPC_BlastTrace, attacker);
	
	for (int i = 0; i < GetArraySize(CFNPC_HitByBlast); i++)
	{
		int victim = EntRefToEntIndex(GetArrayCell(CFNPC_HitByBlast, i));
		if (IsValidEntity(victim))
		{
			if (IsValidClient(victim))
			{
				if (!IsPlayerAlive(victim) || (IsInvuln(victim) && !ignoreInvuln) || (victim == attacker && !hitAttacker))
					continue;
			}

			if (!GetEntProp(victim, Prop_Data, "m_takedamage") && !ignoreInvuln)
				continue;
			
			float vicLoc[3];
			CF_WorldSpaceCenter(victim, vicLoc);
			
			bool passed = true;
					
			if (!skipLOS)
			{
				Handle trace = TR_TraceRayFilterEx(pos, vicLoc, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, CFNPC_AOETrace, victim);
				passed = !TR_DidHit(trace);
				delete trace;
			}
			
			if (filterFunction != INVALID_FUNCTION && !StrEqual(filterPlugin, ""))
			{
				Call_StartFunction(GetPluginHandle(filterPlugin), filterFunction);
				Call_PushCell(victim);
				Call_PushCell(attacker);
				Call_PushCell(inflictor);
				Call_PushCell(weapon);
				Call_PushFloat(damage);
				Call_Finish(passed);
			}
					
			if (passed)
			{
				float dist = GetVectorDistance(pos, vicLoc);

				float realDMG = damage;
				if (dist > falloffStartRange && falloffStartRange >= 0.0)
				{
					realDMG *= 1.0 - (((dist - falloffStartRange) / (falloffEndRange - falloffStartRange)) * falloffMax);
				}
				
				//If the weapon is valid and the victim is a building or prop_physics, deal damage multiplied by building damage attributes:
				if (IsValidEntity(weapon))
				{
					char classname[255];
					GetEntityClassname(victim, classname, sizeof(classname));

					if (GetEntSendPropOffs(weapon, "m_AttributeList") > 0 && (StrEqual(classname, "obj_sentrygun") || StrEqual(classname, "obj_dispenser")
					|| StrEqual(classname, "obj_teleporter") || StrContains(classname, "prop_physics") != -1))
					{
						realDMG *= GetAttributeValue(weapon, 137, 1.0) * GetAttributeValue(weapon, 775, 1.0);
					}
				}
				
				SDKHooks_TakeDamage(victim, inflictor, attacker, realDMG, damageType, weapon, _, pos, false);

				if (hitFunction != INVALID_FUNCTION && !StrEqual(hitPlugin, ""))
				{
					Call_StartFunction(GetPluginHandle(hitPlugin), hitFunction);
					Call_PushCell(victim);
					Call_PushCell(attacker);
					Call_PushCell(inflictor);
					Call_PushCell(weapon);
					Call_PushFloat(damage);
					Call_Finish();
				}
			}
		}
	}
	
	delete CFNPC_HitByBlast;

	return 0;
}

public bool CFNPC_BlastTrace(int entity, int attacker)
{
	//If the victim does not have a team affiliation: never hit.
	if (!HasEntProp(entity, Prop_Send, "m_iTeamNum"))
		return true;
	
	//If the attacker is not a valid entity or is the console: always hit.
	if (!IsValidEntity(attacker) || attacker <= 0)
	{
		PushArrayCell(CFNPC_HitByBlast, EntIndexToEntRef(entity));
		return true;
	}

	//If the attacker does not have a team affiliation: always hit.
	if (!HasEntProp(attacker, Prop_Send, "m_iTeamNum"))
	{
		PushArrayCell(CFNPC_HitByBlast, EntIndexToEntRef(entity));
		return true;
	}

	//If the victim is not on the attacker's team, or the victim IS the attacker: always hit.
	if (GetEntProp(entity, Prop_Send, "m_iTeamNum") != GetEntProp(attacker, Prop_Send, "m_iTeamNum") || (entity == attacker))
	{
		PushArrayCell(CFNPC_HitByBlast, EntIndexToEntRef(entity));
		return true;
	}
	
	return true;
}

public bool CFNPC_AOETrace(entity, contentsmask, target)
{
	if (!CFNPC_LOSCheck(entity, contentsmask))
		return false;
		
	return entity != target;
}

public bool CFNPC_LOSCheck(entity, contentsMask)
{
	if (entity <= MaxClients || view_as<CFNPC>(entity).b_Exists)
		return false;
	
	char classname[255];
	GetEntityClassname(entity, classname, sizeof(classname));
	
	if (StrContains(classname, "tf_projectile") != -1 || StrContains(classname, "info_") != -1 || StrContains(classname, "trigger_") != -1)
		return false;
		
	if (StrContains(classname, "func_") != -1)
	{
		if (!StrEqual("func_brush", classname)
			&& !StrEqual("func_door", classname) && !StrEqual("func_detail", classname) && !StrEqual("func_wall", classname) && !StrEqual("func_rotating", classname)
			&& !StrEqual("func_reflective_glass", classname) && !StrEqual("func_physbox", classname) && !StrEqual("func_movelinear", classname) && !StrEqual("func_door_rotating", classname)
			&& !StrEqual("func_breakable", classname))
		{
			return false;
		}
	}
		
	return true;
}

public any Native_CFNPCIsThisAnNPC(Handle plugin, int numParams)
{
	int ent = GetNativeCell(1);

	if (!IsValidEntity(ent))
		return false;

	char classname[255];
	GetEntityClassname(ent, classname, sizeof(classname));

	if (StrContains(classname, "base_boss") != -1)
		return true;

	return view_as<CFNPC>(ent).b_Exists;
}