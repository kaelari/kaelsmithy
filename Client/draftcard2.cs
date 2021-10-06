using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class draftcard2 : MonoBehaviour, IPointerClickHandler
{
    public void OnPointerClick(PointerEventData eventData)
    {
        if (eventData.button == PointerEventData.InputButton.Right)
        {
            Debug.Log("Right clicked on card: " + cardnumber.ToString() + " ");
            de.fullcarddisplay.SetActive(true);

            Debug.Log(cardnumber);

            card carddata = cc.allcards[cardnumber.ToString()];
            while (carddata.levelsfrom > 0)
            {
                carddata = cc.allcards[carddata.levelsfrom.ToString()];
            }
            de.carddisplay[0].setrawcardnumber(carddata.CardId);
            int a = 1;
            while (carddata.levelsto > 0)
            {
                de.carddisplay[a].gameObject.SetActive(true);
               de.carddisplay[a].setrawcardnumber(carddata.levelsto);

                carddata = cc.allcards[carddata.levelsto.ToString()];
                a += 1;
                if (carddata.levelsto == carddata.CardId)
                {
                    break;
                }
            }
            while (a< 3)
            {
                de.carddisplay[a].gameObject.SetActive(false);
                a += 1;
            }
            return;
        }
        else
        {
            de.addtodeck(offset);
        }

    }
    public int offset;
    public deckeditor de;
    public ClientControl cc;
    public string cardid;
    public TextMeshProUGUI cardname;
    public TextMeshProUGUI cost;
    public Image cardartfield;
    public draft draft;
    public int cardnumber;
    public TextMeshProUGUI text;
    public TextMeshProUGUI attack;
    public TextMeshProUGUI health;
    public TextMeshProUGUI resistance;
    public TextMeshProUGUI armor;
    public GameObject spellplate;
    public Image attacktype;
    public Image cardart;
    public Image faction;
    public List<Image> thresh;
    public Canvas parentcanvas;
    public Canvas ourcanvas;
    public bool needupdate = true;
    public TextMeshProUGUI subtype;
    public void pickthis()
    {
        StartCoroutine(dopick());

    }
    public IEnumerator dopick()
    {
        API api = new API();
        WWWForm form = new WWWForm();
        form.AddField("event", draft.eventid);
        form.AddField("pick", cardid);
        yield return StartCoroutine(api.request("draft", form));
        Debug.Log(api.apiResult);
        draft.updatedata(api.apiResult);
        draft.updatedisplay();


    }

    public void becomecard(string newcardid)
    {
        card thiscard;
        cc.allcards.TryGetValue(newcardid, out thiscard);
        if (thiscard == null)
        {
            Debug.Log("Card not found!");
            return;
        }
        else
        {

            cardid = newcardid;
            cardnumber = System.Int32.Parse(newcardid);
            needupdate = true;

        }

    }
    // Use this for initialization
    void Start () {
        cc = FindObjectOfType<ClientControl>();
    }

	// Update is called once per frame
	void Update () {
        if (needupdate)
        {
            // we should do something here
            if (cc.allcards.TryGetValue(cardnumber.ToString(), out card cardexists))
            {

            }
            else
            {

                return;
            }
            string keywordstring="";
            if (cc.allcards[cardnumber.ToString()].keywords.Count > 0)
            {
                keywordstring = string.Join(", ", cc.allcards[cardnumber.ToString()].keywords);
                keywordstring += "\n";
            }
            text.text = keywordstring + cc.allcards[cardnumber.ToString()].text;
            
            cardname.text = cc.allcards[cardnumber.ToString()].name;
            subtype.text = cc.allcards[cardnumber.ToString()].subtype;

            Sprite factionicon = Resources.Load<Sprite>("Sprites/" + (cc.allcards[cardnumber.ToString()].faction));
            faction.sprite = factionicon;

            if (cc.allcards[cardnumber.ToString()].CardArt != null)
            {
                Sprite art = Resources.Load<Sprite>("cardart/" + (cc.allcards[cardnumber.ToString()].CardArt));
                if (cardartfield != null)
                {
                 
                    cardartfield.sprite = art;
                }else
                {
                    cardart.sprite = art;
                }
            }
            spellplate.SetActive(false);
            attack.transform.parent.gameObject.SetActive(true);
            health.transform.parent.gameObject.SetActive(true);

            if (cc.allcards[cardnumber.ToString()].CardType.Equals("Ship"))
            {
                Debug.Log("it's a ship: " +cardnumber.ToString());

                
                if (cc.allcards[cardnumber.ToString()].Attack > 0)
                {
                    attack.transform.parent.gameObject.SetActive(true);
                    attack.text = cc.allcards[cardnumber.ToString()].Attack.ToString();
                }
                else
                {
                    attack.transform.parent.gameObject.SetActive(false);
                }
                
                health.text = cc.allcards[cardnumber.ToString()].Health.ToString();

                
            }
            else if (cc.allcards[cardnumber.ToString()].CardType.Equals("Effect"))
            {
               attack.transform.parent.gameObject.SetActive(false);
                health.transform.parent.gameObject.SetActive(false);
                spellplate.SetActive(true);

            }
            
            needupdate = false;
        }
    }
}
