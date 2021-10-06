using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class gamelabelcontrol : MonoBehaviour
{
    public Text opponentname;
    public Text deckname;
    public string opponent;
    public string deck;
    public int gameid;
    public ClientControl cc;

    public void redraw()
    {
        opponentname.text = opponent;
        deckname.text = deck;
    }

    public void play()
    {
        cc.switchfocus(gameid.ToString());

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
