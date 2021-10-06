using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using TMPro;
using SimpleJSON;
using UnityEngine.UI;
using System;
using System.Threading;
using UnityEngine.EventSystems;

public class ClientControl : MonoBehaviour
{

    public enum clientStates { NotLoggedIn, AttemptingLogin, LoggedIn, LoginFailed, NotAllowedToLogin, Registering };
    //and have a variable to store this state. default it to not logged in.
    public clientStates clientState = clientStates.NotLoggedIn;
    public InputField usernamefield;
    public InputField passwordfield;
    string username;
    string password;
    GameObject focusobj = null;
    int focusedGameId = 0;
    public GameObject login;
    public GameObject deckeditor;
    public GameObject rewardsfield;
    public GameObject dailyfield;
    public GameObject weeklyfield;
    public GameObject monthlyfield;
    public GameObject seasonfield;
    public GameObject onetimefield;
    public GameObject rewarddisplayprefab;
    public GameObject packsdisplay;
    public GameObject packsopendisplay;
    public GameObject Tutorial;
    public GameObject Tutorial2;
    public GameObject Tutorial3;

    public TextMeshProUGUI gold;
    public TextMeshProUGUI ticket;
    public TextMeshProUGUI greengem;
    public GameObject main;
    public GameObject loginbutton;
    public GameObject registerbuttonfield;
    public GameObject draftprefab;
    public GameObject gameprefab;
    public GameObject registerfield;
    public GameObject queuelabelprefab;
    public GameObject gamelabelprefab;
    public GameObject gamelabelfield;
    public GameObject achievementsprefab;
    public GameObject achievementsfield;
    public GameObject deckselector;
    public GameObject packopenfield;
    public GameObject cardinpackprefab;
    public GameObject objectinpackprefab;
    public Slider exptrack;
    public TextMeshProUGUI expcurrent;
    public TextMeshProUGUI levelcurrent;
    public TextMeshProUGUI levelnext;
    public GameObject levelfield;
    public GameObject levelprefab;
    public GameObject packprefab;
    public GameObject packfield;
    public TMP_InputField registerusername;
    public TMP_InputField registerpassword;
    public TMP_InputField registerpassword2;
    public TMP_InputField registeremail;
    public TextMeshProUGUI registermessage;
    public TextMeshProUGUI registermessage2;
    public Button settingsbutton;
    public GameObject menu;
    public Toggle fullscreen;
    public Dictionary<int, GameObject> gamesrunning = new Dictionary<int, GameObject>();

    public Dictionary<int, GameObject> gamesEndedDict = new Dictionary<int, GameObject>();
    public ModelShark.TooltipManager tooltipmanager;
    public string focus = "Login";
    public Dictionary<string, draftData> draftdata = new Dictionary<string, draftData>();
    public GameObject eventprefab;
    public GameObject eventsfield;
    public GameObject joinbuttonprefab;
    public ClientControl self;
    public string test;
    Dictionary<int, GameObject> eventsdisplayed = new Dictionary<int, GameObject>();
    //public Dictionary<string, JSONNode> allcards = new Dictionary<string, JSONNode>();
    public Dictionary<string, card> allcards = new Dictionary<string, card>();
    public Dictionary<string, JSONNode> decks = new Dictionary<string, JSONNode>();
    public Dictionary<string, JSONNode> levels = new Dictionary<string, JSONNode>();
    public Dictionary<string, Inventory> inventory = new Dictionary<string, Inventory>();
    //public Dictionary<string, JSONNode> achievements = new Dictionary<string, JSONNode>();
    public Dictionary<string, achievementclass> achievements = new Dictionary<string, achievementclass>();
    Resolution[] resolutions;
    public TMP_Dropdown resolutionsdropdown;
    private int lastNumber = 0;
    public int userid=0;
    public AudioSource alert;
    public AudioSource gamestart;
    private float volume;
    public Slider volumeslider;
    public GameObject errorscreen;
    public List<JSONNode> levelsinorder;
    private EventSystem system;
    public void showerror(string errormessage)
    {
        GameObject go = Instantiate(errorscreen);
        TextMeshProUGUI errortextfield = go.GetComponentInChildren<TextMeshProUGUI>();
        errortextfield.text = errormessage;
    }

    public void playsound(string sound)
    {
        if (clientState== clientStates.NotLoggedIn)
        {
            return;
        }
        if (sound.Equals("alert"))
        {
            Debug.Log("Playing sound!");
            alert.volume = volume;
            alert.Play();
        }
        if (sound.Equals("gamestart"))
        {
            gamestart.volume = volume;
            gamestart.Play();
        }
    }
    public void setvolume (float newvolume)
    {
        volume = newvolume;
        PlayerPrefs.SetFloat("volume", volume);
        playsound("alert");

    }
    public void SetResolution(int resolutionindex)
    {
        Resolution resolution = resolutions[resolutionindex];
        Screen.SetResolution(resolution.width, resolution.height, Screen.fullScreen);
    }

