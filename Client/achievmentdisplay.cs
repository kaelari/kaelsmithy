using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class achievmentdisplay : MonoBehaviour
{
    // Start is called before the first frame update
    public TextMeshProUGUI textfield;
    public TextMeshProUGUI titlefield;

    public ClientControl cc;
    public float lifetime;
    public void display(string title, string text)
    {
        textfield.text = text;
        titlefield.text = title;
    }
    void Start()
    {
        lifetime = 10.0f;
        cc = FindObjectOfType<ClientControl>();
    }

    // Update is called once per frame
    void Update()
    {
        if (cc.focus.Equals("Main"))
        {
            lifetime -= Time.deltaTime;
            if (lifetime<0)
            {
                Destroy(this.gameObject);
            }
        }
    }
}
