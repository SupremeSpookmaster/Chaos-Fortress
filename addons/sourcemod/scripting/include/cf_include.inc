#if defined _cfinc_included_
  #endinput
#endif
#define _cfinc_included_

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

enum CF_ViewChangeType
{
	CF_ViewChangeType_None = 0,
	CF_ViewChangeType_FirstPerson,
	CF_ViewChangeType_ThirdPerson,
	CF_ViewChangeType_Full
};

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
forward Action CF_OnPlayerRunCmd(int client, int &buttons, int &impulse, int &weapon)

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
forward Action CF_OnPlayerM2(int client, int &buttons, int &impulse, int &weapon)

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
forward Action CF_OnPlayerM3(int client, int &buttons, int &impulse, int &weapon)

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
forward Action CF_OnPlayerReload(int client, int &buttons, int &impulse, int &weapon)

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
forward Action CF_OnPlayerTab(int client, int &buttons, int &impulse, int &weapon)

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
forward Action CF_OnPlayerJump(int client, int &buttons, int &impulse, int &weapon)

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
forward Action CF_OnPlayerCrouch(int client, int &buttons, int &impulse, int &weapon)

/**
 * Called when a character calls for medic, AKA when they press the E key.
 *
 * @param client			The client who ran the command.
 */
forward void CF_OnPlayerCallForMedic(int client)

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
	float damageForce[3], float damagePosition[3], int &damagecustom)
	
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
	float damageForce[3], float damagePosition[3], int &damagecustom)

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
	float damageForce[3], float damagePosition[3], int &damagecustom)
	
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
 *
 * @return	Return Plugin_Continue to proceed as normal, Plugin_Changed if you changed any of the values, Plugin_Stop or Plugin_Handled to prevent the damage altogether.
 */
forward Action CF_OnTakeDamageAlive_Post(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom)
	
/**
 * Called when a player's Chaos Fortress killstreak is changed.
 *
 * @param client			The client whose killstreak was changed.
 * @param kills				The new killstreak.
 */
forward void CF_OnKillstreakChanged(int client, int kills)

/**
 * Called when a character is killed.
 *
 * @param victim			The player who was killed.
 * @param inflictor			The entity which inflicted the killing blow.
 * @param attacker			The player who is credited for the kill.
 * @param deadRinger		0 if the kill was real, 1 if it was a dead ringer.
 */
forward void CF_OnPlayerKilled(int victim, int inflictor, int attacker, int deadRinger)

/**
 * Called when the Chaos Fortress round state is changed.
 *
 * @param state				The new round state. 0: Pre-game/setup time/waiting for players, 1: round in progress, 2: round has ended.
 */
forward void CF_OnRoundStateChanged(int state)

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
 * Called when a player's character is removed, or they are made to no longer be a character. This occurs when the player dies and whenever the round state changes.
 *
 * @param client			The client whose character was removed.
 *
 */
forward void CF_OnCharacterRemoved(int client);

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
 */
native CF_SetKillstreak(int client, int kills, int killer)

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
native CF_GetCharacterMaxHealth(int client);

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
 * @param override		Optional weapon model override.
 * @param visible		Should the weapon be visible?
 * @param unequip		Should whichever weapon(s) currently in this weapon's slot be removed before equipping this weapon?
 * @param ForceClass	Class to force this weapon to use the animations of, if using ViewChange. 1-9 for the mercs, anything above 9 is considered all-class.
 * @param spawn			If true, ammo is applied one frame later instead of instantly so it doesn't interfere with the resupply event.
 *
 * @return The entity index of the spawned weapon, -1 if not valid.
 */
native int CF_SpawnWeapon(int client, char[] name, int index, int level, int qual, int slot, int reserve, int clip, const char[] att, char override[255] = "", bool visible = true, bool unequip = true, int ForceClass = 0, bool spawn = false);

/**
 * Gets the class of the player's current character.
 *
 * @param client		The client to check.
 *
 * @return The class of the player's character, TFClass_Unknown if invalid.
 */
native TFClassType CF_GetCharacterClass(int client);

