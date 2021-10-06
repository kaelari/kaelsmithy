using SimpleJSON;
using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;


public class deckeditor : MonoBehaviour
{
    public int deckid = 0;
    ClientControl cc;
    public GameObject[] cards;
    List<int> Cardsinview;
    Dictionary<int, int> Cardsindeck = new Dictionary<int, int>();

    public int offset = 0;
    public Button nextbutton;
    public Button prevbutton;
    List<int> possiblecards = new List<int>();
    public GameObject deckfield;
    public GameObject cardindeckprefab;
    public TextMeshProUGUI count;
    public TMP_InputField decknamefield;
    public GameObject loadoptionsfield;
    public GameObject loaddecksfield;
    public GameObject deckprefab;
    public GameObject savefield;
    public GameObject savecomplete;
    public GameObject filters;
    public TextMeshProUGUI errorsfield;
    public TMP_Dropdown savedeckslist;
    public Dictionary<string, bool> filterswitches = new Dictionary<string, bool>();
    public TMP_InputField filtername;
    public TMP_InputField filtertext;
    public TMP_InputField filterkeywords;
    public TMP_InputField filtersubtype;
    public Toggle owned;
    public Toggle ships;
    public Toggle effects;
    public Toggle Helkinite;
    public Toggle Dralk;
    public Toggle Mars;
    public Toggle Earth;
    public GameObject fullcarddisplay;
    public cardinhand[] carddisplay;

    public void openfilters()
    {
        filters.SetActive(true);
    }
    public void closefilters()
    {
        filters.SetActive(false);
        filter();
    }
    public void openload()
    {
        foreach (Transform child in loaddecksfield.transform)
        {
            GameObject.Destroy(child.gameObject);
        }
        loadoptionsfield.SetActive(true);
        foreach (JSONNode deck in cc.decks.Values)
        {
            Debug.Log(deck.ToString());
            GameObject go = Instantiate(deckprefab, loaddecksfield.transform);
            Debug.Log("made deck: " + deck["deckname"]);
            deckoption script = go.GetComponent<deckoption>();
            script.changedeckname(deck["deckname"]);


        }
    }
    public void closeload()
    {
        foreach (Transform child in loaddecksfield.transform)
        {
            GameObject.Destroy(child.gameObject);
        }
        loadoptionsfield.SetActive(false);
    }
    public void removefromdeck(int cardid)
    {
        int cardidout;
        if (Cardsindeck.TryGetValue(cardid, out cardidout))
        {
            Cardsindeck[cardid] -= 1;
            if (Cardsindeck[cardid] <= 0)
            {
                Cardsindeck.Remove(cardid);
            }
        }
        redrawdeck();
    }

    public void loaddeck ( string newdeckname)
    {
        Debug.Log("loading deck " + newdeckname);
        Cardsindeck = new Dictionary<int, int>();
        decknamefield.text = newdeckname;
        string cards = cc.decks[newdeckname]["cards"];
        string[] deckcards = cards.Split(',');
        foreach (string cardid in deckcards)
        {
            
            addtodeck_inner(Int32.Parse(cardid));
        }
        redrawdeck();
        filter();
    }

