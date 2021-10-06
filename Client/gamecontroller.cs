using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using SimpleJSON;
using UnityEngine.UI;
using UnityEditor;
using System;
using System.Linq;

public class gamecontroller : MonoBehaviour
{
    public int gameid;
    public int lastmessagenumber;
    public ClientControl cc;
    public int weare;
    public int opponent;
    public int turn;
    public TextMeshProUGUI name1;
    public TextMeshProUGUI health1;
    public TextMeshProUGUI bodies1;
    public GameObject position;
    public GameObject position2;
    public TextMeshProUGUI name2;
    public TextMeshProUGUI health2;
    public TextMeshProUGUI bodies2;
    public GameObject logfield;
    public GameObject logprefab;
    public Image[] wheelimage1;
    public Button turnbutton;
    public TextMeshProUGUI gold;
    public TextMeshProUGUI ogold;
    public TextMeshProUGUI threshold_fire;
    public TextMeshProUGUI threshold_earth;
    public TextMeshProUGUI threshold_air;
    public TextMeshProUGUI threshold_water;
    public TextMeshProUGUI othreshold_fire;
    public TextMeshProUGUI othreshold_earth;
    public TextMeshProUGUI othreshold_air;
    public TextMeshProUGUI othreshold_water;
    public TextMeshProUGUI targettext;
    public TextMeshProUGUI leveldisplay;
    public TextMeshProUGUI oppleveldisplay;

    public GameObject cardinhandprefab;
    public GameObject cardinplayprefab;
    public GameObject handfield;
    public JSONNode gamedata;
    public Canvas parentcanvas;
    public Dictionary<string, JSONNode> handplayable = new Dictionary<string, JSONNode>();
    public JSONNode forceplayable = null;

    public Dictionary<string, bool> highlight = new Dictionary<string, bool>();
    public Dictionary<string, JSONNode> objectsinplay = new Dictionary<string, JSONNode>();
    private Dictionary<int, bool> messagesproccessed = new Dictionary<int, bool>();
    public Image highlightall;
    public Image lane1;
    public Image lane2;
    public Image lane3;
    public Image lane4;
    public Image lane5;
    public Image olane1;
    public Image olane2;
    public Image olane3;
    public Image olane4;
    public Image olane5;
    public ScrollRect scrollRect;
    public bool targetting = false;
    public cardinhand selectedinhand = null;
    public cardinplay selectedinplay = null;
    private bool forcescrolldown = false;
    public List<String> targets = new List<string>();
    public int targetindex;
    public JSONNode targetinfo;
    public GameObject wonbanner;
    public GameObject lostbanner;
    public GameObject[] wheelhighlights;
    public GameObject fullcarddisplay;
    public cardinhand[] displaycards;