    public void fullscreentoggle(bool isfullscreen)
    {
        Screen.fullScreen = isfullscreen;
    }

    public void settingsbuttonclicked()
    {
        menu.SetActive(true);
    }
    public void returntogameclick()
    {
        menu.SetActive(false);
    }

    public void exitgameclick()
    {
        Application.Quit();
    }

    public void registercancel()
    {
        registerfield.SetActive(false);
        clientState = clientStates.NotLoggedIn;
        system.SetSelectedGameObject(usernamefield.gameObject);
    }
    public void registerbutton()
    {
        registerfield.SetActive(true);
        clientState = clientStates.Registering;
        system.SetSelectedGameObject(registerusername.gameObject);
    }
    public void registerbutton2 ()
    {
        StartCoroutine(registerreal());
        clientState = clientStates.Registering;
        registerbuttonfield.GetComponent<Button>().interactable=false;

    }
    public IEnumerator registerreal()
    {
        Debug.Log("Register real!");
        WWWForm form = new WWWForm();
        form.AddField("username", registerusername.text);
        form.AddField("password", registerpassword.text);
        form.AddField("password2", registerpassword2.text);
        form.AddField("email", registeremail.text);


        // Create a download object
        API api = new API();

        // Wait until the download is done
        yield return StartCoroutine(api.request("register", form));
        Debug.Log("finished registering. "+api.apiResult.ToString());
        if (api.apiResult.Contains("Success"))
        {
            registerfield.SetActive(false);
            login.SetActive(true);
            registermessage.text = "Signed up! You may now log in.";
            usernamefield.text = registeremail.text;
            passwordfield.text = registerpassword.text;

        }else
        {
            registerbuttonfield.GetComponent<Button>().interactable = true;
            registermessage2.text = "Error: "+ api.apiResult;
        }
        clientState = clientStates.NotLoggedIn;
    }
    private void Update()
    {
       
            //check for keypress. allow a login to be initiated if enter is pressed on keyboard
            if (Input.GetKeyDown(KeyCode.Return) || Input.GetKeyDown(KeyCode.KeypadEnter)) {
                Debug.Log("Enter pressed");
                if( clientState == clientStates.NotLoggedIn )
                    {
                    //attempt a login.
                        Login();
                    }
                if (clientState == clientStates.Registering)
                {
                    //attempt a register.
                    Debug.Log("Registering!");
                    registerbutton2();

                }
            }
       
    }
    private void Start()
    {
        Debug.Log("Starting");
        switchfocus("Login");
        system = EventSystem.current;
        API.cc = self;
        GAMEAPI.cc = self;
        resolutions = Screen.resolutions;

        resolutionsdropdown.ClearOptions();
        List<string> options = new List<string>();
        int currentresolutionindex = 0;
        for (int i = 0; i < resolutions.Length; i++)
        {
            string option = resolutions[i].width + "x" + resolutions[i].height;
            options.Add(option);
            if (resolutions[i].width == Screen.width && resolutions[i].height == Screen.height)
            {
                currentresolutionindex = i;
            }
        }
        
        resolutionsdropdown.AddOptions(options);
        resolutionsdropdown.value = currentresolutionindex;
        resolutionsdropdown.RefreshShownValue();
        volume = 0f;
        float oldvolume = PlayerPrefs.GetFloat("volume", 0.5f);
        volumeslider.value = oldvolume;
        volume = oldvolume;
    }

    public void Login()
    {
        username = usernamefield.text;
        password = passwordfield.text;
        PlayerPrefs.SetString("username", username);
        PlayerPrefs.SetString("password", password);
        clientState = clientStates.AttemptingLogin;
        StartCoroutine(loginrequest());
    }

    IEnumerator loginrequest()
    {
        // Create a form object for sending high score data to the server
        WWWForm form = new WWWForm();
        // Assuming the perl script manages high scores for different games
        form.AddField("username", username);
        // The name of the player submitting the scores
        form.AddField("password", password);
        // The score


        // Create a download object
        API api = new API();

        // Wait until the download is done
        yield return StartCoroutine(api.request("login", form));
        if (api.apiResult.Length == 0)
        {
            loginbutton.SetActive(true);
            clientState = clientStates.NotLoggedIn;
            yield break;
        }
        var Logindata = JSON.Parse(api.apiResult);
        if (Logindata["status"].Value.Equals("Success"))
        {
            Debug.Log("Logged in!");
            switchfocus("Main");
            clientState = clientStates.LoggedIn;
            API.session = Logindata["session"];
            lastNumber = Logindata["lastNumber"].AsInt;

            userid = Logindata["playerid"].AsInt;
            
            StartCoroutine(loadall());
        } else
        {
            Debug.Log("Error:" + Logindata["status"].ToString());
            registermessage.text = "Login Failed: Wrong email/password ";
            loginbutton.SetActive(true);
            clientState = clientStates.NotLoggedIn;

        }

    }

