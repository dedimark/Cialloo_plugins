#include <sourcemod>
#include <qqbot>
#include <shavit>

public void Shavit_OnWorldRecord(int client, int style, float time, int jumps, int strafes, float sync, int track, float oldwr, float oldtime, float perfs, float avgvel, float maxvel, int timestamp)
{
    char steamid[32], mapname[64], stylename[36], message[1024];
    GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
    GetCurrentMap(mapname, sizeof(mapname));
    Shavit_GetStyleStrings(style, sStyleName, stylename, sizeof(stylename));

    FormatEx(message, sizeof(message),
    "\
    # New Bhop Record! #\n\
    玩家: %N\n\
    Steamid: %s\n\
    地图: %s\n\
    时间: %.3f\n\
    模式: %s\n\
    跳跃: %d\n\
    加速: %d\n\
    同步率: %f\%", 
    client, 
    steamid,
    mapname, 
    time, 
    stylename,
    jumps, 
    strafes, 
    sync);

    MessageToQQGroup("285620437", message);
}