#include <sourcemod>
#include <morecolors>

Handle g_timer[MAXPLAYERS];

public Plugin myinfo =
{
    name = "advertisement",
    author = "cialloo",
    description = "send ad to player",
    version = "1.0",
    url = "https://www.cialloo.com"
};

public void OnPluginStart()
{
    for(int i = 0; i < MAXPLAYERS; i++)
        g_timer[i] = INVALID_HANDLE;
}

public void OnClientPutInServer(int client)
{
    if(g_timer[client] == INVALID_HANDLE)
        g_timer[client] = CreateTimer(45.0, Timer_SendAdvertisement, client);
}

public Action Timer_SendAdvertisement(Handle Timer, int client)
{
    if(client 
    && IsClientConnected(client) 
    && !IsFakeClient(client) 
    && !IsClientSourceTV(client)
    && !IsClientReplay(client))
        CPrintToChat(client, "{green}Visit our website: {blue}https://cs.cialloo.com\n");

    g_timer[client] = INVALID_HANDLE;
}