    public IEnumerator loadall()
    {
        yield return StartCoroutine(getinventory());
        yield return StartCoroutine(getmydecks());
        yield return StartCoroutine(getcards());
        yield return StartCoroutine(getevents());
        yield return StartCoroutine(getgames());
        yield return StartCoroutine(getqueues());
        yield return StartCoroutine(getachievements());
        yield return StartCoroutine(getlevels());
        
        InvokeRepeating("startPoll", 5.0f, 0.5f);
        yield break;
    }
    public void startPoll()
    {
        StartCoroutine(getPoll());

    }

    public IEnumerator getlevels()
    {
        API api = new API();
        WWWForm form = new WWWForm();
        yield return StartCoroutine(api.request("levels", form));
        var data = JSON.Parse(api.apiResult);

        exptrack.value = data["exp"];
        expcurrent.text = data["exp"];
        levelcurrent.text = data["level"];
        int nextlevel = data["level"].AsInt + 1;
        levelnext.text = nextlevel.ToString();

        int maxlevel=0;
        foreach (JSONNode deck in data["levels"].Values)
        {
            levels[deck["level"]] = deck;
            if (deck["level"].AsInt > maxlevel)
            {
                maxlevel = deck["level"].AsInt;
            }
        }
        for (int i=data["level"]+1; i<=maxlevel; i++) 
        { 
            GameObject go = Instantiate(levelprefab, levelfield.transform);
            levelreward foo = go.GetComponent<levelreward>();
            string rewardstring = levels[i.ToString()]["reward1"];
            string[] reward = rewardstring.Split(':');
            int amount = Int32.Parse(reward[1]);
            foo.redraw(i, amount, reward[0]);
            if (i < data["level"])
            {
                Destroy(go);
            }

        }



    }
    public IEnumerator getachievements()
    {
        API api = new API();
        WWWForm form = new WWWForm();
        yield return StartCoroutine(api.request("achievements", form));
        var data = JSON.Parse(api.apiResult);
        
        foreach (JSONNode achievement in data["achievements"].Values)
        {
            string aid = achievement["achievementId"];
            achievements[aid ] = new achievementclass();
            achievements[aid].title = achievement["achievementName"];
            achievements[aid].desc = achievement["achievementDesc"];
            achievements[aid].expires = achievement["expires"];
            achievements[aid].xp = achievement["exp"];
            achievements[aid].achievementid = achievement["achievementId"];
            achievements[aid].progressneeded = achievement["progressneeded"];
            achievements[aid].progress = achievement["progress"];
            achievements[aid].earned = achievement["earned"];




            GameObject parent = onetimefield;
            if (achievement["expires"].Equals("daily"))
            {
                parent = dailyfield;
            }
            if (achievement["expires"].Equals("weekly"))
            {
                parent = weeklyfield;
            }
            if (achievement["expires"].Equals("monthly"))
            {
                parent = monthlyfield;
            }
            if (achievement["expires"].Equals("season"))
            {
                parent = seasonfield;
            }

            GameObject go = Instantiate(rewarddisplayprefab, parent.transform);
            achievements[aid].display = go;
            rewarddisplay foo = go.GetComponent<rewarddisplay>();
            string progress= "";
            if (achievement["earned"].AsInt > 0)
            {
                progress = "Done";
                foo.dim();
            }else
            {
                string progressinfo = achievement["progress"];
                if (progressinfo.Length == 0)
                {
                    progressinfo = "0";
                }
                progress = progressinfo + "/" + achievement["progressneeded"];
            }
            foo.setup(achievement["achievementName"], achievement["achievementDesc"], achievement["exp"], progress);


        }
    }
    public IEnumerator getmydecks()
    {
        Debug.Log("Getting decks");
        API api = new API();
        WWWForm form = new WWWForm();
        yield return StartCoroutine(api.request("getdecks", form));
        var data = JSON.Parse(api.apiResult);
        Debug.Log(data.ToString());
        decks = new Dictionary<string, JSONNode>();
        foreach (JSONNode deck in  data["decks"].Values)
        {
            
            decks[deck["deckname"]] = deck;
        }

    }
    public IEnumerator getgames()
    {
        
        API api = new API();
        WWWForm form = new WWWForm();
        yield return StartCoroutine(api.request("mygames", form));
        var data = JSON.Parse(api.apiResult);
        foreach (Transform child in gamelabelfield.transform)
        {
            GameObject.Destroy(child.gameObject);
        }
        foreach (JSONNode game in data["games"].AsArray)
        {
            
            GameObject go = Instantiate(gamelabelprefab, gamelabelfield.transform);
            gamelabelcontrol glc = go.GetComponent<gamelabelcontrol>();
            glc.opponent = game["opponent"];
            glc.deck = game["mydeck"];
            glc.gameid = game["gameId"].AsInt;
            glc.redraw();
            if (gamesrunning.TryGetValue(game["gameId"].AsInt, out GameObject foo) )
            {

            }
            else
            {
                //spawn a game
                GameObject newgame = Instantiate(gameprefab);
                gamesrunning[game["gameId"].AsInt] = newgame;
                newgame.GetComponent<Canvas>().enabled = false;
                gamecontroller gc = newgame.GetComponent<gamecontroller>();
                gc.gameid = game["gameId"].AsInt;

            }

        }
    }


