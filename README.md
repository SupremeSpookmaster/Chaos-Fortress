# *NOTICE*
This game mode is currently incompatible with 64-bit servers. I am in the process of reducing gamedata usage so that everything will remain entirely functional when 32-bit is deprecated, but this will take some time. This notice will be deleted when compatibility issues are resolved.

# *Introducing (eventually because this is not done yet) Chaos Fortress: TF2 with custom classes!*
***Chaos Fortress*** is just like normal TF2, but with a twist: instead of playing as one of the nine mercenaries, players step into the shoes of one of many custom characters, each with their own unique kit. Some of these characters are designed to function like suped-up versions of the nine mercenaries, while others act more as wildcards, going their own directions entirely. To top it all off, all of these characters have access to powerful Ultimate Abilities, which charge very slowly over time, or by meeting certain conditions such as dealing damage or healing allies. As for developers, CF is incredibly dev-friendly, coming packed with countless forwards and natives to make the creation of new custom characters a breeze.

***Chaos Fortress*** is a game mode inspired by one of my previous developer ventures: **Boss VS Boss**. It was an old, private game mode, centered around **[the highly talented Batfoxkid's _FF2 Rewrite_](https://github.com/Batfoxkid/Freak-Fortress-2-Rewrite)**, in which every player took control of a Freak Fortress boss and fought alongside their team to kill everybody on the enemy team in the Arena game mode. In addition to being every bit as insane as it sounds, most of the bosses in BvB could get VERY complex, which made the game mode nightmarishly unfriendly to beginners and incredibly difficult to balance. BvB was also plagued by numerous glitches and poor game design practices, to the extent where I finally decided it was time to wipe the slate clean and use what I learned to make something bigger and better. And so, ***Chaos Fortress*** was born!
 
## *Installation Guide:*
  1. Install all of the **[prerequisites](https://github.com/SupremeSpookmaster/Chaos-Fortress#prerequisites)**.
  2. Download the **latest release Installation Build. (LINK PENDING)**
  3. Extract the zip file directly to your server's `tf` folder.
  4. ***Chaos Fortress*** should now be installed on your server!
  5. Configure the game mode to your heart's content. *(Optional)*

## *Update Guide*
  1. Download the **latest release Update Build. (LINK PENDING)** Alternatively, if you do not want to add any new characters that the update may include, download the **latest release No-Characters Update Build. (LINK PENDING)**
  2. Extract the zip file directly to your server's `tf` folder. If you did not choose the no-characters build, you will notice these files: `tf/addons/sourcemod/data/fake_particle_system/fakeparticles.cfg` and `tf/addons/sourcemod/data/pnpc/npcs.cfg`. These files should be skipped, instead see step 3 to know how to handle them. These files do not exist in the no-characters build, so step 3 can be skipped if that is the build you chose.
  3. Some updates will include new characters, and some of these new characters may add new "fake particles" and/or NPCs. When this is the case, if you have made any edits to your server's `fakeparticles.cfg` or `npcs.cfg` files, simply add the new data from the update build's CFGs to your versions. Otherwise, if you have not made any edits, you may simply overwrite your current versions of these files with the new versions.
  4. ***Chaos Fortress*** should now be updated on your server!

## *Prerequisites:*
- **[SourceMod 1.13.7216+](https://www.sourcemod.net/downloads.php)**
- **[TF2Attributes 1.7.0+](https://github.com/FlaminSarge/tf2attributes)**
- **[TF2Items](https://builds.limetech.io/?project=tf2items)**
- **[TF2 Econ Data](https://github.com/nosoop/SM-TFEconData)**
- **[TF2 Econ Dynamic](https://github.com/nosoop/SMExt-TFEconDynamic)**
- **[TF2 Utils](https://github.com/nosoop/SM-TFUtils)**
- **[CollisionHook](https://github.com/voided/CollisionHook)**
- **[SteamWorks](https://users.alliedmods.net/~kyles/builds/SteamWorks/)**
- **[TF2 Custom Attributes](https://forums.alliedmods.net/showthread.php?p=2703773)**
- **[Taunt Gamedata For Sensal](https://raw.githubusercontent.com/FlaminSarge/tf_tauntem/master/tf2.tauntem.txt)** ***TODO: Add this gamedata to CF's gamedata and remove this from prerequisites.***
- **[Fake Particle System](https://github.com/SupremeSpookmaster/Fake-Particle-System)** - Note that you will need to use the version of `data/fake_particle_system/fakeparticles.cfg` which comes packaged with ***Chaos Fortress***, and not the version included in the release build of the Fake Particle System. ***TODO: Use tryincludes and move to recommended.***
- **[TF2 World Text Helper](https://github.com/SupremeSpookmaster/TF2-World-Text-Helper)** ***TODO: Use tryincludes and move to recommended.***
- **[CBaseNPC](https://github.com/TF2-DMB/CBaseNPC)**
- **RECOMMENDED: [TF2 Weaponmodel Override](https://github.com/Zabaniya001/TF2CA-weaponmodel_override)** - Not required to function, but is used by many default characters. ***TODO: Port all features to CF and remove this from prerequisites.***
- **RECOMMENDED: [TF2 Move Speed Unlocker](https://forums.alliedmods.net/showthread.php?p=2659562)** - Not required to function, but makes certain character techniques more fun. ***TODO: Port all features to CF and remove this from prerequisites.***
- **RECOMMENDED: [Queue.inc](https://forums.alliedmods.net/showthread.php?t=319495)** - Not required to function, but *is* required to compile the plugin.
- **RECOMMENDED: [FF2Rewrite's version of cfgmap.inc](https://github.com/Batfoxkid/Freak-Fortress-2-Rewrite/blob/74584d3792ed35c34a09623ab2ea75bfffa82d5b/addons/sourcemod/scripting/include/cfgmap.inc)** - Not required to function, but *is* required to compile the plugin.
- **RECOMMENDED: Enable Halloween Mode.** You can do this however you want, be it through a plugin or just setting the cvar, but I highly recommend you enable Halloween mode so that your characters can take full advantage of the built-in wearables system. ***TODO: Make this an option in gamerules.cfg remove from prerequisites.***
- **RECOMMENDED: [Portable NPC System](https://github.com/SupremeSpookmaster/TF2-Portable-NPC-System)** - Not needed for base functionality, but Gadgeteer will not work without this. Also highly recommended for its custom melee hitreg.

## *Making Custom Characters*
***Chaos Fortress*** comes with a number of pre-made custom characters, but what if that's not enough? What if you want *more*? Don't worry, because Chaos Fortress has you covered: ***if you know how to make a Freak Fortress boss, you'll know how to make a Chaos Fortress character!*** And even if you don't, don't worry; it's not very difficult to figure out if you're experienced with SourceMod development. Most of my experience as a SourceMod developer comes from making Freak Fortress bosses, and I knew most of the developers who might take an interest in this game mode would be similar, so I was very careful to keep the development process for ***Chaos Fortress*** characters as close to that of ***Freak Fortress*** characters as possible.
  - Look at **[mercenary.cfg](https://github.com/SupremeSpookmaster/Chaos-Fortress/blob/main/addons/sourcemod/configs/chaos_fortress/mercenary.cfg)** to see an example of a ***Chaos Fortress*** character CFG.
    - *This file doubles as a character CFG template. Feel free to use it to speed up the development of your characters!*
  - Look at **[cf_mercenary.sp](https://github.com/SupremeSpookmaster/Chaos-Fortress/blob/main/addons/sourcemod/scripting/cf_mercenary.sp)** to see an example of a basic ***Chaos Fortress*** character plugin.
  - Look at **[cf_plugin_template.sp](https://github.com/SupremeSpookmaster/Chaos-Fortress/blob/main/addons/sourcemod/scripting/cf_plugin_template.sp)** for a ***Chaos Fortress*** character plugin template to speed up the development of your characters!
  - Character plugins MUST be placed inside of the `cf_subplugins` sub-folder, and MUST use the `.cf2` file extension.
  - Please note that despite the similarities in their development process, FF2 plugins and configs will ***not*** work for ***Chaos Fortress*** characters.
  - **I *HIGHLY* recommend you refer to the [_Developer Forwards and Natives_ wiki page](https://github.com/SupremeSpookmaster/Chaos-Fortress/wiki/Developer-Forwards-and-Natives) and follow its guidance if you intend to write character plugins.**
    - *Ignoring this wiki page will not break ***Chaos Fortress***, but it will harm your server's organization and may result in awkward issues stemming from plugin execution order. **Ignore at your own peril!***

## *Configuring Active Characters and Packs*
Let's say you want to add or remove a character, or you have a handful of characters you want to be able to activate or deactivate on demand. This is exactly what the character packs system is for.
  - Look at **[characters.cfg](addons/sourcemod/data/chaos_fortress/characters.cfg)** for an example of how to use the character packs system.
  - All characters must be located in **addons/sourcemod/configs/chaos_fortress**.
      - *Sub-directories **are** allowed.*
   
## *Game Mode Configuration Options*
All configurable options specific to this game mode are described in and can be controlled in **[game_rules.cfg](addons/sourcemod/data/chaos_fortress/game_rules.cfg)**.

## *Programming Credits*
Though I do consider myself to be a decent programmer, I have never made a game mode before. As such, I encountered a lot of hurdles during development which, try as I might, I couldn't get over with my existing skill set. For these, I turned to a handful of fellow developers for a helping hand. Without those who are listed here, this mod would be nowhere near my fairly lofty quality standards, and in some cases, would never have even been finished in the first place. Words cannot express my gratitude to these people.
<details>

<summary>Click to view programming credits.</summary>

  - **[Artvin](https://github.com/artvin01)** and **[Batfoxkid](https://github.com/Batfoxkid)**, the creators of ***[TF2 Zombie Riot](https://github.com/artvin01/TF2-Zombie-Riot)***, which I borrowed code from at certain points; practically the entire NPC system was created by reverse-engineering Zombie Riot's NPC base.
  - **[Zabaniya001, AKA Suza](https://github.com/Zabaniya001/Zabaniya001)**, for offering various tips and tricks, help regarding code cleanliness and performance, lots of help with unfamiliar coding territory.
  - **[CookieCat](https://github.com/CookieCat45)**, for help with finding netprops when I was unable to find them myself.
  - **[Jakub/ficool2](https://github.com/ficool2)**, for consistently offering helpful advice on a range of topics.
  - ...And of course, myself: **[Spookmaster](https://github.com/SupremeSpookmaster)** (Lead Dev, Game Mode Creator, All Default Characters)
</details>

## *Content Credits*
No matter how good you are at programming, you're not going to get very far in game development if you don't have good assets. As I like to say: without a programmer, you don't have a game, but without the rest of the crew, you don't have a good game. As such, in making the default characters for Chaos Fortress, I made thorough use of TF2's long history of content mods to cover assets that couldn't be handled by the files available in base TF2. And so, just like with this game mode's programmers, I want to take a moment to give full credit to the original creators of all of the assets I repurposed for this project.
<details>

<summary>Click to view content credits.</summary>

### Mercenary
 - **[DannyBoi151](https://gamebanana.com/members/1382615)** and **[stiffy360](https://gamebanana.com/members/707880)** (ported the **[Fruit Shop Fiend](https://gamebanana.com/mods/197791)** to TF2, which I used for Mercenary's assault rifle)
 - **[Stachekip](https://www.youtube.com/user/Stachekip)** (Voice actor for the Mercenary from **[Open Fortress](https://openfortress.fun/)**, whom CF's Mercenary gets his voice from)
### Spookmaster Bones
 - **[Vargskelethor, AKA Vinesauce Joel](https://www.twitch.tv/vargskelethor)** (Voice)
 - **[The 14th Doctor](https://gamebanana.com/members/1448519)** (Creator of the **[Vinesauce Joel Over Soldier Voice Pack](https://gamebanana.com/sounds/46534)** mod which I took specific sound clips from for dialogue)
### Christian Brutal Sniper
 - **Kekas vas Normandy** (Character Creator, link missing due to channel takedown)
 - **Badass** (Created the team-colored skins)
### Demopan
 - **[ichbinpwnzilla](https://www.reddit.com/r/tf2/comments/ensgh/the_new_face_of_tf2/)** (Character Creator)
</details>
