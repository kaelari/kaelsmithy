using SimpleJSON;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class queuelabelcontrol : MonoBehaviour
{
    public ClientControl cc;
    public TextMeshProUGUI queuename;
    public TextMeshProUGUI deckname;
    public string deck;
    public string queue;
    public int queueid;
    public void redraw(string queue, string deck) 
    {

        queuename.text = "Queue - " + ClientControl.UppercaseFirst( queue);
        deckname.text = deck;
        
        
    }

    public void clickedon( )
    {
        
        StartCoroutine (cc.leavequeue(queueid.ToString()));

    }

    // Start is called before the first frame update
    void Start()
    {
        cc = FindObjectOfType<ClientControl>();
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
