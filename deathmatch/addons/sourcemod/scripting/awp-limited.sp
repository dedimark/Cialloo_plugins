#include <sourcemod>
#include <cstrike>
#include <sdktools>

int g_button[MAXPLAYERS + 1];

public Plugin myinfo =
{
    name = "ciallo_dmawp",
    author = "cialloo",
    description = "limitted the awp",
    version = "1.0",
    url = "https://www.cialloo.com"
};

public OnPluginStart()
{
    //Regist some commands.
    RegConsoleCmd("sm_awp", Cmd_GetAwp);
    RegConsoleCmd("sm_sg550", Cmd_GetSg550);
    RegConsoleCmd("sm_g3sg1", Cmd_GetG3sg1);
}

//Notification.When client connect to this deathmatch server, tell them how to get thoses limited weapons.
public OnClientPutInServer(client)
{
    CreateTimer(10.0, Timer_Annoncement, client);
}


public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    if((buttons & IN_USE) && !(g_button[client] & IN_USE))
    {
        g_button[client] = g_button[client] | IN_USE;
        ClientCommand(client, "sm_awp");
    }

    if(!(buttons & IN_USE) && g_button[client] & IN_USE)
    {
        g_button[client] = g_button[client] &~ IN_USE;
    }
}

public Action Command_GetAwp(int client, int args)
{
    if(IsPlayerAlive(client))
    {
        int clientCash = GetEntProp(client, Prop_Send, "m_iAccount");

        if(clientCash < 4750)
        {
            PrintToChat(client, "\x04一把大狙要4750块!");
            return Plugin_Handled;
        } else {
            int slot = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);

            if(slot != -1)
            {
                RemovePlayerItem(client, slot);
                AcceptEntityInput(slot, "Kill");
            }

            GivePlayerItem(client, "weapon_awp");
            SetEntProp(client, Prop_Send, "m_iAccount", clientCash - 4750);
        }
    } else {
        PrintToChat(client, "您必须活着!");
    }

    return Plugin_Handled;
}

public Action Timer_Annoncement(Handle timer, int client)
{
    if(IsClientConnected(client) && !IsFakeClient(client))
        PrintToChat(client, "\x04awp需要按E键购买,费用4750\nawp需要按E键购买,费用4750\n提供反馈、建议qq群486716091");

    return Plugin_Handled;
}