    public IEnumerator save_inner( string cards, string deckname, int deckid)
    {
        WWWForm form = new WWWForm();
        form.AddField("deck", cards);
        form.AddField("deckname", deckname);
        form.AddField("deckid", deckid);

        // Create a download object
        API api = new API();

        // Wait until the download is done
        yield return StartCoroutine(api.request("savedeck", form));
        Debug.Log("finished saving. " + api.apiResult.ToString());
        StartCoroutine(cc.getmydecks());
        savefield.SetActive(false);
        savecomplete.SetActive(true);
    }
    public void closesaveconfirm()
    {
        savecomplete.SetActive(false);

    }
    public void savenew()
    {
        string cardlist = "";
        foreach (int card in Cardsindeck.Keys)
        {
            int z = 0;
            while (z < Cardsindeck[card])
            {
                if (cardlist.Length == 0)
                {
                    cardlist += card.ToString();
                }
                else
                {
                    cardlist += ", " + card.ToString();
                }
                z++;
            }
        }
        StartCoroutine(save_inner(cardlist, decknamefield.text, 0));

    }
    public void hidesave()
    {
        savefield.SetActive(false);
    }
    public void opensave()
    {
        savefield.SetActive(true);
        errorsfield.text = "";
        List<string> errors = new List<string>();
        int totalcards = 0;
        Dictionary<string, int> factions = new Dictionary<string, int>();

        foreach (int cards in Cardsindeck.Keys)
        {
            totalcards += Cardsindeck[cards];
            factions.TryGetValue(cc.allcards[cards.ToString()].faction, out int number);
            if (number > 0)
            {
                factions[cc.allcards[cards.ToString()].faction] += 1;
            }else
            {
                factions[cc.allcards[cards.ToString()].faction] = 1;
            }
            string key = "card." + cards.ToString();
            Inventory card;
            int wehave = 0;
            if (cc.inventory.TryGetValue(key, out card ))
            {
                wehave = card.number;
            }

            if (wehave < Cardsindeck[cards] )
            {
                int amount = Cardsindeck[cards] - wehave ;
                //errors.Add("Unowned Card: "+amount+"x " + cc.allcards[cards.ToString()].name);
            }
        }
        if (factions.Count > 2)
        {
            errors.Add("To many factions, limit of 2");
        }
        if (totalcards < 30)
        {
            errors.Add("Not enough cards! Only "+totalcards+" cards");
        }
        if (totalcards > 30)
        {
            errors.Add("Too many cards!");
        }
        if (decknamefield.text.Length == 0)
        {
            errors.Add("No deck name!");
        }
        if (errors.Count >0 )
        {
            string errorstring= "Errors/Warnings\r\n";
            foreach (string foo in errors)
            {
                errorstring += foo + "\r\n";
            }
            Debug.Log(errorstring);
            errorsfield.text = errorstring;
        }
        List<string> m_DropOptions = new List<string>();
        int index=0;
        m_DropOptions.Add("None");
        foreach (JSONNode deck in cc.decks.Values)
        {
            Debug.Log(deck.ToString());
            m_DropOptions.Add(deck["deckname"]);
            if (decknamefield.text.Equals(deck["deckname"]))
            {
                index = m_DropOptions.Count - 1;
            }
        }
        savedeckslist.ClearOptions();
        savedeckslist.AddOptions(m_DropOptions);
        savedeckslist.value = index;


    }

    public void overwrite ()
    {
        int index = 0;
        foreach (JSONNode deck in cc.decks.Values)
        {
            Debug.Log(deck.ToString());
            if (savedeckslist.options[savedeckslist.value].text.Equals(deck["deckname"]) ){
                index = deck["deckid"];
            }

        }
        string cardlist = "";
        foreach (int card in Cardsindeck.Keys)
        {
            int z = 0;
            while (z < Cardsindeck[card])
            {
                if (cardlist.Length == 0)
                {
                    cardlist += card.ToString();
                }
                else
                {
                    cardlist += ", " + card.ToString();
                }
                z++;
            }
        }
        StartCoroutine(save_inner(cardlist, decknamefield.text, index));


    }
    public void save ()
    {
        string cardlist = "";
        foreach (int card in Cardsindeck.Keys)
        {
            int z = 0;
            while (z < Cardsindeck[card])
            {
                if (cardlist.Length == 0)
                {
                    cardlist += card.ToString();
                }else
                {
                    cardlist += ", " + card.ToString();
                }
                z++;
            }
        }

        Debug.Log(cardlist);

        StartCoroutine(save_inner(cardlist, decknamefield.text, deckid));

    }
    public void newdeck()
    {
        
        Cardsindeck = new Dictionary<int, int>();
        redrawdeck();
        decknamefield.text = "";
    }
    public void addtodeck_inner (int newcardid)
    {
        int cardidout;
        if (Cardsindeck.TryGetValue(newcardid, out cardidout))
        {
            Cardsindeck[newcardid] += 1;
            if (Cardsindeck[newcardid] > 3)
            {
                Cardsindeck[newcardid] = 3;
            }
        }
        else
        {
            Cardsindeck[newcardid] = 1;
        }
        
    }
    public void addtodeck(int cardid)
    {
        Debug.Log("adding to deck: " + cardid);
        int newcardid = possiblecards[cardid + offset];
        addtodeck_inner(newcardid);
        redrawdeck();
    }

