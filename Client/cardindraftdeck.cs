using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;
using System;
using UnityEngine.EventSystems;

public class cardindraftdeck : MonoBehaviour, IPointerClickHandler
{
    public ClientControl cc;
    public string cardid;
    public TextMeshProUGUI cardname;
    public TextMeshProUGUI cost;
    public TextMeshProUGUI number;
    public bool draft;
    public draft deckeditor;

    public Image[] thresh;
    
    public void OnPointerClick(PointerEventData eventData)
    {
        if (eventData.button == PointerEventData.InputButton.Right)
        {
            Debug.Log("Right clicked on card: " + cardid + " ");
            deckeditor.fullcarddisplay.SetActive(true);

            Debug.Log(number);

            card carddata = cc.allcards[cardid];
            while (carddata.levelsfrom > 0)
            {
                carddata = cc.allcards[carddata.levelsfrom.ToString()];
            }
            deckeditor.carddisplay[0].setrawcardnumber(carddata.CardId);
            int a = 1;
            while (carddata.levelsto > 0)
            {
                deckeditor.carddisplay[a].gameObject.SetActive(true);
                deckeditor.carddisplay[a].setrawcardnumber(carddata.levelsto);

                carddata = cc.allcards[carddata.levelsto.ToString()];
                a += 1;
                if (carddata.levelsto == carddata.CardId)
                {
                    break;
                }
            }
            while (a < 3)
            {
                deckeditor.carddisplay[a].gameObject.SetActive(false);
                a += 1;
            }
            return;
        }
        else
        {
            // Do action
            Debug.Log("pointer click");
            if (!draft)
            {
                int card = Int32.Parse(cardid);
                //deckeditor.removefromdeck(card);
            }
        }
    }
    public void becomecard(string newcardid, int numberofcards)
    {
        card thiscard;
        cc.allcards.TryGetValue(newcardid, out thiscard);
        if (thiscard == null )
        {
            Debug.Log("Card not found!");
            return;
        }else
        {
            cardid = newcardid;
            number.text = numberofcards.ToString();
            cardname.text = thiscard.name;
            
            
        }

    }
    // Use this for initialization
    void Start () {
        
            deckeditor = GetComponentInParent<draft>();
        
	}

	// Update is called once per frame
	void Update () {

	}
}
