using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class levelreward : MonoBehaviour
{
    // Start is called before the first frame update

    public Image iconfield;
    public TextMeshProUGUI levelfield;
    public TextMeshProUGUI amountfield;
    public List<Sprite> sprites;
    Dictionary<string, Sprite> images = new Dictionary<string, Sprite>();
    public int ourlevel = 0;
    public Image blackout;
    public void dim()
    {
        blackout.color = new Color32(0, 0, 0, 180);
    }
    public void redraw(int level, int amount, string icon)
    {
        images["Currency.Gold"] = sprites[0];
        images["Currency.Gems"] = sprites[1];
        images["Currency.Ticket"] = sprites[2];


        levelfield.text = level.ToString();
        ourlevel = level;
        amountfield.text = amount.ToString();
        Sprite outvar;
        if (images.TryGetValue(icon, out outvar))
        {
            iconfield.sprite = images[icon];
        }
        
    }
    
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
