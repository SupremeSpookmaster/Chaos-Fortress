GlobalForward g_PreDamageForward;
GlobalForward g_BonusDamageForward;
GlobalForward g_ResistanceDamageForward;
GlobalForward g_PostDamageForward;
GlobalForward g_AllowStabForward;
GlobalForward g_OnStab;
GlobalForward g_OnTraceAttack;

bool b_HeadshotUseCustomAttribs[2048][2048];

public void CFDMG_MakeForwards()
{
	g_PreDamageForward = new GlobalForward("CF_OnTakeDamageAlive_Pre", ET_Event, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef,
											Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_CellByRef);
	g_BonusDamageForward = new GlobalForward("CF_OnTakeDamageAlive_Bonus", ET_Event, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef,
											Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_CellByRef);
	g_ResistanceDamageForward = new GlobalForward("CF_OnTakeDamageAlive_Resistance", ET_Event, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef,
											Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_CellByRef);
	g_PostDamageForward = new GlobalForward("CF_OnTakeDamageAlive_Post", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell);
	g_AllowStabForward = new GlobalForward("CF_OnCheckCanBackstab", ET_Ignore, Param_Cell, Param_Cell, Param_CellByRef, Param_CellByRef);
	g_OnStab = new GlobalForward("CF_OnBackstab", ET_Ignore, Param_Cell, Param_Cell, Param_FloatByRef);
	g_OnTraceAttack = new GlobalForward("CF_OnTraceAttack", ET_Event, Param_Cell, Param_CellByRef, Param_CellByRef, Param_Cell, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Cell, Param_CellByRef)
}

#if defined _pnpc_included_

public Action PNPC_OnPNPCTakeDamage(PNPC npc, float &damage, int weapon, int inflictor, int attacker, int &damagetype, int &damagecustom, float damageForce[3], float damagePosition[3])
{
	return CFDMG_OnNonPlayerDamaged(npc.Index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, npc.b_IsABuilding);
}

public void PNPC_OnMeleeHit(int attacker, int weapon, int target, float &damage, bool &crit, bool &canStab, bool &forceStab, bool &result)
{
	CFDMG_CheckCanStab(attacker, target, forceStab, canStab);
}

public void PNPC_OnBackstab(int attacker, int victim, float &damage)
{
	CFDMG_OnBackstab(attacker, victim, damage);
}

#endif

void CFDMG_CheckCanStab(int attacker, int target, bool &forceStab, bool &canStab)
{
	if (!IsPhysProp(target))
	{
		Call_StartForward(g_AllowStabForward);

		Call_PushCell(attacker);
		Call_PushCell(target);
		Call_PushCellRef(forceStab);
		Call_PushCellRef(canStab);

		Call_Finish();
	}
}

public void CFDMG_OnBackstab(int attacker, int victim, float &damage)
{
	Call_StartForward(g_OnStab);

	Call_PushCell(attacker);
	Call_PushCell(victim);
	Call_PushFloatRef(damage);

	Call_Finish();
}

public void CFDMG_OnEntityCreated(int entity, const char[] classname)
{
	if (StrContains(classname, "npc") != -1 || StrEqual(classname, "obj_sentrygun") || StrEqual(classname, "obj_dispenser") || StrEqual(classname, "obj_teleporter"))
	{
		SDKHook(entity, SDKHook_TraceAttack, CFDMG_TraceAttack);
	}

	if (StrEqual(classname, "obj_sentrygun") || StrEqual(classname, "obj_dispenser") || StrEqual(classname, "obj_teleporter"))
	{
		SDKHook(entity, SDKHook_OnTakeDamage, CFDMG_OnBuildingDamaged);
	}
}

public Action CFDMG_OnBuildingDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	return CFDMG_OnNonPlayerDamaged(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, true);
}

