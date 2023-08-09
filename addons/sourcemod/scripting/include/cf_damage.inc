GlobalForward g_PreDamageForward;
GlobalForward g_BonusDamageForward;
GlobalForward g_ResistanceDamageForward;
GlobalForward g_PostDamageForward;

public void CFDMG_MakeForwards()
{
	g_PreDamageForward = new GlobalForward("CF_OnTakeDamageAlive_Pre", ET_Event, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_FloatByRef,
											Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_CellByRef);
	g_BonusDamageForward = new GlobalForward("CF_OnTakeDamageAlive_Bonus", ET_Event, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_FloatByRef,
											Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_CellByRef);
	g_ResistanceDamageForward = new GlobalForward("CF_OnTakeDamageAlive_Resistance", ET_Event, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_FloatByRef,
											Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_CellByRef);
	g_PostDamageForward = new GlobalForward("CF_OnTakeDamageAlive_Post", ET_Event, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_FloatByRef,
											Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_CellByRef);
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
	
	//Finally, we call PostDamage:
	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop)
	{
		newValue = CFDMG_CallDamageForward(g_PostDamageForward, victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		if (newValue > ReturnValue)
		{
			ReturnValue = newValue;
		}
	}

	return ReturnValue;
}

public Action CFDMG_CallDamageForward(GlobalForward forwardToCall, &victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon,
	Float:damageForce[3], Float:damagePosition[3], &damagecustom)
{
	Call_StartForward(forwardToCall);
	
	Call_PushCellRef(victim);
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