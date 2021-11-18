#include <sourcemod>

#define EXTENDTIME 1200
#define EXTCHANCE 2

int gI_PlayerExtChance[MAXPLAYERS + 1];

bool gB_PlayerReturn[MAXPLAYERS + 1];

public OnPluginStart()
{
    RegConsoleCmd("sm_ext", Cmd_Ext);
}

public OnMapStart()
{
    for(int i = 0; i < MAXPLAYERS + 1; i++)
    {
        gB_PlayerReturn[i] = false;
    }
}

public OnClientPutInServer(client)
{
    if(!gB_PlayerReturn[client])
    {
        gB_PlayerReturn[client] = true;
        gI_PlayerExtChance[client] = EXTCHANCE;
    }
}

public Action Cmd_Ext(int client, int args)
{
    if(gI_PlayerExtChance[client])
    {
        gI_PlayerExtChance[client]--;
        ExtendMapTimeLimit(EXTENDTIME);
    }
    else
    {
        ReplyToCommand(client, "您的延长次数已用完");
    }
}