public Action CFDMG_OnNonPlayerDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], bool isBuilding)
{
	float originalDmg = damage;
	Action ReturnValue = Plugin_Continue;
	Action newValue;

	int damagecustom = 0;	//This is not used for anything, I only have it because I can't compile this without passing a variable and I really don't feel like restructuring this right now.
	if (IsValidEntity(weapon) && IsValidEntity(victim) && IsValidEntity(attacker))
		CFDMG_CalculateDMGFromCustAtts(victim, attacker, inflictor, damage, weapon, damagePosition, damagecustom);
	
	//First, we call PreDamage:
	ReturnValue = CFDMG_CallDamageForward(g_PreDamageForward, victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	
	//Next, we call BonusDamage:
	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop)
	{
		newValue = CFDMG_CallDamageForward(g_BonusDamageForward, victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		if (newValue > ReturnValue)
		{
			ReturnValue = newValue;
		}
	}
	
	//After that, we call ResistanceDamage:
	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop)
	{
		newValue = CFDMG_CallDamageForward(g_ResistanceDamageForward, victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		if (newValue > ReturnValue)
		{
			ReturnValue = newValue;
		}
	}

	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop && originalDmg != damage)
		ReturnValue = Plugin_Changed;

	//Finally, call PostDamage and then give resources/ult charge:
	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop)
	{
		Call_StartForward(g_PostDamageForward);

		Call_PushCell(victim);
		Call_PushCell(attacker);
		Call_PushCell(inflictor);
		Call_PushFloat(damage);
		Call_PushCell(weapon);

		Call_Finish();
		
		if (CF_GetRoundState() == 1 && attacker != victim && damage > 0.0 && GetTeam(attacker) != GetTeam(victim))
		{
			int health = GetBuildingHealth(victim);

			#if defined _pnpc_included_
			if (PNPC_IsNPC(victim))
				health = view_as<PNPC>(victim).i_Health;
			#endif

			if (RoundFloat(damage) >= health)
			{
				CF_GiveSpecialResource(attacker, 1.0, (isBuilding ? CF_ResourceType_Destruction : CF_ResourceType_Kill));
				CF_GiveUltCharge(attacker, 1.0, (isBuilding ? CF_ResourceType_Destruction : CF_ResourceType_Kill));
			}
			else
			{
				float dmgForResource = damage;
				CF_GiveSpecialResource(attacker, dmgForResource, (isBuilding ? CF_ResourceType_BuildingDamage : CF_ResourceType_DamageDealt));
				CF_GiveUltCharge(attacker, dmgForResource, (isBuilding ? CF_ResourceType_BuildingDamage : CF_ResourceType_DamageDealt));
			}
		}
	}

	return ReturnValue;
}

public Action CFDMG_TraceAttack(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	if (!IsValidEntity(victim))
		return Plugin_Continue;

	int weapon = -1;
	bool infIsNPC = false;

	#if defined _pnpc_included_
	infIsNPC = PNPC_IsNPC(inflictor);
	#endif

	if (!IsABuilding(inflictor, false) && !infIsNPC)
	{
		if (IsAProjectile(inflictor))
			weapon = GetEntPropEnt(inflictor, Prop_Send, "m_hOriginalLauncher");
		else if (IsValidClient(attacker))
			weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon")
	}

	bool wasHeadshot = (hitgroup == HITGROUP_HEAD);

	Call_StartForward(g_OnTraceAttack);

	Call_PushCell(victim);
	Call_PushCellRef(attacker);
	Call_PushCellRef(inflictor);
	Call_PushCell(weapon);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	Call_PushCellRef(ammotype);
	Call_PushCell(hitbox);
	Call_PushCellRef(hitgroup);

	Action result;
	Call_Finish(result);

	bool wasArrow = (IsValidEntity(inflictor) && IsAProjectile(inflictor));
	bool CanHeadshot = false;
	int effect = 2;

	if (hitgroup == HITGROUP_HEAD)
	{
		//Check for CF's internal custom headshot attributes.
		if (IsValidEntity(weapon))
		{
			float mult = TF2CustAttr_GetFloat(weapon, "chaos fortress headshot multiplier", 1.0);
			effect = TF2CustAttr_GetInt(weapon, "chaos fortress headshot effects", 2);

			if (mult != 1.0 || effect < 2)
			{
				if (IsValidEntity(attacker))
					b_HeadshotUseCustomAttribs[victim][attacker] = true;

				hitgroup = HITGROUP_GENERIC;	//Nullify the "real" headshot so we can cleanly apply our custom VFX and multipliers in the OnTakeDamageAlive hook later
				result = Plugin_Changed;
				CanHeadshot = true;
			}
		}

		//Custom headshot attributes were not used, so check if someone used the forward to force a headshot under circumstances where a headshot would not normally occur.
		if (!CanHeadshot && !wasHeadshot && hitgroup == HITGROUP_HEAD)
			CanHeadshot = true;
	}

	//Either a headshot was forced when it normally shouldn't be possible, or we're using the custom headshot attributes, so modify the kill icon.
	if (CanHeadshot)
		SetHeadshotIcon(effect, wasArrow);
	
	return result;
}

