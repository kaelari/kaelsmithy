using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class dropbuttonscript : MonoBehaviour {
    public ClientControl cc;

    public int eventid;
    public void dropevent()
    {
        StartCoroutine( cc.dropevent(eventid.ToString()));

    }
    // Use this for initialization
    void Start () {

	}

	// Update is called once per frame
	void Update () {

	}
}
