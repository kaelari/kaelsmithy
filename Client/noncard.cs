using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class noncard : MonoBehaviour
{
    public Image image;
    public TextMeshProUGUI text;
    
    public void set(string imagename, string newtext)
    {
        text.text = newtext;
        if (imagename.Contains("pack.basic"))
        {
            image.sprite = Resources.Load<Sprite>("Sprites/pack1");
        }
        else if (imagename.Contains("pack"))
        {
            image.sprite = Resources.Load<Sprite>("Sprites/pack2");
        }
        if (imagename.Contains("Currency.Gold"))
        {
            image.sprite = Resources.Load<Sprite>("Sprites/Icon_Gems");
        }
        if (imagename.Contains("Currency.Gems"))
        {
            image.sprite = Resources.Load<Sprite>("Sprites/Icon_Emerald");
        }
        if (imagename.Contains("Currency.Ticket"))
        {
            image.sprite = Resources.Load<Sprite>("Sprites/ticket");
        }
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