void CFDMG_CalculateDMGFromCustAtts(int victim, int attacker, int inflictor, float &damage, int weapon, float damagePosition[3], int &damagecustom)
{
	float override = TF2CustAttr_GetFloat(weapon, "chaos fortress base damage override", -1.0);
	if (override >= 0.0)
	{
		damage = override;
	}

	if (b_HeadshotUseCustomAttribs[victim][attacker])
	{
		damage *= TF2CustAttr_GetFloat(weapon, "chaos fortress headshot multiplier", 1.0);
		damagecustom |= TF_CUSTOM_HEADSHOT;

		int effect = TF2CustAttr_GetInt(weapon, "chaos fortress headshot effects", 2);
		if (effect == 1)
		{
			SpawnParticle(damagePosition, "minicrit_text", 0.2);

			if (IsValidClient(attacker))
				PlayMiniCritSound(attacker);

			if (IsValidClient(victim))
				PlayMiniCritSound(victim);
		}
		else if (effect > 1)
		{
			SpawnParticle(damagePosition, "crit_text", 0.2);

			if (IsValidClient(attacker))
				PlayCritSound(attacker);
				
			if (IsValidClient(victim))
				PlayCritVictimSound(victim);
		}
	}

	if (!b_HeadshotUseCustomAttribs[victim][attacker] || TF2CustAttr_GetInt(weapon, "chaos fortress custom headshot has falloff", 0) != 0)
	{
		float falloffStart = TF2CustAttr_GetFloat(weapon, "chaos fortress falloff distance start", -1.0);
		float falloffEnd = TF2CustAttr_GetFloat(weapon, "chaos fortress falloff distance end", -1.0);
		if (falloffStart >= 0.0 && falloffEnd >= 0.0)
		{
			float falloffMax = TF2CustAttr_GetFloat(weapon, "chaos fortress falloff amount", 0.0);

			if (falloffMax > 0.0)
			{
				float pos[3], vicPos[3];
				CF_WorldSpaceCenter(attacker, pos);
				CF_WorldSpaceCenter(victim, vicPos);

				float dist = GetVectorDistance(pos, vicPos);

				if (dist > falloffStart)
				{
					if (dist >= falloffEnd)
						damage *= (1.0 - falloffMax);
					else
						damage *= 1.0 - (((dist - falloffStart) / (falloffEnd - falloffStart)) * falloffMax);
				}
			}
		}
	}

	b_HeadshotUseCustomAttribs[victim][attacker] = false;
}

