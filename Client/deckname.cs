using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class deckname : MonoBehaviour
{
    public TextMeshProUGUI namefield;
    public string deckid;
    ClientControl cc;

    public void changename (string newname)
    {
        namefield.text = newname;
    }

    public void clicked ()
    {
        Debug.Log("clicked! " + cc.name);
        StartCoroutine( cc.joinconqueue(deckid));
        
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
