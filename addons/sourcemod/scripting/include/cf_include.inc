#if defined _cfinc_included_
  #endinput
#endif
#define _cfinc_included_

#include <cbasenpc>
#include <cfgmap>
#include <sdkhooks>
#include <cf_stocks>

stock void CF_TakeDamage(int entity = 0, int inflictor = 0, int attacker = 0, float damage = 0.0, int damageType=DMG_GENERIC, int weapon=-1,const float damageForce[3]=NULL_VECTOR, const float damagePosition[3]=NULL_VECTOR, bool bypassHooks = false)
{
	SDKHooks_TakeDamage(entity, inflictor, attacker, damage, damageType, IsValidEntity(weapon) ? weapon : -1, damageForce, damagePosition, bypassHooks);
}

#define SDKHooks_TakeDamage CF_TakeDamage

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

enum CF_ResourceType
{
    CF_ResourceType_Generic = 0,
    CF_ResourceType_Regen,
    CF_ResourceType_DamageDealt,
    CF_ResourceType_DamageTaken,
    CF_ResourceType_Healing,
    CF_ResourceType_Kill,
    CF_ResourceType_Percentage
};

enum CF_AbilityType
{
    CF_AbilityType_Ult = 0,
    CF_AbilityType_M2,
    CF_AbilityType_M3,
    CF_AbilityType_Reload,
    CF_AbilityType_SpecialResourceGained,
    CF_AbilityType_SpecialResourceLost,
    CF_AbilityType_SpecialResourceChanged,
    CF_AbilityType_UltChargeGained,
    CF_AbilityType_UltChargeLost,
    CF_AbilityType_UltChargeChanged,
    CF_AbilityType_Custom,
    CF_AbilityType_None
};

enum CF_ClassToken
{
    CF_ClassToken_Scout = 5003,
    CF_ClassToken_Sniper,
    CF_ClassToken_Soldier,
    CF_ClassToken_Demoman,
    CF_ClassToken_Heavy,
    CF_ClassToken_Medic,
    CF_ClassToken_Pyro,
    CF_ClassToken_Spy,
    CF_ClassToken_Engineer
};

enum CF_Emotion
{
	CF_Emotion_Neutral = 0,
	CF_Emotion_Angry,
	CF_Emotion_Happy
};

enum CF_StuckMethod
{
	CF_StuckMethod_None = 0,
	CF_StuckMethod_BlockResize,
	CF_StuckMethod_DelayResize,
	CF_StuckMethod_Kill,
	CF_StuckMethod_Respawn
};

enum CF_CharacterRemovalReason
{
	CF_CRR_GENERIC = 0,
	CF_CRR_DEATH,
	CF_CRR_DISCONNECT,
	CF_CRR_SWITCHED_CHARACTER,
	CF_CRR_ROUNDSTATE_CHANGED,
	CF_CRR_RESPAWNED
};

enum CF_SpellIndex
{
	CF_Spell_Fireball = 0,
	CF_Spell_Bats,
	CF_Spell_Ubercharge,
	CF_Spell_PumpkinMirv,
	CF_Spell_SuperJump,
	CF_Spell_Invisibility,
	CF_Spell_Teleport,
	CF_Spell_LightningBall,
	CF_Spell_Minify,
	CF_Spell_Monoculus,
	CF_Spell_MeteorShower,
	CF_Spell_Skeletons
};

