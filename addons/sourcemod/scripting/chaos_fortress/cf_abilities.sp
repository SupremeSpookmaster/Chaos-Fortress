float f_UltChargeRequired[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltCharge[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltChargeOnRegen[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltChargeOnDamage[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltChargeOnHurt[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltChargeOnHeal[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltChargeOnKill[MAXPLAYERS + 1] = { 0.0, ... };
float f_ResourceRegenInterval[MAXPLAYERS + 1] = { 0.0, ... };
float f_ResourceRegenNext[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltCD[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltCDEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_M2CD[MAXPLAYERS + 1] = { 0.0, ... };
float f_M2CDEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_M3CD[MAXPLAYERS + 1] = { 0.0, ... };
float f_M3CDEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_ReloadCD[MAXPLAYERS + 1] = { 0.0, ... };
float f_ReloadCDEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_M2Cost[MAXPLAYERS + 1] = { 0.0, ... };
float f_M3Cost[MAXPLAYERS + 1] = { 0.0, ... };
float f_ReloadCost[MAXPLAYERS + 1] = { 0.0, ... };
float f_ResourceMax[MAXPLAYERS + 1] = { 0.0, ... };
float f_Resources[MAXPLAYERS + 1] = { 0.0, ... };
float f_ResourcesOnRegen[MAXPLAYERS + 1] = { 0.0, ... };
float f_ResourcesOnDamage[MAXPLAYERS + 1] = { 0.0, ... };
float f_ResourcesOnHurt[MAXPLAYERS + 1] = { 0.0, ... };
float f_ResourcesOnHeal[MAXPLAYERS + 1] = { 0.0, ... };
float f_ResourcesOnKill[MAXPLAYERS + 1] = { 0.0, ... };
float f_NextResourceRegen[MAXPLAYERS + 1] = { 0.0, ... };
float f_ResourcesSinceLastGain[MAXPLAYERS + 1] = { 0.0, ... };
float f_ResourcesToTriggerSound[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltScale[MAXPLAYERS + 1] = { 0.0, ... };
float f_M2Scale[MAXPLAYERS + 1] = { 0.0, ... };
float f_M3Scale[MAXPLAYERS + 1] = { 0.0, ... };
float f_RScale[MAXPLAYERS + 1] = { 0.0, ... };
float f_CancelTemporarySpeedMod[MAXPLAYERS + 1] = { 0.0, ... };
float f_NextShieldCollisionForward[2049][2049];
float f_ChargeRetain = 0.0;
float f_FakeMediShieldHP[2049] = { 0.0, ... };
float f_FakeMediShieldMaxHP[2049] = { 0.0, ... };

char s_UltName[MAXPLAYERS + 1][255];
char s_M2Name[MAXPLAYERS + 1][255];
char s_M3Name[MAXPLAYERS + 1][255];
char s_ReloadName[MAXPLAYERS + 1][255];
char s_ResourceName[MAXPLAYERS + 1][255];
char s_ResourceName_Plural[MAXPLAYERS + 1][255];

bool b_CharacterHasUlt[MAXPLAYERS + 1] = { false, ... };
bool b_UsingResources[MAXPLAYERS + 1] = { false, ... };
bool b_M2IsHeld[MAXPLAYERS + 1] = { false, ... };
bool b_M3IsHeld[MAXPLAYERS + 1] = { false, ... };
bool b_ReloadIsHeld[MAXPLAYERS + 1] = { false, ... };
bool b_ResourceIsUlt[MAXPLAYERS + 1] = { false, ... };
bool b_ResourceIsPercentage[MAXPLAYERS + 1] = { false, ... };
bool b_ResourceIsMetal[MAXPLAYERS + 1] = { false, ... };
bool b_UseHUD[MAXPLAYERS + 1] = { false, ... };
bool b_HasM2[MAXPLAYERS + 1] = { false, ... };
bool b_HasM3[MAXPLAYERS + 1] = { false, ... };
bool b_HasReload[MAXPLAYERS + 1] = { false, ... };
bool b_HoldingReload[MAXPLAYERS + 1] = { false, ... };
bool b_HoldingM2[MAXPLAYERS + 1] = { false, ... };
bool b_HoldingM3[MAXPLAYERS + 1] = { false, ... };
bool b_ForceEndHeldM2[MAXPLAYERS + 1] = { false, ... };
bool b_ForceEndHeldM3[MAXPLAYERS + 1] = { false, ... };
bool b_ForceEndHeldReload[MAXPLAYERS + 1] = { false, ... };
bool b_UltBlocked[MAXPLAYERS + 1] = { false, ... };
bool b_M2Blocked[MAXPLAYERS + 1] = { false, ... };
bool b_M3Blocked[MAXPLAYERS + 1] = { false, ... };
bool b_ReloadBlocked[MAXPLAYERS + 1] = { false, ... };
bool b_UltIsGrounded[MAXPLAYERS + 1] = { false, ... };
bool b_M2IsGrounded[MAXPLAYERS + 1] = { false, ... };
bool b_M3IsGrounded[MAXPLAYERS + 1] = { false, ... };
bool b_ReloadIsGrounded[MAXPLAYERS + 1] = { false, ... };
bool b_IsFakeHealthKit[2049] = { false, ... };
bool b_HeldM2BlocksOthers[MAXPLAYERS + 1] = { false, ... };
bool b_HeldM3BlocksOthers[MAXPLAYERS + 1] = { false, ... };
bool b_HeldReloadBlocksOthers[MAXPLAYERS + 1] = { false, ... };
bool b_IsMedigunShield[2049] = { false, ... };

GlobalForward g_OnAbility;
GlobalForward g_OnUltUsed;
GlobalForward g_OnM2Used;
GlobalForward g_OnM3Used;
GlobalForward g_OnReloadUsed;
GlobalForward g_OnHeldStart;
GlobalForward g_OnHeldEnd;
GlobalForward g_OnHeldEnd_Ability;
GlobalForward g_ResourceGiven;
GlobalForward g_UltChargeGiven;
GlobalForward g_ResourceApplied;
GlobalForward g_UltChargeApplied;
GlobalForward g_ProjectileTeamChanged;
GlobalForward g_PassFilter;
GlobalForward g_ShouldCollide;
GlobalForward g_FakeMediShieldCollision;
GlobalForward g_FakeMediShieldDamaged;
GlobalForward g_AttemptAbility;
GlobalForward g_SimulatedSpellCast;
GlobalForward g_ForcedVMAnimEnd;
GlobalForward g_OnHUDDisplayed;

int i_GenericProjectileOwner[2049] = { -1, ... };
int i_HealingDone[MAXPLAYERS + 1] = { 0, ... };
int i_UltWeaponSlot[MAXPLAYERS + 1] = { -1, ... };
int i_M2WeaponSlot[MAXPLAYERS + 1] = { -1, ... };
int i_M3WeaponSlot[MAXPLAYERS + 1] = { -1, ... };
int i_ReloadWeaponSlot[MAXPLAYERS + 1] = { -1, ... };
int i_UltAmmo[MAXPLAYERS + 1] = { -1, ... };
int i_M2Ammo[MAXPLAYERS + 1] = { -1, ... };
int i_M3Ammo[MAXPLAYERS + 1] = { -1, ... };
int i_ReloadAmmo[MAXPLAYERS + 1] = { -1, ... };
int i_HUDR[MAXPLAYERS + 1] = { 255, ... };
int i_HUDG[MAXPLAYERS + 1] = { 255, ... };
int i_HUDB[MAXPLAYERS + 1] = { 255, ... };
int i_HUDA[MAXPLAYERS + 1] = { 255, ... };

int i_M2Stocks[MAXPLAYERS + 1] = { 0, ... };
int i_M2MaxStocks[MAXPLAYERS + 1] = { 0, ... };
int i_M3Stocks[MAXPLAYERS + 1] = { 0, ... };
int i_M3MaxStocks[MAXPLAYERS + 1] = { 0, ... };
int i_ReloadStocks[MAXPLAYERS + 1] = { 0, ... };
int i_ReloadMaxStocks[MAXPLAYERS + 1] = { 0, ... };

char s_ProjectileLogicPlugin[2049][255];
Function g_ProjectileLogic[2049] = { INVALID_FUNCTION, ... };

//int MODEL_NONE = -1;

bool b_ProjectileCanCollideWithAllies[2049] = { false, ... };
bool b_IsProjectile[2049] = { false, ... };

CF_AbilityType i_HeldBlocked[MAXPLAYERS + 1] = { CF_AbilityType_None, ... };

public void CFA_MakeNatives()
{
	CreateNative("CF_GiveUltCharge", Native_CF_GiveUltCharge);
	CreateNative("CF_SetUltCharge", Native_CF_SetUltCharge);
	CreateNative("CF_GetUltCharge", Native_CF_GetUltCharge);
	CreateNative("CF_ApplyAbilityCooldown", Native_CF_ApplyAbilityCooldown);
	CreateNative("CF_GetAbilityCooldown", Native_CF_GetAbilityCooldown);
	CreateNative("CF_GiveSpecialResource", Native_CF_GiveSpecialResource);
	CreateNative("CF_SetSpecialResource", Native_CF_SetSpecialResource);
	CreateNative("CF_GetSpecialResource", Native_CF_GetSpecialResource);
	CreateNative("CF_GetMaxSpecialResource", Native_CF_GetMaxSpecialResource);
	CreateNative("CF_SetMaxSpecialResource", Native_CF_SetMaxSpecialResource);
	CreateNative("CF_DoAbility", Native_CF_DoAbility);
	CreateNative("CF_ActivateAbilitySlot", Native_CF_ActivateAbilitySlot);
	CreateNative("CF_EndHeldAbilitySlot", Native_CF_EndHeldAbilitySlot);
	CreateNative("CF_EndHeldAbility", Native_CF_EndHeldAbility);
	CreateNative("CF_HasAbility", Native_CF_HasAbility);
	CreateNative("CF_GetArgI", Native_CF_GetArgI);
	CreateNative("CF_GetArgF", Native_CF_GetArgF);
	CreateNative("CF_GetArgS", Native_CF_GetArgS);
	CreateNative("CF_GetAbilitySlot", Native_CF_GetAbilitySlot);
	CreateNative("CF_GetAbilityConfigMapPath", Native_CF_GetAbilityConfigMapPath);
	CreateNative("CF_IsAbilitySlotBlocked", Native_CF_IsAbilitySlotBlocked);
	CreateNative("CF_BlockAbilitySlot", Native_CF_BlockAbilitySlot);
	CreateNative("CF_UnblockAbilitySlot", Native_CF_UnblockAbilitySlot);
	CreateNative("CF_HealPlayer", Native_CF_HealPlayer);
	CreateNative("CF_FireGenericRocket", Native_CF_FireGenericRocket);
	CreateNative("CF_GenericAOEDamage", Native_CF_GenericAOEDamage);
	CreateNative("CF_CreateHealthPickup", Native_CF_CreateHealthPickup);
	CreateNative("CF_CreateShieldWall", Native_CF_CreateShieldWall);
	CreateNative("CF_GetShieldWallHealth", Native_CF_GetShieldWallHealth);
	CreateNative("CF_GetShieldWallMaxHealth", Native_CF_GetShieldWallMaxHealth);
	CreateNative("CF_CheckIsSlotBlocked", Native_CF_CheckIsSlotBlocked);
	CreateNative("CF_ApplyTemporarySpeedChange", Native_CF_ApplyTemporarySpeedChange);
	CreateNative("CF_ToggleHUD", Native_CF_ToggleHUD);
	CreateNative("CF_Teleport", Native_CF_Teleport);
	CreateNative("CF_CheckTeleport", Native_CF_CheckTeleport);
	CreateNative("CF_ChangeAbilityTitle", Native_CF_ChangeAbilityTitle);
	CreateNative("CF_GetAbilityTitle", Native_CF_GetAbilityTitle);
	CreateNative("CF_ChangeSpecialResourceTitle", Native_CF_ChangeSpecialResourceTitle);
	CreateNative("CF_GetSpecialResourceTitle", Native_CF_GetSpecialResourceTitle);
	CreateNative("CF_SetHUDColor", Native_CF_SetHUDColor);
	CreateNative("CF_WorldSpaceCenter", Native_CF_WorldSpaceCenter);
	CreateNative("CF_IsValidTarget", Native_CF_IsValidTarget);
	CreateNative("CF_GetClosestTarget", Native_CF_GetClosestTarget);
	CreateNative("CF_SimulateSpellbookCast", Native_CF_SimulateSpellbookCast);
	CreateNative("CF_ForceViewmodelAnimation", Native_CF_ForceViewmodelAnimation);
	CreateNative("CF_SetAbilityStocks", Native_CF_SetAbilityStocks);
	CreateNative("CF_SetAbilityMaxStocks", Native_CF_SetAbilityMaxStocks);
	CreateNative("CF_GetAbilityStocks", Native_CF_GetAbilityStocks);
	CreateNative("CF_GetAbilityMaxStocks", Native_CF_GetAbilityMaxStocks);
	CreateNative("CF_SetLocalOrigin", Native_CF_SetLocalOrigin);
}

Handle g_hSDKWorldSpaceCenter;
DynamicHook g_DHookRocketExplode;
Handle g_hSetLocalOrigin;
/*Handle g_hSDKResetSequence;
Handle g_hSDKLookupSequence;
Handle g_hSDKGetSequenceDuration;
Handle g_hSDKGetModelPtr;*/

public void CFA_MakeForwards()
{
	g_OnAbility = new GlobalForward("CF_OnAbility", ET_Ignore, Param_Cell, Param_String, Param_String);
	g_OnUltUsed = new GlobalForward("CF_OnUltUsed", ET_Event, Param_Cell);
	g_OnM2Used = new GlobalForward("CF_OnM2Used", ET_Event, Param_Cell);
	g_OnM3Used = new GlobalForward("CF_OnM3Used", ET_Event, Param_Cell);
	g_OnReloadUsed = new GlobalForward("CF_OnReloadUsed", ET_Event, Param_Cell);
	g_OnHeldStart = new GlobalForward("CF_OnHeldStart", ET_Event, Param_Cell, Param_Cell);
	g_OnHeldEnd = new GlobalForward("CF_OnHeldEnd", ET_Event, Param_Cell, Param_Cell, Param_Cell);
	g_OnHeldEnd_Ability = new GlobalForward("CF_OnHeldEnd_Ability", ET_Event, Param_Cell, Param_Cell, Param_String, Param_String);
	g_ResourceGiven = new GlobalForward("CF_OnSpecialResourceGiven", ET_Event, Param_Cell, Param_FloatByRef);
	g_UltChargeGiven = new GlobalForward("CF_OnUltChargeGiven", ET_Event, Param_Cell, Param_FloatByRef);
	g_ResourceApplied = new GlobalForward("CF_OnSpecialResourceApplied", ET_Event, Param_Cell, Param_Float, Param_FloatByRef);
	g_UltChargeApplied = new GlobalForward("CF_OnUltChargeApplied", ET_Event, Param_Cell, Param_Float, Param_FloatByRef);
	g_ProjectileTeamChanged = new GlobalForward("CF_OnGenericProjectileTeamChanged", ET_Ignore, Param_Cell, Param_Cell);
	g_PassFilter = new GlobalForward("CF_OnPassFilter", ET_Event, Param_Cell, Param_Cell, Param_CellByRef);
	g_ShouldCollide = new GlobalForward("CF_OnShouldCollide", ET_Event, Param_Cell, Param_Cell, Param_CellByRef);
	g_FakeMediShieldCollision = new GlobalForward("CF_OnFakeMediShieldCollision", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_FakeMediShieldDamaged = new GlobalForward("CF_OnFakeMediShieldDamaged", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_FloatByRef, Param_CellByRef, Param_Cell);
	g_AttemptAbility = new GlobalForward("CF_OnAbilityCheckCanUse", ET_Event, Param_Cell, Param_String, Param_String, Param_Cell, Param_CellByRef);
	g_SimulatedSpellCast = new GlobalForward("CF_OnSimulatedSpellUsed", ET_Ignore, Param_Cell, Param_Cell);
	g_ForcedVMAnimEnd = new GlobalForward("CF_OnForcedVMAnimEnd", ET_Ignore, Param_Cell, Param_String);
	g_OnHUDDisplayed = new GlobalForward("CF_OnHUDDisplayed", ET_Ignore, Param_Cell, Param_String, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	
	GameData gd = LoadGameConfigFile("chaos_fortress");
	
	//WorldSpaceCenter:
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gd, SDKConf_Virtual, "CBaseEntity::WorldSpaceCenter");
	PrepSDKCall_SetReturnInfo(SDKType_Vector, SDKPass_ByRef);
	if ((g_hSDKWorldSpaceCenter = EndPrepSDKCall()) == null) SetFailState("Failed to create SDKCall for CBaseEntity::WorldSpaceCenter offset!");
	
	//CTFBaseRocket::Explode:
	g_DHookRocketExplode = DHook_CreateVirtual(gd, "CTFBaseRocket::Explode");

	//SetLocalOrigin
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "CBaseEntity::SetLocalOrigin");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	g_hSetLocalOrigin = EndPrepSDKCall();
	if(!g_hSetLocalOrigin)
		LogError("[Gamedata] Could not find CBaseEntity::SetLocalOrigin");
	
	delete gd;
}

public void CFA_OGF()
{
	CFA_ScanProjectiles();
}

public void CFA_ScanProjectiles()
{
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "tf_projectile_*")) != -1)
	{
		if (i_GenericProjectileOwner[entity] != -1)
		{
			int currentOwner = GetClientOfUserId(i_GenericProjectileOwner[entity]);
			int newOwner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
			
			if (newOwner != currentOwner && IsValidClient(currentOwner) && IsValidClient(newOwner))
			{
				if (TF2_GetClientTeam(currentOwner) != TF2_GetClientTeam(newOwner))
				{
					Call_StartForward(g_ProjectileTeamChanged);
					
					Call_PushCell(entity);
					Call_PushCell(TF2_GetClientTeam(newOwner));
					
					Call_Finish();
				}
				
				i_GenericProjectileOwner[entity] = GetClientUserId(newOwner);
			}
		}
	}
}

public void CFA_AddHealingPoints(int client, int amt)
{
	i_HealingDone[client] += amt;
}

public void CFA_Disconnect(int client)
{
	i_HealingDone[client] = 0;
}

public void CFA_OnEntityDestroyed(int entity)
{
	i_GenericProjectileOwner[entity] = -1;
	b_IsFakeHealthKit[entity] = false;
	b_IsMedigunShield[entity] = false;
	b_IsProjectile[entity] = false;
	f_FakeMediShieldHP[entity] = 0.0;
	f_FakeMediShieldMaxHP[entity] = 0.0;
	b_ProjectileCanCollideWithAllies[entity] = false;
	strcopy(s_ProjectileLogicPlugin[entity], 255, "");
	g_ProjectileLogic[entity] = INVALID_FUNCTION;
}

void CFA_UpdateMadeCharacter(int client)
{
	f_CancelTemporarySpeedMod[client] = GetGameTime() + 0.5;
}

public Action GetOwner(int ent)
{
	if (!IsValidEntity(ent))
		return Plugin_Continue;
		
	int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if (IsValidClient(owner))
		i_GenericProjectileOwner[ent] = GetClientUserId(owner);
	
	return Plugin_Continue;
}

Handle HudSync;

bool b_HUDTimerActive = false;

#define NOPE				"replay/record_fail.wav"
#define HEAL_DEFAULT		"items/smallmedkit1.wav"
#define HEAL_DEFAULT_MODEL	"models/items/medkit_medium.mdl"

#define SOUND_SPEED_APPLY		"weapons/discipline_device_power_up.wav"
#define SOUND_SPEED_REMOVE		"weapons/discipline_device_power_down.wav"

public void CFA_MapStart()
{
	HudSync = CreateHudSynchronizer();

	b_HUDTimerActive = false;
	
	PrecacheSound(NOPE);
	PrecacheSound(HEAL_DEFAULT);
	PrecacheModel(HEAL_DEFAULT_MODEL);
	
	PrecacheSound(SOUND_SPEED_APPLY);
	PrecacheSound(SOUND_SPEED_REMOVE);
	
	int entity = FindEntityByClassname(MaxClients + 1, "tf_player_manager");
	if(IsValidEntity(entity))
		SDKHook(entity, SDKHook_ThinkPost, ScoreThink);
		
	//MODEL_NONE = PrecacheModel("models/empty.mdl");
}

public void ScoreThink(int entity)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsValidClient(client))
		{
			SetEntProp(client, Prop_Send, "m_iHealPoints", i_HealingDone[client]);
		}
	}
}

public Action CFA_HUDTimer(Handle timer)
{
	int rState = CF_GetRoundState();
	bool wouldBeStuck;
	bool tooPoor;
	bool CanUse;
	float remCD;
	
	for (int client = 1; client <= MaxClients; client++)
	{
		if (CF_IsPlayerCharacter(client))
		{
			bool showHUD = GetClientButtons(client) & IN_SCORE == 0 && b_UseHUD[client];
			if (IsPlayerAlive(client))
			{
				char HUDText[255];
				
				if (b_CharacterHasUlt[client])
				{
					remCD = CF_GetAbilityCooldown(client, CF_AbilityType_Ult);
					if (remCD < 0.1 && rState == 1)
					{
						CF_GiveUltCharge(client, f_UltChargeOnRegen[client]/10.0, CF_ResourceType_Percentage);
					}
					
					if (showHUD)
					{
						CanUse = CF_CanPlayerUseAbilitySlot(client, CF_AbilityType_Ult, wouldBeStuck, tooPoor);
						
						if ((!CanUse && !tooPoor && !wouldBeStuck) || CF_GetRoundState() != 1)
						{
							Format(HUDText, sizeof(HUDText), "%s: %i[PERCENT] [BLOCKED]\n", s_UltName[client], RoundToFloor((f_UltCharge[client]/f_UltChargeRequired[client]) * 100.0));
						}
						else if (wouldBeStuck && !tooPoor)
						{
							Format(HUDText, sizeof(HUDText), "%s: %i[PERCENT] [BLOCKED; YOU WOULD GET STUCK]\n", s_UltName[client], RoundToFloor((f_UltCharge[client]/f_UltChargeRequired[client]) * 100.0));
						}
						else
						{
							Format(HUDText, sizeof(HUDText), "%s: %i[PERCENT] %s\n", s_UltName[client], RoundToFloor((f_UltCharge[client]/f_UltChargeRequired[client]) * 100.0), f_UltCharge[client] >= f_UltChargeRequired[client] ? "(READY, CALL FOR MEDIC)" : "");
						}
					}
				}
				
				if (b_UsingResources[client] && !b_ResourceIsUlt[client])
				{
					if (GetGameTime() >= f_NextResourceRegen[client] && GetGameTime() >= f_ResourceRegenNext[client])
					{
						CF_GiveSpecialResource(client, 1.0, CF_ResourceType_Regen);
						f_ResourceRegenNext[client] = GetGameTime() + f_ResourceRegenInterval[client];
					}
					
					if (showHUD)
					{
						if (f_ResourceMax[client] > 0.0)
						{
							if (b_ResourceIsPercentage[client])
								Format(HUDText, sizeof(HUDText), "%s\n%s: %i[PERCENT]\n", HUDText, CF_GetSpecialResource(client) != 1.0 ? s_ResourceName_Plural[client] : s_ResourceName[client], RoundToFloor((CF_GetSpecialResource(client)/f_ResourceMax[client]) * 100.0));
							else
								Format(HUDText, sizeof(HUDText), "%s\n%s: %i/%i\n", HUDText, CF_GetSpecialResource(client) != 1.0 ? s_ResourceName_Plural[client] : s_ResourceName[client], RoundToFloor(CF_GetSpecialResource(client)), RoundToFloor(f_ResourceMax[client]));
						}
						else
						{
							Format(HUDText, sizeof(HUDText), "%s\n%s: %i\n", HUDText, CF_GetSpecialResource(client) != 1.0 ? s_ResourceName_Plural[client] : s_ResourceName[client], RoundToFloor(CF_GetSpecialResource(client)));
						}
					}
				}
				
				if (showHUD)
				{
					if (b_HasM2[client])
					{
						CanUse = CF_CanPlayerUseAbilitySlot(client, CF_AbilityType_M2, wouldBeStuck, tooPoor, remCD);

						char prefix[255], suffix[255];
						if (AbilityUsesStocks(client, CF_AbilityType_M2))
							Format(suffix, sizeof(suffix), "[%i/%i]", i_M2Stocks[client], i_M2MaxStocks[client]);

						if (!CanUse && !tooPoor && !wouldBeStuck && remCD < 0.1)
						{
							Format(prefix, sizeof(prefix), "[BLOCKED]");
						}
						else if (wouldBeStuck && !tooPoor)
						{
							Format(prefix, sizeof(prefix), "[BLOCKED; YOU WOULD GET STUCK]");
						}
						else
						{
							if (b_UsingResources[client] && f_M2Cost[client] > 0.0)
							{
								if (b_ResourceIsUlt[client])
								{
									Format(suffix, sizeof(suffix), "%s [%.2f[PERCENT] Ult.]", suffix, (f_M2Cost[client]/f_UltChargeRequired[client]) * 100.0);
								}
								else
								{
									if (b_ResourceIsPercentage[client] && f_ResourceMax[client] > 0.0)
										Format(suffix, sizeof(suffix), "%s [%i[PERCENT] %s]", suffix, RoundToFloor((f_M2Cost[client]/f_ResourceMax[client]) * 100.0), f_M2Cost[client] != 1.0 ? s_ResourceName_Plural[client] : s_ResourceName[client]);
									else
										Format(suffix, sizeof(suffix), "%s [%i %s]", suffix, RoundToFloor(f_M2Cost[client]), f_M2Cost[client] != 1.0 ? s_ResourceName_Plural[client] : s_ResourceName[client]);
								}
							}
							
							remCD = CF_GetAbilityCooldown(client, CF_AbilityType_M2);
							if (remCD > 0.0)
								Format(suffix, sizeof(suffix), "%s (%.1f)", suffix, remCD);

							Format(prefix, sizeof(prefix), "%s", b_M2IsHeld[client] ? (b_HoldingM2[client] ? "[ACTIVE]" : "[Hold M2]") : "[M2]");
						}

						Format(HUDText, sizeof(HUDText), "%s %s %s %s\n", HUDText, prefix, s_M2Name[client], suffix);
					}
					
					if (b_HasM3[client])
					{
						CanUse = CF_CanPlayerUseAbilitySlot(client, CF_AbilityType_M3, wouldBeStuck, tooPoor, remCD);

						char prefix[255], suffix[255];
						if (AbilityUsesStocks(client, CF_AbilityType_M3))
							Format(suffix, sizeof(suffix), "[%i/%i]", i_M3Stocks[client], i_M3MaxStocks[client]);

						if (!CanUse && !tooPoor && !wouldBeStuck && remCD < 0.1)
						{
							Format(prefix, sizeof(prefix), "[BLOCKED]");
						}
						else if (wouldBeStuck && !tooPoor)
						{
							Format(prefix, sizeof(prefix), "[BLOCKED; YOU WOULD GET STUCK]");
						}
						else
						{
							if (b_UsingResources[client] && f_M3Cost[client] > 0.0)
							{
								if (b_ResourceIsUlt[client])
								{
									Format(suffix, sizeof(suffix), "%s [%.2f[PERCENT] Ult.]", suffix, (f_M3Cost[client]/f_UltChargeRequired[client]) * 100.0);
								}
								else
								{
									if (b_ResourceIsPercentage[client] && f_ResourceMax[client] > 0.0)
										Format(suffix, sizeof(suffix), "%s [%i[PERCENT] %s]", suffix, RoundToFloor((f_M3Cost[client]/f_ResourceMax[client]) * 100.0), f_M3Cost[client] != 1.0 ? s_ResourceName_Plural[client] : s_ResourceName[client]);
									else
										Format(suffix, sizeof(suffix), "%s [%i %s]", suffix, RoundToFloor(f_M3Cost[client]), f_M3Cost[client] != 1.0 ? s_ResourceName_Plural[client] : s_ResourceName[client]);
								}
							}
							
							remCD = CF_GetAbilityCooldown(client, CF_AbilityType_M3);
							if (remCD > 0.0)
								Format(suffix, sizeof(suffix), "%s (%.1f)", suffix, remCD);

							Format(prefix, sizeof(prefix), "%s", b_M3IsHeld[client] ? (b_HoldingM3[client] ? "[ACTIVE]" : "[Hold M3]") : "[M3]");
						}

						Format(HUDText, sizeof(HUDText), "%s %s %s %s\n", HUDText, prefix, s_M3Name[client], suffix);
					}
					
					if (b_HasReload[client])
					{
						CanUse = CF_CanPlayerUseAbilitySlot(client, CF_AbilityType_Reload, wouldBeStuck, tooPoor, remCD);

						char prefix[255], suffix[255];
						if (AbilityUsesStocks(client, CF_AbilityType_Reload))
							Format(suffix, sizeof(suffix), "[%i/%i]", i_ReloadStocks[client], i_ReloadMaxStocks[client]);

						if (!CanUse && !tooPoor && !wouldBeStuck && remCD < 0.1)
						{
							Format(prefix, sizeof(prefix), "[BLOCKED]");
						}
						else if (wouldBeStuck && !tooPoor)
						{
							Format(prefix, sizeof(prefix), "[BLOCKED; YOU WOULD GET STUCK]");
						}
						else
						{
							if (b_UsingResources[client] && f_ReloadCost[client] > 0.0)
							{
								if (b_ResourceIsUlt[client])
								{
									Format(suffix, sizeof(suffix), "%s [%.2f[PERCENT] Ult.]", suffix, (f_ReloadCost[client]/f_UltChargeRequired[client]) * 100.0);
								}
								else
								{
									if (b_ResourceIsPercentage[client] && f_ResourceMax[client] > 0.0)
										Format(suffix, sizeof(suffix), "%s [%i[PERCENT] %s]", suffix, RoundToFloor((f_ReloadCost[client]/f_ResourceMax[client]) * 100.0), f_ReloadCost[client] != 1.0 ? s_ResourceName_Plural[client] : s_ResourceName[client]);
									else
										Format(suffix, sizeof(suffix), "%s [%i %s]", suffix, RoundToFloor(f_ReloadCost[client]), f_ReloadCost[client] != 1.0 ? s_ResourceName_Plural[client] : s_ResourceName[client]);
								}
							}
							
							remCD = CF_GetAbilityCooldown(client, CF_AbilityType_Reload);
							if (remCD > 0.0)
								Format(suffix, sizeof(suffix), "%s (%.1f)", suffix, remCD);

							Format(prefix, sizeof(prefix), "%s", b_ReloadIsHeld[client] ? (b_HoldingReload[client] ? "[ACTIVE]" : "[Hold Reload]") : "[Reload]");
						}

						Format(HUDText, sizeof(HUDText), "%s %s %s %s\n", HUDText, prefix, s_ReloadName[client], suffix);
					}
					
					int r = i_HUDR[client];
					int g = i_HUDG[client];
					int b = i_HUDB[client];
					int a = i_HUDA[client];

					Call_StartForward(g_OnHUDDisplayed);

					Call_PushCell(client);
					Call_PushStringEx(HUDText, sizeof(HUDText), SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
					Call_PushCellRef(r);
					Call_PushCellRef(g);
					Call_PushCellRef(b);
					Call_PushCellRef(a);

					Call_Finish();

					ReplaceString(HUDText, sizeof(HUDText), "[PERCENT]", "%%");
					SetHudTextParams(-1.0, 0.8, 0.1, r, g, b, a);
					ShowSyncHudText(client, HudSync, HUDText);
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public void CFA_PlayerKilled(int attacker, int victim)
{
	if (CF_IsPlayerCharacter(attacker) && attacker != victim)
	{
		CF_GiveSpecialResource(attacker, 1.0, CF_ResourceType_Kill);
		
		if (CF_GetRoundState() == 1)
			CF_GiveUltCharge(attacker, 1.0, CF_ResourceType_Kill);
		
		CF_PlayRandomSound(attacker, "", "sound_kill");
	}
	
	if (attacker == victim)
		CF_PlayRandomSound(attacker, "", "sound_suicide");
	
	bool played = CF_PlayRandomSound(victim, "", "sound_killed");
	if (played)
		CF_SilenceCharacter(victim, 2.0);
}

public bool CFA_InitializeUltimate(int client, ConfigMap map)
{
	ConfigMap abilities = map.GetSection("character.abilities");
	ConfigMap subsection = map.GetSection("character.ultimate_stats");
	if (subsection != null)
	{
		subsection.Get("name", s_UltName[client], 255);
		f_UltChargeRequired[client] = GetFloatFromConfigMap(subsection, "charge", 0.0);
		f_UltChargeOnRegen[client] = GetFloatFromConfigMap(subsection, "on_regen", 0.0);
		f_UltChargeOnDamage[client] = GetFloatFromConfigMap(subsection, "on_damage", 0.0);
		f_UltChargeOnHurt[client] = GetFloatFromConfigMap(subsection, "on_hurt", 0.0);
		f_UltChargeOnHeal[client] = GetFloatFromConfigMap(subsection, "on_heal", 0.0);
		f_UltChargeOnKill[client] = GetFloatFromConfigMap(subsection, "on_kill", 0.0);
		f_UltCD[client] = GetFloatFromConfigMap(subsection, "cooldown", 0.0);
		f_UltScale[client] = GetFloatFromConfigMap(subsection, "max_scale", 0.0);
		b_UltIsGrounded[client] = GetBoolFromConfigMap(subsection, "grounded", false);
		i_UltWeaponSlot[client] = GetIntFromConfigMap(subsection, "weapon_slot", -1);
		i_UltAmmo[client] = GetIntFromConfigMap(subsection, "ammo", 0);
		
		CFC_StoreAbilities(client, CF_AbilityType_Ult, abilities);
		
		b_CharacterHasUlt[client] = true;
	}
	else
	{
		b_CharacterHasUlt[client] = false;
	}
	
	return b_CharacterHasUlt[client];
}

Handle g_M2StockTimer[MAXPLAYERS + 1] = { null, ... };
Handle g_M3StockTimer[MAXPLAYERS + 1] = { null, ... };
Handle g_ReloadStockTimer[MAXPLAYERS + 1] = { null, ... };

void DeleteStockTimers(int client)
{
	g_M2StockTimer[client] = null;
	g_M3StockTimer[client] = null;
	g_ReloadStockTimer[client] = null;
}

void CreateStockTimerNextFrame(int client, CF_AbilityType type, float duration)
{
	DataPack pack = new DataPack();
	RequestFrame(CreateIt, pack);
	WritePackCell(pack, GetClientUserId(client));
	WritePackCell(pack, type);
	WritePackFloat(pack, duration);
}

void CreateIt(DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	CF_AbilityType type = ReadPackCell(pack);
	float duration = ReadPackFloat(pack);
	if (CF_IsPlayerCharacter(client))
		CreateStockTimer(client, type, duration);
}

void CreateStockTimer(int client, CF_AbilityType type, float duration)
{
	switch(type)
	{
		case CF_AbilityType_M2:
		{
			if (g_M2StockTimer[client] == null)
			{
				g_M2StockTimer[client] = CreateTimer(duration, Stock_GiveM2, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
				f_M2CDEndTime[client] = GetGameTime() + duration;
			}
		}
		case CF_AbilityType_M3:
		{
			if (g_M3StockTimer[client] == null)
			{
				g_M3StockTimer[client] = CreateTimer(duration, Stock_GiveM3, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
				f_M3CDEndTime[client] = GetGameTime() + duration;
			}
		}
		case CF_AbilityType_Reload:
		{
			if (g_M2StockTimer[client] == null)
			{
				g_ReloadStockTimer[client] = CreateTimer(duration, Stock_GiveReload, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
				f_ReloadCDEndTime[client] = GetGameTime() + duration;
			}
		}
	}
}

public Action Stock_GiveM2(Handle stocky, int id)
{
	int client = GetClientOfUserId(id);
	if (!CF_IsPlayerCharacter(client))
		return Plugin_Continue;

	if (i_M2Stocks[client] < i_M2MaxStocks[client])
		i_M2Stocks[client]++;

	g_M2StockTimer[client] = null;

	if (i_M2Stocks[client] < i_M2MaxStocks[client])
	{
		CreateStockTimerNextFrame(client, CF_AbilityType_M2, f_M2CD[client]);
	}

	return Plugin_Continue;
}

public Action Stock_GiveM3(Handle stocky, int id)
{
	int client = GetClientOfUserId(id);
	if (!CF_IsPlayerCharacter(client))
		return Plugin_Continue;

	if (i_M3Stocks[client] < i_M3MaxStocks[client])
		i_M3Stocks[client]++;

	g_M3StockTimer[client] = null;

	if (i_M3Stocks[client] < i_M3MaxStocks[client])
		CreateStockTimerNextFrame(client, CF_AbilityType_M3, f_M3CD[client]);

	return Plugin_Continue;
}

public Action Stock_GiveReload(Handle stocky, int id)
{
	int client = GetClientOfUserId(id);
	if (!CF_IsPlayerCharacter(client))
		return Plugin_Continue;

	if (i_ReloadStocks[client] < i_ReloadMaxStocks[client])
		i_ReloadStocks[client]++;

	g_ReloadStockTimer[client] = null;

	if (i_ReloadStocks[client] < i_ReloadMaxStocks[client])
		CreateStockTimerNextFrame(client, CF_AbilityType_Reload, f_ReloadCD[client]);

	return Plugin_Continue;
}

public bool CFA_InitializeAbilities(int client, ConfigMap map, bool NewChar)
{
	CFA_InitializeResources(client, map, NewChar);
	
	bool AtLeastOne = false;
	
	ConfigMap abilities = map.GetSection("character.abilities");
	ConfigMap subsection = map.GetSection("character.m2_ability");
	if (subsection != null)
	{
		subsection.Get("name", s_M2Name[client], 255);
		f_M2CD[client] = GetFloatFromConfigMap(subsection, "cooldown", 0.0);
		float startingCD = GetFloatFromConfigMap(subsection, "starting_cd", 0.0)
		CF_ApplyAbilityCooldown(client, startingCD, CF_AbilityType_M2, true, false);
		b_M2IsHeld[client] = GetBoolFromConfigMap(subsection, "held", false);
		if (b_UsingResources[client])
		{
			f_M2Cost[client] = GetFloatFromConfigMap(subsection, "cost", 0.0);
		}
		
		f_M2Scale[client] = GetFloatFromConfigMap(subsection, "max_scale", 0.0);
		b_M2IsGrounded[client] = GetBoolFromConfigMap(subsection, "grounded", false);
		b_HeldM2BlocksOthers[client] = GetBoolFromConfigMap(subsection, "held_block", false) && b_M2IsHeld[client];
		i_M2WeaponSlot[client] = GetIntFromConfigMap(subsection, "weapon_slot", -1);
		i_M2Ammo[client] = GetIntFromConfigMap(subsection, "ammo", 0);

		if (NewChar)
		{
			i_M2Stocks[client] = GetIntFromConfigMap(subsection, "starting_stocks", 0);
			i_M2MaxStocks[client] = GetIntFromConfigMap(subsection, "max_stocks", 0);
			if (i_M2MaxStocks[client] > 0 && i_M2Stocks[client] < i_M2MaxStocks[client])
			{
				CreateStockTimer(client, CF_AbilityType_M2, startingCD);
			}
		}
		
		CFC_StoreAbilities(client, CF_AbilityType_M2, abilities);
		
		b_HasM2[client] = true;
		AtLeastOne = true;
	}
	else
	{
		b_HasM2[client] = false;
	}
	
	subsection = map.GetSection("character.m3_ability");
	if (subsection != null)
	{
		subsection.Get("name", s_M3Name[client], 255);
		f_M3CD[client] = GetFloatFromConfigMap(subsection, "cooldown", 0.0);
		float startingCD = GetFloatFromConfigMap(subsection, "starting_cd", 0.0)
		CF_ApplyAbilityCooldown(client, startingCD, CF_AbilityType_M3, true, false);
		b_M3IsHeld[client] = GetBoolFromConfigMap(subsection, "held", false);
		if (b_UsingResources[client])
		{
			f_M3Cost[client] = GetFloatFromConfigMap(subsection, "cost", 0.0);
		}
		
		f_M3Scale[client] = GetFloatFromConfigMap(subsection, "max_scale", 0.0);
		b_M3IsGrounded[client] = GetBoolFromConfigMap(subsection, "grounded", false);
		b_HeldM3BlocksOthers[client] = GetBoolFromConfigMap(subsection, "held_block", false) && b_M3IsHeld[client];
		
		i_M3WeaponSlot[client] = GetIntFromConfigMap(subsection, "weapon_slot", -1);
		i_M3Ammo[client] = GetIntFromConfigMap(subsection, "ammo", 0);
		
		if (NewChar)
		{
			i_M3Stocks[client] = GetIntFromConfigMap(subsection, "starting_stocks", 0);
			i_M3MaxStocks[client] = GetIntFromConfigMap(subsection, "max_stocks", 0);
			if (i_M3MaxStocks[client] > 0 && i_M3Stocks[client] < i_M3MaxStocks[client])
			{
				CreateStockTimer(client, CF_AbilityType_M3, startingCD);
			}
		}

		CFC_StoreAbilities(client, CF_AbilityType_M3, abilities);
		
		b_HasM3[client] = true;
		AtLeastOne = true;
	}
	else
	{
		b_HasM3[client] = false;
	}
	
	subsection = map.GetSection("character.reload_ability");
	if (subsection != null)
	{
		subsection.Get("name", s_ReloadName[client], 255);
		f_ReloadCD[client] = GetFloatFromConfigMap(subsection, "cooldown", 0.0);
		float startingCD = GetFloatFromConfigMap(subsection, "starting_cd", 0.0)
		CF_ApplyAbilityCooldown(client, startingCD, CF_AbilityType_Reload, true, false);
		b_ReloadIsHeld[client] = GetBoolFromConfigMap(subsection, "held", false);
		if (b_UsingResources[client])
		{
			f_ReloadCost[client] = GetFloatFromConfigMap(subsection, "cost", 0.0);
		}
		
		f_RScale[client] = GetFloatFromConfigMap(subsection, "max_scale", 0.0);
		b_ReloadIsGrounded[client] = GetBoolFromConfigMap(subsection, "grounded", false);
		b_HeldReloadBlocksOthers[client] = GetBoolFromConfigMap(subsection, "held_block", false) && b_ReloadIsHeld[client];
		
		i_ReloadWeaponSlot[client] = GetIntFromConfigMap(subsection, "weapon_slot", -1);
		i_ReloadAmmo[client] = GetIntFromConfigMap(subsection, "ammo", 0);
		
		if (NewChar)
		{
			i_ReloadStocks[client] = GetIntFromConfigMap(subsection, "starting_stocks", 0);
			i_ReloadMaxStocks[client] = GetIntFromConfigMap(subsection, "max_stocks", 0);
			if (i_ReloadMaxStocks[client] > 0 && i_ReloadStocks[client] < i_ReloadMaxStocks[client])
			{
				CreateStockTimer(client, CF_AbilityType_Reload, startingCD);
			}
		}

		CFC_StoreAbilities(client, CF_AbilityType_Reload, abilities);
		
		b_HasReload[client] = true;
		
		AtLeastOne = true;
	}
	else
	{
		b_HasReload[client] = false;
	}
	
	if (!AtLeastOne)
		b_UsingResources[client] = false;
	
	return AtLeastOne;
}

public void CFA_InitializeResources(int client, ConfigMap map, bool NewChar)
{
	ConfigMap subsection = map.GetSection("character.special_resource");
	if (subsection != null)
	{
		b_ResourceIsUlt[client] = GetBoolFromConfigMap(subsection, "is_ult", false);
		
		if (!b_ResourceIsUlt[client])
		{
			b_ResourceIsPercentage[client] = GetBoolFromConfigMap(subsection, "percentage", false);
			b_ResourceIsMetal[client] = GetBoolFromConfigMap(subsection, "is_metal", false);
			
			subsection.Get("name", s_ResourceName[client], 255);
			subsection.Get("name_plural", s_ResourceName_Plural[client], 255);
			float start = GetFloatFromConfigMap(subsection, "start", 0.0);
			float preserve = GetFloatFromConfigMap(subsection, "preserve", 0.0) * CF_GetSpecialResource(client);
			f_ResourceMax[client] = GetFloatFromConfigMap(subsection, "max", 0.0);
			f_ResourceRegenInterval[client] = GetFloatFromConfigMap(subsection, "regen_interval", 0.1);
			f_ResourceRegenNext[client] = GetGameTime() + f_ResourceRegenInterval[client];
			
			bool IgnoreResupply = GetBoolFromConfigMap(subsection, "ignore_resupply", true);
			
			if (!IgnoreResupply || NewChar)
			{
				if (preserve > start && !NewChar)
				{
					CF_SetSpecialResource(client, preserve);
				}
				else
				{
					CF_SetSpecialResource(client, start);
				}
			}
			else
			{
				f_NextResourceRegen[client] = GetGameTime() + 0.2;
			}
			
			f_ResourcesOnRegen[client] = GetFloatFromConfigMap(subsection, "on_regen", 0.0);
			f_ResourcesOnDamage[client] = GetFloatFromConfigMap(subsection, "on_damage", 0.0);
			f_ResourcesOnHurt[client] = GetFloatFromConfigMap(subsection, "on_hurt", 0.0);
			f_ResourcesOnHeal[client] = GetFloatFromConfigMap(subsection, "on_heal", 0.0);
			f_ResourcesOnKill[client] = GetFloatFromConfigMap(subsection, "on_kill", 0.0);
			
			f_ResourcesToTriggerSound[client] = GetFloatFromConfigMap(subsection, "sound_amt", 0.0);
			f_ResourcesSinceLastGain[client] = 0.0;
		}
		
		b_UsingResources[client] = true;
	}
	else
	{
		CF_SetSpecialResource(client, 0.0);
		b_UsingResources[client] = false;
	}
}

public void CFA_SetChargeRetain(float amt)
{
	f_ChargeRetain = amt;
}

public void CFA_ReduceUltCharge_CharacterSwitch(int client)
{
	float newCharge = f_UltChargeRequired[client] * f_ChargeRetain;
	
	if (newCharge > f_UltCharge[client])
		newCharge = f_UltCharge[client];
		
	CF_SetUltCharge(client, newCharge, true);
}

public void CFA_MapEnd()
{
	for (int i = 0; i <= MaxClients; i++)
	{
		f_UltChargeRequired[i] = 0.0;
		f_UltCharge[i] = 0.0;
		f_UltChargeOnRegen[i] = 0.0;
		f_UltChargeOnDamage[i] = 0.0;
		f_UltChargeOnHurt[i] = 0.0;
		f_UltChargeOnHeal[i] = 0.0;
		f_ResourceRegenInterval[i] = 0.0;
		f_UltChargeOnKill[i] = 0.0;
		f_ResourceRegenNext[i] = 0.0;
		f_UltCD[i] = 0.0;
		f_UltCDEndTime[i] = 0.0;
		f_M2CD[i] = 0.0;
		f_M2CDEndTime[i] = 0.0;
		f_M3CD[i] = 0.0;
		f_M3CDEndTime[i] = 0.0;
		f_ReloadCD[i] = 0.0;
		f_ReloadCDEndTime[i] = 0.0;
		f_M2Cost[i] = 0.0;
		f_M3Cost[i] = 0.0;
		f_ReloadCost[i] = 0.0;
		f_ResourceMax[i] = 0.0;
		f_Resources[i] = 0.0;
		f_ResourcesOnRegen[i] = 0.0;
		f_ResourcesOnDamage[i] = 0.0;
		f_ResourcesOnHurt[i] = 0.0;
		f_ResourcesOnHeal[i] = 0.0;
		f_ResourcesOnKill[i] = 0.0;
		f_NextResourceRegen[i] = 0.0;
		f_ResourcesSinceLastGain[i] = 0.0;
		f_ResourcesToTriggerSound[i] = 0.0;
		f_UltScale[i] = 0.0;
		f_M2Scale[i] = 0.0;
		f_RScale[i] = 0.0;
		f_CancelTemporarySpeedMod[i] = 0.0;
		f_M3Scale[i] = 0.0;
		f_M3Scale[i] = 0.0;
		f_M3Scale[i] = 0.0;
		f_M3Scale[i] = 0.0;
		f_M3Scale[i] = 0.0;
		f_M3Scale[i] = 0.0;
		f_M3Scale[i] = 0.0;
		f_M3Scale[i] = 0.0;
		f_M3Scale[i] = 0.0;

		strcopy(s_UltName[i], 255, "");
		strcopy(s_M2Name[i], 255, "");
		strcopy(s_M3Name[i], 255, "");
		strcopy(s_ResourceName[i], 255, "");
		strcopy(s_ReloadName[i], 255, "");
		strcopy(s_ResourceName_Plural[i], 255, "");
		strcopy(s_ReloadName[i], 255, "");
		strcopy(s_ReloadName[i], 255, "");

		b_CharacterHasUlt[i] = false;
		b_UsingResources[i] = false;
		b_M2IsHeld[i] = false;
		b_M3IsHeld[i] = false;
		b_ReloadIsHeld[i] = false;
		b_ResourceIsUlt[i] = false;
		b_ResourceIsPercentage[i] = false;
		b_UseHUD[i] = false;
		b_HasM2[i] = false;
		b_HasM3[i] = false;
		b_HasReload[i] = false;
		b_HoldingReload[i] = false;
		b_HoldingM2[i] = false;
		b_HoldingM3[i] = false;
		b_ForceEndHeldM2[i] = false;
		b_ForceEndHeldM3[i] = false;
		b_ForceEndHeldReload[i] = false;
		b_UltBlocked[i] = false;
		b_M2Blocked[i] = false;
		b_M3Blocked[i] = false;
		b_ReloadBlocked[i] = false;
		b_UltIsGrounded[i] = false;
		b_M2IsGrounded[i] = false;
		b_M3IsGrounded[i] = false;
		b_ReloadIsGrounded[i] = false;
		b_HeldM2BlocksOthers[i] = false;
		b_HeldM3BlocksOthers[i] = false;
		b_HeldReloadBlocksOthers[i] = false;

		i_HealingDone[i] = 0;
		i_UltWeaponSlot[i] = -1;
		i_M2WeaponSlot[i] = -1;
		i_M3WeaponSlot[i] = -1;
		i_ReloadWeaponSlot[i] = -1;
		i_UltAmmo[i] = -1;
		i_M2Ammo[i] = -1;
		i_M3Ammo[i] = -1;
		i_ReloadAmmo[i] = -1;
		i_HUDR[i] = 0;
		i_HUDG[i] = 0;
		i_HUDB[i] = 0;
		i_HUDA[i] = 0;
		i_M2Stocks[i] = 0;
		i_M2MaxStocks[i] = 0;
		i_M3Stocks[i] = 0;
		i_M3MaxStocks[i] = 0;
		i_ReloadStocks[i] = 0;
		i_ReloadMaxStocks[i] = 0;
		i_HUDB[i] = 0;
		i_HUDA[i] = 0;
	}

	for (int i = 0; i < 2049; i++)
	{
		for (int j = 0; j < 2049; j++)
			f_NextShieldCollisionForward[i][j] = 0.0;

		f_FakeMediShieldHP[i] = 0.0;
		f_FakeMediShieldMaxHP[i] = 0.0;
		b_IsFakeHealthKit[i] = false;
		b_IsMedigunShield[i] = false;
		b_ProjectileCanCollideWithAllies[i] = false;
		i_GenericProjectileOwner[i] = -1;
		b_IsProjectile[i] = false;
	}
}

public void CFA_ToggleHUD(int client, bool toggle)
{
	if (!IsValidClient(client))
		return;
		
	b_UseHUD[client] = toggle;
}

public void CF_OnPlayerCallForMedic(int client)
{
	if (!CF_IsPlayerCharacter(client))
		return;
		
	if (!b_CharacterHasUlt[client])
		return;
		
	if (CF_GetRoundState() != 1)
	{
		Nope(client);
		return;
	}
	
	CF_AttemptAbilitySlot(client, CF_AbilityType_Ult);
}

public Action CF_OnPlayerM2(int client, int &buttons, int &impulse, int &weapon)
{
	if (!CF_IsPlayerCharacter(client))
		return Plugin_Continue;
		
	if (!b_HasM2[client])
		return Plugin_Continue;
		
	if (b_M2IsHeld[client])
	{
		CF_AttemptHeldAbility(client, CF_AbilityType_M2, IN_ATTACK2);
	}
	else
	{
		CF_AttemptAbilitySlot(client, CF_AbilityType_M2);
	}
	
	return Plugin_Continue;
}

public Action CF_OnPlayerM3(int client, int &buttons, int &impulse, int &weapon)
{
	if (!CF_IsPlayerCharacter(client))
		return Plugin_Continue;
		
	if (!b_HasM3[client])
		return Plugin_Continue;
		
	if (b_M3IsHeld[client])
	{
		CF_AttemptHeldAbility(client, CF_AbilityType_M3, IN_ATTACK3);
	}
	else
	{
		CF_AttemptAbilitySlot(client, CF_AbilityType_M3);
	}

	return Plugin_Continue;
}

public Action CF_OnPlayerReload(int client, int &buttons, int &impulse, int &weapon)
{
	if (!CF_IsPlayerCharacter(client))
		return Plugin_Continue;
		
	if (!b_HasReload[client])
		return Plugin_Continue;
	
	if (b_ReloadIsHeld[client])
	{
		CF_AttemptHeldAbility(client, CF_AbilityType_Reload, IN_RELOAD);
	}
	else
	{
		CF_AttemptAbilitySlot(client, CF_AbilityType_Reload);
	}
		
	return Plugin_Continue;
}

public void CF_AttemptHeldAbility(int client, CF_AbilityType type, int button)
{
	if (!CF_CanPlayerUseAbilitySlot(client, type))
	{
		Nope(client);
		return;
	}
	
	Action result;
	Call_StartForward(g_OnHeldStart);
	
	Call_PushCell(client);
	Call_PushCell(type);
	
	Call_Finish(result);
	
	if (result != Plugin_Stop && result != Plugin_Handled)
	{
		int slot;
		char soundSlot[255];
		
		switch(type)
		{
			case CF_AbilityType_M2:
			{
				slot = 2;
				soundSlot = "sound_heldstart_m2";
				SDKUnhook(client, SDKHook_PreThink, CFA_HeldM2PreThink);
				SDKHook(client, SDKHook_PreThink, CFA_HeldM2PreThink);
				b_ForceEndHeldM2[client] = false;
				b_HoldingM2[client] = true;
				if (b_HeldM2BlocksOthers[client])
					i_HeldBlocked[client] = CF_AbilityType_M2;
			}
			case CF_AbilityType_M3:
			{
				slot = 3;
				soundSlot = "sound_heldstart_m3";
				SDKUnhook(client, SDKHook_PreThink, CFA_HeldM3PreThink);
				SDKHook(client, SDKHook_PreThink, CFA_HeldM3PreThink);
				b_ForceEndHeldM3[client] = false;
				b_HoldingM3[client] = true;
				if (b_HeldM3BlocksOthers[client])
					i_HeldBlocked[client] = CF_AbilityType_M3;
			}
			case CF_AbilityType_Reload:
			{
				slot = 4;
				soundSlot = "sound_heldstart_reload";
				SDKUnhook(client, SDKHook_PreThink, CFA_HeldReloadPreThink);
				SDKHook(client, SDKHook_PreThink, CFA_HeldReloadPreThink);
				b_ForceEndHeldReload[client] = false;
				b_HoldingReload[client] = true;
				if (b_HeldReloadBlocksOthers[client])
					i_HeldBlocked[client] = CF_AbilityType_Reload;
			}
		}
		
		CF_ActivateAbilitySlot(client, slot);
		CF_PlayRandomSound(client, "", soundSlot);
	}
	else
	{
		Nope(client);
	}
}

bool AbilityUsesStocks(int client, CF_AbilityType slot)
{
	switch (slot)
	{
		case CF_AbilityType_M2:
			return i_M2MaxStocks[client] > 0;
		case CF_AbilityType_M3:
			return i_M3MaxStocks[client] > 0;
		case CF_AbilityType_Reload:
			return i_ReloadMaxStocks[client] > 0;
	}

	return false;
}

public Action CFA_HeldM2PreThink(int client)
{
	b_HoldingM2[client] = (GetClientButtons(client) & IN_ATTACK2 != 0) && !b_ForceEndHeldM2[client] && CF_CanPlayerUseAbilitySlot(client, CF_AbilityType_M2);
	
	if (!b_HoldingM2[client])
	{
		EndHeldM2(client, true);
	}
	
	return Plugin_Continue;
}

void EndHeldM2(int client, bool TriggerCallback, bool resupply = false)
{
	if (!IsValidClient(client))
		return;
		
	SDKUnhook(client, SDKHook_PreThink, CFA_HeldM2PreThink);
	
	if (TriggerCallback)
	{
		CF_EndHeldAbilitySlot(client, 2, resupply);
	}
	else
	{
		if (!AbilityUsesStocks(client, CF_AbilityType_M2))
			CF_ApplyAbilityCooldown(client, f_M2CD[client], CF_AbilityType_M2, true, false);
			
		if (b_UsingResources[client] && !resupply)
		{
			if (b_ResourceIsUlt[client])
			{
				CF_GiveUltCharge(client, -f_M2Cost[client], CF_ResourceType_Generic);
			}
			else
			{
				CF_GiveSpecialResource(client, -f_M2Cost[client], CF_ResourceType_Generic);
			}
		}
			
		if (!resupply)
		{
			CF_PlayRandomSound(client, "", "sound_heldend_m2");
			SubtractStock(client, CF_AbilityType_M2);
		}
			
		b_ForceEndHeldM2[client] = false;
		b_HoldingM2[client] = false;
		if (b_HeldM2BlocksOthers[client])
			i_HeldBlocked[client] = CF_AbilityType_None;

		Call_StartForward(g_OnHeldEnd);
			
		Call_PushCell(client);
		Call_PushCell(CF_AbilityType_M2);
		Call_PushCell(resupply);
			
		Call_Finish();
	}
}

void SubtractStock(int client, CF_AbilityType type)
{
	if (!AbilityUsesStocks(client, type))
		return;

	switch (type)
	{
		case CF_AbilityType_M2:
		{
			if (i_M2Stocks[client] > 0)
			{
				i_M2Stocks[client]--;
				CreateStockTimer(client, CF_AbilityType_M2, f_M2CD[client]);
			}
		}
		case CF_AbilityType_M3:
		{
			if (i_M3Stocks[client] > 0)
			{
				i_M3Stocks[client]--;
				CreateStockTimer(client, CF_AbilityType_M3, f_M3CD[client]);
			}
		}
		case CF_AbilityType_Reload:
		{
			if (i_ReloadStocks[client] > 0)
			{
				i_ReloadStocks[client]--;
				CreateStockTimer(client, CF_AbilityType_Reload, f_ReloadCD[client]);
			}
		}
	}
}

public Action CFA_HeldM3PreThink(int client)
{
	b_HoldingM3[client] = (GetClientButtons(client) & IN_ATTACK3 != 0) && !b_ForceEndHeldM3[client] && CF_CanPlayerUseAbilitySlot(client, CF_AbilityType_M3);
	
	if (!b_HoldingM3[client])
	{
		EndHeldM3(client, true);
	}
	
	return Plugin_Continue;
}

void EndHeldM3(int client, bool TriggerCallback, bool resupply = false)
{
	if (!IsValidClient(client))
		return;
		
	SDKUnhook(client, SDKHook_PreThink, CFA_HeldM3PreThink);	
	
	if (TriggerCallback)
	{	
		CF_EndHeldAbilitySlot(client, 3, resupply);	
	}
	else
	{
		if (!AbilityUsesStocks(client, CF_AbilityType_M3))
			CF_ApplyAbilityCooldown(client, f_M3CD[client], CF_AbilityType_M3, true, false);

		if (b_UsingResources[client] && !resupply)
		{
			if (b_ResourceIsUlt[client])
			{
				CF_GiveUltCharge(client, -f_M3Cost[client], CF_ResourceType_Generic);
			}
			else
			{
				CF_GiveSpecialResource(client, -f_M3Cost[client], CF_ResourceType_Generic);
			}
		}
		
		if (!resupply)
		{
			CF_PlayRandomSound(client, "", "sound_heldend_m3");
			SubtractStock(client, CF_AbilityType_M3);
		}

		b_ForceEndHeldM3[client] = false;
		b_HoldingM3[client] = false;
		if (b_HeldM3BlocksOthers[client])
			i_HeldBlocked[client] = CF_AbilityType_None;
			
		Call_StartForward(g_OnHeldEnd);
			
		Call_PushCell(client);
		Call_PushCell(CF_AbilityType_M3);
		Call_PushCell(resupply);
		
		Call_Finish();
	}
}

public Action CFA_HeldReloadPreThink(int client)
{
	b_HoldingReload[client] = (GetClientButtons(client) & IN_RELOAD != 0) && !b_ForceEndHeldReload[client] && CF_CanPlayerUseAbilitySlot(client, CF_AbilityType_Reload);
	
	if (!b_HoldingReload[client])
	{
		EndHeldReload(client, true);
	}
	
	return Plugin_Continue;
}

void EndHeldReload(int client, bool TriggerCallback, bool resupply = false)
{
	if (!IsValidClient(client))
		return;
	
	SDKUnhook(client, SDKHook_PreThink, CFA_HeldReloadPreThink);

	if (TriggerCallback)
	{
		CF_EndHeldAbilitySlot(client, 4, resupply);
	}
	else
	{
		if (!AbilityUsesStocks(client, CF_AbilityType_Reload))
			CF_ApplyAbilityCooldown(client, f_ReloadCD[client], CF_AbilityType_Reload, true, false);

		if (b_UsingResources[client] && !resupply)
		{
			if (b_ResourceIsUlt[client])
			{
				CF_GiveUltCharge(client, -f_ReloadCost[client], CF_ResourceType_Generic);
			}
			else
			{
				CF_GiveSpecialResource(client, -f_ReloadCost[client], CF_ResourceType_Generic);
			}
		}
			
		if (!resupply)
		{
			SubtractStock(client, CF_AbilityType_Reload);
			CF_PlayRandomSound(client, "", "sound_heldend_reload");
		}
			
		b_ForceEndHeldReload[client] = false;
		b_HoldingReload[client] = false;
		if (b_HeldReloadBlocksOthers[client])
			i_HeldBlocked[client] = CF_AbilityType_None;
			
		Call_StartForward(g_OnHeldEnd);
			
		Call_PushCell(client);
		Call_PushCell(CF_AbilityType_Reload);
		Call_PushCell(resupply);
			
		Call_Finish();
	}
}

public void ResetHeldButtonStats(int client)
{
	b_ForceEndHeldM2[client] = false;
	b_HoldingM2[client] = false;
	
	b_ForceEndHeldM3[client] = false;
	b_HoldingM3[client] = false;
	
	b_ForceEndHeldReload[client] = false;
	b_HoldingReload[client] = false;
	
	SDKUnhook(client, SDKHook_PreThink, CFA_HeldM2PreThink);
	SDKUnhook(client, SDKHook_PreThink, CFA_HeldM3PreThink);
	SDKUnhook(client, SDKHook_PreThink, CFA_HeldReloadPreThink);
}

public void CF_AttemptAbilitySlot(int client, CF_AbilityType type)
{
	if (!CF_CanPlayerUseAbilitySlot(client, type))
	{
		Nope(client);
		return;
	}
	
	float cooldown; float cost;
	int slot;
	char soundSlot[255];
	Action result;
	GlobalForward toCall;
	
	switch(type)
	{
		case CF_AbilityType_Ult:
		{
			cooldown = f_UltCD[client];
			cost = f_UltChargeRequired[client];
			slot = 1;
			toCall = g_OnUltUsed;
		}
		case CF_AbilityType_M2:
		{
			cooldown = f_M2CD[client];
			cost = f_M2Cost[client];
			slot = 2;
			soundSlot = "sound_m2";
			toCall = g_OnM2Used;
		}
		case CF_AbilityType_M3:
		{
			cooldown = f_M3CD[client];
			cost = f_M3Cost[client];
			slot = 3;
			soundSlot = "sound_m3";
			toCall = g_OnM3Used;
		}
		case CF_AbilityType_Reload:
		{
			cooldown = f_ReloadCD[client];
			cost = f_ReloadCost[client];
			slot = 4;
			soundSlot = "sound_reload";
			toCall = g_OnReloadUsed;
		}
	}
	
	Call_StartForward(toCall);
	
	Call_PushCell(client);
	
	Call_Finish(result);
	
	if (result != Plugin_Stop && result != Plugin_Handled)
	{
		CF_ActivateAbilitySlot(client, slot);
		
		if (type == CF_AbilityType_Ult)
		{
			f_UltCharge[client] = 0.0;
			bool played = CF_PlayRandomSound(client, "", "sound_ultimate_activation");
			
			if (!played)
			{
				played = CF_PlayRandomSound(client, "", "sound_ultimate_activation_self");
				
				bool played2 = CF_PlayRandomSound(client, "", "sound_ultimate_activation_friendly");
				if (!played)
					played = played2;
					
				played2 = CF_PlayRandomSound(client, "", "sound_ultimate_activation_hostile");
				if (!played)
					played = played2;
			}
			
			//char conf[255];
			//CF_GetPlayerConfig(client, conf, sizeof(conf));
			ConfigMap map = new ConfigMap(g_Characters[client].MapPath);
			if (map != null)
			{
				float distance = GetFloatFromConfigMap(map, "character.ultimate_stats.radius", 999999.0);
				float pos[3];
				GetClientAbsOrigin(client, pos);
				
				for (int i = 1; i <= MaxClients; i++)
				{
					if (i != client && IsValidMulti(i, true, true))
					{ 
						float otherPos[3];
						GetClientAbsOrigin(i, otherPos);
						
						if (GetVectorDistance(pos, otherPos, true) <= Pow(distance, 2.0))
						{
							bool otherPlayed = false;
							
							if (TF2_GetClientTeam(i) == TF2_GetClientTeam(client))
							{
								otherPlayed = CF_PlayRandomSound(i, "", "sound_ultimate_react_friendly");
							}
							else
							{
								otherPlayed = CF_PlayRandomSound(i, "", "sound_ultimate_react_hostile");
							}
							
							if (otherPlayed)
								CF_SilenceCharacter(i, 2.0);
						}
					}
				}
				
				DeleteCfg(map);
			}
			
			if (played)
				CF_SilenceCharacter(client, 1.0);
		}
		else
		{
			CF_PlayRandomSound(client, "", soundSlot);
		}

		if (type == CF_AbilityType_Ult || (b_ResourceIsUlt[client] && b_UsingResources[client]))
		{
			CF_GiveUltCharge(client, -cost);
		}
		else if (b_UsingResources[client])
		{
			CF_GiveSpecialResource(client, -cost);
		}
		
		if (!AbilityUsesStocks(client, type))
			CF_ApplyAbilityCooldown(client, cooldown, type, true, false);
	}
	else
	{
		Nope(client);
	}
}

bool CF_CanPlayerUseAbilitySlot(int client, CF_AbilityType type, bool &BlockedByResize = false, bool &BlockedByTooFewResources = false, float &remCD = 0.0)
{
	BlockedByResize = false;
	BlockedByTooFewResources = false;

	bool UsingStocks = AbilityUsesStocks(client, type);
	remCD = CF_GetAbilityCooldown(client, type);
	
	if (remCD > 0.0 && !UsingStocks)
		return false;
	
	if (i_HeldBlocked[client] != CF_AbilityType_None && i_HeldBlocked[client] != type)
		return false;
		
	if (TF2_IsPlayerStunned(client))
		return false;

	switch(type)
	{
		case CF_AbilityType_Ult:
		{
			if (b_UltBlocked[client])
				return false;
				
			if (b_UltIsGrounded[client] && GetEntityFlags(client) & FL_ONGROUND == 0)
				return false;

			int acWep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			
			if (i_UltWeaponSlot[client] > -1 && (!IsValidEntity(acWep) || GetPlayerWeaponSlot(client, i_UltWeaponSlot[client]) != acWep))
				return false;
				
			if (i_UltAmmo[client] > 0 && (!IsValidEntity(acWep) || i_UltAmmo[client] < GetClip(acWep)))
				return false;
				
			if (!HasEnoughResources(client, f_UltChargeRequired[client], type))
			{
				BlockedByTooFewResources = true;
				return false;
			}
				
			if (f_UltScale[client] > 0.0 && CheckPlayerWouldGetStuck(client, f_UltScale[client]))
			{
				BlockedByResize = true;
				return false;
			}

		}
		case CF_AbilityType_M2:
		{
			if (b_M2Blocked[client])
				return false;
				
			if (b_M2IsGrounded[client] && GetEntityFlags(client) & FL_ONGROUND == 0)
				return false;

			if (UsingStocks && i_M2Stocks[client] < 1)
				return false;
				
			int acWep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			
			if (i_M2WeaponSlot[client] > -1 && (!IsValidEntity(acWep) || GetPlayerWeaponSlot(client, i_M2WeaponSlot[client]) != acWep))
				return false;
				
			if (i_M2Ammo[client] > 0 && (!IsValidEntity(acWep) || i_M2Ammo[client] < GetClip(acWep)))
				return false;
				
			if (!HasEnoughResources(client, f_M2Cost[client], type))
			{
				BlockedByTooFewResources = true;
				return false;
			}	
			
			if (f_M2Scale[client] > 0.0 && CheckPlayerWouldGetStuck(client, f_M2Scale[client]))
			{
				BlockedByResize = true;
				return false;
			}
		}
		case CF_AbilityType_M3:
		{
			if (b_M3Blocked[client])
				return false;
				
			if (b_M3IsGrounded[client] && GetEntityFlags(client) & FL_ONGROUND == 0)
				return false;

			if (UsingStocks && i_M3Stocks[client] < 1)
				return false;
				
			int acWep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			
			if (i_M3WeaponSlot[client] > -1 && (!IsValidEntity(acWep) || GetPlayerWeaponSlot(client, i_M3WeaponSlot[client]) != acWep))
				return false;
				
			if (i_M3Ammo[client] > 0 && (!IsValidEntity(acWep) || i_M3Ammo[client] < GetClip(acWep)))
				return false;

			if (!HasEnoughResources(client, f_M3Cost[client], type))
			{
				BlockedByTooFewResources = true;
				return false;
			}
					
			if (f_M3Scale[client] > 0.0 && CheckPlayerWouldGetStuck(client, f_M3Scale[client]))
			{
				BlockedByResize = true;
				return false;
			}
		}
		case CF_AbilityType_Reload:
		{
			if (b_ReloadBlocked[client])
				return false;
				
			if (b_ReloadIsGrounded[client] && GetEntityFlags(client) & FL_ONGROUND == 0)
				return false;

			if (UsingStocks && i_ReloadStocks[client] < 1)
				return false;
				
			int acWep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			
			if (i_ReloadWeaponSlot[client] > -1 && (!IsValidEntity(acWep) || GetPlayerWeaponSlot(client, i_ReloadWeaponSlot[client]) != acWep))
				return false;
				
			if (i_ReloadAmmo[client] > 0 && (!IsValidEntity(acWep) || i_ReloadAmmo[client] < GetClip(acWep)))
				return false;
				
			if (!HasEnoughResources(client, f_ReloadCost[client], type))
			{
				BlockedByTooFewResources = true;
				return false;
			}
				
			if (f_RScale[client] > 0.0 && CheckPlayerWouldGetStuck(client, f_RScale[client]))
			{
				BlockedByResize = true;
				return false;
			}
		}
	}
	
	return !CF_CheckIsSlotBlocked(client, view_as<int>(type) + 1);
}

public bool HasEnoughResources(int client, float cost, CF_AbilityType type)
{
	if(b_UsingResources[client] || type == CF_AbilityType_Ult)
	{
		float available = (b_ResourceIsUlt[client] || type == CF_AbilityType_Ult) ? f_UltCharge[client] : CF_GetSpecialResource(client);
		if (cost > available)
		{
			return false;
		}
	}
	
	return true;
}

public Native_CF_GiveUltCharge(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	float amt = GetNativeCell(2);
	CF_ResourceType type = GetNativeCell(3);
	bool IgnoreCD = GetNativeCell(4);
	
	if (CF_GetAbilityCooldown(client, CF_AbilityType_Ult) > 0.0 && !IgnoreCD)
		return;
	
	if (type != CF_ResourceType_Generic)
	{
		switch(type)
		{
			case CF_ResourceType_Regen:
			{
				amt *= f_UltChargeOnRegen[client];
			}
			case CF_ResourceType_DamageDealt:
			{
				amt *= f_UltChargeOnDamage[client];
			}
			case CF_ResourceType_DamageTaken:
			{
				amt *= f_UltChargeOnHurt[client];
			}
			case CF_ResourceType_Healing:
			{
				amt *= f_UltChargeOnHeal[client];
			}
			case CF_ResourceType_Kill:
			{
				amt *= f_UltChargeOnKill[client];
			}
			case CF_ResourceType_Percentage:
			{
				amt = f_UltChargeRequired[client] * amt * 0.01;
			}
		}
	}
	
	Call_StartForward(g_UltChargeGiven);
	
	Call_PushCell(client);
	Call_PushFloatRef(amt);
	
	Action result;
	Call_Finish(result);
	
	if (result != Plugin_Handled && result != Plugin_Stop)
		CF_SetUltCharge(client, f_UltCharge[client] + amt);
}

public Native_CF_SetUltCharge(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	float amt = GetNativeCell(2);
	
	bool IgnoreCD = GetNativeCell(3);
	
	if (CF_GetAbilityCooldown(client, CF_AbilityType_Ult) > 0.0 && !IgnoreCD)
		return;
	
	Call_StartForward(g_UltChargeApplied);
	
	Call_PushCell(client);
	Call_PushFloat(f_UltCharge[client]);
	Call_PushFloatRef(amt);
	
	Action result;
	Call_Finish(result);
	
	if (result != Plugin_Handled && result != Plugin_Stop)
	{
		if (amt < 0.0)
			amt = 0.0;
			
		if (amt >= f_UltChargeRequired[client])
		{
			amt = f_UltChargeRequired[client];
		}
		
		float oldCharge = f_UltCharge[client];
		f_UltCharge[client] = amt;
		
		if (oldCharge < f_UltChargeRequired[client] && f_UltCharge[client] >= f_UltChargeRequired[client])
		{
			CF_PlayRandomSound(client, "", "sound_ultimate_ready");
		}
		
		/*if (oldCharge != amt)
		{
			CF_ActivateAbilitySlot(client, 10);
			
			if (amt > oldCharge)
				CF_ActivateAbilitySlot(client, 8);
			else
				CF_ActivateAbilitySlot(client, 9);
		}*/
	}
}

public any Native_CF_GetUltCharge(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return 0.0;
	
	return f_UltCharge[client];
}

public Native_CF_GiveSpecialResource(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	if (b_ResourceIsUlt[client] || !b_UsingResources[client])
		return;
		
	float amt = GetNativeCell(2);
	CF_ResourceType type = GetNativeCell(3);
	
	if (type != CF_ResourceType_Generic)
	{
		switch(type)
		{
			case CF_ResourceType_Regen:
			{
				amt *= f_ResourcesOnRegen[client];
			}
			case CF_ResourceType_DamageDealt:
			{
				amt *= f_ResourcesOnDamage[client];
			}
			case CF_ResourceType_DamageTaken:
			{
				amt *= f_ResourcesOnHurt[client];
			}
			case CF_ResourceType_Healing:
			{
				amt *= f_ResourcesOnHeal[client];
			}
			case CF_ResourceType_Kill:
			{
				amt *= f_ResourcesOnKill[client];
			}
			case CF_ResourceType_Percentage:
			{
				amt = f_ResourceMax[client] * amt * 0.01;
			}
		}
	}
	
	Call_StartForward(g_ResourceGiven);
	
	Call_PushCell(client);
	Call_PushFloatRef(amt);
	
	Action result;
	Call_Finish(result);
	
	if (result != Plugin_Handled && result != Plugin_Stop && amt != 0.0)
		CF_SetSpecialResource(client, CF_GetSpecialResource(client) + amt);
}

public Native_CF_SetSpecialResource(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	if (b_ResourceIsUlt[client] || !b_UsingResources[client])
		return;
		
	float amt = GetNativeCell(2);
	
	Call_StartForward(g_ResourceApplied);
	
	Call_PushCell(client);
	Call_PushFloat(CF_GetSpecialResource(client));
	Call_PushFloatRef(amt);
	
	Action result;
	Call_Finish(result);
	
	if (result != Plugin_Handled && result != Plugin_Stop)
	{
		if (amt < 0.0)
			amt = 0.0;
			
		if (amt >= f_ResourceMax[client] && f_ResourceMax[client] > 0.0)
		{
			amt = f_ResourceMax[client];
		}
		
		float oldResources = CF_GetSpecialResource(client);
		
		f_Resources[client] = amt;
		if (b_ResourceIsMetal[client])
			SetEntProp(client, Prop_Send, "m_iAmmo", RoundFloat(f_Resources[client]), 4, 3);
		
		if (amt != oldResources)
		{
			if (amt > oldResources && f_ResourcesToTriggerSound[client] > 0.0)
			{
				float diff = amt - oldResources;
				f_ResourcesSinceLastGain[client] += diff;
				if (f_ResourcesSinceLastGain[client] >= f_ResourcesToTriggerSound[client])
				{
					f_ResourcesSinceLastGain[client] -= f_ResourcesToTriggerSound[client];
					
					CF_PlayRandomSound(client, "", "sound_resource_gained");
				}
			}
			
			/*CF_ActivateAbilitySlot(client, 7);
			
			if (amt > oldResources)
				CF_ActivateAbilitySlot(client, 5);
			else
				CF_ActivateAbilitySlot(client, 6);*/
		}
	}
}

public any Native_CF_GetSpecialResource(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return 0.0;
		
	if (b_ResourceIsUlt[client] || !b_UsingResources[client])
		return 0.0;
	
	if (b_ResourceIsMetal[client])
		return float(GetEntProp(client, Prop_Data, "m_iAmmo", 4, 3));
		
	return f_Resources[client];
}

public any Native_CF_GetMaxSpecialResource(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return 0.0;
		
	if (b_ResourceIsUlt[client] || !b_UsingResources[client])
		return 0.0;
	
	return f_ResourceMax[client];
}

public Native_CF_SetMaxSpecialResource(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float amt = GetNativeCell(2);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	if (b_ResourceIsUlt[client] || !b_UsingResources[client])
		return;
	
	f_ResourceMax[client] = amt;
}

public Native_CF_ApplyAbilityCooldown(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	float cd = GetNativeCell(2);
	CF_AbilityType type = GetNativeCell(3);
	bool override = GetNativeCell(4);
	bool delay = GetNativeCell(5);
	
	float gameTime = GetGameTime();
	
	if (delay)
	{
		DataPack pack = new DataPack();
		RequestFrame(ApplyCDOnDelay, pack);
		WritePackCell(pack, GetClientUserId(client));
		WritePackFloat(pack, gameTime);
		WritePackCell(pack, type);
		WritePackFloat(pack, cd);
		WritePackCell(pack, override);
	}
	else
	{
		switch (type)
		{
			case CF_AbilityType_Ult:
			{
				f_UltCDEndTime[client] = (override || GetGameTime() >= f_UltCDEndTime[client]) ? gameTime + cd : f_UltCDEndTime[client] + cd;
			}
			case CF_AbilityType_M2:
			{
				f_M2CDEndTime[client] = (override || GetGameTime() >= f_M2CDEndTime[client]) ? gameTime + cd : f_M2CDEndTime[client] + cd;
			}
			case CF_AbilityType_M3:
			{
				f_M3CDEndTime[client] = (override || GetGameTime() >= f_M3CDEndTime[client]) ? gameTime + cd : f_M3CDEndTime[client] + cd;
			}
			case CF_AbilityType_Reload:
			{
				f_ReloadCDEndTime[client] = (override || GetGameTime() >= f_ReloadCDEndTime[client]) ? gameTime + cd : f_ReloadCDEndTime[client] + cd;
			}
		}

		if (AbilityUsesStocks(client, type))
			CreateStockTimer(client, type, override ? cd : (CF_GetAbilityCooldown(client, type) + cd));
	}
}

public void ApplyCDOnDelay(DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	float gameTime = ReadPackFloat(pack);
	CF_AbilityType type = ReadPackCell(pack);
	float cd = ReadPackFloat(pack);
	bool override = ReadPackCell(pack);
	delete pack;
	
	if (!IsValidClient(client))
		return;
		
	switch (type)
	{
		case CF_AbilityType_Ult:
		{
			f_UltCDEndTime[client] = (override || GetGameTime() >= f_UltCDEndTime[client]) ? gameTime + cd : f_UltCDEndTime[client] + cd;
		}
		case CF_AbilityType_M2:
		{
			f_M2CDEndTime[client] = (override || GetGameTime() >= f_M2CDEndTime[client]) ? gameTime + cd : f_M2CDEndTime[client] + cd;
		}
		case CF_AbilityType_M3:
		{
			f_M3CDEndTime[client] = (override || GetGameTime() >= f_M3CDEndTime[client]) ? gameTime + cd : f_M3CDEndTime[client] + cd;
		}
		case CF_AbilityType_Reload:
		{
			f_ReloadCDEndTime[client] = (override || GetGameTime() >= f_ReloadCDEndTime[client]) ? gameTime + cd : f_ReloadCDEndTime[client] + cd;
		}
	}

	if (AbilityUsesStocks(client, type))
		CreateStockTimer(client, type, override ? cd : (CF_GetAbilityCooldown(client, type) + cd));
}

public any Native_CF_GetAbilityCooldown(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return 0.0;

	CF_AbilityType type = GetNativeCell(2);
	
	float gameTime = GetGameTime();
	
	switch (type)
	{
		case CF_AbilityType_Ult:
		{
			return gameTime >= f_UltCDEndTime[client] ? 0.0 : f_UltCDEndTime[client] - gameTime;
		}
		case CF_AbilityType_M2:
		{
			return gameTime >= f_M2CDEndTime[client] ? 0.0 : f_M2CDEndTime[client] - gameTime;
		}
		case CF_AbilityType_M3:
		{
			return gameTime >= f_M3CDEndTime[client] ? 0.0 : f_M3CDEndTime[client] - gameTime;
		}
		case CF_AbilityType_Reload:
		{
			return gameTime >= f_ReloadCDEndTime[client] ? 0.0 : f_ReloadCDEndTime[client] - gameTime;
		}
	}
	
	return 0.0;
}

public Native_CF_DoAbility(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	char abName[255], pluginName[255];
	GetNativeString(2, pluginName, sizeof(pluginName));
	GetNativeString(3, abName, sizeof(abName));
	
	Call_StartForward(g_OnAbility);
		
	Call_PushCell(client);
	Call_PushString(pluginName);
	Call_PushString(abName);
	
	Call_Finish();
}

public Native_CF_ActivateAbilitySlot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int slot = GetNativeCell(2);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	switch(slot)
	{
		case 1:
		{
			DoAllAbilities(client, g_Characters[client].Abilities_Ult);
		}
		case 2:
		{
			if (!b_M2IsHeld[client])
				SubtractStock(client, CF_AbilityType_M2);

			DoAllAbilities(client, g_Characters[client].Abilities_M2);
		}
		case 3:
		{
			if (!b_M3IsHeld[client])
				SubtractStock(client, CF_AbilityType_M3);

			DoAllAbilities(client, g_Characters[client].Abilities_M3);
		}
		case 4:
		{
			if (!b_ReloadIsHeld[client])
				SubtractStock(client, CF_AbilityType_Reload);

			DoAllAbilities(client, g_Characters[client].Abilities_Reload);
		}
	}
}

public void DoAllAbilities(int client, Handle abilities)
{
	if (abilities == null)
		return;
		
	for (int i = 0; i < GetArraySize(abilities); i += 2)
	{
		char abName[255], plugName[255];
		GetArrayString(abilities, i, plugName, sizeof(plugName));
		GetArrayString(abilities, i + 1, abName, sizeof(abName));
		CF_DoAbility(client, plugName, abName);
	}
}

public any Native_CF_CheckIsSlotBlocked(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int slot = GetNativeCell(2);
	
	if (!CF_IsPlayerCharacter(client))
		return true;
		
	bool result = false;
	switch(slot)
	{
		case 1:
		{
			result = ScanAllAbilities(client, g_Characters[client].Abilities_Ult, slot);
		}
		case 2:
		{
			result = ScanAllAbilities(client, g_Characters[client].Abilities_M2, slot);
		}
		case 3:
		{
			result = ScanAllAbilities(client, g_Characters[client].Abilities_M3, slot);
		}
		case 4:
		{
			result = ScanAllAbilities(client, g_Characters[client].Abilities_Reload, slot);
		}
	}
	
	return result;
}

public bool ScanAllAbilities(int client, Handle abilities, int slot)
{
	if (abilities == null)
		return true;
		
	bool result = false;
		
	for (int i = 0; i < GetArraySize(abilities); i += 2)
	{
		char abName[255], plugName[255];
		GetArrayString(abilities, i, plugName, sizeof(plugName));
		GetArrayString(abilities, i + 1, abName, sizeof(abName));
		
		Call_StartForward(g_AttemptAbility);
			
		Call_PushCell(client);
		Call_PushString(plugName);
		Call_PushString(abName);
		Call_PushCell(view_as<CF_AbilityType>(slot - 1));
		Call_PushCellRef(result);
			
		Action diditwork;
		Call_Finish(diditwork);
			
		if (diditwork == Plugin_Changed && !result)
		{
			return true;
		}
	}
	
	return false;
}

public Native_CF_EndHeldAbilitySlot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	int slot = GetNativeCell(2);
	bool resupply = GetNativeCell(3);
	
	char pluginName[255], abName[255];
	
	ConfigMap map = new ConfigMap(g_Characters[client].MapPath);
	if (map == null)
		return;
		
	ConfigMap abilities = map.GetSection("character.abilities");
	if (abilities == null)
	{
		DeleteCfg(map);
		return;
	}
		
	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "ability_%i", i);
		
	ConfigMap subsection = abilities.GetSection(secName);
	while (subsection != null)
	{
		if (GetIntFromConfigMap(subsection, "slot", -1) == slot)
		{
			subsection.Get("ability_name", abName, sizeof(abName));
			subsection.Get("plugin_name", pluginName, sizeof(pluginName));
			
			Call_StartForward(g_OnHeldEnd_Ability);
			
			Call_PushCell(client);
			Call_PushCell(resupply);
			Call_PushString(pluginName);
			Call_PushString(abName);
		
			Call_Finish();
		}
		
		i++;
		Format(secName, sizeof(secName), "ability_%i", i);
		subsection = abilities.GetSection(secName);
	}
	
	switch(slot)
	{
		case 2:
		{
			EndHeldM2(client, false, resupply);
		}
		case 3:
		{
			EndHeldM3(client, false, resupply);
		}
		case 4:
		{
			EndHeldReload(client, false, resupply);
		}
	}
	
	DeleteCfg(map);
}

public Native_CF_EndHeldAbility(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	char pluginName[255], abName[255];
	GetNativeString(2, pluginName, sizeof(pluginName));
	GetNativeString(3, abName, sizeof(abName));
	bool resupply = GetNativeCell(4);
	
	Call_StartForward(g_OnHeldEnd_Ability);
			
	Call_PushCell(client);
	Call_PushCell(resupply);
	Call_PushString(pluginName);
	Call_PushString(abName);
		
	Call_Finish();
}

public void Nope(int client)
{
	EmitSoundToClient(client, NOPE);
}

public Native_CF_HasAbility(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return false;
		
	char targetPlugin[255], targetAbility[255], pluginName[255], abName[255];
	
	ConfigMap map = new ConfigMap(g_Characters[client].MapPath);
	if (map == null)
		return false;
		
	GetNativeString(2, targetPlugin, sizeof(targetPlugin));
	GetNativeString(3, targetAbility, sizeof(targetAbility));
		
	ConfigMap abilities = map.GetSection("character.abilities");
	if (abilities == null)
	{
		DeleteCfg(map);
		return false;
	}
		
	bool ReturnValue = false;
		
	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "ability_%i", i);
		
	ConfigMap subsection = abilities.GetSection(secName);
	while (subsection != null)
	{
		subsection.Get("ability_name", abName, sizeof(abName));
		subsection.Get("plugin_name", pluginName, sizeof(pluginName));
		
		if (StrEqual(targetPlugin, pluginName) && StrEqual(targetAbility, abName))
		{
			ReturnValue = true;
			break;
		}
		
		i++;
		Format(secName, sizeof(secName), "ability_%i", i);
		subsection = abilities.GetSection(secName);
	}
	
	DeleteCfg(map);
	
	return ReturnValue;
}

public Native_CF_GetArgI(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return -1;
		
	char targetPlugin[255], targetAbility[255], argName[255], pluginName[255], abName[255];
	
	ConfigMap map = new ConfigMap(g_Characters[client].MapPath);
	if (map == null)
		return -1;
		
	GetNativeString(2, targetPlugin, sizeof(targetPlugin));
	GetNativeString(3, targetAbility, sizeof(targetAbility));
	GetNativeString(4, argName, sizeof(argName));
		
	ConfigMap abilities = map.GetSection("character.abilities");
	if (abilities == null)
	{
		DeleteCfg(map);
		return -1;
	}
		
	int ReturnValue = -1;
		
	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "ability_%i", i);
		
	ConfigMap subsection = abilities.GetSection(secName);
	while (subsection != null)
	{
		subsection.Get("ability_name", abName, sizeof(abName));
		subsection.Get("plugin_name", pluginName, sizeof(pluginName));
		
		if (StrEqual(targetPlugin, pluginName) && StrEqual(targetAbility, abName))
		{
			ReturnValue = GetIntFromConfigMap(subsection, argName, -1);
			break;
		}
		
		i++;
		Format(secName, sizeof(secName), "ability_%i", i);
		subsection = abilities.GetSection(secName);
	}
	
	DeleteCfg(map);
	
	return ReturnValue;
}

public any Native_CF_GetArgF(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return -1.0;
		
	char targetPlugin[255], targetAbility[255], argName[255], pluginName[255], abName[255];
	
	ConfigMap map = new ConfigMap(g_Characters[client].MapPath);
	if (map == null)
		return -1.0;
		
	GetNativeString(2, targetPlugin, sizeof(targetPlugin));
	GetNativeString(3, targetAbility, sizeof(targetAbility));
	GetNativeString(4, argName, sizeof(argName));
		
	ConfigMap abilities = map.GetSection("character.abilities");
	if (abilities == null)
	{
		DeleteCfg(map);
		return -1.0;
	}
		
	float ReturnValue = -1.0;
		
	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "ability_%i", i);
		
	ConfigMap subsection = abilities.GetSection(secName);
	while (subsection != null)
	{
		subsection.Get("ability_name", abName, sizeof(abName));
		subsection.Get("plugin_name", pluginName, sizeof(pluginName));
		
		if (StrEqual(targetPlugin, pluginName) && StrEqual(targetAbility, abName))
		{
			ReturnValue = GetFloatFromConfigMap(subsection, argName, -1.0);
			break;
		}
		
		i++;
		Format(secName, sizeof(secName), "ability_%i", i);
		subsection = abilities.GetSection(secName);
	}
	
	DeleteCfg(map);
	
	return ReturnValue;
}

public any Native_CF_GetAbilitySlot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return CF_AbilityType_None;
		
	char targetPlugin[255], targetAbility[255], pluginName[255], abName[255];
	
	ConfigMap map = new ConfigMap(g_Characters[client].MapPath);
	if (map == null)
		return CF_AbilityType_None;
		
	GetNativeString(2, targetPlugin, sizeof(targetPlugin));
	GetNativeString(3, targetAbility, sizeof(targetAbility));
		
	ConfigMap abilities = map.GetSection("character.abilities");
	if (abilities == null)
	{
		DeleteCfg(map);
		return CF_AbilityType_None;
	}
		
	CF_AbilityType ReturnValue = CF_AbilityType_None;
		
	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "ability_%i", i);
		
	ConfigMap subsection = abilities.GetSection(secName);
	while (subsection != null)
	{
		subsection.Get("ability_name", abName, sizeof(abName));
		subsection.Get("plugin_name", pluginName, sizeof(pluginName));
		
		if (StrEqual(targetPlugin, pluginName) && StrEqual(targetAbility, abName))
		{
			int slotNum = GetIntFromConfigMap(subsection, "slot", -1);
			if (slotNum < 1)
				ReturnValue = CF_AbilityType_Custom;
			else
				ReturnValue = view_as<CF_AbilityType>(slotNum - 1);
			
			break;
		}
		
		i++;
		Format(secName, sizeof(secName), "ability_%i", i);
		subsection = abilities.GetSection(secName);
	}
	
	DeleteCfg(map);
	
	return ReturnValue;
}

public Native_CF_GetArgS(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int size = GetNativeCell(6);
	
	if (!CF_IsPlayerCharacter(client))
	{
		SetNativeString(5, "", size, false);
		return;
	}
		
	char targetPlugin[255], targetAbility[255], argName[255], pluginName[255], abName[255];
	
	ConfigMap map = new ConfigMap(g_Characters[client].MapPath);
	if (map == null)
		return;
		
	GetNativeString(2, targetPlugin, sizeof(targetPlugin));
	GetNativeString(3, targetAbility, sizeof(targetAbility));
	GetNativeString(4, argName, sizeof(argName));
		
	ConfigMap abilities = map.GetSection("character.abilities");
	if (abilities == null)
	{
		DeleteCfg(map);
		SetNativeString(5, "", size, false);
		return;
	}
		
	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "ability_%i", i);
		
	ConfigMap subsection = abilities.GetSection(secName);
	while (subsection != null)
	{
		subsection.Get("ability_name", abName, sizeof(abName));
		subsection.Get("plugin_name", pluginName, sizeof(pluginName));
		
		if (StrEqual(targetPlugin, pluginName) && StrEqual(targetAbility, abName))
		{
			char arg[255]; 
			subsection.Get(argName, arg, sizeof(arg));
			SetNativeString(5, arg, size, false);
			break;
		}
		
		i++;
		Format(secName, sizeof(secName), "ability_%i", i);
		subsection = abilities.GetSection(secName);
	}
	
	DeleteCfg(map);
}

public Native_CF_GetAbilityConfigMapPath(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int length = GetNativeCell(6);
	
	if (!CF_IsPlayerCharacter(client))
	{
		SetNativeString(5, "", length);
		return;
	}
		
	char targetPlugin[255], targetAbility[255], section[255], pluginName[255], abName[255];
	
	ConfigMap map = new ConfigMap(g_Characters[client].MapPath);
	if (map == null)
	{
		SetNativeString(5, "", length);
		return;
	}
		
	GetNativeString(2, targetPlugin, sizeof(targetPlugin));
	GetNativeString(3, targetAbility, sizeof(targetAbility));
	GetNativeString(4, section, sizeof(section));
		
	ConfigMap abilities = map.GetSection("character.abilities");
	if (abilities == null)
	{
		DeleteCfg(map);
		SetNativeString(5, "", length);
		return;
	}
		
	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "ability_%i", i);
		
	ConfigMap subsection = abilities.GetSection(secName);
	while (subsection != null)
	{
		subsection.Get("ability_name", abName, sizeof(abName));
		subsection.Get("plugin_name", pluginName, sizeof(pluginName));
		
		if (StrEqual(targetPlugin, pluginName) && StrEqual(targetAbility, abName))
		{
			char path[255];
			Format(path, sizeof(path), "character.abilities.%s.%s", secName, section);
			SetNativeString(5, path, length);
			break;
		}
		
		i++;
		Format(secName, sizeof(secName), "ability_%i", i);
		subsection = abilities.GetSection(secName);
	}
	
	DeleteCfg(map);
}

public any Native_CF_IsAbilitySlotBlocked(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	
	if (!CF_IsPlayerCharacter(client))
		return false;
		
	switch(type)
	{
		case CF_AbilityType_Ult:
		{
			return b_UltBlocked[client];
		}
		case CF_AbilityType_M2:
		{
			return b_M2Blocked[client];
		}
		case CF_AbilityType_M3:
		{
			return b_M3Blocked[client];
		}
		case CF_AbilityType_Reload:
		{
			return b_ReloadBlocked[client];
		}
		default:
		{
			return false;
		}
	}
}

public Native_CF_BlockAbilitySlot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	switch(type)
	{
		case CF_AbilityType_Ult:
		{
			b_UltBlocked[client] = true;
		}
		case CF_AbilityType_M2:
		{
			b_M2Blocked[client] = true;
		}
		case CF_AbilityType_M3:
		{
			b_M3Blocked[client] = true;
		}
		case CF_AbilityType_Reload:
		{
			b_ReloadBlocked[client] = true;
		}
	}
}

public Native_CF_UnblockAbilitySlot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	switch(type)
	{
		case CF_AbilityType_Ult:
		{
			b_UltBlocked[client] = false;
		}
		case CF_AbilityType_M2:
		{
			b_M2Blocked[client] = false;
		}
		case CF_AbilityType_M3:
		{
			b_M3Blocked[client] = false;
		}
		case CF_AbilityType_Reload:
		{
			b_ReloadBlocked[client] = false;
		}
	}
}