    public TextMeshProUGUI level;
    public TextMeshProUGUI olevel;
    public GameObject extratargetsdisplay;
    public GameObject extratargetscards;
    public IEnumerator playcard(string card, List<String> target)
    {
        GAMEAPI gapi = new GAMEAPI();
        WWWForm form = new WWWForm();
        form.AddField("game", gameid);
        form.AddField("card", card);
        string targetstring = "[";
        foreach (var item in target)
        {
            targetstring += "\""+item+"\",\n";
        }

        targetstring += "\"\"]";
        form.AddField("target", targetstring);
        form.AddField("startmessage", lastmessagenumber);
        Debug.Log("targetstring: " + targetstring);
        yield return gapi.request("play", form);
        
        Debug.Log("Play: " + gapi.apiResult);
        var data = JSON.Parse(gapi.apiResult);
        if (data["status"].ToString().Contains("failed"))
        {
            cc.showerror(data.ToString());
            yield break;
        }
        parsemessages(data["messages"]);
        Debug.Log(data);

    }
    public IEnumerator playforced(string triggerid, List<String> target)
    {
        GAMEAPI gapi = new GAMEAPI();
        WWWForm form = new WWWForm();
        form.AddField("game", gameid);
        form.AddField("trigger", triggerid);
        string targetstring = "[";
        foreach (var item in target)
        {
            targetstring += "\"" + item + "\",\n";
        }

        targetstring += "\"\"]";
        form.AddField("target", targetstring);
        form.AddField("startmessage", lastmessagenumber);
        Debug.Log("targetstring: " + targetstring);
        yield return gapi.request("forced", form);

        Debug.Log("forced: " + gapi.apiResult);
        var data = JSON.Parse(gapi.apiResult);
        if (data["status"].ToString().Contains("failed"))
        {
            cc.showerror(data.ToString());
            yield break;
        }
        parsemessages(data["messages"]);
        Debug.Log(data);

    }
    public IEnumerator getgamedata()
    {
        GAMEAPI gapi = new GAMEAPI();
        WWWForm form = new WWWForm();
        form.AddField("game", gameid);

        yield return gapi.request("getallgamestat", form);
        
        var data = JSON.Parse(gapi.apiResult);
        gamedata = data["gamedata"];
        if (gamedata["status"].ToString().Contains("failed"))
        {
            cc.showerror(gamedata.ToString());
            yield break;
        }
        
        Debug.Log("gamedata: "+ gamedata.ToString());
        if (gamedata["players"]["1"]["playerid"].AsInt == cc.userid)
        {
            weare = 1;
            opponent = 2;
        } else
        {
            weare = 2;
            opponent = 1;
        }
        if (gamedata["turn"].AsInt == weare )
        {
            //our turn
            turnbutton.interactable = true;
            
        } else
        {
            turnbutton.interactable = false;
            //not our turn
        }
        if (gamedata["objects"].Count > 0)
        {
            foreach (string item in gamedata["objects"].Keys)
            {
                objectsinplay[item] = gamedata["objects"][item];
            }
            Debug.Log(gamedata["objects"].Count);

        }
        if (gamedata["lane"].HasKey(weare.ToString()))
        {
            //make card in play here
            foreach (string item in gamedata["lane"][weare.ToString()].Keys)
            {
                int foo = gamedata["lane"][weare.ToString()][item];
                if (foo == 0){
                    continue;
                }
                if (item.Contains("1"))
                {
                    GameObject go = Instantiate(cardinplayprefab, lane1.transform);
                    cardinplay card = go.GetComponent<cardinplay>();
                    card.setcardnumber(gamedata["lane"][weare.ToString()]["1"]);
                    card.parentcanvas = parentcanvas;
                    card.gamescriptlink = this;
                }
                if (item.Contains("2"))
                {
                    GameObject go = Instantiate(cardinplayprefab, lane2.transform);
                    cardinplay card = go.GetComponent<cardinplay>();
                    card.setcardnumber(gamedata["lane"][weare.ToString()]["2"]);
                    card.parentcanvas = parentcanvas;
                    card.gamescriptlink = this;
                }
                if (item.Contains("3"))
                {
                    GameObject go = Instantiate(cardinplayprefab, lane3.transform);
                    cardinplay card = go.GetComponent<cardinplay>();
                    card.setcardnumber(gamedata["lane"][weare.ToString()]["3"]);
                    card.parentcanvas = parentcanvas;
                    card.gamescriptlink = this;
                }
                if (item.Contains("4"))
                {
                    GameObject go = Instantiate(cardinplayprefab, lane4.transform);
                    cardinplay card = go.GetComponent<cardinplay>();
                    card.setcardnumber(gamedata["lane"][weare.ToString()]["4"]);
                    card.parentcanvas = parentcanvas;
                    card.gamescriptlink = this;
                }
                if (item.Contains("5"))
                {
                    GameObject go = Instantiate(cardinplayprefab, lane5.transform);
                    cardinplay card = go.GetComponent<cardinplay>();
                    card.setcardnumber(gamedata["lane"][weare.ToString()]["5"]);
                    card.parentcanvas = parentcanvas;
                    card.gamescriptlink = this;
                }

            }
        }
        if (gamedata["lane"].HasKey(opponent.ToString()))
        {
            foreach (string item in gamedata["lane"][opponent.ToString()].Keys)
            {
                
                int foo = gamedata["lane"][opponent.ToString()][item];
                if (foo == 0)
                {
                    continue;
                }
                if (item.Contains("1"))
                {
                    GameObject go = Instantiate(cardinplayprefab, olane1.transform);
                    cardinplay card = go.GetComponent<cardinplay>();
                    card.setcardnumber(gamedata["lane"][opponent.ToString()]["1"]);
                    card.parentcanvas = parentcanvas;
                    card.gamescriptlink = this;
                }
                if (item.Contains("2"))
                {
                    GameObject go = Instantiate(cardinplayprefab, olane2.transform);
                    cardinplay card = go.GetComponent<cardinplay>();
                    card.setcardnumber(gamedata["lane"][opponent.ToString()]["2"]);
                    card.parentcanvas = parentcanvas;
                    card.gamescriptlink = this;
                }
                if (item.Contains("3"))
                {
                    GameObject go = Instantiate(cardinplayprefab, olane3.transform);
                    cardinplay card = go.GetComponent<cardinplay>();
                    card.setcardnumber(gamedata["lane"][opponent.ToString()]["3"]);
                    card.parentcanvas = parentcanvas;
                    card.gamescriptlink = this;
                }
                if (item.Contains("4"))
                {
                    GameObject go = Instantiate(cardinplayprefab, olane4.transform);
                    cardinplay card = go.GetComponent<cardinplay>();
                    card.setcardnumber(gamedata["lane"][opponent.ToString()]["4"]);
                    card.parentcanvas = parentcanvas;
                    card.gamescriptlink = this;
                }
                if (item.Contains("5"))
                {
                    GameObject go = Instantiate(cardinplayprefab, olane5.transform);
                    cardinplay card = go.GetComponent<cardinplay>();
                    card.setcardnumber(gamedata["lane"][opponent.ToString()]["5"]);
                    card.parentcanvas = parentcanvas;
                    card.gamescriptlink = this;
                }

            }

        }


            name1.text = gamedata["players"][weare.ToString()]["name"];
        health1.text = gamedata["players"][weare.ToString()]["life"];
        level.text = gamedata["players"][weare.ToString()]["level"]+"-"+ gamedata["players"][weare.ToString()]["levelprogress"];
        bodies1.text = gamedata["players"][weare.ToString()]["bodies"];
        turn = gamedata["turn"].AsInt;
        

        name2.text = gamedata["players"][opponent.ToString()]["name"];
        health2.text = gamedata["players"][opponent.ToString()]["life"];
        bodies2.text = gamedata["players"][opponent.ToString()]["bodies"];
        olevel.text = gamedata["players"][opponent.ToString()]["level"] + "-" + gamedata["players"][opponent.ToString()]["levelprogress"];

        if (gamedata["players"][weare.ToString()] != null)    
        {
            Debug.Log("GAME: we have a not null hand: "+ gamedata["players"][weare.ToString()]);
            foreach (JSONNode item in gamedata["players"][weare.ToString()]["hand"].AsArray)
            {
                GameObject go = Instantiate(cardinhandprefab, handfield.transform);
                cardinhand card = go.GetComponent<cardinhand>();
                card.setcardnumber(item.AsInt);
                card.parentcanvas = parentcanvas;
                card.gamescriptlink = this;

            }
        }
        if (gamedata["players"][weare.ToString()]["gold"] != null)
        {
            gold.text = gamedata["players"][weare.ToString()]["gold"];
        }
        if (gamedata["players"][opponent.ToString()]["gold"] != null)
        {
            ogold.text = gamedata["players"][opponent.ToString()]["gold"];
        }
        if ((gamedata["players"][weare.ToString()]["threshold"] != null) && (!gamedata["players"][weare.ToString()]["threshold"].ToString().Contains("null")))
        {

            foreach (string type in gamedata["players"][weare.ToString()]["threshold"].Keys)
            {
                if (type.Contains("R"))
                {
                    threshold_fire.text = gamedata["players"][weare.ToString()]["threshold"][type];
                }
                if (type.Contains("G"))
                {
                    threshold_earth.text = gamedata["players"][weare.ToString()]["threshold"][type];
                }
                if (type.Contains("P"))
                {
                    threshold_water.text = gamedata["players"][weare.ToString()]["threshold"][type];
                }
                if (type.Contains("T"))
                {
                    threshold_air.text = gamedata["players"][weare.ToString()]["threshold"][type];
                }


            }
        }
        if ((gamedata["players"][opponent.ToString()]["threshold"] != null) && (!gamedata["players"][opponent.ToString()]["threshold"].ToString().Contains("null")))
        {

            foreach (string type in gamedata["players"][opponent.ToString()]["threshold"].Keys)
            {
                if (type.Contains("R"))
                {
                    othreshold_fire.text = gamedata["players"][opponent.ToString()]["threshold"][type];
                }
                if (type.Contains("G"))
                {
                    othreshold_earth.text = gamedata["players"][opponent.ToString()]["threshold"][type];
                }
                if (type.Contains("P"))
                {
                    othreshold_water.text = gamedata["players"][opponent.ToString()]["threshold"][type];
                }
                if (type.Contains("T"))
                {
                    othreshold_air.text = gamedata["players"][opponent.ToString()]["threshold"][type];
                }


            }


        }

        Debug.Log(gamedata["hidden"][weare.ToString()].ToString());
        if (gamedata["forceplay"] != null && gamedata["turn"].AsInt == weare )
        {
            Debug.Log("force play! "+gamedata["forceplay"].ToString());
            forceplayable = gamedata["forceplay"][0];
            if (forceplayable["targets"] == null)
            {
                Debug.Log("We're clearing force playable");
                forceplayable = null;
            }
            else
            {
                Debug.Log("Found forced play");
                targetindex = 0;
                targetinfo = forceplayable["targets"];
                highlighttargets(targetinfo);
                if (forceplayable["revealtargets"])
                {
                    Debug.Log("We need to make a targets display");
                    extratargetsdisplay.SetActive(true);
                    for (int j = 0; j < extratargetscards.transform.childCount; ++j)
                    {
                        Destroy(extratargetscards.transform.GetChild(j).gameObject);
                    }
                    for (int i = 0; i < targetinfo[targetindex]["raw"].Count; i++)
                    {
                        GameObject go = Instantiate(cardinhandprefab, extratargetscards.transform);
                        cardinhand foo = go.GetComponent<cardinhand>();
                        foo.parentcanvas = parentcanvas;
                        foo.gamescriptlink = this;
                        foo.setcardnumber(targetinfo[targetindex]["raw"][i]);
                        
                    }
                    
                }
            }
        }
        if (gamedata["hidden"][weare.ToString()] != null)
        {
            Debug.Log("hidden found:" +gamedata["hidden"][weare.ToString()]);
            if (gamedata["hidden"][weare.ToString()]["moveoptions"])
            {
                string[] wheel = gamedata["hidden"][weare.ToString()]["moveoptions"].ToString().Trim('"').Split(',');
                for (int j = 0; j < wheel.Length; j++)
                {
                    int position = Int32.Parse(wheel[j]);
                    wheelhighlights[position].SetActive(true);

                }
            }
            if (gamedata["hidden"][weare.ToString()]["handplayable"])
            {
                string[] cards = gamedata["hidden"][weare.ToString()]["handplayable"].ToString().Trim('"').Split(';');
                for (int j = 0; j < cards.Length; j++)
                {
                    string separator = ":";

                    int separatorIndex = cards[j].IndexOf(separator);
                    if (separatorIndex > 0)
                    {
                        string result = cards[j].Substring(separatorIndex + separator.Length);
                        Debug.Log("result: " + result);
                        result = result.Replace("\\", "");
                        Debug.Log("Handplayable: " + cards[j].Substring(0, separatorIndex));
                        Debug.Log("result: " + result);

                        handplayable[cards[j].Substring(0, separatorIndex)] = JSON.Parse(result);
                        Debug.Log("handplayable: " + handplayable[cards[j].Substring(0, separatorIndex)].ToString());
                    }
                }
            }
        }
        parsemessageslogonly(data["messages"]);
        InvokeRepeating("getallmessages", 4.0f, 3.0f);

        yield break;

    }
    public void concede()
    {
        StartCoroutine(concede_inner());
    }
    public IEnumerator concede_inner ()
    {
        GAMEAPI gapi = new GAMEAPI();
        WWWForm form = new WWWForm();
        form.AddField("game", gameid);
        form.AddField("startmessage", lastmessagenumber);
        yield return gapi.request("concede", form);
        Debug.Log(gapi.apiResult);
    }
    public void getallmessages()
    {
        StartCoroutine(getmessages());
    }