//TODO: This will need to be expanded upon to include things like medigun shields
stock bool CF_DefaultTrace(entity, contentsMask)
{
	if (entity <= MaxClients)
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

//Generic line-of-sight trace.
stock bool CF_LOSTrace(int entity, int contentsmask, int target)
{
	if (IsValidClient(entity) || entity == target || IsABuilding(entity))
		return false;

	return Brush_Is_Solid(entity);
}

  ////////////////////////////////////////
 ////////////// FORWARDS: ///////////////
////////////////////////////////////////

/**
 * Called when a character runs any command.
 *
 * @param client			The client who ran the command.
 * @param buttons			The button(s) pressed.
 * @param impulse			Copyback buffer containing the current impulse command.
 * @param weapon			Entity index of the new weapon held by the player, 0 if weapon was not swapped.
 *
 * @return					Return Plugin_Continue to proceed as normal, Plugin_Changed if you altered any of these variables, or Plugin_Handled to prevent the command from being run.
 */
forward Action CF_OnPlayerRunCmd(int client, int &buttons, int &impulse, int &weapon);

/**
 * Called when a character presses M2.
 *
 * @param client			The client who ran the command.
 * @param buttons			The button(s) pressed.
 * @param impulse			Copyback buffer containing the current impulse command.
 * @param weapon			Entity index of the new weapon held by the player, 0 if weapon was not swapped.
 *
 * @return					Return Plugin_Continue to proceed as normal, Plugin_Changed if you altered any of these variables, or Plugin_Handled to prevent the command from being run.
 */
forward Action CF_OnPlayerM2(int client, int &buttons, int &impulse, int &weapon);

/**
 * Called when a character presses M3.
 *
 * @param client			The client who ran the command.
 * @param buttons			The button(s) pressed.
 * @param impulse			Copyback buffer containing the current impulse command.
 * @param weapon			Entity index of the new weapon held by the player, 0 if weapon was not swapped.
 *
 * @return					Return Plugin_Continue to proceed as normal, Plugin_Changed if you altered any of these variables, or Plugin_Handled to prevent the command from being run.
 */
forward Action CF_OnPlayerM3(int client, int &buttons, int &impulse, int &weapon);

/**
 * Called when a character presses their reload button.
 *
 * @param client			The client who ran the command.
 * @param buttons			The button(s) pressed.
 * @param impulse			Copyback buffer containing the current impulse command.
 * @param weapon			Entity index of the new weapon held by the player, 0 if weapon was not swapped.
 *
 * @return					Return Plugin_Continue to proceed as normal, Plugin_Changed if you altered any of these variables, or Plugin_Handled to prevent the command from being run.
 */
forward Action CF_OnPlayerReload(int client, int &buttons, int &impulse, int &weapon);

/**
 * Called when a character presses their scoreboard button.
 *
 * @param client			The client who ran the command.
 * @param buttons			The button(s) pressed.
 * @param impulse			Copyback buffer containing the current impulse command.
 * @param weapon			Entity index of the new weapon held by the player, 0 if weapon was not swapped.
 *
 * @return					Return Plugin_Continue to proceed as normal, Plugin_Changed if you altered any of these variables, or Plugin_Handled to prevent the command from being run.
 */
forward Action CF_OnPlayerTab(int client, int &buttons, int &impulse, int &weapon);

/**
 * Called when a character presses their jump button. NOTICE: This runs even if they are already in the air, it is purely to detect the button press.
 *
 * @param client			The client who ran the command.
 * @param buttons			The button(s) pressed.
 * @param impulse			Copyback buffer containing the current impulse command.
 * @param weapon			Entity index of the new weapon held by the player, 0 if weapon was not swapped.
 *
 * @return					Return Plugin_Continue to proceed as normal, Plugin_Changed if you altered any of these variables, or Plugin_Handled to prevent the command from being run.
 */
forward Action CF_OnPlayerJump(int client, int &buttons, int &impulse, int &weapon);

/**
 * Called when a character presses their crouch button. NOTICE: This runs even if they are already in the air, it is purely to detect the button press.
 *
 * @param client			The client who ran the command.
 * @param buttons			The button(s) pressed.
 * @param impulse			Copyback buffer containing the current impulse command.
 * @param weapon			Entity index of the new weapon held by the player, 0 if weapon was not swapped.
 *
 * @return					Return Plugin_Continue to proceed as normal, Plugin_Changed if you altered any of these variables, or Plugin_Handled to prevent the command from being run.
 */
forward Action CF_OnPlayerCrouch(int client, int &buttons, int &impulse, int &weapon);

/**
 * Called when a character calls for medic, AKA when they press the E key.
 *
 * @param client			The client who ran the command.
 */
forward void CF_OnPlayerCallForMedic(int client);

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
 *
 * @return	Return Plugin_Continue to proceed as normal, Plugin_Changed if you changed any of the values, Plugin_Stop or Plugin_Handled to prevent the damage altogether.
 */
forward Action CF_OnTakeDamageAlive_Pre(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom);
	
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
 *
 * @return	Return Plugin_Continue to proceed as normal, Plugin_Changed if you changed any of the values, Plugin_Stop or Plugin_Handled to prevent the damage altogether.
 */
forward Action CF_OnTakeDamageAlive_Bonus(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom);

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
 *
 * @return	Return Plugin_Continue to proceed as normal, Plugin_Changed if you changed any of the values, Plugin_Stop or Plugin_Handled to prevent the damage altogether.
 */
forward Action CF_OnTakeDamageAlive_Resistance(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom);
	
/**
 * Called when a character takes damage, after all of Chaos Fortress' other OnTakeDamageAlive forwards have been called.
 * This is where you should put anything that depends on damage dealt, such as gaining 1 imaginary token for every 40 points of damage dealt.
 *
 * @param victim					The player who took damage.
 * @param attacker					The player who dealt the damage.
 * @param inflictor					The entity which inflicted the damage (EX: Engineer's sentry gun in vanilla TF2)
 * @param damage					The damage dealt.
 * @param weapon					The weapon used.
 *
 * @return	Return Plugin_Continue to proceed as normal, Plugin_Changed if you changed any of the values, Plugin_Stop or Plugin_Handled to prevent the damage altogether.
 */
forward Action CF_OnTakeDamageAlive_Post(int victim, int attacker, int inflictor, float damage, int weapon);
	
/**
 * Called when a simulated medigun shield created by CF_CreateShieldWall is damaged.
 *
 * @param victim					The shield which took damage.
 * @param attacker					The player who dealt the damage.
 * @param inflictor					The entity which inflicted the damage (EX: Engineer's sentry gun in vanilla TF2)
 * @param damage					The damage dealt.
 * @param damagetype				The type of damage dealt.
 * @param owner						The owner of the shield.
 *
 * @return	Return Plugin_Continue to proceed as normal, Plugin_Changed if you changed any of the values, Plugin_Stop or Plugin_Handled to prevent the damage altogether.
 */	
forward Action CF_OnFakeMediShieldDamaged(int shield, int attacker, int inflictor, float &damage, int &damagetype, int owner);

/**
 * Called when a simulated medigun shield created by CF_CreateShieldWall collides with another entity.
 *
 * @param victim					The shield which collided.
 * @param attacker					The entity the shield collided with.
 * @param owner						The shield's owner.
 */	
forward void CF_OnFakeMediShieldCollision(int shield, int collider, int owner);
	
/**
 * Called when a player's Chaos Fortress killstreak is changed.
 *
 * @param client			The client whose killstreak was changed.
 * @param kills				The new killstreak.
 */
forward void CF_OnKillstreakChanged(int client, int kills);

/**
 * DEPRECATED! Use CF_OnPlayerKilled_Pre instead, it does all of this but with added features.
 * Called when a character is killed.
 *
 * @param victim			The player who was killed.
 * @param inflictor			The entity which inflicted the killing blow.
 * @param attacker			The player who is credited for the kill.
 * @param deadRinger		0 if the kill was real, 1 if it was a dead ringer.
 */
forward void CF_OnPlayerKilled(int victim, int inflictor, int attacker, int deadRinger);

/**
 * Called when a player is killed, using EventHookMode_Pre. Change any of the following variables (excluding deadRinger) to modify the event.
 *
 * @param victim			The client who was killed.
 * @param inflictor			The entity index of whatever inflicted the killing blow.
 * @param attacker			The player who dealt the damage.
 * @param weapon			The weapon used to kill the target. Changing this will modify the kill icon.
 * @param console			The name of the weapon, as stated in the console (EX: if this is Cool Gun, the console will read "Played 1 killed Player 2 with Cool Gun").
 * @param custom			Certain kill icons require you to set this, as they cannot be achieved by simply setting the weapon string.
 * @param deadRinger		Was this a fake death caused by the Dead Ringer?
 * @param critType			The type of crit which killed the victim. Set to 0 for no crit, 1 for it to appear as a mini-crit, and 2 for it to appear as a normal crit.
 * @param damagebits		Can be used to modify the type of damage which inflicted the kill.
 *
 * @return	Plugin_Changed to apply your changes if you changed any variables, Plugin_Stop or Plugin_Handled to prevent the event from being fired, or Plugin_Continue to proceed as normal.
 */
forward Action CF_OnPlayerKilled_Pre(int &victim, int &inflictor, int &attacker, char weapon[255], char console[255], int &custom, int deadRinger, int &critType, int &damagebits);

/**
 * Called when the Chaos Fortress round state is changed.
 *
 * @param state				The new round state. 0: Pre-game/setup time/waiting for players, 1: round in progress, 2: round has ended.
 */
forward void CF_OnRoundStateChanged(int state);

/**
 * Called when a player activates an ability.
 *
 * @param client			The client whose ability was activated.
 * @param pluginName		The name of the ability's plugin, as specified in the config as "plugin_name".
 * @param pluginName		The name of the ability's ability, as specified in the config as "ability_name".
 */
forward void CF_OnAbility(int client, char pluginName[255], char abilityName[255]);

/**
 * Called when a player uses their Ultimate Ability.
 *
 * @param client			The client whose Ultimate Ability was activated.
 *
 * @return	Plugin_Handled or Plugin_Stop to prevent the Ultimate Ability from being used, otherwise return Plugin_Continue to allow it.
 */
forward Action CF_OnUltUsed(int client);

/**
 * Called when a player uses their M2 ability. For held abilities, use CF_OnHeldStart instead.
 *
 * @param client			The client whose M2 ability was activated.
 *
 * @return	Plugin_Handled or Plugin_Stop to prevent the M2 ability from being used, otherwise return Plugin_Continue to allow it.
 */
forward Action CF_OnM2Used(int client);

/**
 * Called when a player uses their M3 ability. For held abilities, use CF_OnHeldStart instead.
 *
 * @param client			The client whose M3 ability was activated.
 *
 * @return	Plugin_Handled or Plugin_Stop to prevent the M3 ability from being used, otherwise return Plugin_Continue to allow it.
 */
forward Action CF_OnM3Used(int client);

/**
 * Called when a player uses their reload ability. For held abilities, use CF_OnHeldStart instead.
 *
 * @param client			The client whose reload ability was activated.
 *
 * @return	Plugin_Handled or Plugin_Stop to prevent the reload ability from being used, otherwise return Plugin_Continue to allow it.
 */
forward Action CF_OnReloadUsed(int client);
	
/**
 * Called when a player attempts to use a held ability.
 *
 * @param client			The client whose held ability was started.
 * @param type				The type of held ability (M2, M3, or Reload).
 *
 * @return	Plugin_Handled or Plugin_Stop to prevent the held ability from being used, otherwise return Plugin_Continue to allow it.
 */
forward Action CF_OnHeldStart(int client, CF_AbilityType type);

/**
 * Called when a held ability ends.
 *
 * @param client			The client whose held ability was ended.
 * @param type				The type of held ability (M2, M3, or Reload).
 * @param resupply			If true, the ability was ended due to the resupply event instead of the button being released.
 *
 */
forward void CF_OnHeldEnd(int client, CF_AbilityType type, bool resupply);

/**
 * Called when a held ability ends, referencing a specific ability.
 *
 * @param client			The client whose held ability was ended.
 * @param resupply			If true, the ability was ended due to the resupply event instead of the button being released.
 * @param pluginName		The plugin name of the held ability which was ended, specified as "plugin_name" in the character's config.
 * @param abilityName		The ability name of the held ability which was ended, specified as "ability_name" in the character's config.
 *
 */
forward void CF_OnHeldEnd_Ability(int client, bool resupply, char pluginName[255], char abilityName[255]);

/**
 * Called when a player is transformed into a character. This occurs when the player spawns and whenever they resupply.
 *
 * @param client			The client who was transformed into a character.
 *
 */
forward void CF_OnCharacterCreated(int client);

/**
 * Called when a player's character is removed for any reason.
 *
 * @param client			The client whose character was removed.
 * @param reason			Represents the reason the player's character was removed.
 *
 */
forward void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason);

/**
 * Called when Chaos Fortress' internal sound hook gets called. Useful so you don't need to make your own sound hooks for every plugin that needs one.
 *
 * @param strSound		The sound that was played.
 * @param entity		The source of the sound.
 * @param channel		The sound's channel.
 * @param volume		The sound's volume.
 * @param level			The sound's level.
 * @param pitch			The sound's pitch.
 * @param flags			The sound's flags.
 *
 * @return		Plugin_Continue to play the sound normally, Plugin_Changed if you changed any variables, and Plugin_Handled or Plugin_Stop to prevent the sound from playing.
 */