    public IEnumerator getqueues()
    {
        
        API api = new API();
        WWWForm form = new WWWForm();
        yield return StartCoroutine(api.request("getmyqueues", form));
        var data = JSON.Parse(api.apiResult);
        foreach (Transform child in gamelabelfield.transform)
        {
            if (child.GetComponent<queuelabelcontrol>())
            {
                GameObject.Destroy(child.gameObject);
            }

        }
        
        foreach (JSONNode queue in data["result"].AsArray)
        {
            //spawn a game

            GameObject newqueue = Instantiate(queuelabelprefab, gamelabelfield.transform);
            queuelabelcontrol control = newqueue.GetComponent<queuelabelcontrol>();
            control.cc = this;
            control.redraw(queue["queuekey"], queue["deckname"]);
            control.queueid = queue["rowid"];



        }
    }


    public IEnumerator getcards()
    {
        API api = new API();
        WWWForm form = new WWWForm();
        yield return StartCoroutine(api.request("getcarddata", form));
        var data = JSON.Parse(api.apiResult);

        foreach (JSONNode card in data["result"].AsArray)
        {
            allcards[card["CardId"]] = new card();
            allcards[card["CardId"]].Attack = card["Attack"].AsInt;
            allcards[card["CardId"]].level = card["level"].AsInt;
            allcards[card["CardId"]].levelsfrom = card["levels from"].AsInt;
            allcards[card["CardId"]].levelsto = card["levelsto"].AsInt;
            allcards[card["CardId"]].CardArt = card["Cardart"];
            allcards[card["CardId"]].CardType = card["CardType"];
            allcards[card["CardId"]].Cost = card["Cost"].AsInt;
            allcards[card["CardId"]].Health = card["Health"].AsInt;
            allcards[card["CardId"]].faction = card["Faction"];
            allcards[card["CardId"]].FlavorText = card["FlavorText"];
            allcards[card["CardId"]].name = card["Name"];
            allcards[card["CardId"]].rarity = card["rarity"];
            allcards[card["CardId"]].text = card["Text"];
            allcards[card["CardId"]].Tooltips = card["Tooltips"];
            allcards[card["CardId"]].subtype = card["subtype"];
            allcards[card["CardId"]].CardId = card["CardId"].AsInt;
            string keywords = card["keywords"];
            if (keywords.Length > 0)
            {
                string[] keyword = keywords.Split(',');
                foreach (string foo in keyword)
                {
                    allcards[card["CardId"]].keywords.Add(foo);
                }

            }
        }


    }
    public IEnumerator openpack(string sku)
    {
        API api = new API();
        WWWForm form = new WWWForm();
        form.AddField("container", sku);
        
        yield return StartCoroutine(api.request("opencontainer", form));
        var data = JSON.Parse(api.apiResult);
        Debug.Log(data.ToString());
        packsopendisplay.SetActive(true);
        foreach (Transform foo in packopenfield.transform) {
            Destroy(foo.gameObject);
        }

        foreach (string newsku in data["newsku"].Keys)
        {
            Inventory bar;
            if (inventory.TryGetValue(newsku, out bar)) {
                bar.number += data["newsku"][newsku];
            }else
            {
                inventory[newsku] = new Inventory();
                inventory[newsku].number = data["newsku"][newsku];
            }
            if (newsku.Contains("Currency.Gold"))
            {
                gold.text = inventory[newsku].number.ToString();
            }
            if (newsku.Contains("Currency.Gems"))
            {
                greengem.text = inventory[newsku].number.ToString();
            }
            if (newsku.Contains("Currency.Ticket"))
            {
                ticket.text = inventory[newsku].number.ToString();
            }


            if (newsku.StartsWith("card."))
            {
                string cardid = newsku.Substring(5);
                Debug.Log(cardid);
                GameObject go = Instantiate(cardinpackprefab, packopenfield.transform);
                cardinhand foo = go.GetComponent<cardinhand>();
                foo.parentcanvas = packsdisplay.GetComponent<Canvas>();
                foo.setcardnumber(Int32.Parse(cardid));
                if (data["newsku"][newsku] > 1)
                {
                    foo.setnumberofcards(data["newsku"][newsku]);
                }

            }else
            {
                GameObject go = Instantiate(objectinpackprefab, packopenfield.transform);
                noncard foo = go.GetComponent<noncard>();
                foo.set(newsku, data["newsku"][newsku]);



            }


        }



    }
    public IEnumerator dropevent(string eventid)
    {
        API api = new API();
        WWWForm form = new WWWForm();
        form.AddField("event", eventid);
        if (draftdata.TryGetValue(eventid, out draftData foo))
        {
            Destroy(draftdata[eventid].displayobj.gameObject);
            draftdata.Remove(eventid);

        }
        yield return StartCoroutine(api.request("leaveevent", form));
        StartCoroutine(getevents());

    }
    public IEnumerator leavequeue(string eventid)
    {
        API api = new API();
        WWWForm form = new WWWForm();
        form.AddField("queueid", eventid);
        
        yield return StartCoroutine(api.request("leavequeue", form));
        
        StartCoroutine(getqueues());
        StartCoroutine(getevents());
        
    }

