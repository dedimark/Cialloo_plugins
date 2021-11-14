#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>

#define VERSION "1.0.0"

enum
{
    ALERT,
    ANNOUCEMENT,
    WEAPONAWP,
    WEAPONSG550,
    WEAPONG3SG1
};

enum    //define limited weapon's price
{
    AWPPRICE = 4750,
    SG550PRICE = 5000,
    G3SG1PRICE = 5000
};

char STRING[][] =
{
    //notification
    "您必须活着才能购买武器!",
    "\x04awp需要按E键购买,费用4750\nawp需要按E键购买,费用4750\n提供反馈、建议qq群486716091",
    //weapon name
    "大狙",
    "警连狙",
    "匪连狙"
};

public Plugin myinfo =
{
    name = "limit specific weapon in deathmatch game mode",
    author = "达达",
    description = "limit-weapon",
    version = VERSION,
    url = "https://www.cialloo.com"
};

public OnPluginStart()
{
    //Regist some commands.
    RegConsoleCmd("sm_awp", Cmd_GetAwp);
    RegConsoleCmd("sm_sg550", Cmd_GetSg550);
    RegConsoleCmd("sm_g3sg1", Cmd_GetG3sg1);

    HookEvent("player_spawn", Event_PlaySpawn);     //place player in buy zone
}

//Notification.When client connect to this deathmatch server, tell them how to get thoses limited weapons.
public OnClientPutInServer(client)
{
    CreateTimer(10.0, Timer_Annoncement, client);
}

public void Event_PlaySpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    SDKHook(client, SDKHook_PostThinkPost, Hook_PostThinkPost);
}

public Hook_PostThinkPost(entity)
{
    SetEntProp(entity, Prop_Send, "m_bInBuyZone", 1);       // player in buyzone everywhere
}

public Action Timer_Annoncement(Handle timer, int client)
{
    if(IsClientConnected(client) && !IsFakeClient(client))
        PrintToChat(client, "%s", ANNOUCEMENT);

    return Plugin_Handled;
}

public Action Cmd_GetAwp(int client, int args)
{
    if(IsPlayerAlive(client))
    {
        int clientCash = GetEntProp(client, Prop_Send, "m_iAccount");

        if(clientCash < AWPPRICE)       
        {
            PrintToChat(client, "\x04一把%s要%d块!", STRING[WEAPONAWP], AWPPRICE);
            return Plugin_Handled;
        } else {
            int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);

            if(slot != -1)
            {
                RemovePlayerItem(client, slot);
                AcceptEntityInput(slot, "Kill");
            }

            GivePlayerItem(client, "weapon_awp");
            SetEntProp(client, Prop_Send, "m_iAccount", clientCash - AWPPRICE);
        }
    } else {
        PrintToChat(client, "%s", ALERT);
    }

    return Plugin_Handled;
}

public Action Cmd_GetG3sg1(int client, int args)
{
    if(IsPlayerAlive(client))
    {
        int clientCash = GetEntProp(client, Prop_Send, "m_iAccount");

        if(clientCash < G3SG1PRICE)       
        {
            PrintToChat(client, "\x04一把%s要%d块!", STRING[WEAPONG3SG1], G3SG1PRICE);       //change later.
            return Plugin_Handled;
        } else {
            int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);

            if(slot != -1)
            {
                RemovePlayerItem(client, slot);
                AcceptEntityInput(slot, "Kill");
            }

            GivePlayerItem(client, "weapon_awp");
            SetEntProp(client, Prop_Send, "m_iAccount", clientCash - G3SG1PRICE);
        }
    } else {
        PrintToChat(client, "%s", ALERT);
    }

    return Plugin_Handled;
}

public Action Cmd_GetSg550(int client, int args)
{
    if(IsPlayerAlive(client))
    {
        int clientCash = GetEntProp(client, Prop_Send, "m_iAccount");

        if(clientCash < SG550PRICE)       
        {
            PrintToChat(client, "\x04一把%s要%d块!", STRING[WEAPONSG550], SG550PRICE);     //change later
            return Plugin_Handled;
        } else {
            int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);

            if(slot != -1)
            {
                RemovePlayerItem(client, slot);
                AcceptEntityInput(slot, "Kill");
            }

            GivePlayerItem(client, "weapon_awp");
            SetEntProp(client, Prop_Send, "m_iAccount", clientCash - SG550PRICE);
        }
    } else {
        PrintToChat(client, "%s", ALERT);
    }

    return Plugin_Handled;
}