public Native_CF_SetHUDColor(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int r = GetNativeCell(2);
	int g = GetNativeCell(3);
	int b = GetNativeCell(4);
	int a = GetNativeCell(5);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	if (r >= 0)
		i_HUDR[client] = r;
	if (g >= 0)
		i_HUDG[client] = g;
	if (b >= 0)
		i_HUDB[client] = b;	
	if (a >= 0)
		i_HUDA[client] = a;
}

public Native_CF_HealPlayer(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int healer = GetNativeCell(2);
	int amt = GetNativeCell(3);
	float hpMult = GetNativeCell(4);
	
	if (!IsValidMulti(client))
		return;
		
	int maxHP = TF2Util_GetEntityMaxHealth(client);
	int totalMax = RoundFloat(float(maxHP) * hpMult);
	int current = GetEntProp(client, Prop_Send, "m_iHealth");
	
	int healingDone = amt;
	
	if (current < totalMax)
	{
		int newHP = current + amt;
		if (newHP > totalMax)
		{
			int diff = newHP - totalMax;
			newHP -= diff;
			healingDone -= diff;
		}
		
		SetEntProp(client, Prop_Send, "m_iHealth", newHP);
	}
	else
	{
		healingDone = 0;
	}
	
	if (healingDone > 0 && IsValidClient(healer) && healer != client)
	{
		CFA_GiveChargesForHealing(healer, float(healingDone));
		
		CFA_AddHealingPoints(healer, healingDone);
	}
}