    public void fetchevents()
    {
        StartCoroutine(getevents());
    
    }

    public IEnumerator getPoll()
    {
        API api = new API();
        WWWForm form = new WWWForm();
        form.AddField("lastNumber", lastNumber);

        yield return StartCoroutine(api.request("poll", form));
        
        if (api.apiResult.Length < 2)
        {
            yield break;
        }
        var data = JSON.Parse(api.apiResult);
        

        foreach (JSONNode datarow in data["messages"].AsArray)
        {
            if (datarow["messageId"].AsInt > lastNumber)
            {
                Debug.Log("lastnumber: " + lastNumber.ToString());

                lastNumber = datarow["messageId"].AsInt;
            }
            string message = datarow["message"];

            if (datarow["message"].ToString().Contains("GAME STARTED"))
            {
                Debug.Log("GAME STARTED!");
                StartCoroutine(getgames());
                StartCoroutine(getevents());
            }
            if (datarow["message"].ToString().Contains("Won game"))
            {
                Debug.Log("GAME WON!");
                StartCoroutine(getgames());
                StartCoroutine(getevents());
            }
            if (datarow["message"].ToString().Contains("Lost game"))
            {
                Debug.Log("GAME Lost!");
                StartCoroutine(getgames());
                StartCoroutine(getevents());
            }
            if (message.StartsWith("new:"))
            {
                Debug.Log("new inventory item: "+message);
                string[] foo = message.Split(':');
                int change = Int32.Parse(foo[2]);
                inventory[foo[1]].number += change;
                if (change > 0)
                {
                    GameObject achievement = Instantiate(achievementsprefab, achievementsfield.transform);
                    achievmentdisplay script = achievement.GetComponent<achievmentdisplay>();
                    script.display("New Item(s)!", foo[2] + " " + foo[1]);
                }
                if (foo[1].Contains("Gold"))
                {
                    gold.text = inventory[foo[1]].number.ToString();
                }
                if (foo[1].Contains("Ticket"))
                {
                    ticket.text = inventory[foo[1]].number.ToString();
                }
                if (foo[1].Contains("Gem"))
                {
                    greengem.text = inventory[foo[1]].number.ToString();
                }
            }
            if (message.StartsWith("exp:"))
            {
                string[] foo = message.Split(':');
                int exp = Int32.Parse(foo[1]);
                exptrack.value = exp;
            }
            if (message.StartsWith("level:"))
            {
                string[] foo = message.Split(':');
                int exp = Int32.Parse(foo[1]);
                levelcurrent.text = exp.ToString();
                exp += 1;
                levelnext.text = exp.ToString();
            }

            if (message.StartsWith("A"))
            {
                message = message.TrimStart('A');
                //int achievementid = Int32.Parse(message);
                GameObject achievement = Instantiate(achievementsprefab, achievementsfield.transform);
                achievmentdisplay script = achievement.GetComponent<achievmentdisplay>();
                script.display("Achievment Unlocked - "+achievements[message].title+"!", achievements[message].desc);
                achievements[message].display.GetComponent<rewarddisplay>().dim();
                Debug.Log("Achievement! "+message);
                StartCoroutine(getmydecks());
                StartCoroutine(getinventory());

            }

        }
    }
        public IEnumerator getevents()
    {
        API api = new API();
        WWWForm form = new WWWForm();
        yield return StartCoroutine(api.request("getevents", form));
        var data = JSON.Parse(api.apiResult);
        yield return StartCoroutine(api.request("getmyevents", form));
        var mydata = JSON.Parse(api.apiResult);
        Debug.Log("result: " + api.apiResult);
        Debug.Log(data);
        Debug.Log(mydata);

        foreach (JSONNode eventdata in data["events"].AsArray)
        {

            GameObject temp;
            if (eventsdisplayed.TryGetValue(eventdata["EventId"].AsInt, out temp))
            {
                eventscript es = eventsdisplayed[eventdata["EventId"].AsInt].GetComponent<eventscript>();
                es.joinfield.SetActive(true);
                es.statusfield.SetActive(false);
                continue;
            }
            Debug.Log("not already displayed");
            GameObject go = Instantiate(eventprefab, eventsfield.transform) as GameObject;
            eventscript eventscript = go.GetComponent<eventscript>();
            string[] entryoptions = eventdata["EntryFees"].Value.Split(',');
            foreach (string entryoption in entryoptions ) {
                GameObject go2 = Instantiate(joinbuttonprefab, eventscript.joinfield.transform) as GameObject;
                TextMeshProUGUI textfield=go2.GetComponentInChildren<TextMeshProUGUI>();
                string[] costs = entryoption.Split(':');
                joinbuttonscript buttonscript = go2.GetComponent<joinbuttonscript>();
                if (buttonscript == null )
                {
                    Debug.Log("IT's null!!!!!!!");
                }
                buttonscript.cc = self;
                buttonscript.currency = costs[1];
                buttonscript.eventid = eventdata["EventId"].AsInt;
                if (costs[1].Contains("Gold"))
                {
                    textfield.text = costs[0] + "  <sprite index=2>";
                }

                else if (costs[1].Contains("Ticket"))
                {
                    textfield.text = costs[0] + "  <sprite index=1>";
                }
                else if (costs[1].Contains("Gems"))
                {
                    textfield.text = costs[0] + "  <sprite index=3>";
                }
                else
                {
                    textfield.text = costs[0] + " "+costs[1];
                }
                //textfield.text = entryoption;
            }
            eventsdisplayed[eventdata["EventId"].AsInt] = go;

        }
        foreach (JSONNode ineventdata in mydata["result"].AsArray)
        {

            if (ineventdata["eventid"] == 0)
            {
                Debug.Log("null");
                continue;
            }
            eventscript es = eventsdisplayed[ineventdata["eventid"].AsInt].GetComponent<eventscript>();
            es.joinfield.SetActive(false);
            es.statusfield.SetActive(true);
            es.Statustitle.text = ineventdata["Status"];
            dropbuttonscript db = eventsdisplayed[ineventdata["eventid"].AsInt].GetComponentInChildren<dropbuttonscript>();
            db.cc = self;
            db.eventid = ineventdata["eventid"].AsInt;
            if (ineventdata["Status"].ToString().Contains("Drafting"))
            {
                Debug.Log("we're drafting");
                es.draftbutton.SetActive(true);

                es.draftbutton.GetComponent<draftbutton>().draftid = db.eventid.ToString();

                es.queuebutton.SetActive(false);
                draftData draftinfo;
                if (draftdata.TryGetValue(db.eventid.ToString(), out draftinfo))
                {
                    Debug.Log("We already know about this draft");
                }else
                {
                    //we just found out about this draft so we need to create prefabs and such
                    Debug.Log("spawning draft");
                    draftdata[db.eventid.ToString()] = new draftData
                    {
                        PickHistorySkus = new List<string>(),
                        CurrentPickSkus = new List<string>()
                    };
                    GameObject go = Instantiate(draftprefab);
                    draftdata[db.eventid.ToString()].displayobj = go;
                    go.GetComponent<Canvas>().enabled = false;
                    draft draftscript = go.GetComponent<draft>();
                    draftscript.cc = self;
                    draftscript.eventid = db.eventid;
                    draftscript.data = draftdata[db.eventid.ToString()];

                    form = new WWWForm();
                    form.AddField("event", db.eventid.ToString());
                    
                    Coroutine coroutine = StartCoroutine(api.request("draft", form));
                    yield return coroutine;
                    var mydraftdata = JSON.Parse(api.apiResult);

                    foreach (JSONNode card in mydraftdata["result"]["cardspicked"].AsArray)
                    {
                        
                        draftdata[db.eventid.ToString()].PickHistorySkus.Add(card.Value);
                    }
                    foreach (JSONNode card in mydraftdata["result"]["cardsavailable"].AsArray)
                    {
                        draftdata[db.eventid.ToString()].CurrentPickSkus.Add(card.Value);
                    }

                    draftscript.updatedisplay();





                }
            }else
            {
                Debug.Log("We're not drafting" + ineventdata["Status"]);
                es.eventinfo = ineventdata;
                es.draftbutton.SetActive(false);
                es.queuebutton.SetActive(true);
                if (ineventdata["Status"].ToString().Contains("Queued") )
                {
                    Debug.Log("Already Queued/joined");
                    es.queuebutton.SetActive(false);
                }
                if (ineventdata["Status"].ToString().Contains("Playing"))
                {
                    Debug.Log("Already Queued/joined");
                    es.queuebutton.SetActive(false);
                }
            }
        }

    }
    public IEnumerator joinconqueue(string deckid)
    {

        API api = new API();
        WWWForm form = new WWWForm();
        //Debug.Log(eventinfo.ToString(0));
        form.AddField("deckid", deckid);
        yield return StartCoroutine(api.request("joinqueue", form));
        var data = JSON.Parse(api.apiResult);
        
        if (data["status"].ToString().Contains("failed")) { 
            showerror(api.apiResult);
        }
        yield return StartCoroutine(getevents());
        deckselector.SetActive(false);
        StartCoroutine(getqueues());
    }
    private IEnumerator clientachievement(int achievement, int progress)
    {
        API api = new API();
        WWWForm form = new WWWForm();
        form.AddField("achievement", achievement.ToString());
        form.AddField("progress", progress.ToString());
        yield return StartCoroutine(api.request("claimachievement", form));
    }
        private IEnumerator getinventory()
    {
        API api = new API();
        WWWForm form = new WWWForm();
        yield return StartCoroutine(api.request("getinventory", form));
        var data = JSON.Parse(api.apiResult);

        foreach (JSONNode item in data["skus"])
        {

            string sku = item["sku"];
            inventory[sku] = new Inventory();
            inventory[sku].number = item["number"];
            if (item["accountbound"].AsInt > 0)
            {
                inventory[sku].accountbound = true;
            }
            if (sku.Equals("Currency.Gold"))
            {
                gold.text = item["number"].AsInt.ToString("N0");
            }
            if (sku.Equals("Currency.Ticket"))
            {
                ticket.text = item["number"].AsInt.ToString("N0");

            }
            if (sku.Equals("Currency.Gems"))
            {
                greengem.text = item["number"].AsInt.ToString("N0");

            }
            if (sku.StartsWith("pack.")) {
                GameObject go = Instantiate(packprefab, packfield.transform);
                pack foo = go.GetComponent<pack>();
                foo.info(sku, item["number"]);

            }
        }
    }
    public void focusrewards()
    {
        switchfocus("Rewards");

    }
    public void focuspacks()
    {
        switchfocus("Packs");

    }
    public void switchfocus(string gameid)
    {
        //focusobj = null;
        focusedGameId = 0;

        login.GetComponent<Canvas>().enabled = false;
        deckeditor.GetComponent<Canvas>().enabled = false;
        Debug.Log("switching to " + gameid);
        //no. dont deactivate. just hide
        main.GetComponent<Canvas>().enabled = false;
        Tutorial.GetComponent<Canvas>().enabled = false;
        Tutorial2.GetComponent<Canvas>().enabled = false;
        Tutorial3.GetComponent<Canvas>().enabled = false;
        deckeditor.GetComponent<Canvas>().enabled = false;
        rewardsfield.GetComponent<Canvas>().enabled = false;
        packsdisplay.GetComponent<Canvas>().enabled = false;
        //we will need to loop through all games and turn their focus off.
        if (focusobj != null)
        {
            focusobj.GetComponent<Canvas>().enabled = false;
        }
        if (Int32.TryParse(gameid, out int gameidint))
        {

            if (gamesrunning.TryGetValue(gameidint, out GameObject foo))
            {
                focusobj = foo;
                foo.GetComponent<Canvas>().enabled = true;
                tooltipmanager.GuiCanvas = foo.GetComponent<Canvas>();

            }
        }
        //this is hitting the main screen.
        if (gameid.Equals("Main"))
        {

            main.GetComponent<Canvas>().enabled = true;
            tooltipmanager.GuiCanvas = main.GetComponent<Canvas>();
            focusobj = main;

            //go through any ended games and destroy them.
          //  ClearEndedGames();
        }

        if (gameid.Equals("Login"))
        {
            login.GetComponent<Canvas>().enabled = true;
            tooltipmanager.GuiCanvas = login.GetComponent<Canvas>();
            
            focusobj = login;
        }
        if (gameid.Equals("Deck"))
        {
            deckeditor.GetComponent<Canvas>().enabled = true;
            tooltipmanager.GuiCanvas = deckeditor.GetComponent<Canvas>();
            focusobj = deckeditor;
            deckeditor.GetComponent<deckeditor>().filter();
        }
        if (gameid.Equals("Rewards"))
        {
            rewardsfield.GetComponent<Canvas>().enabled = true;
            tooltipmanager.GuiCanvas = rewardsfield.GetComponent<Canvas>();
            focusobj = rewardsfield;
            
        }
        if (gameid.Equals("Packs"))
        {
            packsdisplay.GetComponent<Canvas>().enabled = true;
            tooltipmanager.GuiCanvas = rewardsfield.GetComponent<Canvas>();
            focusobj = packsdisplay;

        }
        if (gameid.Equals("Tutorial"))
        {
            Tutorial.GetComponent<Canvas>().enabled = true;
            tooltipmanager.GuiCanvas = Tutorial.GetComponent<Canvas>();
            focusobj = Tutorial;

        }
        if (gameid.Equals("Tutorial2"))
        {
            Tutorial2.GetComponent<Canvas>().enabled = true;
            tooltipmanager.GuiCanvas = Tutorial2.GetComponent<Canvas>();
            focusobj = Tutorial2;

        }
        if (gameid.Equals("Tutorial3"))
        {
            Tutorial3.GetComponent<Canvas>().enabled = true;
            tooltipmanager.GuiCanvas = Tutorial3.GetComponent<Canvas>();
            focusobj = Tutorial3;
            // do the client based achievement here... 
            StartCoroutine(clientachievement(8, 1));

        }
        draftData bar;
        string a = focus.Substring(0, 1);
        string draft = focus.Substring(1, focus.Length - 1);
        if (a.Equals("D"))
        {
            if (draftdata.TryGetValue(draft, out bar))
            {
                draftdata[draft].displayobj.GetComponent<Canvas>().enabled = false;
            }
        }

        a = gameid.Substring(0, 1);
        draft = gameid.Substring(1, gameid.Length - 1);
        if (a.Equals("D"))
        {
            if (draftdata.TryGetValue(draft, out bar))
            {
                Debug.Log("getting draft data: " + draft);
                draftdata[draft].displayobj.GetComponent<Canvas>().enabled = true;
                tooltipmanager.GuiCanvas = draftdata[draft].displayobj.GetComponent<Canvas>();
                focusobj = draftdata[draft].displayobj;
                //switch screen sound

            }
        }


        tooltipmanager.TooltipContainer.transform.SetParent(null);
        focus = gameid;
    }
    public static string UppercaseFirst(string s)
    {
        // Check for empty string.
        if (string.IsNullOrEmpty(s))
        {
            return string.Empty;
        }
        // Return char and concat substring.
        return char.ToUpper(s[0]) + s.Substring(1);
    }
}



