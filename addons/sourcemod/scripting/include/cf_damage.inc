/**
 * Called when a character takes damage, before any modifications have been made by Chaos Fortress.
 *
 * For the sake of organization and to avoid plugin execution conflicts: 
 *
 * - Put damage bonuses in CF_OnTakeDamageAlive_Bonus.
 * - Put damage penalties, such as damage resistance, in CF_OnTakeDamageAlive_Resistance.
 * - Put anything which depends on the damage dealt (for example: gaining 1 imaginary token for every 40 points of damage dealt) in 
 * 		CF_OnTakeDamageAlive_Post.
 *
 * @param victim					The player who took damage.
 * @param attacker					The player who dealt the damage.
 * @param inflictor					The entity which inflicted the damage (EX: Engineer's sentry gun in vanilla TF2)
 * @param damage					The damage dealt.
 * @param damagetype				The type of damage dealt.
 * @param weapon					The weapon which dealt the damage.
 * @param damageForce				The force of the damage, used for ragdolls.
 * @param damagePosition			The position from which damageForce is applied to ragdolls.
 * @param damagecustom				Custom damage flags such as backstabs.
 */
forward void CF_OnTakeDamageAlive_Pre(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon,
	float damageForce[3], float damagePosition[3], int damagecustom)
	
/**
 * Called when a character takes damage, after CF_OnTakeDamageAlive_Pre has been called.
 * This is where you should put your damage bonuses.
 *
 * @param victim					The player who took damage.
 * @param attacker					The player who dealt the damage.
 * @param inflictor					The entity which inflicted the damage (EX: Engineer's sentry gun in vanilla TF2)
 * @param damage					The damage dealt.
 * @param damagetype				The type of damage dealt.
 * @param weapon					The weapon which dealt the damage.
 * @param damageForce				The force of the damage, used for ragdolls.
 * @param damagePosition			The position from which damageForce is applied to ragdolls.
 * @param damagecustom				Custom damage flags such as backstabs.
 */
forward void CF_OnTakeDamageAlive_Bonus(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon,
	float damageForce[3], float damagePosition[3], int damagecustom)

/**
 * Called when a character takes damage, after CF_OnTakeDamageAlive_Pre and CF_OnTakeDamageAlive_Bonus have been called.
 * This is where you should put your damage penalties/resistances.
 *
 * @param victim					The player who took damage.
 * @param attacker					The player who dealt the damage.
 * @param inflictor					The entity which inflicted the damage (EX: Engineer's sentry gun in vanilla TF2)
 * @param damage					The damage dealt.
 * @param damagetype				The type of damage dealt.
 * @param weapon					The weapon which dealt the damage.
 * @param damageForce				The force of the damage, used for ragdolls.
 * @param damagePosition			The position from which damageForce is applied to ragdolls.
 * @param damagecustom				Custom damage flags such as backstabs.
 */
forward void CF_OnTakeDamageAlive_Resistance(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon,
	float damageForce[3], float damagePosition[3], int damagecustom)
	
/**
 * Called when a character takes damage, after all of Chaos Fortress' other OnTakeDamageAlive forwards have been called.
 * This is where you should put anything that depends on damage dealt, such as gaining 1 imaginary token for every 40 points of damage dealt.
 *
 * @param victim					The player who took damage.
 * @param attacker					The player who dealt the damage.
 * @param inflictor					The entity which inflicted the damage (EX: Engineer's sentry gun in vanilla TF2)
 * @param damage					The damage dealt.
 * @param damagetype				The type of damage dealt.
 * @param weapon					The weapon which dealt the damage.
 * @param damageForce				The force of the damage, used for ragdolls.
 * @param damagePosition			The position from which damageForce is applied to ragdolls.
 * @param damagecustom				Custom damage flags such as backstabs.
 */
forward void CF_OnTakeDamageAlive_Post(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon,
	float damageForce[3], float damagePosition[3], int damagecustom)

GlobalForward g_PreDamageForward;
GlobalForward g_BonusDamageForward;
GlobalForward g_ResistanceDamageForward;
GlobalForward g_PostDamageForward;

public void CFDMG_MakeForwards()
{
	g_PreDamageForward = new GlobalForward("CF_OnTakeDamageAlive_Pre", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Float,
											Param_Cell, Param_Cell, Param_Array, Param_Array, Param_Cell);
	g_BonusDamageForward = new GlobalForward("CF_OnTakeDamageAlive_Bonus", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Float,
											Param_Cell, Param_Cell, Param_Array, Param_Array, Param_Cell);
	g_ResistanceDamageForward = new GlobalForward("CF_OnTakeDamageAlive_Resistance", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Float,
											Param_Cell, Param_Cell, Param_Array, Param_Array, Param_Cell);
	g_PostDamageForward = new GlobalForward("CF_OnTakeDamageAlive_Post", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Float,
											Param_Cell, Param_Cell, Param_Array, Param_Array, Param_Cell);
}

public Action CFDMG_OnTakeDamageAlive(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon,
	Float:damageForce[3], Float:damagePosition[3], damagecustom)
{	
	//First, we call PreDamage:
	CFDMG_CallDamageForward(g_PreDamageForward, victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	
	//Next, we call BonusDamage:
	CFDMG_CallDamageForward(g_BonusDamageForward, victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	
	//After that, we call ResistanceDamage:
	CFDMG_CallDamageForward(g_ResistanceDamageForward, victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	
	//Finally, we call PostDamage:
	CFDMG_CallDamageForward(g_PostDamageForward, victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	
	//Always return Plugin_Changed to save on complexity:
	return Plugin_Changed;
}

public void CFDMG_CallDamageForward(GlobalForward forwardToCall, &victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon,
	Float:damageForce[3], Float:damagePosition[3], &damagecustom)
{
	Call_StartForward(forwardToCall);
	
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(inflictor);
	Call_PushFloat(damage);
	Call_PushCell(damagetype);
	Call_PushCell(weapon);
	Call_PushArray(damageForce, sizeof(damageForce));
	Call_PushArray(damagePosition, sizeof(damagePosition));
	Call_PushCell(damagecustom);
	
	Call_Finish();
	
	return;
}