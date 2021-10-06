using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class joinbuttonscript : MonoBehaviour {
    public ClientControl cc;
    public string currency;
    public int eventid;

    public void clickedon ()
    {

        StartCoroutine(joinevent(eventid));

    }

    public IEnumerator joinevent(int eventid)
    {
        API api = new API();
        WWWForm form = new WWWForm();
        form.AddField("event", eventid);
        form.AddField("sku", currency);
        yield return StartCoroutine(api.request("joinevent", form));
        Debug.Log("joinresult: "+ api.apiResult);
        cc.fetchevents();
    }

	// Use this for initialization
	void Start () {

	}

	// Update is called once per frame
	void Update () {

	}
}