    public void redrawdeck()
    {
        int cardcount = 0;
        Debug.Log("deckfield: "+deckfield);
        foreach (Transform child in deckfield.transform)
        {
            Destroy(child.gameObject);
            Debug.Log("destroyed something: " + child.gameObject);
        }
        foreach (int cardid in Cardsindeck.Keys)
        {
            GameObject go = Instantiate(cardindeckprefab, deckfield.transform);
            Debug.Log("made card: " + cardid);
            cardindeck script = go.GetComponent<cardindeck>();
            script.cc = cc;
            script.becomecard(cardid.ToString(), Cardsindeck[cardid]);
            cardcount += Cardsindeck[cardid];
        }



        count.text = cardcount.ToString() + "/30";
    }

    public void nextpage ()
    {
        offset += 6;
        prevbutton.interactable = true;
        filter();
    }
    public void lastpage()
    {
        offset -= 6;
        if (offset <= 0)
        {
            prevbutton.interactable = false;
            offset = 0;
        }
        filter();
    }
    public void filter()
    {
        possiblecards = new List<int>();
        

        foreach (card card in cc.allcards.Values) {
            //we should check if the card passes filters;
            if (card.rarity.Equals("Token"))
            {
                continue;
            }
            if (card.level != 1)
            {
                continue;
            }
            if (filtername.text.Length > 0)
            {
                Debug.Log(filtername.text);
                Debug.Log(card.name);
                if (card.name.ToLower().Contains(filtername.text.ToLower()))
                {

                }
                else
                {
                    continue;
                }
            }

            if (filtersubtype.text.Length > 0)
            {
                
                if (card.subtype.ToLower().Contains(filtersubtype.text.ToLower()))
                {

                }
                else
                {
                    continue;
                }
            }

            if (filtertext.text.Length> 0 )
            {
                if (card.text.ToLower().Contains(filtertext.text.ToLower()))
                {

                }else
                {
                    continue;
                }
            }
            if (filterkeywords.text.Length > 0)
            {
                bool failed = true;
                foreach (string foo in card.keywords)
                {
                    if (foo.ToLower().Contains(filterkeywords.text.ToLower() ) )
                    {
                        failed = false;
                    }
                }
                if (failed)
                {
                    continue;
                }
            }
            if (Mars.isOn || Earth.isOn || Dralk.isOn || Helkinite.isOn)
            {
                if (card.faction.Equals("Mars"))
                {
                    if (!Mars.isOn)
                    {
                        continue;
                    }
                }
                if (card.faction.Equals("Earth"))
                {
                    if (!Earth.isOn)
                    {
                        continue;
                    }
                }
                if (card.faction.Equals("Dralk"))
                {
                    if (!Dralk.isOn)
                    {
                        continue;
                    }
                }
                if (card.faction.Equals("Helkinite"))
                {
                    if (!Helkinite.isOn)
                    {
                        continue;
                    }
                }

            }

            if (effects.isOn)
            {
                if (!card.CardType.Contains("Effect") )
                {
                    continue;
                }
            }
            if (ships.isOn)
            {
                if (!card.CardType.Contains("Ship") )
                {
                    continue;
                }
            }



            if (owned.isOn)
            {
                Inventory foo;
                if (cc.inventory.TryGetValue("card."+card.CardId.ToString(), out foo) )
                {

                }else
                {
                    continue;
                }
            }



            possiblecards.Add(card.CardId);
        }
        possiblecards.Sort((x, y) => cc.allcards[x.ToString()].name.CompareTo(cc.allcards[y.ToString()].name));
        int z = 0;
        if (offset > possiblecards.Count)
        {
            offset = 0;
        }
        foreach (int cardid in possiblecards)
        {
            if (z >= 6 || (z+offset >= possiblecards.Count) )
            {
                break;
            }
            cards[z].GetComponent<draftcard2>().becomecard(possiblecards[z+offset].ToString());
            cards[z].SetActive(true);
            z++;
        }
        nextbutton.interactable = true;

        while (z < 6)
        {
            
            cards[z].SetActive(false);
            z++;
        }
        if (z + offset >=possiblecards.Count)
        {
            nextbutton.interactable = false;
        }
        

    }

    // Start is called before the first frame update
    void Start()
    {
        cc = FindObjectOfType<ClientControl>();
        filterswitches["owned"] = true;
        filterswitches["R"] = false;
        filterswitches["G"] = false;
        filterswitches["B"] = false;
        filterswitches["T"] = false;
        filterswitches["Ship"] = false;
        filterswitches["Effect"] = false;


    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
