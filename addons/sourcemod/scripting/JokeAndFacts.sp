#include <sourcemod>
#include <sdktools>
#include <ripext>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.2"

ConVar jf_enablejokes;
ConVar jf_enablefacts;
ConVar jf_enablequotes;
ConVar jf_automatic_facts;
ConVar jf_automatic_jokes;
ConVar jf_automatic_quotes;
ConVar jf_jokes_timer;
ConVar jf_facts_timer;
ConVar jf_quotes_timer;
Handle autojokes;
Handle autofacts;
Handle autoquotes;

public Plugin myinfo = 
{
	name = "Random jokes, facts & quotes",
	author = "Nathy",
	description = "Get some random jokes, facts and quotes",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/nathyzinhaa"
};

public void OnPluginStart()
{   
    RegConsoleCmd("sm_joke", Command_joke);
    RegConsoleCmd("sm_fact", Command_facts);
    RegConsoleCmd("sm_quote", Command_quotes);
    RegConsoleCmd("sm_jokes", Command_joke);
    RegConsoleCmd("sm_facts", Command_facts);
    RegConsoleCmd("sm_quotes", Command_quotes);
    jf_enablejokes = CreateConVar("sm_enable_jokes", "1");
    jf_enablefacts = CreateConVar("sm_enable_facts", "1");
    jf_enablequotes = CreateConVar("sm_enable_quotes", "1");
    jf_automatic_facts = CreateConVar("sm_automatic_facts", "1");
    jf_automatic_jokes = CreateConVar("sm_automatic_jokes", "1");
    jf_automatic_quotes = CreateConVar("sm_automatic_quotes", "1");
    jf_jokes_timer = CreateConVar("sm_jokestimer", "1380");
    jf_facts_timer = CreateConVar("sm_factstimer", "1080");
    jf_quotes_timer = CreateConVar("sm_quotestimer", "780");
    AutoExecConfig(true, "JokeAndFacts");
}

public void OnConfigsExecuted()
{
    RestartFactsTimer();
    RestartJokesTimer();
    RestartQuotesTimer();
}

void OnFactsReceived(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) {
        return;
    }

    JSONObject facts = view_as<JSONObject>(response.Data);

    char fact[256];
    facts.GetString("fact", fact, sizeof(fact));

    PrintToChatAll("\x01 \x04[Fact] \x01%s", fact);
} 

void OnJokesReceived(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) {
        return;
    }

    JSONObject jokes = view_as<JSONObject>(response.Data);

    char joke[256];
    jokes.GetString("joke", joke, sizeof(joke));

    PrintToChatAll("\x01 \x04[Joke] \x01%s", joke);
}

void OnQuotesReceived(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) {
        return;
    }

    JSONObject quotes = view_as<JSONObject>(response.Data);

    char quote[256];
    quotes.GetString("quote", quote, sizeof(quote));

    PrintToChatAll("\x01 \x04[Quote] \x01%s", quote);
} 

public Action Command_joke(int client, int args)
{
	if(GetConVarInt(jf_enablejokes) == 1)
	{
    HTTPRequest jokereq = new HTTPRequest("https://api.popcat.xyz/joke");
    
    jokereq.Get(OnJokesReceived);
    }
}

public Action Command_facts(int client, int args)
{
	if(GetConVarInt(jf_enablefacts) == 1)
	{
    HTTPRequest factreq = new HTTPRequest("https://api.popcat.xyz/fact");
    factreq.Get(OnFactsReceived);
    }
}

public Action Command_quotes(int client, int args)
{
	if(GetConVarInt(jf_enablequotes) == 1)
	{
    HTTPRequest quotereq = new HTTPRequest("https://api.popcat.xyz/quote");
    quotereq.Get(OnQuotesReceived);
    }
}
// https://api.popcat.xyz/quote
public Action factstimer(Handle timer)
{
	if(GetConVarInt(jf_automatic_facts) == 1)
	{
	    HTTPRequest factreq = new HTTPRequest("https://api.popcat.xyz/fact");
	    factreq.Get(OnFactsReceived);
	}
}

public Action jokestimer(Handle timer)
{
	if(GetConVarInt(jf_automatic_jokes) == 1)
    {
	    HTTPRequest jokereq = new HTTPRequest("https://api.popcat.xyz/joke");
	    jokereq.Get(OnJokesReceived);
    }
}

public Action quotestimer(Handle timer)
{
	if(GetConVarInt(jf_automatic_quotes) == 1)
	{
	    HTTPRequest quotereq = new HTTPRequest("https://api.popcat.xyz/quote");
	    quotereq.Get(OnQuotesReceived);
	}
}

void RestartFactsTimer()
{
    delete autofacts;
    autofacts = CreateTimer(float(jf_facts_timer.IntValue), factstimer, _, TIMER_REPEAT);
}

void RestartJokesTimer()
{
    delete autojokes;
    autojokes = CreateTimer(float(jf_jokes_timer.IntValue), jokestimer, _, TIMER_REPEAT);
}

void RestartQuotesTimer()
{
    delete autoquotes;
    autoquotes = CreateTimer(float(jf_quotes_timer.IntValue), quotestimer, _, TIMER_REPEAT);
}

