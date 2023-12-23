/*
This basic plugin template exists to provide devs with an easy starting point for their character plugins, to get all of the annoying tedious work out of the way.
To use this template, just replace the placeholder text (MY_PLUGIN, MY_ABILITY, cf_plugin_template, etc) with whatever you need. Then, you can add any missing
forwards your plugin needs as you work.
*/

#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define MY_PLUGIN		"cf_plugin_template"
#define MY_ABILITY		"cf_example_ability"

//Precache all of your plugin-specific sounds and models here.
public void OnMapStart()
{
}

//Hook your events in here.
public void OnPluginStart()
{
}

//This forward is called when an ability is activated. It is best used to check if the ability being activated is
//one of our plugin's abilities, so that our plugin can read that ability's variables and act as such.
public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	//The activated ability's plugin is not this plugin, don't do anything.
	if (!StrEqual(pluginName, MY_PLUGIN))
		return;
	
	//The activated ability belongs to our plugin, check to see which ability it is.	
	if (StrContains(abilityName, MY_ABILITY) != -1)
	{
		//The ability which was activated was "cf_example_ability", send the client's index and the ability's name to a
		//separate method to apply the ability's effects.
		My_Ability_Activate(client, abilityName);
	}
}

//This is a custom ability activation method, used by this plugin. In a real character plugin, this is where you would
//read the ability's variables via the "CF_GetArg" natives and apply its special effects. For example, if our ability
//shoots a rocket with customizable damage, this is where we would read the ability's args from the config to get the
//rocket's damage and then shoot it.
public void My_Ability_Activate(int client, char abilityName[255])
{
}

//When a player becomes a character, this forward is called. This forward is best used for passive abilities.
//For example, if our character plugin contains a passive ability that gives the character low gravity, we would
//read the passive ability's variables and apply them in here.
public void CF_OnCharacterCreated(int client)
{
}

//When a player's character is removed (typically when they die or leave the match), this forward is called.
//This forward is best for cleaning up variables used by your ability. For example, if our character plugin
//contains a passive ability that attaches a particle to the character, we would remove that particle in here
//to prevent it from following the player's spectator camera while they're dead.
public void CF_OnCharacterRemoved(int client)
{
}