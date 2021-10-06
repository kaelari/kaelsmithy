using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class rewarddisplay : MonoBehaviour
{
    public TextMeshProUGUI titlefield;
    public TextMeshProUGUI descfield;
    public TextMeshProUGUI xpfield;
    public TextMeshProUGUI progressfield;
    public Image blackout;
    public void dim()
    {
        blackout.color = new Color32(0, 0, 0, 180);
    }
    public void setup(string title, string desc, string xp, string progress)
    {
        titlefield.text = title;
        descfield.text = desc;
        xpfield.text = xp;
        progressfield.text = progress;
    }


    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
