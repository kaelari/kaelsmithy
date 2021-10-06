using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;

public class clickonlog : MonoBehaviour, IPointerClickHandler
{
    TextMeshProUGUI pTextMeshPro;
    ClientControl cc;
    gamecontroller gamescriptlink;

    public void OnPointerClick(PointerEventData eventData)
    {
        Debug.Log("clicked on log");
        int linkIndex = TMP_TextUtilities.FindIntersectingLink(pTextMeshPro, eventData.position, null);
        if (linkIndex != -1)
        { // was a link clicked?
            TMP_LinkInfo linkInfo = pTextMeshPro.textInfo.linkInfo[linkIndex];

            // open the link id as a url, which is the metadata we added in the text field
            Debug.Log("Clicked on link! " + linkInfo.GetLinkID());
            Debug.Log("Right clicked on card: " + linkInfo.GetLinkID().ToString() + " " + gamescriptlink.ToString());
            gamescriptlink.fullcarddisplay.SetActive(true);
            cardinhand[] foo = gamescriptlink.fullcarddisplay.GetComponentsInChildren<cardinhand>();

            //.setrawcardnumber( int.Parse(linkInfo.GetLinkID()));
            card carddata = cc.allcards[linkInfo.GetLinkID()];
            while (carddata.levelsfrom > 0)
            {
                carddata = cc.allcards[carddata.levelsfrom.ToString()];
            }
            foo[0].setrawcardnumber(carddata.CardId);
            int a = 1;
            while (carddata.levelsto > 0)
            {
                foo[a].setrawcardnumber(carddata.levelsto);

                carddata = cc.allcards[carddata.levelsto.ToString()];
                a += 1;
                if (carddata.levelsto == carddata.CardId)
                {
                    break;
                }
            }
            while (a < 3)
            {
                gamescriptlink.displaycards[a].gameObject.SetActive(false);
                a += 1;
            }


            return;


        }
    }
    public void Start()
    {
        gamescriptlink = GetComponentInParent<gamecontroller>();
        pTextMeshPro = GetComponent<TextMeshProUGUI>();
        cc = FindObjectOfType<ClientControl>();
    }


}