public void CFDMG_OnTakeDamageAlive_Post(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	Call_StartForward(g_PostDamageForward);

	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(inflictor);
	Call_PushFloat(damage);
	Call_PushCell(weapon);

	Call_Finish();
	
	if (!IsInvuln(victim) && CF_GetRoundState() == 1 && attacker != victim && damage > 0.0 && GetTeam(attacker) != GetTeam(victim))
	{
		float dmgForResource = damage;
		if (dmgForResource > CF_GetCharacterMaxHealth(victim))
			dmgForResource = CF_GetCharacterMaxHealth(victim);
			
		CF_GiveSpecialResource(attacker, dmgForResource, CF_ResourceType_DamageDealt);
		CF_GiveUltCharge(attacker, dmgForResource, CF_ResourceType_DamageDealt);
		CF_GiveSpecialResource(victim, dmgForResource, CF_ResourceType_DamageTaken);
		CF_GiveUltCharge(victim, dmgForResource, CF_ResourceType_DamageTaken);
	}

	if (victim == attacker)
		CF_IgnoreNextKB(victim);

	CF_SetKBWeapon(victim, weapon);
}

int i_LastWeaponDamagedBy[MAXPLAYERS + 1] = { -1, ... };

public Action CFDMG_OnTakeDamageAlive(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon,
	Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	float originalDmg = damage;
	Action ReturnValue = Plugin_Continue;
	Action newValue;

	bool usingCustomMeleeHitreg = false;

	#if defined _pnpc_included_
	usingCustomMeleeHitreg = PNPC_IsMeleeHitregEnabled();
	#endif

	if (!usingCustomMeleeHitreg && IsValidClient(victim) && weapon == GetPlayerWeaponSlot(attacker, 2))
	{
		bool canStab = damagecustom & TF_CUSTOM_BACKSTAB != 0, forceStab = false;
		CFDMG_CheckCanStab(attacker, victim, forceStab, canStab);

		if (canStab || forceStab)
		{
			CFDMG_OnBackstab(attacker, victim, damage);
			ReturnValue = Plugin_Changed;

			if (damagecustom & TF_CUSTOM_BACKSTAB == 0)
				damagecustom |= TF_CUSTOM_BACKSTAB;
		}
		else if (damagecustom & TF_CUSTOM_BACKSTAB != 0)
		{
			damagecustom &= ~TF_CUSTOM_BACKSTAB;
			damage = 0.0;
			ReturnValue = Plugin_Changed;
		}
	}

	if (IsValidEntity(weapon) && IsValidEntity(victim) && IsValidEntity(attacker))
		CFDMG_CalculateDMGFromCustAtts(victim, attacker, inflictor, damage, weapon, damagePosition, damagecustom);
	
	//First, we call PreDamage:
	ReturnValue = CFDMG_CallDamageForward(g_PreDamageForward, victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	
	//Next, we call BonusDamage:
	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop)
	{
		newValue = CFDMG_CallDamageForward(g_BonusDamageForward, victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		if (newValue > ReturnValue)
		{
			ReturnValue = newValue;
		}
	}
	
	//After that, we call ResistanceDamage:
	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop)
	{
		newValue = CFDMG_CallDamageForward(g_ResistanceDamageForward, victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		if (newValue > ReturnValue)
		{
			ReturnValue = newValue;
		}
	}

	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop && originalDmg != damage)
		ReturnValue = Plugin_Changed;

	if (IsValidEntity(weapon))
		i_LastWeaponDamagedBy[victim] = EntIndexToEntRef(weapon);
	else
		i_LastWeaponDamagedBy[victim] = -1;

	return ReturnValue;
}

public void CFDMG_GetIconFromLastDamage(int victim, const char output[255])
{
	CF_GetWeaponKillIcon(EntRefToEntIndex(i_LastWeaponDamagedBy[victim]), output, 255);
}

public Action CFDMG_CallDamageForward(GlobalForward forwardToCall, victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon,
	Float:damageForce[3], Float:damagePosition[3], &damagecustom)
{
	Call_StartForward(forwardToCall);
	
	Call_PushCell(victim);
	Call_PushCellRef(attacker);
	Call_PushCellRef(inflictor);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	Call_PushCellRef(weapon);
	Call_PushArray(damageForce, sizeof(damageForce));
	Call_PushArray(damagePosition, sizeof(damagePosition));
	Call_PushCellRef(damagecustom);
	
	Action ReturnValue;
	Call_Finish(ReturnValue);

	return ReturnValue;
}