public void CFA_GiveChargesForHealing(int healer, float healingDone)
{
	CF_GiveUltCharge(healer, healingDone, CF_ResourceType_Healing);
	CF_GiveSpecialResource(healer, healingDone, CF_ResourceType_Healing);
}

public Native_CF_FireGenericRocket(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!IsValidClient(client))
		return -1;
	
	float dmg = GetNativeCell(2);
	float velocity = GetNativeCell(3);
	bool crit = GetNativeCell(4);
	bool allowAlliedCollisions = GetNativeCell(5);
	char pluginName[255];
	GetNativeString(6, pluginName, sizeof(pluginName));
	Function logic = GetNativeFunction(7);
	float forwardDistance = 20.0 * CF_GetCharacterScale(client);
	
	int rocket = CreateEntityByName("tf_projectile_rocket");
	
	if (IsValidEntity(rocket))
	{
		int iTeam = GetClientTeam(client);
		
		SetEntPropEnt(rocket, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(rocket,    Prop_Send, "m_bCritical", view_as<int>(crit));
		SetEntProp(rocket,    Prop_Send, "m_iTeamNum",     iTeam, 1);
		SetEntData(rocket, FindSendPropInfo("CTFProjectile_Rocket", "m_nSkin"), (iTeam-2), 1, true);
		SetEntDataFloat(rocket, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected") + 4, dmg, true);
		
		SetVariantInt(iTeam);
		AcceptEntityInput(rocket, "TeamNum", -1, -1, 0);
		
		SetVariantInt(iTeam);
		AcceptEntityInput(rocket, "SetTeam", -1, -1, 0); 
		
		DispatchSpawn(rocket);
			
		float spawnLoc[3], angles[3], rocketVel[3], vBuffer[3];
		GetClientEyePosition(client, spawnLoc);
		GetClientEyeAngles(client, angles);
			
		GetAngleVectors(angles, vBuffer, NULL_VECTOR, NULL_VECTOR);
		
		rocketVel[0] = vBuffer[0]*velocity;
		rocketVel[1] = vBuffer[1]*velocity;
		rocketVel[2] = vBuffer[2]*velocity;
			
		if (forwardDistance != 0.0)
		{
			float fLen = forwardDistance * Sine( DegToRad( angles[0] + 90.0 ) );
			spawnLoc[0] = spawnLoc[0] + fLen * Cosine( DegToRad( angles[1] + 0.0) );
			spawnLoc[1] = spawnLoc[1] + fLen * Sine( DegToRad( angles[1] + 0.0) );
			spawnLoc[2] = spawnLoc[2] + forwardDistance * Sine( DegToRad( -1 * (angles[0] + 0.0)) );
		}
		TeleportEntity(rocket, spawnLoc, angles, rocketVel);
		
		b_ProjectileCanCollideWithAllies[rocket] = allowAlliedCollisions;
		s_ProjectileLogicPlugin[rocket] = pluginName;
		g_ProjectileLogic[rocket] = logic;
		
		if (!StrEqual(pluginName, "") && logic != INVALID_FUNCTION)
			g_DHookRocketExplode.HookEntity(Hook_Pre, rocket, GenericProjectile_Explode);
		
		return rocket;
	}
	
	return -1;
}

public MRESReturn GenericProjectile_Explode(int rocket)
{
	if (!StrEqual(s_ProjectileLogicPlugin[rocket], "") && g_ProjectileLogic[rocket] != INVALID_FUNCTION)
	{
		Handle plugin = GetPluginHandle(s_ProjectileLogicPlugin[rocket]);
		if (plugin != null)
		{
			MRESReturn ReturnValue = MRES_Ignored;
			
			Call_StartFunction(plugin, g_ProjectileLogic[rocket]);
			
			Call_PushCell(rocket);
			Call_PushCell(GetEntPropEnt(rocket, Prop_Send, "m_hOwnerEntity"));
			Call_PushCell(GetEntProp(rocket, Prop_Send, "m_iTeamNum"));
			
			Call_Finish(ReturnValue);
			
			return ReturnValue;
		}
	}
	
	return MRES_Ignored;
}

int entityBeingTraced = -1;
public bool CF_AOETrace(entity, contentsmask)
{
	if (!CF_DefaultTrace(entity, contentsmask))
		return false;
		
	return entity != entityBeingTraced;
}

ArrayList AOE_Hits = null;

public any Native_CF_GenericAOEDamage(Handle plugin, int numParams)
{
	Handle ReturnValue = CreateArray(16);
	
	int attacker = GetNativeCell(1);
	
	if (!IsValidEntity(attacker))
		return ReturnValue;
		
	int inflictor = GetNativeCell(2);
	int weapon = GetNativeCell(3);
	float dmg = GetNativeCell(4);
	int damageType = GetNativeCell(5);
	float radius = GetNativeCell(6);
	float groundZero[3];
	GetNativeArray(7, groundZero, sizeof(groundZero));
	float falloffStart = GetNativeCell(8);
	float falloffMax = GetNativeCell(9);
	bool skipDefault = GetNativeCell(10);
	bool includeUser = GetNativeCell(11);
	bool ignoreInvuln = GetNativeCell(12);
	char pluginName[255];
	GetNativeString(13, pluginName, sizeof(pluginName));
	Function logic = GetNativeFunction(14);

	delete AOE_Hits;
	AOE_Hits = CreateArray(255);
	
	TR_EnumerateEntitiesSphere(groundZero, radius, PARTITION_NON_STATIC_EDICTS, GenericAOE_Trace, attacker);
	
	for (int i = 0; i < GetArraySize(AOE_Hits); i++)
	{
		int victim = EntRefToEntIndex(GetArrayCell(AOE_Hits, i));
		if (IsValidEntity(victim))
		{
			if (IsValidClient(victim))
			{
				if (!IsPlayerAlive(victim) || (IsInvuln(victim) && !ignoreInvuln) || (victim == attacker && !includeUser))
					continue;
			}

			if (!GetEntProp(victim, Prop_Data, "m_takedamage") && !ignoreInvuln)
				continue;
			
			float vicLoc[3];
			GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", vicLoc);
			if (CF_IsPlayerCharacter(victim))
				vicLoc[2] += 40.0 * CF_GetCharacterScale(victim);

			float dist = GetVectorDistance(groundZero, vicLoc);

			if (dist > radius)
				continue;
			
			bool passed = true;
					
			if (!skipDefault)
			{
				entityBeingTraced = victim;
				Handle trace = TR_TraceRayFilterEx(groundZero, vicLoc, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, CF_AOETrace);
				passed = !TR_DidHit(trace);
				delete trace;
			}
			
			if (logic != INVALID_FUNCTION && !StrEqual(pluginName, ""))
			{
				Call_StartFunction(GetPluginHandle(pluginName), logic);
				Call_PushCell(victim);
				Call_Finish(passed);
			}
					
			if (passed)
			{
				float realDMG = dmg;
				if (dist > falloffStart)
				{
					realDMG *= 1.0 - (((dist - falloffStart) / (radius - falloffStart)) * falloffMax);
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
				
				SDKHooks_TakeDamage(victim, inflictor, attacker, realDMG, damageType, weapon, _, groundZero, false);
				PushArrayCell(ReturnValue, victim);
			}
		}
	}
	
	delete AOE_Hits;
	
	return ReturnValue;
}

public bool GenericAOE_Trace(int entity, int attacker)
{
	if (!HasEntProp(entity, Prop_Send, "m_iTeamNum"))
		return true;
		
	int targTeam = GetEntProp(attacker, Prop_Send, "m_iTeamNum");
	
	if (GetEntProp(entity, Prop_Send, "m_iTeamNum") != targTeam || (entity == attacker))
	{
		PushArrayCell(AOE_Hits, EntIndexToEntRef(entity));
		return true;
	}
	
	return true;
}

public Action CH_ShouldCollide(int ent1, int ent2, bool &result)
{
	Action ReturnVal = Plugin_Continue;
	bool CallForward = true;
	
	//First test: only allow simulated health kits to collide with the world.
	if (b_IsFakeHealthKit[ent1] || b_IsFakeHealthKit[ent2])
	{
		bool block = ent1 != 0 && ent2 != 0;
		
		if (block)
		{
			result = false;
			ReturnVal = Plugin_Changed;
			CallForward = false;
		}
	}
	
	//Second test: only allow simulated medigun shields to collide with entities on the opposite team.
	if (b_IsMedigunShield[ent1] || b_IsMedigunShield[ent2])
	{
		bool block = MediShield_Collision(ent1, ent2);
		
		if (block)
		{
			result = false;
			ReturnVal = Plugin_Changed;
			CallForward = false;
		}
	}
	
	if (CallForward)
	{
		Call_StartForward(g_ShouldCollide);
		
		Call_PushCell(ent1);
		Call_PushCell(ent2);
		Call_PushCellRef(result);
		
		Call_Finish(ReturnVal);
	}
	
	return ReturnVal;
}

public void MediShield_CollisionForward(int ent1, int ent2, int owner)
{
	float gt = GetGameTime();
	if (gt > f_NextShieldCollisionForward[ent1][ent2])
	{
		Call_StartForward(g_FakeMediShieldCollision);
		
		Call_PushCell(ent1);
		Call_PushCell(ent2);
		Call_PushCell(owner);
		
		Call_Finish();
		
		f_NextShieldCollisionForward[ent1][ent2] = gt + 0.2;
	}
}

public void MediShield_DamageForward(int shield, int attacker, int inflictor, float &damage, int &damagetype, int owner)
{
	Call_StartForward(g_FakeMediShieldDamaged);
	
	Call_PushCell(shield);
	Call_PushCell(attacker);
	Call_PushCell(inflictor);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	Call_PushCell(owner);
	
	Action returnVal;
	Call_Finish(returnVal);
}

public Action CH_PassFilter(int ent1, int ent2, bool &result)
{
	Action ReturnVal = Plugin_Continue;
	bool CallForward = true;

	if (ent1 < 0 || ent1 > 2048 || ent2 < 0 || ent2 > 2048)
		return Plugin_Continue;
	
	if (b_IsProjectile[ent1] && b_IsProjectile[ent2])
	{
		result = false;
		ReturnVal = Plugin_Changed;
		CallForward = false;
	}
	//First test: don't allow TF2 projectiles to collide with their owners or players who are on their owner's team:
	else if (IsValidClient(GetClientOfUserId(i_GenericProjectileOwner[ent1])))
	{
		TFTeam team = view_as<TFTeam>(GetEntProp(ent1, Prop_Send, "m_iTeamNum"));
		int owner = GetEntPropEnt(ent1, Prop_Send, "m_hOwnerEntity");
		if (ent2 == owner || (IsValidMulti(ent2, true, true, true, team) && !b_ProjectileCanCollideWithAllies[ent1]))
		{
			result = false;
			ReturnVal = Plugin_Changed;
			CallForward = false;
		}
	}
	else if (IsValidClient(GetClientOfUserId(i_GenericProjectileOwner[ent2])))
	{
		TFTeam team = view_as<TFTeam>(GetEntProp(ent2, Prop_Send, "m_iTeamNum"));
		int owner = GetEntPropEnt(ent2, Prop_Send, "m_hOwnerEntity");
		if (ent1 == owner || (IsValidMulti(ent1, true, true, true, team) && !b_ProjectileCanCollideWithAllies[ent2]))
		{
			result = false;
			ReturnVal = Plugin_Changed;
			CallForward = false;
		}
	}
	
	//Second test: don't allow fake health kits to collide with ANYTHING except for world geometry.
	if (b_IsFakeHealthKit[ent1] || b_IsFakeHealthKit[ent2])
	{
		bool block = ent1 != 0 && ent2 != 0;
		
		if (block)
		{
			result = false;
			ReturnVal = Plugin_Changed;
			CallForward = false;
		}
	}
	
	//Third test: only allow simulated medigun shields to collide with entities on the opposite team.
	if (b_IsMedigunShield[ent1] || b_IsMedigunShield[ent2])
	{
		bool block = MediShield_Collision(ent1, ent2);
		
		if (block)
		{
			result = false;
			ReturnVal = Plugin_Changed;
			CallForward = false;
		}
	}
		
	if (CallForward)
	{
		Call_StartForward(g_PassFilter);
		
		Call_PushCell(ent1);
		Call_PushCell(ent2);
		Call_PushCellRef(result);
		
		Call_Finish(ReturnVal);
	}
	
	return ReturnVal;
}

public Native_CF_CreateShieldWall(Handle plugin, int numParams)
{
	int owner = GetNativeCell(1);
	char model[255], skin[16];
	GetNativeString(2, model, sizeof(model));
	GetNativeString(3, skin, sizeof(skin));
	float scale = GetNativeCell(4);
	float health = GetNativeCell(5);
	float pos[3], ang[3];
	GetNativeArray(6, pos, sizeof(pos));
	GetNativeArray(7, ang, sizeof(ang));
	float lifespan = GetNativeCell(8);
	
	int prop = CreateEntityByName("prop_physics_multiplayer");
	if (IsValidEntity(prop))
	{
		DispatchKeyValue(prop, "targetname", "shield"); 
		PrecacheModel(model);
		DispatchKeyValue(prop, "model", model);
		
		DispatchSpawn(prop);
		
		ActivateEntity(prop);
		
		if (IsValidClient(owner))
		{
			SetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity", owner);
			SetEntProp(prop, Prop_Send, "m_iTeamNum", GetClientTeam(owner));
		}
		
		DispatchKeyValue(prop, "skin", skin);
		char healthChar[16];
		Format(healthChar, sizeof(healthChar), "%i", RoundFloat(health));
		DispatchKeyValue(prop, "Health", healthChar);
		SetEntityHealth(prop, RoundFloat(health));
		f_FakeMediShieldHP[prop] = health;
		f_FakeMediShieldMaxHP[prop] = health;
		
		char scalechar[16];
		Format(scalechar, sizeof(scalechar), "%f", scale);
		DispatchKeyValue(prop, "modelscale", scalechar);
		
		b_IsMedigunShield[prop] = true;
		SetEntityGravity(prop, 0.0);
		
		SDKHook(prop, SDKHook_OnTakeDamage, Shield_OnTakeDamage);
		SDKHook(prop, SDKHook_Touch, Shield_OnTouch);
		
		if (lifespan > 0.0)
		{
			CreateTimer(lifespan, Timer_RemoveEntity, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		TeleportEntity(prop, pos, ang, NULL_VECTOR);
		
		for (int i = 0; i <= 2048; i++)
		{
			f_NextShieldCollisionForward[prop][i] = 0.0;
		}
	}
	
	return prop;
}

public Action Shield_OnTouch(int shield, int collider)
{
	int owner = GetEntPropEnt(shield, Prop_Data, "m_hOwnerEntity");
	MediShield_CollisionForward(shield, collider, owner);
	return Plugin_Continue;
}

public Action Shield_OnTakeDamage(int prop, int &attacker, int &inflictor, float &damage, int &damagetype) 
{
	int owner = GetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity");
	
	if (IsValidClient(owner) && IsValidMulti(attacker, false, _, true, TF2_GetClientTeam(owner)))
	{
		damage = 0.0;
	}
	else
	{
		MediShield_DamageForward(prop, attacker, inflictor, damage, damagetype, owner);
	}
	
	f_FakeMediShieldHP[prop] -= damage;
	if (f_FakeMediShieldHP[prop] < 0.0)
	{
		RemoveEntity(prop);
	}
	
	damage = 0.0;
	
	return Plugin_Changed;
}

bool MediShield_Collision(int ent1, int ent2)
{
	//Neither entity is a medigun shield, don't modify collision.
	if (!b_IsMedigunShield[ent1] && !b_IsMedigunShield[ent2])
		return false;
		
	//Block collision if a medigun shield is colliding with the world.
	if (b_IsMedigunShield[ent1] && ent2 == 0 || b_IsMedigunShield[ent2] && ent1 == 0)
		return true;
		
	int team1 = GetEntProp(ent1, Prop_Send, "m_iTeamNum");
	int team2 = GetEntProp(ent2, Prop_Send, "m_iTeamNum");
	
	//The entity being collided with is not the world, block collision if the entities are on the same team.
	return team1 == team2;
}

public any Native_CF_GetShieldWallHealth(Handle plugin, int numParams)
{
	int shield = GetNativeCell(1);
	
	if (!IsValidEntity(shield))
		return 0.0;
		
	if (!b_IsMedigunShield[shield])
		return 0.0;
		
	return f_FakeMediShieldHP[shield];
}

public Native_CF_ChangeAbilityTitle(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	char newName[255];
	GetNativeString(3, newName, sizeof(newName));
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	switch(type)
	{
		case CF_AbilityType_Ult:
			Format(s_UltName[client], 255, "%s", newName);
		case CF_AbilityType_M2:
			Format(s_M2Name[client], 255, "%s", newName);
		case CF_AbilityType_M3:
			Format(s_M3Name[client], 255, "%s", newName);
		case CF_AbilityType_Reload:
			Format(s_ReloadName[client], 255, "%s", newName);
	}
}

public Native_CF_GetAbilityTitle(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	switch(type)
	{
		case CF_AbilityType_Ult:
			SetNativeString(3, s_UltName[client], 255);
		case CF_AbilityType_M2:
			SetNativeString(3, s_M2Name[client], 255);
		case CF_AbilityType_M3:
			SetNativeString(3, s_M3Name[client], 255);
		case CF_AbilityType_Reload:
			SetNativeString(3, s_ReloadName[client], 255);
	}
}

public Native_CF_ChangeSpecialResourceTitle(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char newName[255], newNamePlural[255];
	GetNativeString(2, newName, sizeof(newName));
	GetNativeString(3, newNamePlural, sizeof(newNamePlural));
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	Format(s_ResourceName[client], 255, "%s", newName);
	Format(s_ResourceName_Plural[client], 255, "%s", newNamePlural);
}

public Native_CF_GetSpecialResourceTitle(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char newName[255], newNamePlural[255];
	GetNativeString(2, newName, sizeof(newName));
	GetNativeString(3, newNamePlural, sizeof(newNamePlural));
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	SetNativeString(2, s_ResourceName[client], 255);
	SetNativeString(3, s_ResourceName_Plural[client], 255);
}

public any Native_CF_CheckTeleport(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float distance = GetNativeCell(2); 
	bool directional = GetNativeCell(3);
	float override[3];
	GetNativeArray(5, override, sizeof(override));
	bool UseOverride = GetNativeCell(6);
	
	if (!IsValidMulti(client))
		return false;
		
	float pos[3];
	bool result = DPT_TryTeleport(client, distance, directional, pos, false, override, UseOverride);
	SetNativeArray(4, pos, sizeof(pos));
	return result;
}

public Native_CF_Teleport(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float distance = GetNativeCell(2); 
	bool directional = GetNativeCell(3);
	bool IgnoreSafety = GetNativeCell(5);
	float override[3];
	GetNativeArray(6, override, sizeof(override));
	bool UseOverride = GetNativeCell(7);
	
	if (!IsValidMulti(client))
		return;
		
	float pos[3];
	bool result = DPT_TryTeleport(client, distance, directional, pos, IgnoreSafety, override, UseOverride);
	SetNativeArray(4, pos, sizeof(pos));
	
	if (result)
	{
		float eyeAngles[3];
		GetClientEyeAngles(client, eyeAngles);
		
		int buttons = GetClientButtons(client);
		if (buttons & IN_DUCK != 0)
		{
			if (directional)
			{
				bool left = buttons & IN_LEFT != 0 && buttons & IN_RIGHT == 0;
				bool right = buttons & IN_RIGHT != 0 && buttons & IN_LEFT == 0;
				
				float flipmod = 0.0;
				
				if (left)
				{
					flipmod = 90.0;
				}
				else if (right)
				{
					flipmod = -90.0;
				}
				
				if (flipmod > 0.0)
				{
					eyeAngles[1] += -flipmod * 2.0;
				}
				else
				{
					if (buttons & IN_BACK != 0 && buttons & IN_FORWARD == 0)
					{
						eyeAngles[0] += 180.0;
					}
					else
					{
						eyeAngles[1] += 180.0;
					}
				}
			}
			else
			{
				eyeAngles[1] += 180.0;
			}
		}
		
		TeleportEntity(client, pos, eyeAngles, NULL_VECTOR);
	}
}

public any Native_CF_GetShieldWallMaxHealth(Handle plugin, int numParams)
{
	int shield = GetNativeCell(1);
	
	if (!IsValidEntity(shield))
		return 0.0;
		
	if (!b_IsMedigunShield[shield])
		return 0.0;
		
	return f_FakeMediShieldMaxHP[shield];
}

public Native_CF_ApplyTemporarySpeedChange(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int mode = GetNativeCell(2);
	float amt = GetNativeCell(3);
	float duration = GetNativeCell(4);
	int maxMode = GetNativeCell(5);
	float maxSpeed = GetNativeCell(6);
	bool sound = GetNativeCell(7);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	float baseSpeed = CF_GetCharacterBaseSpeed(client);
	float currentSpeed = CF_GetCharacterSpeed(client);

	float targetSpeed;
	switch (mode)
	{
		case 1:
			targetSpeed = currentSpeed + ((baseSpeed * amt) - baseSpeed);
		case 2:
			targetSpeed = currentSpeed * amt;
		default:
			targetSpeed = currentSpeed + amt;
	}
		
	if (maxMode != 0)
	{
		float targetMax = maxSpeed;
		if (maxMode == 1)
			targetMax *= baseSpeed;

		//We only cap targetSpeed if it is faster than the user's current speed, because that means this speed change is meant to be a buff.
		//We don't want buffs to slow people down just because they already have a stronger buff active.
		if (targetSpeed > targetMax && targetSpeed > currentSpeed)
			targetSpeed = targetMax;
	}
	
	float speedGained = targetSpeed - currentSpeed;
	if (speedGained != 0.0)
	{
		CF_SetCharacterSpeed(client, targetSpeed);
		
		if (duration > 0.0)
		{
			DataPack pack = new DataPack();
			WritePackCell(pack, GetClientUserId(client));
			WritePackFloat(pack, speedGained);
			WritePackFloat(pack, GetGameTime() + duration);
			WritePackCell(pack, sound);
			RequestFrame(TempSpeed_Check, pack);
		}
	}
	
	if (sound)
		EmitSoundToClient(client, SOUND_SPEED_APPLY);
}

public void TempSpeed_Check(DataPack pack)
{
	ResetPack(pack);
	
	int client = GetClientOfUserId(ReadPackCell(pack));
	float speedGained = ReadPackFloat(pack);
	float endTime = ReadPackFloat(pack);
	bool sound = ReadPackCell(pack);
	
	//f_CancelTemporarySpeedMod is used so that we don't revert speed if the client becomes a new character before the speed is set to revert.
	if (!CF_IsPlayerCharacter(client) || GetGameTime() < f_CancelTemporarySpeedMod[client])
	{
		delete pack;
		return;
	}
	
	if (GetGameTime() >= endTime)
	{
		float current = CF_GetCharacterSpeed(client);
		CF_SetCharacterSpeed(client, current - speedGained);
		
		if (sound)
			EmitSoundToClient(client, SOUND_SPEED_REMOVE);
		
		delete pack;
		return;
	}
	
	RequestFrame(TempSpeed_Check, pack);
}

public Native_CF_ToggleHUD(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	bool toggle = GetNativeCell(2);
	
	CFA_ToggleHUD(client, toggle);
}

public Native_CF_WorldSpaceCenter(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	float output[3];
	GetNativeArray(2, output, sizeof(output));
	
	if (!IsValidEntity(entity))
		return;
		
	SDKCall(g_hSDKWorldSpaceCenter, entity, output);
	SetNativeArray(2, output, sizeof(output));
}

public Native_CF_CreateHealthPickup(Handle plugin, int numParams)
{
	int owner = GetNativeCell(1);
	float amt = GetNativeCell(2);
	float radius = GetNativeCell(3);
	int mode = GetNativeCell(4);
	float lifespan = GetNativeCell(5);
	float pos[3];
	GetNativeArray(6, pos, sizeof(pos));
	char pluginName[255];
	GetNativeString(7, pluginName, sizeof(pluginName));
	Function filter = GetNativeFunction(8);
	char model[255], sequence[255], sound[255], physModel[255];
	GetNativeString(9, model, sizeof(model));
	GetNativeString(10, sequence, sizeof(sequence));
	float rate = GetNativeCell(11);
	float scale = GetNativeCell(12);
	int skin = GetNativeCell(13);
	GetNativeString(14, sound, sizeof(sound));
	float hpMult = GetNativeCell(15);
	GetNativeString(16, physModel, sizeof(physModel));
	float mass = GetNativeCell(17);
	float inertia = GetNativeCell(18);
	
	int phys = CreateEntityByName("prop_physics_override");
	int prop = CreateEntityByName("prop_dynamic_override");
	if (IsValidEntity(phys) && IsValidEntity(prop))
	{
		DispatchKeyValue(phys, "targetname", "healthparent"); 
		DispatchKeyValue(phys, "spawnflags", "2"); 
		DispatchKeyValue(phys, "model", physModel);
		DispatchKeyValueFloat(phys, "massScale", mass);
		DispatchKeyValueFloat(phys, "intertiascale", inertia);
				
		DispatchSpawn(phys);
				
		ActivateEntity(phys);
		
		SetEntProp(phys, Prop_Data, "m_takedamage", 0, 1);
		
		if (IsValidClient(owner))
		{
			SetEntPropEnt(phys, Prop_Data, "m_hOwnerEntity", owner);
			SetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity", owner);
		}
			
		SetEntProp(phys, Prop_Send, "m_fEffects", 32);
		
		SetEntityModel(prop, model);
					
		char scalechar[16];
		Format(scalechar, sizeof(scalechar), "%f", scale);
		DispatchKeyValue(prop, "modelscale", scalechar);
		DispatchKeyValue(prop, "StartDisabled", "false");
					
		DispatchSpawn(prop);
					
		AcceptEntityInput(prop, "Enable");
		
		TeleportEntity(phys, pos, NULL_VECTOR, NULL_VECTOR);
		TeleportEntity(prop, pos, NULL_VECTOR, NULL_VECTOR);
		
		DispatchKeyValue(prop, "spawnflags", "1");
		SetVariantString("!activator");
		AcceptEntityInput(prop, "SetParent", phys);
		
		SetVariantString(sequence);
		AcceptEntityInput(prop, "SetAnimation");
		DispatchKeyValueFloat(prop, "playbackrate", rate);
		char skinchar[16];
		Format(skinchar, sizeof(skinchar), "%i", skin);
		DispatchKeyValue(prop, "skin", skinchar);
		
		if (lifespan > 0.0)
		{
			CreateTimer(lifespan, Timer_RemoveEntity, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(lifespan, Timer_RemoveEntity, EntIndexToEntRef(phys), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		b_IsFakeHealthKit[phys] = true;
		
		DataPack pack = new DataPack();
		
		WritePackCell(pack, IsValidClient(owner) ? GetClientUserId(owner) : -1);
		WritePackCell(pack, EntIndexToEntRef(phys));
		WritePackFloat(pack, amt);
		WritePackFloat(pack, radius);
		WritePackCell(pack, mode);
		WritePackFunction(pack, filter);
		WritePackString(pack, sound);
		WritePackFloat(pack, hpMult);
		WritePackString(pack, pluginName);
		WritePackString(pack, "healthgained_red_large");
		WritePackString(pack, "healthgained_blu_large");
		
		RequestFrame(FakeHealthKit_Think, pack);
		
		return phys;
	}
	
	return -1;
}

public void FakeHealthKit_Think(DataPack pack)
{
	ResetPack(pack);
	
	int owner = GetClientOfUserId(ReadPackCell(pack));
	int kit = EntRefToEntIndex(ReadPackCell(pack));
	float amt = ReadPackFloat(pack);
	float radius = ReadPackFloat(pack);
	int mode = ReadPackCell(pack);
	Function filter = ReadPackFunction(pack);
	char snd[255], plugin[255], redPart[255], bluePart[255];
	ReadPackString(pack, snd, sizeof(snd));
	float hpMult = ReadPackFloat(pack);
	ReadPackString(pack, plugin, sizeof(plugin));
	ReadPackString(pack, redPart, sizeof(redPart));
	ReadPackString(pack, bluePart, sizeof(bluePart));

	if (!IsValidEntity(kit))
	{
		delete pack;
		return;
	}
		
	float pos[3];
	GetEntPropVector(kit, Prop_Send, "m_vecOrigin", pos);
	
	Handle FunctionPlugin = GetPluginHandle(plugin);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidMulti(i))
		{
			float pos2[3];
			GetClientAbsOrigin(i, pos2);
			
			bool result;
			
			if (FunctionPlugin == INVALID_HANDLE || filter == INVALID_FUNCTION)
			{
				result = true;
			}
			else
			{
				Call_StartFunction(FunctionPlugin, filter);
				
				Call_PushCell(kit);
				Call_PushCell(owner);
				Call_PushCell(i);
				
				Call_Finish(result);
			}
			
			int maxHPCheck = RoundFloat(float(TF2Util_GetEntityMaxHealth(i)) * hpMult);
			if (GetEntProp(i, Prop_Send, "m_iHealth") >= maxHPCheck)
				result = false;
			
			if (GetVectorDistance(pos, pos2) <= radius && result)
			{
				float healing = amt;
				
				if (mode == 0)
				{
					float maxHP = float(TF2Util_GetEntityMaxHealth(i));
					healing = amt * maxHP;
				}
				
				CF_HealPlayer(i, owner, RoundFloat(healing), hpMult);
				EmitSoundToClient(i, snd, _, _, 120);
				
				delete pack;
				
				RemoveEntity(kit);
				
				if (TF2_GetClientTeam(i) == TFTeam_Red)
				{
					SpawnParticle(pos, redPart, 2.0);
				}
				else
				{
					SpawnParticle(pos, bluePart, 2.0);
				}
				
				return;
			}
		}
	}
		
	RequestFrame(FakeHealthKit_Think, pack);
}

float Medigun_HealBucket[MAXPLAYERS + 1] = { 0.0, ... };

public Action Medigun_PreThink(int client)
{
	if (!IsPlayerHoldingWeapon(client, 1))
		return Plugin_Continue;
	
	int medigun = GetPlayerWeaponSlot(client, 1);
	if (!IsValidEntity(medigun))
		return Plugin_Continue;
		
	char classname[255];
	GetEntityClassname(medigun, classname, sizeof(classname));
	
	if (StrContains(classname, "medigun") == -1)
	{
		SDKUnhook(client, SDKHook_PreThink, Medigun_PreThink);
		return Plugin_Stop;
	}
	
	int target = GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
	if (IsValidEntity(target) && target > 0)
	{
		float amt = Medigun_CalculateHealRate(medigun, client) / 63.0;
		CFA_GiveChargesForHealing(client, amt);
		
		Medigun_HealBucket[client] += amt;
		if (Medigun_HealBucket[client] >= 1.0)
		{
			int heals = RoundToFloor(Medigun_HealBucket[client]);
			float remainder = Medigun_HealBucket[client] - float(heals);
			
			CFA_AddHealingPoints(client, heals);
			Medigun_HealBucket[client] = remainder;
		}
	}
	
	return Plugin_Continue;
}

//Note that this does not account for crit heals.
float Medigun_CalculateHealRate(int medigun, int client)
{
	float BaseHealingRate = 24.0;
	BaseHealingRate *= GetAttributeValue(medigun, 7, 1.0);
	BaseHealingRate *= GetAttributeValue(medigun, 8, 1.0);
	float mastery = 0.25 * GetAttributeValue(medigun, 493, 0.0);
	BaseHealingRate *= (1.0 + mastery);
	
	if (TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
		BaseHealingRate *= 2.0;
		
	if (TF2_IsPlayerInCondition(client, TFCond_KingAura) || TF2_IsPlayerInCondition(client, TFCond_KingRune))
		BaseHealingRate *= 1.5;

	if (GetAttributeValue(medigun, 231, 0.0) > 0.0 && TF2_IsPlayerInCondition(client, TFCond_MegaHeal))
		BaseHealingRate *= 3.0;
		
	return BaseHealingRate;
}

public Native_CF_IsValidTarget(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	TFTeam team = GetNativeCell(2);
	char pluginName[255];
	GetNativeString(3, pluginName, sizeof(pluginName));
	Function filter = GetNativeFunction(4);
	
	if (!IsValidEntity(entity))
		return false;
		
	if (team != TFTeam_Unassigned)
	{
		if (!HasEntProp(entity, Prop_Send, "m_iTeamNum"))
			return false;
			
		TFTeam entTeam = view_as<TFTeam>(GetEntProp(entity, Prop_Send, "m_iTeamNum"));
		if (team != entTeam)
			return false;
	}
	
	if (!StrEqual(pluginName, "") && filter != INVALID_FUNCTION)
	{
		Handle FunctionPlugin = GetPluginHandle(pluginName);
	
		bool result;
			
		if (FunctionPlugin == INVALID_HANDLE)
		{
			result = true;
		}
		else
		{
			Call_StartFunction(FunctionPlugin, filter);
				
			Call_PushCell(entity);
				
			Call_Finish(result);
		}
		
		delete FunctionPlugin;
		
		return result;
	}
	
	return true;
}

public Native_CF_GetClosestTarget(Handle plugin, int numParams)
{
	float pos[3];
	GetNativeArray(1, pos, sizeof(pos));
	
	bool IncludeEntities = GetNativeCell(2);
	
	float closestDist = GetNativeCellRef(3);
	float maxDist = GetNativeCell(4);
	TFTeam team = GetNativeCell(5);
	char pluginName[255];
	GetNativeString(6, pluginName, sizeof(pluginName));
	Function filter = GetNativeFunction(7);
	
	int closestEnt = -1;
	
	for (int i = 1; i <= (IncludeEntities ? 2048 : MaxClients); i++)
	{
		if (!CF_IsValidTarget(i, team, pluginName, filter))
			continue;
		
		float otherPos[3];
		CF_WorldSpaceCenter(i, otherPos);
		
		float dist = GetVectorDistance(pos, otherPos);
		
		if (maxDist > 0.0 && dist > maxDist)
			continue;
			
		if (dist < closestDist || closestEnt == -1)
		{
			closestDist = dist;
			closestEnt = i;
		}
	}
	
	return closestEnt;
}

bool b_BlockFireballs[MAXPLAYERS + 1] = { false, ... };
bool b_Casting[MAXPLAYERS + 1] = { false, ... };

public Native_CF_SimulateSpellbookCast(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char atts[255];
	GetNativeString(2, atts, sizeof(atts));
	CF_SpellIndex index = GetNativeCell(3);
	bool instant = GetNativeCell(5);
	if (instant)
	{
		if (StrEqual(atts, ""))
			Format(atts, sizeof(atts), "178 ; 0.0");
		else
			Format(atts, sizeof(atts), "%s ; 178 ; 0.0", atts);
	}
	
	int weapon = TF2_GetActiveWeapon(client);
	if (!IsValidEntity(weapon))
		return;
		
	char classname[255];
	GetEntityClassname(weapon, classname, sizeof(classname));
	Format(classname, sizeof(classname), "use %s", classname);
	
	TF2_RemoveWeaponSlot(client, 5);
	int spellbook = CF_SpawnWeapon(client, "tf_weapon_spellbook", 1070, 77, 7, 5, 0, 0, atts);
	if (!IsValidEntity(spellbook))
		return;
		
	FakeClientCommand(client, "use tf_weapon_spellbook");
			
	b_BlockFireballs[client] = GetNativeCell(4);
	b_Casting[client] = true;
			
	SetEntProp(spellbook, Prop_Send, "m_iSpellCharges", 1);
	SetEntProp(spellbook, Prop_Send, "m_iSelectedSpellIndex", view_as<int>(index));
	
	DataPack pack = new DataPack();
	CreateDataTimer(0.3, DeleteSimulatedSpellbook, pack, TIMER_FLAG_NO_MAPCHANGE);	//TODO: 0.3 is a magic number and will break shit if the user decides to mess with the spellbook's deploy time. Figure out a different way to remove the spellbook after it is done casting. Also need to prevent weapon switching during the cast.
	WritePackCell(pack, GetClientUserId(client));
	WritePackString(pack, classname);
}

public Action DeleteSimulatedSpellbook(Handle deletethebook, DataPack pack)
{
	ResetPack(pack);
	
	int client = GetClientOfUserId(ReadPackCell(pack));
	char command[255];
	ReadPackString(pack, command, sizeof(command));
	
	if (!IsValidMulti(client))
		return Plugin_Continue;
		
	FakeClientCommand(client, command);
	TF2_RemoveWeaponSlot(client, 5);
	
	return Plugin_Continue;
}

public void CFA_OnEntityCreated(int entity, const char[] classname)
{
	if (StrContains(classname, "tf_projectile") != -1)
	{
		SDKHook(entity, SDKHook_SpawnPost, GetOwner);
		b_IsProjectile[entity] = true;
		b_ProjectileCanCollideWithAllies[entity] = StrEqual(classname, "tf_projectile_healing_bolt");
	}
	
	if (StrContains(classname, "tf_projectile_spell") != -1)
	{
		SDKHook(entity, SDKHook_SpawnPost, OnSpellSpawn);
	}
}

public Action OnSpellSpawn(int ent)
{
	if (!IsValidEntity(ent))
		return Plugin_Continue;
		
	int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if (!IsValidClient(owner))
		return Plugin_Continue;
	
	if (!b_Casting[owner])
		return Plugin_Continue;
	
	int entity = ent;
	
	if (b_BlockFireballs[owner])
	{	
		entity = -1;
		TeleportEntity(ent, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(ent, "Kill");
		RemoveEntity(ent);
			
		b_BlockFireballs[owner] = false;
	}
	
	Call_StartForward(g_SimulatedSpellCast);
	
	Call_PushCell(owner);
	Call_PushCell(entity);
	
	Call_Finish();
	
	b_Casting[owner] = false;
	
	return Plugin_Continue;
}

bool IsCasting(int client) { return b_Casting[client]; }

bool b_VMHideWeapon[MAXPLAYERS + 1] = { false, ... };
bool b_VMBlockSwitch[MAXPLAYERS + 1] = { false, ... };
bool b_VMBlockAttack[MAXPLAYERS + 1] = { false, ... };

float f_VMAnimEndTime[MAXPLAYERS + 1] = { 0.0, ... };

int VMAnim_FakeVM[MAXPLAYERS+1] = { -1, ... };

char VMAnim_ForcedSequence[MAXPLAYERS + 1][255];

//TODO: Make this work with custom weapon models.
public Native_CF_ForceViewmodelAnimation(Handle plugin, int numParams)
{
	return 0;
	/*int client = GetNativeCell(1);
	char activity[255];
	GetNativeString(2, activity, sizeof(activity));
	bool hideWeapon = GetNativeCell(3);
	bool blockAttack = GetNativeCell(4);
	bool blockWeaponSwitch = GetNativeCell(5);
	
	int ent = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if (!IsValidEntity(ent))
		return;
		
	CBaseAnimating viewmodel = CBaseAnimating(ent);
	int sequence = viewmodel.LookupSequence(activity);
	if (sequence == -1)
		return;
		
	float duration = viewmodel.SequenceDuration(sequence);
	
	viewmodel.ResetSequence(sequence);
	
	float gt = GetGameTime();
	f_VMAnimEndTime[client] = gt + duration;
	b_VMHideWeapon[client] = hideWeapon;
	b_VMBlockSwitch[client] = blockWeaponSwitch;
	b_VMBlockAttack[client] = blockAttack;
	Format(VMAnim_ForcedSequence[client], 255, "%s", activity);
	
	if (blockAttack)
	{
		VMAnim_BlockAttacks(client);
	}
	
	if (hideWeapon)
	{	
		int fakeVM = CreateEntityByName("tf_wearable_vm");
		if (IsValidEntity(fakeVM))
		{
			int team = GetEntProp(client, Prop_Send, "m_iTeamNum");
			
			SetEntProp(ent, Prop_Send, "m_fEffects", GetEntProp(ent, Prop_Send, "m_fEffects") | EF_NODRAW);
			
			SetEntProp(fakeVM, Prop_Send, "m_nModelIndex", GetEntProp(ent, Prop_Send, "m_nModelIndex"));
			SetEntProp(fakeVM, Prop_Send, "m_fEffects", 129);
			SetEntProp(fakeVM, Prop_Send, "m_iTeamNum", team);
			SetEntProp(fakeVM, Prop_Send, "m_nSkin", team-2);
			SetEntProp(fakeVM, Prop_Send, "m_usSolidFlags", 4);
			SetEntityCollisionGroup(fakeVM, 11);
			SetEntProp(fakeVM, Prop_Send, "m_bValidatedAttachedEntity", 1);
				
			DispatchSpawn(fakeVM);
			SetVariantString("!activator");
			ActivateEntity(fakeVM);

			VMAnim_FakeVM[client] = EntIndexToEntRef(fakeVM);

			SDKCall_EquipWearable(client, fakeVM);
		}
	}
	
	RequestFrame(VMAnim_Check, GetClientUserId(client));*/
}

public void VMAnim_BlockAttacks(int client)
{
	for (int i = 0; i <= 5; i++)
	{
		int weapon = GetPlayerWeaponSlot(client, i);
			
		if (IsValidEntity(weapon))
		{
			float nextAttack = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack");
			if (nextAttack < f_VMAnimEndTime[client])
			{
				nextAttack = f_VMAnimEndTime[client] + 0.1;
				SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", nextAttack);
			}
				
			//TODO: Repeat for secondary and special attacks
		}
	}
}

/*public void VMAnim_Check(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return;
		
	float gt = GetGameTime();
	float timePerFrame = 0.01587302;
	
	if (gt + timePerFrame >= f_VMAnimEndTime[client])
	{
		if (b_VMHideWeapon[client])
		{
			int fakeVM = EntRefToEntIndex(VMAnim_FakeVM[client]);
			if (IsValidEntity(fakeVM))
			{
				TF2_RemoveWearable(client, fakeVM);
			}
			int ent = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
			if (IsValidEntity(ent))
			{
				SetEntProp(ent, Prop_Send, "m_fEffects", GetEntProp(ent, Prop_Send, "m_fEffects") &~ EF_NODRAW);
			}
			
			b_VMHideWeapon[client] = false;
		}
		b_VMBlockSwitch[client] = false;
		
		Call_StartForward(g_ForcedVMAnimEnd);
		
		Call_PushCell(client);
		Call_PushString(VMAnim_ForcedSequence[client]);
		
		Call_Finish();
		
		return;
	}
	else	//We do this every frame instead of just once at the start because otherwise other plugins may interfere.
	{
		if (b_VMBlockAttack[client])
			VMAnim_BlockAttacks(client);
	}
	
	RequestFrame(VMAnim_Check, id);
}*/

public Action CFA_WeaponCanSwitch(int client, int weapon)
{
    if (!b_VMBlockSwitch[client])
    	return Plugin_Continue;
    	
    if (GetGameTime() <= f_VMAnimEndTime[client])
    	return Plugin_Handled;
    	
    return Plugin_Continue;
} 

public Native_CF_SetAbilityStocks(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	int numStocks = GetNativeCell(3);
	bool ignoreMax = GetNativeCell(4);

	if (!CF_IsPlayerCharacter(client))
		return;

	if (!AbilityUsesStocks(client, type))
		return;

	switch(type)
	{
		case CF_AbilityType_M2:
		{
			i_M2Stocks[client] = numStocks;
			if (i_M2Stocks[client] > i_M2MaxStocks[client] && !ignoreMax)
				i_M2Stocks[client] = i_M2MaxStocks[client];

			if (i_M2Stocks[client] < i_M2MaxStocks[client])
				CreateStockTimer(client, type, f_M2CD[client]);
		}
		case CF_AbilityType_M3:
		{
			i_M3Stocks[client] = numStocks;
			if (i_M3Stocks[client] > i_M3MaxStocks[client] && !ignoreMax)
				i_M3Stocks[client] = i_M3MaxStocks[client];

			if (i_M3Stocks[client] < i_M3MaxStocks[client])
				CreateStockTimer(client, type, f_M3CD[client]);
		}
		case CF_AbilityType_Reload:
		{
			i_ReloadStocks[client] = numStocks;
			if (i_ReloadStocks[client] > i_ReloadMaxStocks[client] && !ignoreMax)
				i_ReloadStocks[client] = i_ReloadMaxStocks[client];

			if (i_ReloadStocks[client] < i_ReloadMaxStocks[client])
				CreateStockTimer(client, type, f_ReloadCD[client]);
		}
	}
}

public Native_CF_SetAbilityMaxStocks(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	int numStocks = GetNativeCell(3);

	if (!CF_IsPlayerCharacter(client))
		return;

	switch(type)
	{
		case CF_AbilityType_M2:
		{
			i_M2MaxStocks[client] = numStocks;
			CreateStockTimer(client, type, f_M2CD[client]);
		}
		case CF_AbilityType_M3:
		{
			i_M3MaxStocks[client] = numStocks;
			CreateStockTimer(client, type, f_M3CD[client]);
		}
		case CF_AbilityType_Reload:
		{
			i_ReloadMaxStocks[client] = numStocks;
			CreateStockTimer(client, type, f_ReloadCD[client]);
		}
	}
}

public Native_CF_GetAbilityStocks(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);

	switch(type)
	{
		case CF_AbilityType_M2:
		{
			return i_M2Stocks[client];
		}
		case CF_AbilityType_M3:
		{
			return i_M3Stocks[client];
		}
		case CF_AbilityType_Reload:
		{
			return i_ReloadStocks[client];
		}
	}
}

public Native_CF_GetAbilityMaxStocks(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);

	switch(type)
	{
		case CF_AbilityType_M2:
		{
			return i_M2MaxStocks[client];
		}
		case CF_AbilityType_M3:
		{
			return i_M3MaxStocks[client];
		}
		case CF_AbilityType_Reload:
		{
			return i_ReloadMaxStocks[client];
		}
	}
}

public Native_CF_SetLocalOrigin(Handle plugin, int numParams)
{
	int index = GetNativeCell(1);
	float localOrigin[3];
	GetNativeArray(2, localOrigin, 3);
	SDKCall_SetLocalOrigin(index, localOrigin);
}

stock void SDKCall_SetLocalOrigin(int index, float localOrigin[3])
{
	if(g_hSetLocalOrigin)
	{
		SDKCall(g_hSetLocalOrigin, index, localOrigin);
	}
}