    public IEnumerator getmessages()
    {
        GAMEAPI gapi = new GAMEAPI();
        WWWForm form = new WWWForm();
        form.AddField("game", gameid);
        form.AddField("startmessage", lastmessagenumber);
        yield return gapi.request("allmessages", form);
        //Debug.Log(gapi.apiResult);
        var data = JSON.Parse(gapi.apiResult);
        if (data["status"] != null)
        {
            if (data["status"].ToString().Contains("failed"))
            {
                cc.showerror(data.ToString());
                yield break;
            }
        }
        if (data["messages"] != null)
        {
            parsemessages(data["messages"]);
        }
        yield break;
    }
    public void returntomain()
    {
        cc.switchfocus("Main");
    }

    public void actionwheel(int place)
    {
        Debug.Log("clicked actionwheel " + place);
        StartCoroutine(moveonwheel(place));
    }
    public void parsemessageslogonly(JSONNode messages)
    {
        for (int i = 0; i < messages.Count; i++)
        {
            //Debug.Log("this is message: " + messages[i]["messageid"].ToString() + " last message was: " + lastmessagenumber.ToString());
            if (messages[i]["messageid"].AsInt > lastmessagenumber)
            {
                lastmessagenumber = messages[i]["messageid"].AsInt;
            }
            if (messages[i]["logmessage"].ToString().Length > 0)
            {
                GameObject go = Instantiate(logprefab, logfield.transform);
                TextMeshProUGUI text = go.GetComponent<TextMeshProUGUI>();
                if (messages[i]["turn"])
                {

                    if (messages[i]["turn"].AsInt == weare)
                    {
                        text.text = "<color=blue>"+ messages[i]["logmessage"]+"</color>";
                    }else
                    {
                        text.text = "<color=red>" + messages[i]["logmessage"] + "</color>";
                    }

                }
                else
                {
                    text.text = messages[i]["logmessage"];
                }

                forcescrolldown = true;


            }
        }
    }
    public void parsemessages(JSONNode messages)
    {
        //Debug.Log(messages.ToJSON(0));

        for (int i = 0; i < messages.Count; i++)
        {
            Debug.Log("this is message: " + messages[i]["messageid"].ToString() + " last message was: " + lastmessagenumber.ToString());
            if (messagesproccessed.TryGetValue(messages[i]["messageid"].AsInt, out bool donealready))
            {
                //we've already done this message but got it again for some reason. this can happen due to lag.
                Debug.Log("already proccessed this message");
                continue;
            }
            messagesproccessed[messages[i]["messageid"].AsInt] = true;
            if (messages[i]["messageid"].AsInt > lastmessagenumber)
            {
                lastmessagenumber = messages[i]["messageid"].AsInt;
            }
            if (messages[i]["logmessage"].ToString().Length >0)
            {
                GameObject go = Instantiate(logprefab, logfield.transform);
                TextMeshProUGUI text = go.GetComponent<TextMeshProUGUI>();
                if (messages[i]["turn"])
                {
                    Debug.Log("We have a turn field: " + messages[i]["turn"] + "  - " + weare.ToString());
                    if (messages[i]["turn"].AsInt == weare)
                    {
                        text.text = "<color=blue>" + messages[i]["logmessage"] + "</color>";
                    }
                    else
                    {
                        text.text = "<color=red>" + messages[i]["logmessage"] + "</color>";
                    }

                }
                else
                {
                    text.text = messages[i]["logmessage"];
                }
                if (messages[i]["logmessage"].ToString().Contains("ended their turn"))
                {
                    //we should play a turn sound here
                    cc.playsound("alert");

                }
                forcescrolldown = true;

            }
            Debug.Log(messages[i].ToString());
            if (messages[i]["ended"])
            {
                int winner = messages[i]["ended"].AsInt;
                if (winner == weare)
                {
                    //we won!
                    wonbanner.SetActive(true);
                }
                if (winner == opponent)
                {
                    //we lost!
                    lostbanner.SetActive(true);
                }
            }
            if (messages[i]["object"])
            {
                string separator = ":";
                string a = messages[i]["object"];
                int separatorIndex = a.IndexOf(separator);
                if (separatorIndex > 0)
                {
                    string objectnumber = a.Substring(0, separatorIndex);
                    Debug.Log(a.Substring(separatorIndex + 1));
                    objectsinplay[objectnumber] = JSON.Parse(a.Substring(separatorIndex + 1));
                    Debug.Log("objects: " + objectnumber + " : " + objectsinplay[objectnumber]);
                    objectsinplay[objectnumber]["needupdate"] = 1;
                }
            }
            if (messages[i]["moveoptions"])
            {
                Debug.Log(messages[i]["moveoptions"]);
                string[] wheel = messages[i]["moveoptions"].ToString().Trim('"').Split(',');
                for (int j = 0; j < wheelhighlights.Length; j++)
                {
                    wheelhighlights[j].SetActive(false);
                }

                for (int j = 0; j < wheel.Length; j++)
                {
                    
                    int position = Int32.Parse(wheel[j]);
                    if (position < 0)
                    {
                        break;
                    }
                    wheelhighlights[position].SetActive(true);

                }
            }
            if (messages[i]["lane"])
            {
                string[] lanes = messages[i]["lane"].ToString().Trim('"').Split(';');
                foreach (string lanestring in lanes)
                {
                    Debug.Log("lanestring: " + lanestring);
                    string[] laneinfo = lanestring.Split(':');
                    if (laneinfo.Length < 3)
                    {
                        continue;
                    }
                    Debug.Log("laneinfo: " + laneinfo[0] + " : " + laneinfo[1] + " : " + laneinfo[2]);
                    if (laneinfo[0].Contains(weare.ToString()))
                    {
                        //our lanes
                        
                        if (laneinfo[1].Contains("1"))
                        {
                            if (lane1.transform.childCount > 0)
                            {
                                Destroy(lane1.transform.GetChild(0).gameObject);
                            }
                            if (laneinfo[2].Equals("0"))
                            {

                            }
                            else
                            {
                                GameObject go = Instantiate(cardinplayprefab, lane1.transform);
                                cardinplay card = go.GetComponent<cardinplay>();
                                card.setcardnumber(Int32.Parse(laneinfo[2]));
                                card.parentcanvas = parentcanvas;
                                card.gamescriptlink = this;
                            }
                        }
                        if (laneinfo[1].Contains("2"))
                        {
                            if (lane2.transform.childCount > 0)
                            {
                                Destroy(lane2.transform.GetChild(0).gameObject);
                            }
                            if (laneinfo[2].Equals("0"))
                            {

                            }
                            else
                            {
                                GameObject go = Instantiate(cardinplayprefab, lane2.transform);
                                cardinplay card = go.GetComponent<cardinplay>();
                                card.setcardnumber(Int32.Parse(laneinfo[2]));
                                card.parentcanvas = parentcanvas;
                                card.gamescriptlink = this;
                            }
                        }
                        if (laneinfo[1].Contains("3"))
                        {
                            if (lane3.transform.childCount > 0)
                            {
                                Destroy(lane3.transform.GetChild(0).gameObject);
                            }
                            if (laneinfo[2].Equals("0"))
                            {

                            }
                            else
                            {
                                GameObject go = Instantiate(cardinplayprefab, lane3.transform);
                                cardinplay card = go.GetComponent<cardinplay>();
                                card.setcardnumber(Int32.Parse(laneinfo[2]));
                                card.parentcanvas = parentcanvas;
                                card.gamescriptlink = this;
                            }
                        }
                        if (laneinfo[1].Contains("4"))
                        {
                            if (lane4.transform.childCount > 0)
                            {
                                Destroy(lane4.transform.GetChild(0).gameObject);
                            }
                            if (laneinfo[2].Equals("0"))
                            {

                            }
                            else
                            {
                                GameObject go = Instantiate(cardinplayprefab, lane4.transform);
                                cardinplay card = go.GetComponent<cardinplay>();
                                card.setcardnumber(Int32.Parse(laneinfo[2]));
                                card.parentcanvas = parentcanvas;
                                card.gamescriptlink = this;
                            }
                        }
                        if (laneinfo[1].Contains("5"))
                        {
                            if (lane5.transform.childCount > 0)
                            {
                                Destroy(lane5.transform.GetChild(0).gameObject);
                            }
                            if (laneinfo[2].Equals("0"))
                            {

                            }
                            else
                            {
                                GameObject go = Instantiate(cardinplayprefab, lane5.transform);
                                cardinplay card = go.GetComponent<cardinplay>();
                                card.setcardnumber(Int32.Parse(laneinfo[2]));
                                card.parentcanvas = parentcanvas;
                                card.gamescriptlink = this;
                            }
                        }







                    }
                    if (laneinfo[0].Contains(opponent.ToString()))
                    {
                        //our lanes
                        if (laneinfo[1].Contains("1"))
                        {
                            if (olane1.transform.childCount > 0)
                            {
                                Destroy(olane1.transform.GetChild(0).gameObject);
                            }
                            if (laneinfo[2].Equals("0"))
                            {

                            }
                            else
                            {
                                GameObject go = Instantiate(cardinplayprefab, olane1.transform);
                                cardinplay card = go.GetComponent<cardinplay>();
                                card.setcardnumber(Int32.Parse(laneinfo[2]));
                                card.parentcanvas = parentcanvas;
                                card.gamescriptlink = this;
                            }
                        }
                        if (laneinfo[1].Contains("2"))
                        {
                            if (olane2.transform.childCount > 0)
                            {
                                Destroy(olane2.transform.GetChild(0).gameObject);
                            }
                            if (laneinfo[2].Equals("0"))
                            {

                            }
                            else
                            {
                                GameObject go = Instantiate(cardinplayprefab, olane2.transform);
                                cardinplay card = go.GetComponent<cardinplay>();
                                card.setcardnumber(Int32.Parse(laneinfo[2]));
                                card.parentcanvas = parentcanvas;
                                card.gamescriptlink = this;
                            }
                        }
                        if (laneinfo[1].Contains("3"))
                        {
                            if (olane3.transform.childCount > 0)
                            {
                                Destroy(olane3.transform.GetChild(0).gameObject);
                            }
                            if (laneinfo[2].Equals("0"))
                            {

                            }
                            else
                            {
                                GameObject go = Instantiate(cardinplayprefab, olane3.transform);
                                cardinplay card = go.GetComponent<cardinplay>();
                                card.setcardnumber(Int32.Parse(laneinfo[2]));
                                card.parentcanvas = parentcanvas;
                                card.gamescriptlink = this;
                            }
                        }
                        if (laneinfo[1].Contains("4"))
                        {
                            if (olane4.transform.childCount > 0)
                            {
                                Destroy(olane4.transform.GetChild(0).gameObject);
                            }
                            if (laneinfo[2].Equals("0"))
                            {

                            }
                            else
                            {
                                GameObject go = Instantiate(cardinplayprefab, olane4.transform);
                                cardinplay card = go.GetComponent<cardinplay>();
                                card.setcardnumber(Int32.Parse(laneinfo[2]));
                                card.parentcanvas = parentcanvas;
                                card.gamescriptlink = this;
                            }
                        }
                        if (laneinfo[1].Contains("5"))
                        {
                            if (olane5.transform.childCount > 0)
                            {
                                Destroy(olane5.transform.GetChild(0).gameObject);
                            }
                            if (laneinfo[2].Equals("0"))
                            {

                            }
                            else
                            {
                                GameObject go = Instantiate(cardinplayprefab, olane5.transform);
                                cardinplay card = go.GetComponent<cardinplay>();
                                card.setcardnumber(Int32.Parse(laneinfo[2]));
                                card.parentcanvas = parentcanvas;
                                card.gamescriptlink = this;
                            }
                        }





                    }

                }


            }

            if ((messages[i]["draws"] != null) && (!messages[i]["draws"].ToString().Contains("null")))
            {
                string[] card = messages[i]["draws"].ToString().Trim('"').Split(':');

                foreach (string cardnum in card)
                {
                    Debug.Log(cardnum + " "+ card[0]);
                    if (cardnum is null)
                    {
                        Debug.Log("error");
                        continue;
                    }
                    int cardnumber = Int32.Parse(cardnum);
                    if (cardnumber > 0)
                    {
                        GameObject go = Instantiate(cardinhandprefab, handfield.transform);
                        cardinhand cardinhand = go.GetComponent<cardinhand>();
                        cardinhand.setcardnumber(cardnumber);
                        cardinhand.parentcanvas = parentcanvas;
                        cardinhand.gamescriptlink = this;
                    }else
                    {
                        cardnumber = Math.Abs(cardnumber);
                        

                        foreach (cardinhand child in handfield.transform.GetComponentsInChildren<cardinhand>())
                        {
                            if (child.cardnumber == cardnumber)
                            {
                                //destroy this child here.
                                Destroy(child.gameObject);
                                break;
                            }
                        }
                    }
                }

            }
            if (messages[i]["forcedaction"] != null)
            {


                Debug.Log("forced action found: "+messages[i]["forcedaction"]);
                forceplayable = JSON.Parse( messages[i]["forcedaction"]);
                Debug.Log(forceplayable);
                Debug.Log(forceplayable["targets"]);
                if (forceplayable["targets"] == null )
                {
                    Debug.Log("We're clearing force playable");
                    forceplayable = null;
                }else
                {
                    targetindex = 0;
                    targetinfo = forceplayable["targets"];
                    highlighttargets(targetinfo);
                    if (forceplayable["revealtargets"])
                    {
                        Debug.Log("We need to make a targets display");
                        extratargetsdisplay.SetActive(true);

                        for (int j = 0; j < extratargetscards.transform.childCount; ++j)
                        {
                            Destroy(extratargetscards.transform.GetChild(j).gameObject);
                        }
                        for (int j = 0; j < targetinfo[targetindex]["raw"].Count; j++)
                        {
                            GameObject go = Instantiate(cardinhandprefab, extratargetscards.transform);
                            cardinhand foo = go.GetComponent<cardinhand>();
                            foo.parentcanvas = parentcanvas;
                            foo.gamescriptlink = this;
                            foo.setcardnumber(targetinfo[targetindex]["raw"][j]);

                        }

                    }
                }
            }
            if (messages[i]["handplayable"] != null)
            {
                handplayable.Clear();
                string[] cards = messages[i]["handplayable"].ToString().Trim('"').Split(';');

                for (int j = 0; j < cards.Length; j++)
                {
                    string separator = ":";

                    int separatorIndex = cards[j].IndexOf(separator);
                    if (separatorIndex > 0)
                    {
                        string result = cards[j].Substring(separatorIndex + separator.Length);
                        result = result.Replace("\\", "");
                        Debug.Log("Handplayable: " + cards[j].Substring(0, separatorIndex));
                        Debug.Log("result: " + result);
                        handplayable[cards[j].Substring(0, separatorIndex)] = JSON.Parse(result);
                    }
                }

            }
            if ((messages[i]["gold"] != null) && (!messages[i]["gold"].ToString().Contains("null")))
            {
                string[] goldstring = messages[i]["gold"].ToString().Trim('"').Split(';');
                foreach (string item in goldstring)
                {
                    if (item.Length == 0)
                    {
                        continue;
                    }
                    Debug.Log("item is: " + item);
                    string[] values = item.Split(':');
                    if (values[0].Contains( weare.ToString() ) )
                    {
                        gold.text = values[1];
                    }else
                    {
                        ogold.text = values[1];
                    }
                }

                

            }
            if ((messages[i]["life"] != null) && (!messages[i]["life"].ToString().Contains("null")))
            {
                string[] lifestring = messages[i]["life"].ToString().Trim('"').Split(';');

                foreach (string item in lifestring)
                {
                    string[] values= item.Split(':');
                    if (values[0].Contains(weare.ToString()))
                    {
                        health1.text = values[1];
                    }

                    if (values[0].Contains(opponent.ToString()))
                    {
                        health2.text = values[1];
                    }

                }



            }
            if ((messages[i]["levels"] != null) && (!messages[i]["levels"].ToString().Contains("null")))
            {
                string[] lifestring = messages[i]["levels"].ToString().Trim('"').Split(';');

                foreach (string item in lifestring)
                {
                    string[] values = item.Split(':');
                    if (values[0].Contains(weare.ToString()))
                    {
                        level.text = values[1];
                    }

                    if (values[0].Contains(opponent.ToString()))
                    {
                        olevel.text = values[1];
                    }

                }



            }
            if ((messages[i]["threshold"] != null) && (!messages[i]["threshold"].ToString().Contains("null") ) && messages[i]["threshold"].ToString().Length >=3 )
            {

                Debug.Log("threshold is : " + messages[i]["threshold"]);
                Debug.Log("threshold is : " + messages[i]["threshold"][weare.ToString()]);
                JSONNode thresholdvars = JSON.Parse(messages[i]["threshold"]);
                
                foreach (string type in thresholdvars[weare.ToString()].Keys)
                {
                    Debug.Log(thresholdvars[weare.ToString()][type]);
                    if (type.Contains("R"))
                    {
                        threshold_fire.text = thresholdvars[weare.ToString()][type];
                    }
                    if (type.Contains("G"))
                    {
                        threshold_earth.text = thresholdvars[weare.ToString()][type];
                    }
                    if (type.Contains("P"))
                    {
                        threshold_water.text = thresholdvars[weare.ToString()][type];
                    }
                    if (type.Contains("T"))
                    {
                        threshold_air.text = thresholdvars[weare.ToString()][type];
                    }


                }
                //thresholdvars = JSON.Parse(messages[i]["threshold"][opponent.ToString()]);

                foreach (string type in thresholdvars[opponent.ToString()].Keys)
                {
                    Debug.Log(thresholdvars[opponent.ToString()][type]);
                    if (type.Contains("R"))
                    {
                        othreshold_fire.text = thresholdvars[opponent.ToString()][type];
                    }
                    if (type.Contains("G"))
                    {
                        othreshold_earth.text = thresholdvars[opponent.ToString()][type];
                    }
                    if (type.Contains("P"))
                    {
                        othreshold_water.text = thresholdvars[opponent.ToString()][type];
                    }
                    if (type.Contains("T"))
                    {
                        othreshold_air.text = thresholdvars[opponent.ToString()][type];
                    }


                }

            }
            if (messages[i]["turn"].AsInt > 0 && messages[i]["turn"].AsInt == weare)
            {
                turnbutton.interactable = true;
                turn = messages[i]["turn"].AsInt;
            }
            else if (messages[i]["turn"].AsInt > 0)
            {
                turnbutton.interactable = false;
                turn = messages[i]["turn"].AsInt;
            }
            if ( (messages[i]["changeposition"] != null) &&  (! messages[i]["changeposition"].ToString().Contains("null") ) )
            {
                int newposition=-1;
                string[] pos = messages[i]["changeposition"].ToString().Trim('"').Split(':');
                Debug.Log(pos[0]);
                Debug.Log(pos[1]);
                int player = int.Parse(pos[0]);
                newposition = int.Parse(pos[1]);
                if (player == cc.userid)
                {
                    turnbutton.interactable = true;
                    if (newposition >= 0)
                    {
                        Debug.Log("our position: " + newposition.ToString());
                        position.SetActive(true);
                        
                        position.transform.localRotation = Quaternion.Euler(0, 0, -40 * newposition);
                        //position.transform.Rotate(0, 0, -40 * newposition);
                    }
                    else
                    {
                        position.SetActive(false);
                    }
                }else
                {
                    if (newposition >= 0)
                    {
                        position2.SetActive(true);
                        position2.transform.localRotation = Quaternion.Euler(0, 0, -40 * newposition);
                        //position2.transform.Rotate(0, 0, -40 * newposition);
                    }
                    else
                    {
                        position2.SetActive(false);
                    }
                }
            }
        }
    }
    public void highlighttargets(JSONNode targets)
    {
        int validtargets = 0;
        
        targetting = true;
        targetinfo = targets;
        highlight.Clear();
        if (!( targets[0] == null ))
        {
            if (targets[targetindex].HasKey("text"))
            {
                Debug.Log("target index text is : "+targets[targetindex]["text"]);
                targettext.text = targets[targetindex]["text"];
            }else
            {
                targettext.text = "";
            }
            
            if (!(targets[targetindex]["l"] == null))
            {
                

                foreach (var item in targets[targetindex]["l"])
                {

                    if (item.ToString().Contains("1"))
                    {
                        highlight["lane1"] = true;
                        validtargets += 1;
                    }
                    if (item.ToString().Contains("2"))
                    {
                        highlight["lane2"] = true;
                        validtargets += 1;
                    }
                    if (item.ToString().Contains("3"))
                    {
                        highlight["lane3"] = true;
                        validtargets += 1;
                    }
                    if (item.ToString().Contains("4"))
                    {
                        highlight["lane4"] = true;
                        validtargets += 1;
                    }
                    if (item.ToString().Contains("5"))
                    {
                        highlight["lane5"] = true;
                        validtargets += 1;
                    }

                }
            }
            if (!(targets[targetindex]["raw"] == null))
            {
                var target = targets[targetindex]["raw"].AsArray;
                if (targets[targetindex]["revealtargets"])
                {
                    for (int j = 0; j < extratargetscards.transform.childCount; ++j)
                    {
                        Destroy(extratargetscards.transform.GetChild(j).gameObject);
                    }
                }
                for (int i = 0; i < target.Count; i++)
                {
                    if (targets[targetindex]["revealtargets"])
                    {
                        extratargetsdisplay.SetActive(true);
                        GameObject go = Instantiate(cardinhandprefab, extratargetscards.transform);
                        cardinhand foo = go.GetComponent<cardinhand>();
                        foo.parentcanvas = parentcanvas;
                        foo.gamescriptlink = this;
                        foo.setcardnumber(targets[targetindex]["raw"][i]);
                    }
                    Debug.Log("item is" +target[i]);
                    highlight[target[i]] = true;
                    validtargets += 1;
                }

            }

            if (!(targets[targetindex]["o"] == null))
            {
                

                foreach (var item in targets[targetindex]["o"])
                {
                    
                    if (item.ToString().Contains("1"))
                    {
                        highlight["olane1"] = true;
                        validtargets += 1;
                    }
                    if (item.ToString().Contains("2"))
                    {
                        highlight["olane2"] = true;
                        validtargets += 1;
                    }
                    if (item.ToString().Contains("3"))
                    {
                        highlight["olane3"] = true;
                        validtargets += 1;
                    }
                    if (item.ToString().Contains("4"))
                    {
                        highlight["olane4"] = true;
                        validtargets += 1;
                    }
                    if (item.ToString().Contains("5"))
                    {
                        highlight["olane5"] = true;
                        validtargets += 1;
                    }

                }
            }
        }
        else
        {
            Debug.Log("no key 0 " + targets.ToString());
        }
        if (validtargets == 0)
        {
            Debug.Log("no targets, highlight playfield"+ targets);
            //we should highlight the whole playfield
            highlight["nolane"] = true;
        }
        
        
    }
    public bool checktarget(string lane)
    {
        if (targetting == false)
        {
            Debug.Log("we're not targetting!");
            return false;
        }
        if (targetinfo == null)
        {
            Debug.Log("no targetinfo");
            return false;
        }
        bool valid = false;
        if (lane.StartsWith("ol"))
        {
            char lanenumber = lane.Last<char>();
            Debug.Log(lanenumber);
            Debug.Log("count is" + targetinfo[targetindex]);
            for (int i = 0; i < targetinfo[targetindex]["o"].AsArray.Count; i++)
            {
                Debug.Log(targetinfo[targetindex]["o"][i] + " maybe equals " + lanenumber);
                if (targetinfo[targetindex]["o"][i].ToString().Contains(lanenumber))
                {
                    Debug.Log("valid target");
                    valid = true;
                }

            }

        }
        else if (lane.StartsWith("l"))
        {
            char lanenumber = lane.Last<char>();
            for (int i = 0; i < targetinfo[targetindex]["l"].AsArray.Count; i++)
            {
                Debug.Log(targetinfo[targetindex]["l"][i] + " maybe equals " + lanenumber);
                if (targetinfo[targetindex]["l"][i].ToString().Contains(lanenumber))
                {
                    Debug.Log("valid target");
                    valid = true;
                }

            }
        }
        else
        {
            for (int i = 0; i < targetinfo[targetindex]["raw"].AsArray.Count; i++)
            {
                Debug.Log(targetinfo[targetindex]["raw"][i] + " maybe equals " + lane);
                if (targetinfo[targetindex]["raw"][i].ToString().Contains(lane))
                {
                    Debug.Log("valid target");
                    valid = true;
                }

            }
        }
        if (highlight.TryGetValue("nolane", out bool notused))
        {
            Debug.Log("no targets needed so we're valid");
            valid = true;
        }
        if (!valid)
        {
            return false;
        }

        return true;
    }
    public void clickontarget (string lane )
    {
        Debug.Log("we clicked on a target! "+lane);
        Debug.Log(targetinfo);
        if (targetting == false)
        {
            Debug.Log("we're not targetting!");
            return;
        }
        if (selectedinplay != null || selectedinhand != null || forceplayable != null)
        {
            Debug.Log(targetinfo);
            if (!checktarget(lane))
            {
                return;
            }
            targets.Add(lane);

            
            if (targets.Count() >= targetinfo.Count)
            {
                Debug.Log("Sending play to server");
                if (selectedinplay)
                {
                    StartCoroutine(playcard(selectedinplay.cardnumber.ToString(), targets));
                }
                else if (selectedinhand) { 
                    StartCoroutine(playcard(selectedinhand.cardnumber.ToString(), targets));
                }else
                {
                    StartCoroutine(playforced(forceplayable["trigger"], targets));
                }
                extratargetsdisplay.SetActive(false);
                dehighlight();
                targetting = false;
            }else
            {
                targetindex += 1;
                highlighttargets(targetinfo);
            }
        }
        return;
    }
    public void dehighlight()
    {
        targetindex = 0;
        targetting = false;
        selectedinhand = null;
        selectedinplay = null;
        targetinfo = null;
        targets.Clear();
        highlight.Clear();
        targettext.text = "";
        forceplayable = null;
    }
    private IEnumerator moveonwheel (int place)
    {
        GAMEAPI gapi = new GAMEAPI();
        WWWForm form = new WWWForm();
        form.AddField("game", gameid);
        form.AddField("newposition", place);
        form.AddField("startmessage", lastmessagenumber);
        yield return gapi.request("move", form);
     
        var data = JSON.Parse(gapi.apiResult);
        Debug.Log(data);
        if (data["status"].ToString().Contains("Failed"))
        {
            cc.showerror(data.ToString());
            yield break;
        }

        parsemessages(data["messages"]);



        yield break;
    }

    public void endturn()
    {
        StartCoroutine(endturninner());
        turnbutton.interactable = false;
        dehighlight();

    }

    private IEnumerator endturninner()
    {
        GAMEAPI gapi = new GAMEAPI();
        WWWForm form = new WWWForm();
        form.AddField("game", gameid);
        form.AddField("startmessage", lastmessagenumber );
        yield return gapi.request("turn", form);
        
      
        var data = JSON.Parse(gapi.apiResult);
        if (data["status"].ToString().Contains("failed"))
        {
            cc.showerror(data.ToString());
            yield break;
        }
        parsemessages(data["messages"]);
        yield break;

    }

    // Start is called before the first frame update
    void Start()
    {
        cc = FindObjectOfType<ClientControl>();
        GAMEAPI.session = API.session;
        StartCoroutine(getgamedata());
        cc.playsound("gamestart");
        
    }

    // Update is called once per frame
    void Update()
    {
        if (forcescrolldown)
        {
            Canvas.ForceUpdateCanvases(); 
            scrollRect.verticalScrollbar.value = 0f;
            Canvas.ForceUpdateCanvases();
            forcescrolldown = false;
        }
    }
}