/**
 * DEPRECATED! USE CF_GetViewChangeType INSTEAD!
 * 
 * OLD FUNCTIONALITY: Checks if the player's current character is using the ViewChange system.
 *
 * @param client		The client to check.
 *
 * @return True if the client is valid and is a character which uses ViewChange, false otherwise.
 */
native bool CF_GetCharacterUsingViewChange(int client);

/**
 * Attaches a particle to a client, using Chaos Fortress' system to automatically handle several important things particles need.
 * In specific, this system automatically blocks the particle from view if the client is invisible, automatically despawns the particle if the client
 * dies or disconnects, and prevents the particle from blocking the client's view in first person.
 *
 * @param client		The client to attach the particle to.
 * @param particle		The particle's name.
 * @param point			The attachment point of the particle.
 * @param lifespan		Optional particle duration, 0.0 or below for infinite.
 * @param xOff			Optional X-axis offset, in hammer units.
 * @param yOff			Optional Y-axis offset, in hammer units.
 * @param zOff			Optional Z-axis offset, in hammer units.
 *
 * @return The entity index of the spawned particle, -1 if invalid.
 */
native int CF_AttachParticle(int client, char particle[255], char point[255], float lifespan = 0.0, float xOff = 0.0, float yOff = 0.0, float zOff = 0.0);

/**
 * Attaches a wearable to a client, using Chaos Fortress' system to automatically handle several important things particles need.
 * In specific, this system automatically blocks the wearable from view if the client is invisible, automatically despawns the wearable if the client
 * dies or disconnects, and prevents the wearable from blocking the client's view in first person.
 *
 * @param client		The client to attach the wearable to.
 * @param index			The wearable's item index.
 * @param visible		Set to false if you want to hide the wearable from view.
 * @param paint			Any number 1-29 will paint the wearable, if applicable. See the Chaos Fortress wiki page for a list: https://github.com/SupremeSpookmaster/Chaos-Fortress/wiki/Miscellaneous-Data#paint-indexes
 * @param style			Optional style override for cosmetic wearables.
 * @param atts			Optional item attributes for the wearable.
 * @param lifespan		Optional lifespan for the wearable, 0.0 or below for infinite.
 *
 * @return The entity index of the spawned wearable, -1 if invalid.
 */
native int CF_AttachWearable(int client, int index, bool visible, int paint, int style, char atts[255] = "", float lifespan = 0.0);

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
 * Applies a cooldown to an ability slot, given a set of parameters.
 *
 * @param client		The client to set the cooldown of.
 * @param duration		The duration the ability should be placed on cooldown.
 * @param type			The slot which should be placed on cooldown. If ult is blocked, you will also be unable to gain ult charge.
 * @param override		If true, this new cooldown will completely override any existing cooldowns. Otherwise, it is simply added to the current cooldown.
 * @param delay 		Set to true to delay the cooldown application by one frame so it doesn't interfere with other cooldown application sources. Enabled by default.
 *
 */
native CF_ApplyAbilityCooldown(int client, float duration, CF_AbilityType type, bool override = false, bool delay = true);

/**
 * Retrieves the remaining cooldown of the client's given ability slot.
 *
 * @param client		The client to set the cooldown of.
 * @param type			CF_AbilityType pertaining to the given slot.
 *
 */
native float CF_GetAbilityCooldown(int client, CF_AbilityType type);

/**
 * Activates a given ability, if it exists on the character.
 *
 * @param client		The client whose ability to activate.
 * @param pluginName			The plugin name of the ability, as specified in the config as "plugin_name".
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
 * Gets the chosen client's viewchange type.
 *
 * @param client		The client whose viewchange to check.
 *
 * @return A CF_ViewChangeType representing the client's viewchange.
 */
native CF_ViewChangeType CF_GetViewChangeType(int client);

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
 * @param damage				The optional damage dealt to trigger this sound, used by sound_bighit.
 *
 * @return		True if the sound was played, false otherwise.
 */
native bool CF_PlayRandomSound(int source, char Config[255], char Sound[255], float damage = 0.0)