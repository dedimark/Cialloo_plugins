#include <sourcemod>
#include <morecolors>

public Plugin myinfo =
{
    name = "advertisement",
    author = "cialloo",
    description = "send ad to player",
    version = "1.0",
    url = "https://www.cialloo.com"
};

public void OnClientPutInServer(int client)
{
    CreateTimer(45.0, Timer_SendAdvertisement, client);
}

public Action Timer_SendAdvertisement(Handle Timer, int client)
{
    if(client 
    && IsClientConnected(client) 
    && !IsFakeClient(client) 
    && !IsClientSourceTV(client)
    && !IsClientReplay(client))
        CPrintToChat(client, "{green}Visit our website: {blue}https://cs.cialloo.com\n");
}