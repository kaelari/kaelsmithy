using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;

public class login : MonoBehaviour {
    public InputField usernamefield;
    public InputField passwordfield;
    public string username;
    string password;
    







    // Use this for initialization
    void Start () {
        usernamefield.text = PlayerPrefs.GetString("username", "");
        passwordfield.text = PlayerPrefs.GetString("password", "");
    }

	// Update is called once per frame
	void Update () {

	}
}
