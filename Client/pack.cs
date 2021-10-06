using System.Collections;
using System.Collections.Generic;
using TMPro;

using UnityEngine;

public class pack : MonoBehaviour
{
    public string sku;
    public TextMeshProUGUI number;
    public int amountwehave;
    ClientControl cc;

    public void info(string newsku, int amount) { 
    
        sku = newsku;
        number.text = amount.ToString();
        amountwehave = amount;
    }

    public void click()
    {
        StartCoroutine( cc.openpack(sku) );
        amountwehave -= 1;
        number.text = amountwehave.ToString();
    }

    void Start()
    {
        cc = FindObjectOfType<ClientControl>();
    }

}
