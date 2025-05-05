GlobalForward g_PreDamageForward;
GlobalForward g_BonusDamageForward;
GlobalForward g_ResistanceDamageForward;
GlobalForward g_PostDamageForward;
GlobalForward g_AllowStabForward;
GlobalForward g_OnStab;

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
}

#if defined _pnpc_included_

public Action PNPC_OnPNPCTakeDamage(PNPC npc, float &damage, int weapon, int inflictor, int attacker, int &damagetype, int &damagecustom, float damageForce[3], float damagePosition[3])
{
	return CFDMG_OnNonPlayerDamaged(npc.Index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, npc.b_IsABuilding);
}

public void PNPC_OnMeleeHit(int attacker, int weapon, int target, float &damage, bool &crit, bool &canStab, bool &forceStab, bool &result)
{
	canStab = false;
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

public void PNPC_OnBackstab(int attacker, int victim, float &damage)
{
	Call_StartForward(g_OnStab);

	Call_PushCell(attacker);
	Call_PushCell(victim);
	Call_PushFloatRef(damage);

	Call_Finish();
}

#endif

public void CFDMG_OnEntityCreated(int entity, const char[] classname)
{
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
	Action ReturnValue = Plugin_Continue;
	Action newValue;
	
	int damagecustom = 0;	//This is not used for anything, I only have it because I can't compile this without passing a variable and I really don't feel like restructuring this right now.
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
		
		if (CF_GetRoundState() == 1 && attacker != victim && damage > 0.0)
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

public void CFDMG_OnTakeDamageAlive_Post(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	Call_StartForward(g_PostDamageForward);

	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(inflictor);
	Call_PushFloat(damage);
	Call_PushCell(weapon);

	Call_Finish();
	
	if (!IsInvuln(victim) && CF_GetRoundState() == 1 && attacker != victim && damage > 0.0)
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
}

int i_LastWeaponDamagedBy[MAXPLAYERS + 1] = { -1, ... };

public Action CFDMG_OnTakeDamageAlive(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon,
	Float:damageForce[3], Float:damagePosition[3], damagecustom)
{	
	Action ReturnValue = Plugin_Continue;
	Action newValue;
	
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