forward Action CF_SoundHook(char strSound[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags);
	
/**
 * Called when a character is given their special resource.
 * WARNING: DO NOT CALL CF_GiveSpecialResource OR CF_SetSpecialResource IN THIS CALLBACK UNLESS YOU KNOW WHAT YOU ARE DOING!
 *
 * @param client		The client who received the special resource.
 * @param amt			The amount given.
 *
 * @return		Plugin_Continue to give the resource normally, modify amt and return Plugin_Changed to change the amount given, and Plugin_Handled or Plugin_Stop to prevent the resource from being given.
 */
forward Action CF_OnSpecialResourceGiven(int client, float &amt);

/**
 * Called when a character's special resource is set.
 * WARNING: DO NOT CALL CF_GiveSpecialResource OR CF_SetSpecialResource IN THIS CALLBACK UNLESS YOU KNOW WHAT YOU ARE DOING!
 *
 * @param client		The client who received the special resource.
 * @param current		The client's current special resource, before changes are applied.
 * @param amt			The client's new special resource.
 *
 * @return		Plugin_Continue to set special resource normally, modify amt and return Plugin_Changed to change the client's special resource, and Plugin_Handled or Plugin_Stop to prevent the ult charge from being set.
 */
forward Action CF_OnSpecialResourceApplied(int client, float current, float &amt);

/**
 * Called when a character is given any amount of ult charge.
 * WARNING: DO NOT CALL CF_GiveUltCharge OR CF_SetUltCharge IN THIS CALLBACK UNLESS YOU KNOW WHAT YOU ARE DOING!
 *
 * @param client		The client who received the ult charge.
 * @param amt			The amount given.
 *
 * @return		Plugin_Continue to give the ult charge normally, modify amt and return Plugin_Changed to change the amount given, and Plugin_Handled or Plugin_Stop to prevent the ult charge from being given.
 */
forward Action CF_OnUltChargeGiven(int client, float &amt);

/**
 * Called when a character's ult charge is set.
 * WARNING: DO NOT CALL CF_GiveUltCharge OR CF_SetUltCharge IN THIS CALLBACK UNLESS YOU KNOW WHAT YOU ARE DOING!
 *
 * @param client		The client who received the ult charge.
 * @param current		The client's current ult charge, before changes are applied.
 * @param amt			The client's new ult charge.
 *
 * @return		Plugin_Continue to set ult charge normally, modify amt and return Plugin_Changed to change the client's ult charge, and Plugin_Handled or Plugin_Stop to prevent the ult charge from being set.
 */
forward Action CF_OnUltChargeApplied(int client, float current, float &amt);

/**
 * Called when a TF2 projectile has its team changed.
 *
 * @param entity		The projectile.
 * @param newTeam		The projectile's new team.
 *
 */
forward void CF_OnGenericProjectileTeamChanged(int entity, TFTeam newTeam);

/**
 * Called when CollisionHook's CH_PassFilter gets called, after all of Chaos Fortress' own tests. Using this instead of CH_PassFilter guarantees your plugin's collision logic will not conflict with that of Chaos Fortress.
 *
 * @param ent1			The first entity.
 * @param ent2			The second entity.
 * @param result		Set to false and return Plugin_Changed to prevent collision, ignore otherwise.
 *
 * @return Set result to false and return Plugin_Changed to prevent collision, otherwise return Plugin_Continue.
 */
forward Action CF_OnPassFilter(int ent1, int ent2, bool &result);

/**
 * Called when CollisionHook's CH_ShouldCollide gets called, after all of Chaos Fortress' own tests. Using this instead of CH_ShouldCollide guarantees your plugin's collision logic will not conflict with that of Chaos Fortress.
 *
 * @param ent1			The first entity.
 * @param ent2			The second entity.
 * @param result		Set to false and return Plugin_Changed to prevent collision, ignore otherwise.
 *
 * @return Set result to false and return Plugin_Changed to prevent collision, otherwise return Plugin_Continue.
 */
forward Action CF_OnShouldCollide(int ent1, int ent2, bool &result);

/**
 * Called when checking to see if an ability can be used. Only compatible with the default ability types: Ultimate, M2, M3, and Reload.
 *
 * @param client		The client who is being checked.
 * @param plugin		The plugin_name of the ability being checked.
 * @param ability		The ability_name of the ability being checked.
 * @param type			The ability slot being checked, such as CF_AbilityType_Ultimate.
 * @param result 		Set to false and return Plugin_Changed to block the ability from being used. Otherwise, set to true and return Plugin_Continue.
 *
 * @return Set result to false and return Plugin_Changed to block the ability, otherwise return Plugin_Continue.
 */
forward Action CF_OnAbilityCheckCanUse(int client, char plugin[255], char ability[255], CF_AbilityType type, bool &result);

/**
 * Called one frame after a client attacks with a weapon. Used to modify the time until the weapon can attack again.
 *
 * @param client		The client who attacked.
 * @param weapon		The weapon which was used.
 * @param slot			The slot the weapon belongs to (0: primary, 1: secondary, 2: melee).
 * @param classname		The classname of the weapon (IE "tf_weapon_knife").
 * @param rate			Multiplier to be used to adjust attack rate. 0.5 = attack 50% faster, 2.0 = attack 100% slower, 1.0 = no change.
 *						Note that no matter what you do, the attack interval for non-knife melee weapons will never fall below 0.275 seconds, because otherwise they would break.
 *
 * @return Change "rate" and return Plugin_Changed to modify the attack rate, otherwise return Plugin_Continue.
 */
forward Action CF_OnCalcAttackInterval(int client, int weapon, int slot, char classname[255], float &rate);

/**
 * Called when a prop_physics or prop_physics_override collides with a NON-EXPLOSIVE (huntsman arrow, rescue ranger bolt, etc) tf_projectile.
 *
 * @param prop			The prop_physics.
 * @param entity		The projectile which collided with prop.
 * @param propTeam		The TFTeam of the prop_physics.
 * @param entityTeam 	The TFTeam of the projectile.
 * @param propOwner		The owner of the prop_physics.
 * @param entityOwner	The owner of the projectile.
 * @param classname		The projectile's classname.
 * @param launcher		The weapon which originally launched the projectile.
 * @param damage		The damage the projectile should inflict. Only applies if propTeam and entityTeam are different. Can be changed to alter the damage.
 * @param pos			The position of the projectile.
 *
 * @return Change "damage" and return Plugin_Changed to modify the damage if the teams are different, otherwise return Plugin_Continue.
 */
forward Action CF_OnPhysPropHitByProjectile(int prop, int entity, TFTeam propTeam, TFTeam entityTeam, int propOwner, int entityOwner, char classname[255], int launcher, float damage, float pos[3]);

/**
 * Called when a spell is cast using the "CF_SimulateSpellbookCast" native.
 *
 * @param client		The client who cast the spell.
 * @param entity		The projectile created by the spell (-1 if blocked).
 */
forward void CF_OnSimulatedSpellUsed(int client, int entity);

/**
 * Called when a forced viewmodel animation started by "CF_ForceViewmodelAnimation" ends (this does NOT get called if the client dies/disconnects mid-sequence).
 *
 * @param client		The client whose viewmodel was animated.
 * @param sequence		The sequence which was forced.
 */
forward void CF_OnForcedVMAnimEnd(int client, char sequence[255]);

/**
 * Called when a character's HUD is about to be displayed.
 * 
 * @param client		The client whose HUD is about to be displayed.
 * @param HUDText		The text to be displayed. Can be altered. Any instances of [PERCENT] are automatically replaced with %.
 * @param r				R value of the HUD's color. Can be altered.
 * @param g				G value of the HUD's color. Can be altered.
 * @param b				B value of the HUD's color. Can be altered.
 * @param a				A value of the HUD's color. Can be altered.
 */
forward void CF_OnHUDDisplayed(int client, char HUDText[255], int &r, int &g, int &b, int &a);

  ///////////////////////////////////////
 ////////////// NATIVES: ///////////////
///////////////////////////////////////
	
/**
 * Retrieves the killstreak of a given client.
 *
 * @param client		The client whose killstreak to retrieve.
 *
 * @return The player's current killstreak. 0 if dead, -1 if invalid client.
 */
native CF_GetKillstreak(int client);

/**
 * Sets the killstreak of a given client.
 *
 * @param client		The client whose killstreak to set.
 * @param kills			The new killstreak.
 * @param killer		The player who scored the kill. Used for announcing the end of a long killstreak.
 * @param announce		Announces the change in the killstreak in accordance with game_rules.cfg if set to true.
 */
native CF_SetKillstreak(int client, int kills, int killer, bool announce = true)

/**
 * Determines whether or not the chosen client was holding M2 during the previous frame.
 *
 * @param client		The client to check.
 *
 * @return True if the client was holding M2, false otherwise.
 */
native CF_GetM2Status(int client);

/**
 * Determines whether or not the chosen client was holding M3 during the previous frame.
 *
 * @param client		The client to check.
 *
 * @return True if the client was holding M3, false otherwise.
 */
native CF_GetM3Status(int client);

/**
 * Determines whether or not the chosen client was holding reload during the previous frame.
 *
 * @param client		The client to check.
 *
 * @return True if the client was holding reload, false otherwise.
 */
native CF_GetReloadStatus(int client);

/**
 * Determines whether or not the chosen client was holding their jump key during the previous frame.
 *
 * @param client		The client to check.
 *
 * @return True if the client was holding jump, false otherwise.
 */
native CF_GetJumpStatus(int client);

/**
 * Determines whether or not the chosen client was holding their scoreboard button during the previous frame.
 *
 * @param client		The client to check.
 *
 * @return True if the client was holding tab, false otherwise.
 */
native CF_GetTabStatus(int client);

/**
 * Determines whether or not the chosen client was holding crouch during the previous frame.
 *
 * @param client		The client to check.
 *
 * @return True if the client was holding crouch, false otherwise.
 */
native CF_GetCrouchStatus(int client);

/**
 * Retrieves the current round state.
 *
 * @return The current round state. 0: pre-game/waiting for players/setup, 1: round in progress, 2: round has ended.
 */
native CF_GetRoundState();

/**
 * Retrieves the client's current character config.
 *
 * @param client		The client whose config to retrieve.
 * @param buffer		Output buffer.
 * @param size			Output buffer size.
 *
 * @return The config used by the client's current character, stored in the buffer. Returns an empty string is the client is invalid, or not currently a character. 
 */
native CF_GetPlayerConfig(int client, char[] buffer, int size);

/**
 * Sets the client's current character config.
 *
 * @param client		The client whose config to set.
 * @param confName		The new config.
 */
native CF_SetPlayerConfig(int client, char[] confName);

/**
 * Returns the max HP of the given client's character.
 *
 * @param client		The client whose max HP to get.
 * 
 * @return Returns a float value equal to the max health of the client's character, 0.0 if the client is invalid or their character has no specified max HP.
 */
native float CF_GetCharacterMaxHealth(int client);

/**
 * Retrieves the character's archetype, stored in the output buffer.
 * 
 * @param client	Client whose archetype to get.
 * @param output	Output buffer.
 * @param size		Output buffer length.
 * 
 * @return	The character's archetype, stored in the output buffer.
 */
native CF_GetCharacterArchetype(int client, char[] output, int size);

/**
 * Sets the character's archetype.
 * 
 * @param client	Client whose archetype to set.
 * @param archetype	New archetype.
 */
native CF_SetCharacterArchetype(int client, char[] archetype);

/**
 * Sets the max HP of the given client's character.
 *
 * @param client		The client whose max HP to set.
 * @param NewHP			The max HP to set.
 */
native CF_SetCharacterMaxHealth(int client, float NewHP);

/**
 * Returns the weight of the given client's character.
 *
 * @param client		The client whose weight to get.
 * 
 * @return Returns a float value equal to the weight of the client's character, 0.0 if the client is invalid or their character has no specified weight.
 *
 */
native float CF_GetCharacterWeight(int client);

/**
 * Sets the weight of the given client's character. 
 * This is a custom stat which is used to modify all knockback inflicted to the character, provided said knockback is applied by using CF_ApplyKnockback.
 *
 * @param client		The client whose weight to set.
 * @param NewWeight		The new weight.
 *
 */
native float CF_SetCharacterWeight(int client, float NewWeight);

/**
 * Inflicts knockback upon a client.
 *
 * @param client					The client to knock back.
 * @param force						The force of the knockback.
 * @param angles					The angles of the knockback.
 * @param IgnoreWeight				If set to true, the victim's "weight" stat does not affect the force of the knockback.
 * @param IgnoreQuickFix			If set to true, TFCond_MegaHeal will not prevent the knockback.
 * @param IgnoreInvuln				If set to true, invulnerability will not prevent the knockback.
 * @param OverrideCurrentVelocity	If set to true, the knockback completely interrupts the user's current velocity. Otherwise, the knockback is simply added to their current velocity.
 *
 */
native CF_ApplyKnockback(int client, float force, float angles[3], bool IgnoreWeight = false, bool IgnoreQuickFix = false, bool IgnoreInvuln = false, bool OverrideCurrentVelocity = false);

/**
 * Retrieves the max speed, in hammer units per second, of the given client's current character.
 *
 * @param client				The client whose max speed to retrieve.
 *
 * @return	The character's max speed, or 0.0 of the client is not a character.
 */
native float CF_GetCharacterSpeed(int client);

/**
 * Sets the client's max speed, provided they are a character.
 *
 * @param client				The client whose max speed to set.
 * @param NewSpeed				The new max speed to set.
 */
native CF_SetCharacterSpeed(int client, float NewSpeed);

/**
 * Retrieves the model scale of the given client's current character.
 *
 * @param client				The client whose model scale to retrieve.
 *
 * @return	The character's model scale, or 0.0 of the client is not a character.
 */
native float CF_GetCharacterScale(int client);

/**
 * Sets the client's model scale, provided they are a character.
 *
 * @param client				The client whose model scale to set.
 * @param NewScale				The new model scale to set.
 * @param StuckMethod			The method to use for handling situations in which resizing the player to this scale would get them stuck.
 *									- CF_StuckMethod_None: Do nothing and let the player be resized anyways.
 *									- CF_StuckMethod_BlockResize: Prevent the resize from occurring.
 *									- CF_StuckMethod_DelayResize: Delay the resize until the player is in a location where it would not get them stuck.
 *									- CF_StuckMethod_Kill: Forces the player to killbind.
 *									- CF_StuckMethod_Respawn: Respawns the player and sends them back to spawn.
 * @param failure				Optional message to print to the client's chat if they cannot be resized.
 * @param success				Optional message to print to the chient's chat when they are successfully resized.
 */
native CF_SetCharacterScale(int client, float NewScale, CF_StuckMethod StuckMethod, char failure[255] = "", char success[255] = "");

/**
 * Retrieves the name of the given client's current character.
 *
 * @param client				The client whose character's name to retrieve.
 * @param output				Output buffer.
 * @param size					Size of the output buffer.
 *
 * @return	The name of the client's current character, stored in the output buffer, or an empty string if the client is not a character.
 */
native CF_GetCharacterName(int client, char output[255], int size);

/**
 * Changes the client's character name, provided they are a character.
 *
 * @param client				The client whose character model to set.
 * @param NewName				The new name to set.
 */
native CF_SetCharacterName(int client, char NewName[255]);

/**
 * Retrieves the model path of the given client's current character's viewmodel arms.
 *
 * @param client				The client whose character's arms to retrieve.
 * @param output				Output buffer.
 *
 * @return	The model path for the client's viewmodel arms, stored in the output buffer, or an empty string if the client is not a character or does not have custom arms.
 */
native CF_GetCharacterArms(int client, char output[255]);

//Crashes on Linux due to empty string (TODO)
/**
 * Changes the model path of the given client's current character's viewmodel arms. 
 *
 * @param client				The client whose arms to set.
 * @param NewArms				The new model to be used for arms.
 */
//native CF_SetCharacterArms(int client, char NewArms[255]);

/**
 * Retrieves the model path of the given client's current character.
 *
 * @param client				The client whose character's model path to retrieve.
 * @param output				Output buffer.
 * @param size					Size of the output buffer.
 *
 * @return	The model path of the client's current character, stored in the output buffer, or an empty string if the client is not a character.
 */
native CF_GetCharacterModel(int client, char output[255], int size);

/**
 * Changes the client's character model, provided they are a character and the given model exists.
 *
 * @param client				The client whose character model to set.
 * @param NewModel				The new character model.
 */
native CF_SetCharacterModel(int client, char NewModel[255]);

/**
 * Determines whether or not the chosen client is a character.
 *
 * @param client		The client to check.
 *
 * @return True if the client is a character, false if they are invalid or not a character.
 */
native bool CF_IsPlayerCharacter(int client);

/**
 * Gives a weapon to the given client.
 *
 * @param client		The client to give the weapon to.
 * @param name			The weapon's classname.
 * @param index			The weapon's index.
 * @param level			The weapon's level.
 * @param qual			The weapon's quality.
 * @param slot			The weapon's slot. 0 for primary, 1 for secondary, 2 for melee.
 * @param reserve		The weapon's reserve ammo.
 * @param clip			The ammo held in the weapon's clip/magazine/whatever.
 * @param att			The weapon's attributes.
 * @param override		Optional weapon model override (THIS IS UNIMPLEMENTED, USE A CUSTOM ATTRIBUTE INSTEAD)
 * @param visible		Should the weapon be visible?
 * @param unequip		Should whichever weapon(s) currently in this weapon's slot be removed before equipping this weapon?
 * @param ForceClass	Class to force this weapon to use the animations of, if using ViewChange. 1-9 for the mercs, anything above 9 is considered all-class. (UNIMPLEMENTED)
 * @param spawn			If true, ammo is applied one frame later instead of instantly so it doesn't interfere with the resupply event.
 * @param fireAbility	The ability to activate when this weapon fires, optional.
 * @param firePlugin	The plugin of the ability to activate when this weapon fires, optional.
 * @param fireSound		The sound slot to use when this weapon fires, optional.
 * @param autoEquip		If set to false, the weapon is only *created*, not equipped. Useful if you need to run your own logic before equipping the weapon yourself. NOTE: If spawning a PDA, sapper, or disguise kit with this set to false, you must equip it on the same frame you call this on, otherwise it will not equip.
 *
 * @return The entity index of the spawned weapon, -1 if not valid.
 */
native int CF_SpawnWeapon(int client, char[] name, int index, int level, int qual, int slot, int reserve, int clip, const char[] att, char override[255] = "", bool visible = true, bool unequip = true, int ForceClass = 0, bool spawn = false, char fireAbility[255] = "", char firePlugin[255] = "", char fireSound[255] = "", bool autoEquip = true);

/**
 * Gets the ability name and plugin name of a given weapon.
 *
 * @param weapon			The weapon to check.
 * @param abBuffer			Buffer to use for the ability name.
 * @param abLen				Length of the ability buffer.
 * @param plugBuffer		Buffer to use for the plugin name.
 * @param plugLen			Length of the plugin buffer.
 *
 * @return The ability and plugin names of the ability used by the given weapon when it attacks, stored in abBuffer and plugBuffer respectively.
 */
native CF_GetWeaponAbility(int weapon, char abBuffer[255], int abLen, char plugBuffer[255], int plugLen);

/**
 * Gets the sound slot used by a given weapon.
 *
 * @param weapon			The weapon to check.
 * @param buffer			Buffer to use for the sound slot.
 * @param len				Length of the buffer.
 *
 * @return The sound slot used by the given weapon, stored in buffer.
 */
native CF_GetWeaponSound(int weapon, char buffer[255], int len);

/**
 * Gets the visibility of a given weapon.
 *
 * @param weapon			The weapon to check.
 *
 * @return True if the weapon is visible, false if it is not or if it is invalid.
 */
native bool CF_GetWeaponVisibility(int weapon);

/**
 * Gets the class of the player's current character.
 *
 * @param client		The client to check.
 *
 * @return The class of the player's character, TFClass_Unknown if invalid.
 */
native TFClassType CF_GetCharacterClass(int client);

/**
 * Sets the class of the player's current character.
 *
 * @param client		The client to check.
 * @param NewClass		The new class to set.
 */
native CF_SetCharacterClass(int client, TFClassType NewClass);

/**
 * Attaches a particle to a client, using Chaos Fortress' system to automatically handle several important things particles need.
 * In specific, this system automatically blocks the particle from view if the client is invisible, automatically despawns the particle if the client
 * dies or disconnects, and prevents the particle from blocking the client's view in first person.
 *
 * @param client		The client to attach the particle to.
 * @param particle		The particle's name.
 * @param point			The attachment point of the particle.
 * @param preserve		If set to true, this particle is not removed on resupply unless the player becomes a different character.
 * @param lifespan		Optional particle duration, 0.0 or below for infinite.
 * @param xOff			Optional X-axis offset, in hammer units.
 * @param yOff			Optional Y-axis offset, in hammer units.
 * @param zOff			Optional Z-axis offset, in hammer units.
 *
 * @return The entity index of the spawned particle, -1 if invalid.
 */
native int CF_AttachParticle(int client, char particle[255], char point[255], bool preserve = false, float lifespan = 0.0, float xOff = 0.0, float yOff = 0.0, float zOff = 0.0);

/**
 * Attaches a wearable to a client, using Chaos Fortress' system to automatically handle several important things particles need.
 * In specific, this system automatically blocks the wearable from view if the client is invisible, automatically despawns the wearable if the client
 * dies or disconnects, and prevents the wearable from blocking the client's view in first person.
 *
 * @param client		The client to attach the wearable to.
 * @param index			The wearable's item index.
 * @param classname		The wearable's classname.
 * @param visible		Set to false if you want to hide the wearable from view.
 * @param paint			Any number 1-29 will paint the wearable, if applicable. See the Chaos Fortress wiki page for a list: https://github.com/SupremeSpookmaster/Chaos-Fortress/wiki/Miscellaneous-Data#paint-indexes
 * @param style			Optional style override for cosmetic wearables.
 * @param preserve		If set to true, the wearable is not removed on resupply unless the player's character is changed.
 * @param atts			Optional item attributes for the wearable.
 * @param lifespan		Optional lifespan for the wearable, 0.0 or below for infinite.
 *
 * @return The entity index of the spawned wearable, -1 if invalid.
 */
native int CF_AttachWearable(int client, int index, char classname[255], bool visible, int paint, int style, bool preserve = false, char atts[255] = "", float lifespan = 0.0);

/**
 * Gives a client ult charge, based on the parameters given. This can also remove ult charge if "coefficient" is negative.
 *
 * @param client		The client to give ult charge to.
 * @param coefficient	The amount of charge to give, relative to the specified CF_ResourceType.
 * @param ResourceType The method with which ult charge should be given.
 * 						CF_ResourceType_Generic: directly adds "coefficient" to the user's current ult charge.
 *						CF_ResourceType_Regen: directly adds "coefficient" * on_regen to the user's current ult charge.
 *						CF_ResourceType_DamageDealt: directly adds "coefficient" * on_damage to the user's current ult charge.
 *						CF_ResourceType_DamageTaken: directly adds "coefficient" * on_hurt to the user's current ult charge.
 *						CF_ResourceType_Healing: directly adds "coefficient" * on_heal to the user's current ult charge.
 *						CF_ResourceType_Kill: directly adds "coefficient" * on_kill to the user's current ult charge.
 *						CF_ResourceType_Percentage: directly fills the user's ult charge by "coefficient"-percent. IE 0.2 would fill ult charge by 20%.
 * @param IgnoreCD		If set to true, the ult charge is given even if the user's ultimate is on cooldown.
 *
 */
native CF_GiveUltCharge(int client, float coefficient, CF_ResourceType ResourceType = CF_ResourceType_Generic, bool IgnoreCD = false);

/**
 * Sets a client's ult charge.
 *
 * @param client		The client to set the ult charge of.
 * @param amt			The new ult charge.
 * @param IgnoreCD		If set to true, the ult charge is given even if the user's ultimate is on cooldown.
 *
 */
native CF_SetUltCharge(int client, float amt, bool IgnoreCD = false);

/**
 * Gets a client's ult charge.
 *
 * @param client		The client to get the ult charge of.
 * 
 * @return	A float value equal to the client's current ult charge, 0.0 if the client is invalid or not a character.
 *
 */
native float CF_GetUltCharge(int client);

/**
 * Gives a client some of their special resource, based on the given ResourceType. Does nothing if the client's special resource has is_ult enabled.
 *
 * @param client		The client to give the special resource to.
 * @param coefficient	The quantity of resources to give, relative to the specified CF_ResourceType.
 * @param ResourceType The method with which resources should be given.
 * 						CF_ResourceType_Generic: directly adds "coefficient" to the user's current resources.
 *						CF_ResourceType_Regen: directly adds "coefficient" * on_regen to the user's current resources.
 *						CF_ResourceType_DamageDealt: directly adds "coefficient" * on_damage to the user's current resources.
 *						CF_ResourceType_DamageTaken: directly adds "coefficient" * on_hurt to the user's current resources.
 *						CF_ResourceType_Healing: directly adds "coefficient" * on_heal to the user's current resources.
 *						CF_ResourceType_Kill: directly adds "coefficient" * on_kill to the user's current resources.
 *						CF_ResourceType_Percentage: directly fills the user's resources by "coefficient"-percent. IE 0.2 would fill resources by 20%.
 *
 */
native CF_GiveSpecialResource(int client, float coefficient, CF_ResourceType ResourceType = CF_ResourceType_Generic);

/**
 * Sets a client's special resource amount. Does nothing if the client's special resource has is_ult enabled.
 *
 * @param client		The client to set the special resource of.
 * @param amt			The new special resource.
 *
 */
native CF_SetSpecialResource(int client, float amt);

/**
 * Gets a client's special resources.
 *
 * @param client		The client to get the special resources of.
 * 
 * @return	A float value equal to the client's current resources, 0.0 if the client is invalid, not a character, not using resources, or has is_ult enabled on their special resource.
 *
 */
native float CF_GetSpecialResource(int client);

/**
 * Gets a client's maximum special resource capacity.
 *
 * @param client		The client to get the special resource capacity of.
 * 
 * @return	A float value equal to the client's max resources, 0.0 if the client is invalid, not a character, not using resources, or has is_ult enabled on their special resource.
 *
 */
native float CF_GetMaxSpecialResource(int client);

/**
 * Sets a client's maximum special resource capacity.
 *
 * @param client		The client to set the special resource capacity of.
 * @param amt			The new max resource capacity.
 *
 */
native float CF_SetMaxSpecialResource(int client);

/**
 * Applies a cooldown to an ability slot, given a set of parameters.
 *
 * @param client		The client to set the cooldown of.
 * @param duration		The duration the ability should be placed on cooldown.
 * @param type			The slot which should be placed on cooldown. If ult is blocked, you will also be unable to gain ult charge. This only works with CF_AbilityType_Ult, M2, M3, and Reload.
 * @param override		If true, this new cooldown will completely override any existing cooldowns. Otherwise, it is simply added to the current cooldown.
 * @param delay 		Set to true to delay the cooldown application by one frame so it doesn't interfere with other cooldown application sources. Enabled by default.
 *
 */
native void CF_ApplyAbilityCooldown(int client, float duration, CF_AbilityType type, bool override = false, bool delay = true);

/**
 * Retrieves the remaining cooldown of the client's given ability slot.
 *
 * @param client		The client to set the cooldown of.
 * @param type			CF_AbilityType pertaining to the given slot. This only works with CF_AbilityType_Ult, M2, M3, and Reload.
 *
 * @return	A float representing the ability's remaining cooldown.
 */
native float CF_GetAbilityCooldown(int client, CF_AbilityType type);

/**
 * Activates a given ability, if it exists on the character.
 *
 * @param client		The client whose ability to activate.
 * @param pluginName	The plugin name of the ability, as specified in the config as "plugin_name".
 * @param abilityName	The ability name of the ability, as specified in the config as "ability_name".
 *
 */
native CF_DoAbility(int client, char pluginName[255], char abilityName[255]);

/**
 * Ends all held abilities in a given slot, if it exists on the character.
 *
 * @param client		The client whose ability to end.
 * @param slot			The slot to end (2 for M2, 3 for M3, 4 for Reload).
 * @param resupply		If true, this is treated as if the ability was ended by the resupply event.
 *
 */
native CF_EndHeldAbilitySlot(int client, int slot, bool resupply);

/**
 * Ends a specific held ability.
 *
 * @param client		The client whose ability to end.
 * @param pluginName			The plugin name of the ability to end, as specified in the config as "plugin_name".
 * @param abilityName			The ability name of the ability to end, as specified in the config as "ability_name".
 * @param resupply		If set to true, this is treated as if the ability was ended by the resupply event.
 *
 */
native CF_EndHeldAbility(int client, char pluginName[255], char abilityName[255], bool resupply);

/**
 * Activates every ability a client's character has, which uses a given ability slot.
 *
 * @param client		The client whose abilities to activate.
 * @param slot			The slot to use.
 *
 */
native CF_ActivateAbilitySlot(int client, int slot);

/**
 * DEPRECATED; USE CF_IsAbilitySlotBlocked INSTEAD!
 */
native CF_CheckIsSlotBlocked(int client, int slot);

/**
 * Checks if a given character has a specified ability.
 *
 * @param client		The client whose abilities to check.
 * @param pluginName			The plugin name of the ability, as specified in the config as "plugin_name".
 * @param abilityName	The ability name of the ability, as specified in the config as "ability_name".
 *
 * @return True if the client's character has the specified ability, false if not.
 */
native bool CF_HasAbility(int client, char pluginName[255], char abilityName[255]);

/**
 * Gets an int value from a specified ability's arg.
 *
 * @param client		The client whose abilities to check.
 * @param pluginName	The plugin name of the ability, as specified in the config as "plugin_name".
 * @param abilityName	The ability name of the ability, as specified in the config as "ability_name".
 * @param argName		The arg to check.
 *
 * @return An int equal to the value obtained from the given ability's specified arg, -1 if no such value was present.
 */
native int CF_GetArgI(int client, char pluginName[255], char abilityName[255], char argName[255]);

/**
 * Gets a float value from a specified ability's arg.
 *
 * @param client		The client whose abilities to check.
 * @param pluginName	The plugin name of the ability, as specified in the config as "plugin_name".
 * @param abilityName	The ability name of the ability, as specified in the config as "ability_name".
 * @param argName		The arg to check.
 *
 * @return A float equal to the value obtained from the given ability's specified arg, -1.0 if no such value was present.
 */
native float CF_GetArgF(int client, char pluginName[255], char abilityName[255], char argName[255]);

/**
 * Gets an ability slot from a specified ability.
 *
 * @param client		The client whose abilities to check.
 * @param pluginName	The plugin name of the ability, as specified in the config as "plugin_name".
 * @param abilityName	The ability name of the ability, as specified in the config as "ability_name".
 *
 * @return A CF_AbilityType pertaining to the chosen ability's slot, CF_AbilityType_None if the ability doesn't exist or the client is invalid/not a character.
 */
native CF_AbilityType CF_GetAbilitySlot(int client, char pluginName[255], char abilityName[255]);

/**
 * Gets a string value from a specified ability's arg.
 *
 * @param client		The client whose abilities to check.
 * @param pluginName	The plugin name of the ability, as specified in the config as "plugin_name".
 * @param abilityName	The ability name of the ability, as specified in the config as "ability_name".
 * @param argName		The arg to check.
 * @param buffer		Output buffer.
 * @param size			Size of the output buffer.
 *
 * @return The string obtained from the given ability's specified arg (empty if the arg was not found), stored in the output buffer.
 */
native CF_GetArgS(int client, char pluginName[255], char abilityName[255], char argName[255], char output[255], int size);

/**
 * Gets a string value from a specified ability's arg.
 *
 * @param client		The client whose abilities to check.
 * @param pluginName	The plugin name of the ability, as specified in the config as "plugin_name".
 * @param abilityName	The ability name of the ability, as specified in the config as "ability_name".
 * @param section		The section you want the ConfigMap to lead to. For example, if your ability has a section you want to retrieve called "custom_attributes", you would pass custom_attributes to this value.
 * @param output		Output buffer.
 * @param size			Output buffer size.
 *
 * @return A string representing the config's path to the given section, intended to be used to create a ConfigMap.
 */
native CF_GetAbilityConfigMapPath(int client, char pluginName[255], char abilityName[255], char section[255], char output[255], int size);

/**
 * Gets a random sound from a given boss config.
 *
 * @param Config 				The config to grab the sound from. Must be a direct path such as "configs/chaos_fortress/character.cfg". You can obtain this easily with CF_GetCharacterConfig.
 * @param Sound					The sound section to grab from, such as "sound_kill".
 * @param Output				The output buffer.
 * @param len					The length of the output buffer.
 *
 * @return A KeyValType corresponding to the chosen sound. KeyValType_Value for sounds without special settings, KeyValType_Section for sounds with special settings, and KeyValType_Null for invalid sounds.
 */
native KeyValType CF_GetRandomSound(char Config[255], char Sound[255], char Output[255], int len);

/**
 * Plays a random sound from a client's boss config, as specified by the settings below.
 *
 * @param source				The source to play the sound from. If this is a valid client, Config can be left blank to automatically grab their current character config.
 * @param Config				The config to grab the sound from. If source is a valid client and you leave this blank, the config is automatically grabbed from that client's current character.
 * @param Sound					The sound section to grab from, such as "sound_kill".
 *
 * @return		True if the sound was played, false otherwise.
 */
native bool CF_PlayRandomSound(int source, char Config[255], char Sound[255]);

/**
 * Temporarily blocks all class dialogue on a given character.
 *
 * @param client				The client to silence.
 * @param duration				The duration of the silence.
 *
 */
native CF_SilenceCharacter(int client, float duration);

/**
 * Retrieves the given client's current K/D, using the rules specified in game_rules.
 *
 * @param client				The client whose K/D to retrieve.
 *
 * @return	A float value equal to the client's K/D.
 */
native float CF_GetKD(int client);

/**
 * Retrieves the given client's current "emotion", based on their K/D. Currently this is used only for spawn sounds, further functionality may be implemented in the future.
 *
 * @param client				The client whose "emotion" to retrieve.
 *
 * @return	CF_Emotion_Angry if the client's K/D is too low, CF_Emotion_Happy if it is high, CF_Emotion_Neutral for anything in-between.
 */
native CF_Emotion CF_GetCharacterEmotion(int client);

/**
 * Checks if a client's specified ability slot is blocked. Only works for CF_AbilityType_Ult, M2, M3, and Reload, all others return false.
 *
 * @param client				The client whose ability slot to check.
 * @param type					The ability slot to check.
 *
 * @return	True if the slot is blocked, false if it is not or if the client/type is invalid.
 */
native bool CF_IsAbilitySlotBlocked(int client, CF_AbilityType type);

/**
 * Blocks a specified ability slot from being used. Only works for CF_AbilityType_Ult, M2, M3, and Reload.
 *
 * @param client				The client whose ability slot to block.
 * @param type					The ability slot to block.
 */
native CF_BlockAbilitySlot(int client, CF_AbilityType type);

/**
 * Unblocks a specified ability slot. Only works for CF_AbilityType_Ult, M2, M3, and Reload.
 *
 * @param client				The client whose ability slot to unblock.
 * @param type					The ability slot to unblock.
 */
native CF_UnblockAbilitySlot(int client, CF_AbilityType type);

/**
 * Heals a specified player for a specified amount, and gives the healer credit for it.
 *
 * @param client				The client to heal.
 * @param healer				The client who performed the healing (does not need to be a valid client).
 * @param amt					The amount of healing given.
 * @param hpMult				The maximum percentage of the client's max HP for this to heal to. For example: 1.5 would allow this instance to heal the client up to a maximum of 150% of their max HP.
 */
native CF_HealPlayer(int client, int healer, int amt, float hpMult);

/**
 * Launches a generic rocket, as if the user had fired a rocket launcher.
 *
 * @param client				The client to shoot the rocket.
 * @param dmg					The rocket's base damage.
 * @param velocity				The rocket's base velocity.
 * @param crit					Set to true to make the rocket crit.
 * @param collideWithAllies		Set to true to allow the rocket to collide with allies.
 * @param pluginName			Name of the plugin which owns the logic function.
 * @param logic					Function to call when the rocket collides with something. Must accept 3 ints as parameters (first is the rocket, second is its owner, third is the rocket's team) and return an MRESReturn.
 *
 * @return	The entity index of the rocket. 
 */
native CF_FireGenericRocket(int client, float dmg, float velocity, bool crit = false, bool collideWithAllies = false, char pluginName[255] = "", Function logic = INVALID_FUNCTION);

/**
 * Creates a simulated health kit, with more customizable options than just creating an 'item_healthkit'.
 *
 * @param owner					The client who owns the health kit. Points for healing get awarded to this player if they are a valid client.
 * @param amt					The amount of healing provided to the client who picks the health kit up.
 * @param radius				Distance from the health kit at which the health kit will be picked up.
 * @param mode					Mode in which the health provided by this kit should be given. 0: percentage-based, all other values: flat value.
 * @param lifespan				Duration the health kit should be active. 0.0 or below: infinite.
 * @param pos					The position the health kit should be spawned at.
 * @param plugin				Name of the plugin which is calling this native. Only necessary if "filter" is used.
 * @param filter				Function used to determine who should be able to pick up the health kit. The function must return a bool value, with the first parameter being the health kit's entity index, the second parameter as its owner, and the third paremeter as the client attempting to pick up the health kit.
 * @param model					Optional model to be used for the health kit.
 * @param sequence				Optional animation sequence to be used for the health kit.
 * @param rate					Optional playback rate for the animation sequence.
 * @param scale					Optional model scale to be used for the health kit's model.
 * @param skin					Optional skin to set for the health kit's model.
 * @param sound					Optional sound to play when somebody picks up the health kit.
 * @param hpMult				Optional max HP multiplier provided by the health kit. IE, if this is 1.5, the health kit can heal the player who grabs it up to a maximum of 50% overheal.
 * @param physModel				Optional invisible model to be used for the health kit's physics. 
 * @param redParticle			Optional particle effect to spawn when this health kit is picked up by a red player.
 * @param blueParticle			Optional particle effect to spawn when this health kit is picked up by a blue player.
 * @param massScale				Optional amount to scale the mass of the health kit for the sake of physics simulations.
 * @param intertiaScale			Optional amount to scale the intertia of the health kit for the sake of physics simulations.
 *
 * @return	The entity index of the health kit, or -1 if it fails to spawn.
 */
native int CF_CreateHealthPickup(int owner, float amt, float radius, int mode, float lifespan, float pos[3], char plugin[255] = "", Function filter = INVALID_FUNCTION, char model[255] = "models/items/medkit_medium.mdl", char sequence[255] = "idle", float rate = 1.0, float scale = 1.0, int skin = 0, char sound[255] = "items/smallmedkit1.wav", float hpMult = 1.0, char physModel[255] = "models/items/medkit_medium.mdl", float massScale = 1.0, float inertiaScale = 1.0);

/**
 * Creates a simulated medigun shield by using a physics prop.
 *
 * @param owner					The client who owns the medigun shield.
 * @param model					The model to be used for the medigun shield. THIS MODEL MUST HAVE WORKING PHYSICS!
 * @param skin					Model skin to be used.
 * @param scale					Model scale.
 * @param health				How much health does the medigun shield have?
 * @param pos					Position to spawn the medigun shield at.
 * @param ang					Angles to spawn the medigun shield with.
 * @param lifespan				How long should the medigun shield be active? (0.0 or below: infinite)
 *
 * @return	The entity index of the medigun shield, or -1 if it fails to spawn.
 */
native int CF_CreateShieldWall(int owner, char model[255], char skin[16], float scale, float health, float pos[3], float ang[3], float lifespan = 0.0);

/**
 * Retrieves the remaining HP of a simulated medigun shield.
 *
 * @param shield					The shield.
 *
 * @return	The remaining HP of the shield, or 0.0 if the entity is not a simulated medigun shield.
 */
native float CF_GetShieldWallHealth(int shield);

/**
 * Retrieves the max HP of a simulated medigun shield.
 *
 * @param shield					The shield.
 *
 * @return	The max HP of the shield, or 0.0 if the entity is not a simulated medigun shield.
 */
native float CF_GetShieldWallMaxHealth(int shield);

/**
 * Inflicts generic area-of-effect damage within a specified radius
 *
 * @param attacker				The player who triggered this damage. This entire process is skipped if this client is not valid.
 * @param inflictor				The inflictor of the damage, such as a rocket.
 * @param weapon				The weapon used to inflict the damage, such as a rocket launcher.
 * @param dmg					The base damage dealt.
 * @param damageType			The type of damage dealt.
 * @param radius				The radius in which damage should be dealt.
 * @param groundZero			The origin of the damage.
 * @param falloffStart			The distance from groundZero at which damage falloff begins to take place.
 * @param falloffMax			The maximum damage penalty caused by falloff, as a percentage. Ex: 0.8 would be 80%
 * @param skipDefaultFilter		If set to true, Chaos Fortress' default trace filter (CF_DefaultTrace) is ignored. Useful if you want this damage to ignore shields or go through walls.
 * @param includeUser			If set to true, this can damage the user if they are within the radius.
 * @param ignoreInvuln			If set to true, invulnerable players are added to the array returned by this native as long as they would have still been hit by it otherwise.
 * @param pluginName			Name of the plugin which owns the logic function.
 * @param logic					Optional function which you can use to filter out specific entities that are within the blast radius. This function must take one int as a parameter (the entity being checked), and return a bool (true to allow the entity to be hit, false otherwise).
 *
 * @return	An array containing the entity indices of all entities hit by this damage, useful for applying additional effects to victims. This gets returned even if it is empty, you will need to manually close the handle when you are done with it.
 */
native Handle CF_GenericAOEDamage(int attacker, int inflictor, int weapon, float dmg, int damageType, float radius, float groundZero[3], float falloffStart, float falloffMax, bool skipDefaultFilter = false, bool includeUser = true, bool ignoreInvuln = false, char pluginName[255] = "", Function logic = INVALID_FUNCTION);

/**
 * Applies a temporary change to the client's movement speed.
 *
 * @param client			The client whose speed to modify.
 * @param mode				Used to determine how to modify the client's speed.
 *							1: Multiply the client's BASE speed by "amt", then add or subtract speed based on the amount of speed gained or lost. IE, if this is 0.8 and the client's base speed is 100, the client's speed will be reduced by 20 HU/s.
 *							2: Multiply the client's CURRENT speed by "amt". IE, if this is 1.2, and the client's current speed is 100, the client's speed will increase by 20 HU/s.
 *							All Other Values: Directly add/subtract "amt" to/from the client's current speed.
 * @param amt				The coefficient to be used to modify the client's speed, based on the chosen mode.
 * @param duration			The duration of the speed change. 0.0 or below: duration is infinite.
 * @param maxMode			Used to determine how to limit the client's speed.
 *							0: Do not check for a max movement speed.
 *							1: If the user's movement speed would become higher than their base speed multiplied by maxSpeed, cap their speed at the product of that operation.
 *							All Other Values: If the user's movement speed would become higher than maxSpeed, cap their speed at maxSpeed.
 * @param sounds			If true: plays the speed boost sound effects of the Disciplinary Action when the speed change begins and when it ends.
 */
native CF_ApplyTemporarySpeedChange(int client, int mode, float amt, float duration, int maxMode, float maxSpeed, bool sounds = true);

/**
 * Retrieves the client's base movement speed, before any external modifiers.
 *
 * @param client			The client whose base speed to retrieve.
 *
 * @return	The client's base movement speed, or 0.0 if the client is invalid/not a character.
 */
native float CF_GetCharacterBaseSpeed(int client);

/**
 * Transforms a client into the specified character.
 *
 * @param client			The client to set. This client must be a valid, living player.
 * @param character			The config name of the character to set, relative to configs/chaos_fortress. You may also write the entire, full path of the config, relative to the sourcemod folder.
 * @param message			Optional message printed to the client's screen.
 *
 * @return	True if the character was successfully forced, false otherwise.
 */
native bool CF_MakeClientCharacter(int client, char character[255], char message[255] = "");

/**
 * Enables or disables Chaos Fortress' default HUD for a given client. Note that the HUD is automatically re-enabled when the player becomes a character, if that character uses CF's built-in ability system.
 *
 * @param client			The client to toggle the HUD for.
 * @param toggle			True to use the default HUD, false to turn it off.
 */
native CF_ToggleHUD(int client, bool toggle);

/**
 * Changes the display name of a given ability slot for the specified client.
 *
 * @param client			The client to change the ability name for.
 * @param type				The ability slot to change the display name for.
 * @param newName			The new display name.
 */
native CF_ChangeAbilityTitle(int client, CF_AbilityType type, char newName[255]);

/**
 * Retrieves the display name of a given ability slot for the specified client, stored in the output buffer.
 *
 * @param client			The client to retrieve the ability name of.
 * @param type				The ability slot to retrieve the display name of.
 * @param output			Output buffer to store the ability's name in.
 */
native CF_GetAbilityTitle(int client, CF_AbilityType type, char output[255]);

/**
 * Changes the display name of the given client's special resource.
 *
 * @param client			The client to change the resource name for.
 * @param newName			The new display name.
 * @param newNamePlural		The new display name to be used if the user does not have exactly 1 of the special resource.
 */
native CF_ChangeSpecialResourceTitle(int client, char newName[255], char newNamePlural[255]);

/**
 * Retrieves the display name of the given client's special resource, stored in the output buffers.
 *
 * @param client			The client to retrieve the special resource name of.
 * @param output			Output buffer to store the special resource's name in.
 * @param output_plural		Output buffer to store the title of the special resource used when the user does not have exactly 1 of the special resource.
 */
native CF_GetSpecialResourceTitle(int client, char output[255], char output_plural[255]);

/**
 * Checks if a client should be able to teleport to the location they are aiming at, up to a certain distance away.
 * ALL FUNCTIONALITY PROVIDED BY THIS NATIVE AND CF_Teleport WERE WRITTEN BY SARYSA! All I did was port them and add the "directional" feature.
 *
 * @param client			The client to attempt the teleport.
 * @param distance			The distance of the teleport.
 * @param directional		If true, the direction of the teleport is affected by the user's movement keys.
 * @param output			Optional output vector to store the position the client will teleport to.
 * @param PositionOverride	If set to a valid vector and UseOverride is set to true, this position will be checked instead of the position at the player's crosshairs. This bypasses "distance" and "directional".
 * @param UseOverride		Set PositionOverride to a valid vector and set this to true to override the destination being checked.
 *
 * @return	True if the client can teleport without getting stuck, false if they can't or are an invalid client.
 */
native bool CF_CheckTeleport(int client, float distance, bool directional, float output[3] = NULL_VECTOR, float PositionOverride[3] = NULL_VECTOR, bool UseOverride = false)

/**
 * Checks if an entity is in any of the spawn rooms associated with the given TFTeam.
 *
 * @param entity			The entity to check.
 * @param team				The team to check.
 *
 * @return	True if the entity is in a spawn room belonging to the given team, false otherwise.
 */
native bool CF_IsEntityInSpawn(int entity, TFTeam team)

/**
 * Makes a client teleport in the direction they are aiming, up to a certain distance away. If they are holding crouch, they will "flip" to view the location they were at before the teleport.
 * ALL FUNCTIONALITY PROVIDED BY THIS NATIVE AND CF_CheckTeleport WERE WRITTEN BY SARYSA! 
 * All I did was port them and add the "directional" and "flip" features.
 *
 * @param client			The client to attempt the teleport.
 * @param distance			The distance of the teleport.
 * @param directional		If true, the direction of the teleport is affected by the user's movement keys.
 * @param output			Optional output vector to store the position the client will teleport to.
 * @param IgnoreSafetyCheck	If set to true, the teleport will occur even if something is in the way of your destination or you would get stuck.
 * @param PositionOverride	If set to a valid vector and UseOverride is set to true, the player will be teleported to that position instead of to their cursor. This bypasses "distance" and "directional".
 * @param UseOverride		Set PositionOverride to a valid vector and set this to true to override the teleport destination.
 *
 */
native void CF_Teleport(int client, float distance, bool directional, float output[3] = NULL_VECTOR, bool IgnoreSafetyCheck = false, float PositionOverride[3] = NULL_VECTOR, bool UseOverride = false);

/**
 * Changes the RGBA values of the given client's HUD text. Note that this is automatically reset every time the player respawns, changes their character, or touches a resupply locker.
 *
 * @param client			The client to change the HUD color for.
 * @param r					R value. Set to anything below 0 to leave unchanged.
 * @param g					G value. Set to anything below 0 to leave unchanged.
 * @param b					B value. Set to anything below 0 to leave unchanged.
 * @param a					A value. Set to anything below 0 to leave unchanged.
 *
 */
native void CF_SetHUDColor(int client, int r = 255, int g = 255, int b = 255, int a = 255);

/**
 * Retrieves the coordinates of the center of the given entity based on its collision hull, stored in the output buffer.
 *
 * @param entity		The entity to get the center of.
 * @param output		Output buffer to store the coordinates in.
 *
 * @return		The coordinates of the entity's center.
 */
native void CF_WorldSpaceCenter(int entity, float output[3]);

/**
 * Checks whether or not the given entity is valid and matches a set of given requirements.
 *
 * @param entity		The entity to check.
 * @param team			The team the entity must be on, or TFTeam_Unassigned to ignore teams.
 * @param plugin		Name of the plugin which is calling this native. Only necessary if "filter" is used.
 * @param filter		Optional function for you to add your own extra requirements to. This function must take one int as a parameter, that being the entity's index, and must return a bool (true to count as valid, false otherwise).
 *
 * @return		True if the entity is both a valid entity and matches the given requirements, false otherwise.
 */
native bool CF_IsValidTarget(int entity, TFTeam team, char[] plugin = "", Function filter = INVALID_FUNCTION);

/**
 * Retrieves the entity nearest to the given point, with optional filters so that only certain entities are included.
 *
 * @param pos				The position to search from.
 * @param IncludeEntities	If set to true, this native will cycle through ALL entities instead of just players, which is much more expensive. Only set to true if you absolutely need to.
 * @param distance			Optional return parameter in which the distance from "pos" too the nearest entity will be stored.
 * @param maxDistance		The maximum possible distance an entity can be from "pos" to be counted. <= 0.0: no limit.
 * @param team				The team an entity must be on in order to be counted, or TFTeam_Unassigned to ignore teams.
 * @param plugin			Name of the plugin which is calling this native. Only necessary if "filter" is used.
 * @param filter			Optional function for you to add your own extra requirements to. This function must take one int as a parameter, that being the entity's index, and return a bool.
 *
 * @return		True if the entity is both a valid entity and matches the given requirements, false otherwise.
 */
native int CF_GetClosestTarget(float pos[3], bool IncludeEntities = false, float &distance = 0.0, float maxDistance = 0.0, TFTeam team = TFTeam_Unassigned, char[] plugin = "", Function filter = INVALID_FUNCTION);

/**
 * Gives a client a spellbook and forces them to cast it.
 * Calls the "CF_OnSimulatedSpellUsed" forward at the moment when the spell would normally be cast unless index is set to CF_Spell_SuperJump, CF_Spell_Minify, CF_Spell_Invisibility, or CF_Spell_Ubercharge.
 *
 * @param client			The client to do this with.
 * @param attributes		Optional spellbook attributes.
 * @param index				Can be set to any CF_SpellIndex to change the spell which is cast, along with its sound effect.
 * @param dont_cast			If true, the projectile spawned by this spell will not spawn. CF_OnSimulatedSpellUsed will still be called. This will not prevent the effects of CF_Spell_SuperJump, CF_Spell_Minify, CF_Spell_Invisibility, or CF_Spell_Ubercharge from activating.
 * @param instant			If set to true, automatically adds "178 ; 0.0" to the given attributes for instant deploy time.
 *
 * @note 	It should be noted that using this native will still trigger the spell-cast VFX and SFX. If you only want the viewmodel animation, use CF_ForceViewmodelAnimation instead and set the "activity" parameter to ACT_SPELL_VM_FIRE.
 */
native CF_SimulateSpellbookCast(int client, char[] attributes = "", CF_SpellIndex index = CF_Spell_Fireball, bool dont_cast = true, bool instant = true);

/**
 * Forces a client's viewmodel (their hands, what you see in first-person) to play a specified sequence.
 *
 * @param client				The client whose viewmodel to animate.
 * @param sequence				The sequence to force. For example: "spell_fire" will force the spell-casting animation.
 * @param hideWeapon			If true, the weapon currently held by the user will be hidden during the animation.
 * @param blockAttack			If true, the user will be unable to attack during the animation.
 * @param blockWeaponSwitch		If true, the user will be unable to switch their weapon during the animation.
 *
 * @note	Weapons that are physically part of the user's hands, such as the gunslinger, are not hidden by hideWeapon.
 */
native CF_ForceViewmodelAnimation(int client, char[] sequence, bool hideWeapon = true, bool blockAttack = true, bool blockWeaponSwitch = true);

/**
 * Sets the number of uses an ability currently has. Only works if the ability's max stocks > 0.
 * 
 * @param client		The client.
 * @param type			The ability slot to set stocks for.
 * @param stocks		The number of uses to set.
 * @param ignoreMax		If true: ignore the maximum number of stocks.
 */
native void CF_SetAbilityStocks(int client, CF_AbilityType type, int stocks, bool ignoreMax = true);

/**
 * Sets the maximum number of uses an ability can hold. If the ability was previously a normal ability and not a stockpile ability, 
 * this will convert it to a stockpile ability. Similarly, if the ability is a stockpile ability and you set maxStocks to 0, it will be converted
 * to a normal ability.
 * 
 * @param client		The client.
 * @param type			The ability slot to set max stocks for.
 * @param maxStocks		Max stocks held.
 */
native void CF_SetAbilityMaxStocks(int client, CF_AbilityType type, int maxStocks);

/**
 * Retrieves the current remaining number of uses a character has on an ability slot.
 * 
 * @param client		The client.
 * @param type			The ability slot to retrieve uses for.
 * 
 * @return		The number of remaining uses the client has for the given ability slot.
 */
native int CF_GetAbilityStocks(int client, CF_AbilityType type);

/**
 * Retrieves the current maximum number of uses a character has on an ability slot.
 * 
 * @param client		The client.
 * @param type			The ability slot to retrieve uses for.
 * 
 * @return		The maximum number of uses the client can stockpile for the given ability slot.
 */
native int CF_GetAbilityMaxStocks(int client, CF_AbilityType type);

/**
 * Sets the local origin of a given entity.
 * 
 * @param entity	The entity.
 * @param origin	The origin to set.
 */
native void CF_SetLocalOrigin(int entity, float origin[3]);

/**
 * Begins lag compensation for this client. Call CF_EndLagCompensation when you are done.
 * 
 * @param client	The client to lag-compensate.
 */
native void CF_StartLagCompensation(int client);

/**
 * Ends lag compensation for this client. Will not work unless you have called CF_StartLagCompensation first.
 * 
 * @param client	The client whose lag compensation to end.
 */
native void CF_EndLagCompensation(int client);

/**
 * Activates all abilities which use the given slot.
 * 
 * @param client	The client whose ability slot to activate.
 * @param slot		The ability slot to activate.
 */
native void CF_DoAbilitySlot(int client, int slot);

/**
 * Performs a trace ray from startPos to endPos, and returns an ArrayList of players who were caught.
 * This is automatically lag-compensated.
 * Can be paired with CF_TraceShot to determine if a given victim was headshot, as well as to get the individual hit positions of every victim hit by this trace.
 * 
 * @param client			The client to trace for.
 * @param startPos			The starting position of the trace.
 * @param endPos			The ending position of the trace.
 * @param numPenetrations	Optional max number of targets the ray can penetrate.
 * @param team				Optional team to check for, using CF_IsValidTarget. Targets who are considered invalid by CF_IsValidTarget are ignored by this native.
 * @param plugin			Plugin name of the optional filter function, using CF_IsValidTarget. Only necessary if "filter" is used.
 * @param filter			Function name of the optional filter function, using CF_IsValidTarget. This function must take one int as a parameter, that being the entity's index, and must return a bool (true to count as valid, false otherwise).
 * @param hitPos			Optional output vector to store the end position of the trace, if it reaches the maximum number of penetrations and hits another target.
 * 
 * @return	An ArrayList of all of the entities who were hit by this trace, sorted by distance from the starting position.
 */
native ArrayList CF_DoBulletTrace(int client, float startPos[3], float endPos[3], int numPenetrations = 0, TFTeam team, char[] plugin = "", Function filter = INVALID_FUNCTION, float hitPos[3] = NULL_VECTOR);

/**
 * Performs a trace ray from startPos to endPos, and checks to see if the trace goes through the target.
 * This is automatically lag-compensated.
 * 
 * @param user		The client who is running the trace.
 * @param target	The target to check for headshots.
 * @param startPos	The starting position of the trace.
 * @param endPos	The ending position of the trace.
 * @param headshot	This gets set to true if this trace goes through the target's head.
 * @param doLagComp	If set to false: lag compensation is skipped.
 * @param hitPos	Optional output vector to store the position at which the trace and the target intersect, if they hit.
 * 
 * @return	True if the trace headshots the target, false otherwise.
 */
native void CF_TraceShot(int user, int target, float startPos[3], float endPos[3], bool &headshot = false, bool doLagComp = true, float hitPos[3] = NULL_VECTOR);

/**
 * Automatically sets up and calls CF_DoBulletTrace and CF_TraceShot, then deals damage to every enemy it hits.
 * This is automatically lag-compensated.
 * 
 * @param client		The client to fire the bullet.
 * @param ang			The angle of the shot.
 * @param damage		Base damage.
 * @param hsMult		Headshot damage multiplier.
 * @param spread		Random spread.
 * @param hitPlugin		Name of the plugin containing the optional function to call on a hit.
 * @param hitFunction	Optional function to call on a hit. Must take an int for the attacker, an int for the victim, a float by reference for damage, a bool by reference for falloff, a bool by reference for headshot, an int by reference for headshot effects, and a bool by reference for crits.
 * 						Example: void MyHeadshotCallback(int attacker, int victim, float &baseDamage, bool &allowFalloff, bool &isHeadshot, int &hsEffect, bool &crit)
 * 						baseDamage can be changed to modify the damage dealt before falloff is calculated.
 * 						Setting allowFalloff to false will block damage falloff from being calculated.
 * 						isHeadshot can be modified to force or prevent a headshot.
 * 						hsEffect is used for particle/sound effects on headshots. If <= 0, no effects are displayed. If set to 1, mini-crit effects are used. If >= 2, full crit effects are used.
 * 						crit can be set to true to force the attack to crit, or to prevent a crit. Forcing a crit will force hsEffect to 2.
 * @param falloffStart	Range at which damage falloff begins.
 * @param falloffEnd	Range at which damage falloff becomes its strongest.
 * @param falloffMax	Maximum percentage of damage to subtract based on falloff, IE 0.3 = 30% reduced damage.
 * @param pierce		The maximum number of enemies pierced by this attack.
 * @param team			Optional team to check for, using CF_IsValidTarget. Targets who are considered invalid by CF_IsValidTarget are ignored by this native.
 * @param plugin		Plugin name of the optional filter function, using CF_IsValidTarget. Only necessary if "filter" is used.
 * @param filter		Function name of the optional filter function, using CF_IsValidTarget. This function must take one int as a parameter, that being the entity's index, and must return a bool (true to count as valid, false otherwise).
 * @param particle		Bullet tracer particle to use. Must be a multi-point particle.
 */
native void CF_FireGenericBullet(int client, float ang[3], float damage, float hsMult = 1.0, float spread = 0.0, char[] hitPlugin = "", Function hitFunction = INVALID_FUNCTION, float falloffStart = 0.0, float falloffEnd = 0.0, float falloffMax = 0.0, int pierce = 0, TFTeam team, char[] plugin = "", Function filter = INVALID_FUNCTION, char[] particle = "bullet_shotgun_tracer01_red");