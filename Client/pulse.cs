using SimpleJSON;
using UnityEngine;
using UnityEngine.UI;

public class pulse : MonoBehaviour
{
    public float alphaChange;
    public float minAlpha;
    public float maxAlpha;
    public bool hovered = false;
    public cardinhand card;
    public bool special;
    public Color highlight;
    public Color targethighlight;
    public Color hoverhighlight;
    public Color playinghighlight;
    // Update is called once per frame
    void Update()
    {
        //TODO improvements required here
        
        if (card.gamescriptlink == null)
        {
            return;
        }
        if (card.gamescriptlink.turn == card.gamescriptlink.weare && card.gamescriptlink.targetting== false && card.gamescriptlink.handplayable.TryGetValue(card.cardnumber.ToString(), out JSONNode value ))
        {
            if (card.hovering)
            {
                GetComponent<Image>().color = hoverhighlight;
            }
            else
            {

                GetComponent<Image>().color = highlight;
            }

        }else if (card.gamescriptlink.targetting == true && card.gamescriptlink.highlight.TryGetValue(card.cardnumber.ToString(), out bool found) )
        {
            if (card.hovering)
            {
                GetComponent<Image>().color = hoverhighlight;
            }
            else
            {
                GetComponent<Image>().color = targethighlight;
            }
        }
        else if (card.gamescriptlink.selectedinhand == card )
        {
            GetComponent<Image>().color = playinghighlight;
        }
        else 
        {
            Color c = GetComponent<Image>().color;
            c.a = 0;
            GetComponent<Image>().color = c;

        }
    }
}
