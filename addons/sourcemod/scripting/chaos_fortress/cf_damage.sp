GlobalForward g_PreDamageForward;
GlobalForward g_BonusDamageForward;
GlobalForward g_ResistanceDamageForward;
GlobalForward g_PostDamageForward;

public void CFDMG_MakeForwards()
{
	g_PreDamageForward = new GlobalForward("CF_OnTakeDamageAlive_Pre", ET_Event, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef,
											Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_CellByRef);
	g_BonusDamageForward = new GlobalForward("CF_OnTakeDamageAlive_Bonus", ET_Event, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef,
											Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_CellByRef);
	g_ResistanceDamageForward = new GlobalForward("CF_OnTakeDamageAlive_Resistance", ET_Event, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef,
											Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_CellByRef);
	g_PostDamageForward = new GlobalForward("CF_OnTakeDamageAlive_Post", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell);
}

public void CFDMG_OnTakeDamageAlive_Post(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	Call_StartForward(g_PostDamageForward);

	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(inflictor);
	Call_PushCell(damage);
	Call_PushCell(weapon);

	Call_Finish();
	
	if (CF_GetRoundState() == 1 && attacker != victim)
	{
		if (damage > float(GetClientHealth(victim)))
			damage = float(GetClientHealth(victim));
			
		CF_GiveSpecialResource(attacker, damage, CF_ResourceType_DamageDealt);
		CF_GiveUltCharge(attacker, damage, CF_ResourceType_DamageDealt);
		CF_GiveSpecialResource(victim, damage, CF_ResourceType_DamageTaken);
		CF_GiveUltCharge(victim, damage, CF_ResourceType_DamageTaken);
	}
}

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

	return ReturnValue;
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