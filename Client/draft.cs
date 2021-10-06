using SimpleJSON;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class draft : MonoBehaviour {
    public ClientControl cc;
    public draftData data = new draftData();
    public GameObject cardstopickfield;
    public GameObject cardspickedfield;
    public GameObject cardsindraftprefab;
    public GameObject cardstodraftprefab;
    public int eventid;
    public GameObject fullcarddisplay;
    public cardinhand[] carddisplay;

    public void updatedisplay()
    {
        //int z = 0;
        foreach (Transform child in cardstopickfield.transform)
        {
            Destroy(child.gameObject);
            Debug.Log("destroyed something: "+child.gameObject);
        }
        foreach (Transform child in cardspickedfield.transform)
        {
            Destroy(child.gameObject);
            Debug.Log("destroyed something");
        }
        Dictionary<string, int> combined = new Dictionary<string, int>();

        foreach (string cardid in data.PickHistorySkus)
        {
            if (combined.TryGetValue(cardid, out int value)){
                Debug.Log("new value");
                combined[cardid] ++;
            }else
            {
                
                combined[cardid] = 1;
            }
        }
        foreach (string cardid in combined.Keys)
        {
            GameObject go = Instantiate(cardsindraftprefab, cardspickedfield.transform);

            cardindraftdeck script =go.GetComponent<cardindraftdeck>();
            script.cc = cc;
            script.becomecard(cardid, combined[cardid]);
        }
        foreach (string cardid in data.CurrentPickSkus)
        {
            GameObject go = Instantiate(cardstodraftprefab, cardstopickfield.transform);

            draftcard script = go.GetComponent<draftcard>();

            script.cc = cc;
            script.cardid = cardid;
            script.draft = this;
            script.becomecard(cardid);
        }
    }

    public void updatedata (string dataasstring)
    {
        var mydraftdata = JSON.Parse(dataasstring);

        Debug.Log("cards picked: " + mydraftdata["result"].ToString(0));
        data.PickHistorySkus.Clear();
        if (mydraftdata["result"].ToString().Contains("Draft Complete"))
        {
            cc.switchfocus("Main");
            StartCoroutine(cc.getevents());
            
            return;
        }
        foreach (JSONNode card in mydraftdata["result"]["cardspicked"].AsArray)
        {
            Debug.Log(card.ToString());

            data.PickHistorySkus.Add(card.Value);
        }
        data.CurrentPickSkus.Clear();
        foreach (JSONNode card in mydraftdata["result"]["cardsavailable"].AsArray)
        {
            data.CurrentPickSkus.Add(card.Value);
        }
    }

    // Use this for initialization
    void Start () {

	}

	// Update is called once per frame
	void Update () {

	}
    public void gomain()
    {
        cc.switchfocus("Main");
    }
}
