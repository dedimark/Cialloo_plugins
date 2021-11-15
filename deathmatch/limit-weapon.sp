#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>

#define VERSION "1.0.0"

bool gb_IsValidBuyTime[MAXPLAYERS];     // when the player can call specific weapon menu

int gi_KeyBuffer[MAXPLAYERS];  

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
    "\x04复活后按下蹲键选择大狙和连狙。\n提供反馈、建议qq群486716091",
    //weapon name
    "大狙",
    "警连狙",
    "匪连狙"
};

public Plugin myinfo =
{
    name = "limit-weapon",
    author = "达达",
    description = "limit specific weapon in deathmatch game mode",
    version = VERSION,
    url = "https://www.cialloo.com"
};

public OnPluginStart()
{
    //Regist some commands.
    RegConsoleCmd("sm_awp", Cmd_GetAwp);
    RegConsoleCmd("sm_sg550", Cmd_GetSg550);
    RegConsoleCmd("sm_g3sg1", Cmd_GetG3sg1);
    RegConsoleCmd("sm_limitedguns", Cmd_LimittedGuns);

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
    gb_IsValidBuyTime[client] = true;
    CreateTimer(3.5, Timer_BuyTimeOver, client);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    if(IsPlayerAlive(client))
    {
        if((buttons & IN_DUCK) && !(gi_KeyBuffer[client] & IN_DUCK) && gb_IsValidBuyTime[client])
        {
            gi_KeyBuffer[client] = gi_KeyBuffer[client] | IN_DUCK;
            ClientCommand(client, "sm_limitedguns");
        }
        else if(!(buttons & IN_DUCK) && gi_KeyBuffer[client] & IN_DUCK)
        {
            gi_KeyBuffer[client] = gi_KeyBuffer[client] & ~IN_DUCK;
        }
    }
}

public Action Timer_Annoncement(Handle timer, int client)
{
    if(IsClientConnected(client) && !IsFakeClient(client))
        PrintToChat(client, "%s", ANNOUCEMENT);

    return Plugin_Handled;
}

public Action Timer_BuyTimeOver(Handle timer, int client)
{
    gb_IsValidBuyTime[client] = false;
}

public int Menu_LimittedWeaponMenu(Menu menu, MenuAction action, int param1, int param2)
{
    if(action == MenuAction_Select)
    {
        switch(param2)
        {
            case 0:
                ClientCommand(param1, "sm_awp");
            case 1:
                ClientCommand(param2, "sm_sg550");
            case 2:
                ClientCommand(param1, "sm_g3sg1");
        }
    }
}

// Create menu
public Action Cmd_LimittedGuns(int client, int args)
{
    Menu weaponmenu = new Menu(Menu_LimittedWeaponMenu);
    weaponmenu.AddItem(STRING[2], STRING[2]);
    weaponmenu.AddItem(STRING[3], STRING[3]);
    weaponmenu.AddItem(STRING[4], STRING[4]);
    weaponmenu.ExitButton = false;
    weaponmenu.Display(client, 20);
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

            GivePlayerItem(client, "weapon_g3sg1");
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

            GivePlayerItem(client, "weapon_sg550");
            SetEntProp(client, Prop_Send, "m_iAccount", clientCash - SG550PRICE);
        }
    } else {
        PrintToChat(client, "%s", ALERT);
    }

    return Plugin_Handled;
}