public class GAMEAPI
{
    public static string session = "";
    public string apiResult;
    public static ClientControl cc;

    public IEnumerator request(string script, WWWForm form)
    {
        string urlbase = "https://kaelari.tech/ksgame/";
        string url = urlbase + script + ".cgi";

        if (session.Length > 0)
        {
            form.AddField("session", session);
        }
        UnityWebRequest download = UnityWebRequest.Post(url, form);
        yield return download.SendWebRequest();

        if (download.isNetworkError || download.isHttpError)
        {
            Debug.Log("Error downloading: " + download.url + " - " + download.error + " " + download.downloadHandler.text);
            apiResult = "Error " + download.error + download.downloadHandler.text;
            cc.showerror(apiResult);
            apiResult = "";
        }
        else
        {
            apiResult = download.downloadHandler.text;

        }


        yield break;

    }

}
public class API
{
    public static string session="";
    public static ClientControl cc;
    public string apiResult;
    
    public IEnumerator request(string script, WWWForm form)
    {
        string urlbase = "https://kaelari.tech/ksplatform/";
        string url = urlbase + script + ".cgi";
        
        if (session.Length > 0)
        {
            form.AddField("session", session);
        }
        UnityWebRequest download = UnityWebRequest.Post(url, form);
        yield return download.SendWebRequest();
        //Debug.Log("sent request to "+url);
        
        if (download.isNetworkError || download.isHttpError)
        {
            Debug.Log("Error downloading: " +download.url+" - "+ download.error+" "+ download.downloadHandler.text);
            apiResult = "Error "+download.error+download.downloadHandler.text;
            cc.showerror(apiResult);
            apiResult = download.downloadHandler.text; 
        }
        else
        {
            //Debug.Log(download.downloadHandler.text);
            apiResult = download.downloadHandler.text;
            
        }

        //Debug.Log("returning from " + url);
        yield break;

    }
    
}
public class Inventory
{
    public int number = 0;
    public bool accountbound = false;

}
public class card
{
    public string name;
    public int AttackType;
    public string CardArt;
    public string FlavorText;
    public string Tooltips;
    public int level;
    public int Health;
    public string rarity;
    public int Cost;
    public int Attack;
    public int Shield;
    public string text;
    public string CardType;
    public string faction;
    public string Threshold;
    public string subtype;
    public int CardId;
    public int levelsfrom;
    public int levelsto;
    public List<string> keywords = new List<string>();

}
public class achievementclass
{
    public string title;
    public string desc;
    public int xp;
    public int progress;
    public int progressneeded;
    public GameObject display;
    public int achievementid;
    public bool earned;
    public string expires;

}

    public class draftData
{
    public string eventId;
    public string DraftStateId;
    public string CurrentPickKey;
    //public string[] CurrentPickSkus;
    public List<string> CurrentPickSkus;
    //public string[] PickHistorySkus;
    public List<string> PickHistorySkus;
    public int NumTotalPicksLeft;
    public GameObject displayobj;
}