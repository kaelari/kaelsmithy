using SimpleJSON;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class highlight : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    // Start is called before the first frame update
    public Image highlightfield;
    public gamecontroller gamescriptlink;
    public string lane;
    public bool hovering = false;
    public string l;
    public string cardnumber;
    public void OnPointerEnter(PointerEventData eventdata)
    {
        hovering = true;
    }
    public void OnPointerExit(PointerEventData eventdata)
    {
        hovering = false;
    }

    // Update is called once per frame
    void Update()
    {
        if (gamescriptlink.selectedinplay == null && gamescriptlink.selectedinhand == null && gamescriptlink.handplayable.TryGetValue(cardnumber, out JSONNode foo) ){
            Color color = highlightfield.color;
            color.b = 0;
            color.r = 255;
            color.g = 0;
            color.a = 255;
            highlightfield.color = color;
            if (hovering)
            {
                highlightfield.color = new Color(1.0f, 0.0f, 1.0f, 1.0f);
            }
        }
        else if (gamescriptlink.highlight.TryGetValue(lane, out bool value ) )
        {
            Color color = highlightfield.color;
            color.b = 255;
            color.r = 0;
            color.g = 0;
            color.a = 255;
            highlightfield.color = color;
            if (hovering)
            {
                highlightfield.color = new Color(1.0f, 0.0f, 1.0f, 1.0f);
            }
        }
        else
        {
            Color color = highlightfield.color;
            color.b = 255;
            color.r = 255;
            color.g = 255;
            color.a = 0;
            highlightfield.color = color;
        }
    }
}
