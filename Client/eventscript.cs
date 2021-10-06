using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using System.Runtime.CompilerServices;

public class eventscript : MonoBehaviour {
    public GameObject statusfield;
    public GameObject joinfield;
    public GameObject title;
    public TextMeshProUGUI Statustitle;
    public SimpleJSON.JSONNode eventinfo;
    public GameObject queuebutton;
    public GameObject draftbutton;
    public ClientControl cc;
    public bool constructed = false;

    public void Start()
    {
        cc = FindObjectOfType<ClientControl>();

    }

    public void clickedjoinqueue()
    {
        if (constructed)
        {
            //need to open deck selector
            cc.deckselector.SetActive(true);
        }
        else
        {
            StartCoroutine(queue());
        }
    }
    public IEnumerator queue()
    {

        API api = new API();
        WWWForm form = new WWWForm();
        Debug.Log(eventinfo.ToString(0));

        form.AddField("eventid", eventinfo["rowid"].AsInt);

        yield return StartCoroutine(api.request("joinqueue", form));
        Debug.Log(api.apiResult);
        yield return StartCoroutine(cc.getevents() ) ;
        yield return StartCoroutine(cc.getqueues());


    }

}
