using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class draftbutton : MonoBehaviour {
    public string draftid;
    ClientControl cc;

    public void switchtodraft()
    {
        Debug.Log("A");
        cc.switchfocus("D" + draftid);



    }
	// Use this for initialization
	void Start () {
        cc   = FindObjectOfType<ClientControl>();
    }

	// Update is called once per frame
	void Update () {

	}
}
