using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class deckoption : MonoBehaviour
{
    deckeditor de;
    string deckname;
    public TextMeshProUGUI decknamefield;
    public GameObject parent;

    public void changedeckname (string newdeckname)
    {
        deckname = newdeckname;
        decknamefield.text = deckname;
    }

    public void clickedon ()
    {
        de.loaddeck(deckname);
        de.closeload();
    }
    // Start is called before the first frame update
    void Start()
    {
        de = FindObjectOfType<deckeditor>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
