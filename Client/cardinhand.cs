using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using SimpleJSON;
using UnityEngine.EventSystems;

public class cardinhand : MonoBehaviour, IPointerClickHandler, IPointerEnterHandler, IPointerExitHandler, IBeginDragHandler, IEndDragHandler, IDragHandler
{
    public bool needupdate = true;
    public int cardnumber;
    public int rawcardnumber;
    public TextMeshProUGUI cardname;
    public TextMeshProUGUI text;
    public TextMeshProUGUI attack;
    public TextMeshProUGUI health;
    public GameObject spellplate;
    public Image level;
    public Image cardart;
    public Image faction;
    public Canvas parentcanvas;
    public Canvas ourcanvas;
    public gamecontroller gamescriptlink;
    public GameObject numberofcards;
    ClientControl cc;
    public bool hovering = false;
    bool dragging = false;
    public Transform parenttransform;
    int index;
    public bool dontreturn = false;
    public TextMeshProUGUI subtype;

    public void OnDrag(PointerEventData eventdata)
    {
        if (gamescriptlink == null)
        {
            return;
        }
        if (dragging)
        {
            transform.position = eventdata.position;
        }
    }
    public void OnBeginDrag(PointerEventData eventdata)
    {
        Debug.Log("started draging");
        if (gamescriptlink == null)
        {
            return;
        }

        if (gamescriptlink.forceplayable != null)
        {
            Debug.Log("we have target info already, shouldn't be dragging");
            dragging = false;
            return;
        }
        OnPointerClick(eventdata);
        dragging = true;

        parenttransform = transform.parent;
        Debug.Log(parenttransform.gameObject.name);
        index = transform.GetSiblingIndex();
        transform.SetParent(transform.parent.parent.parent.parent.parent);
        Debug.Log(parenttransform.gameObject.name);
        GetComponent<CanvasGroup>().blocksRaycasts = false;
        transform.SetAsLastSibling();


    }
    public void OnEndDrag(PointerEventData eventdata)
    {
        if (gamescriptlink == null)
        {
            return;
        }
        Debug.Log("ended draging");
        if (dragging == false)
        {
            return;
        }
        dragging = false;
        
        if (!dontreturn)
        {
            //we should mark this card as no longer being queued.
            Debug.Log("returning because don't return not set");
            Debug.Log("name:"+parenttransform.gameObject.name);
            transform.SetParent(parenttransform);
            Debug.Log("parent: " + transform.parent.gameObject.name);

            //transform.SetSiblingIndex(index);
            //transform.position = transform.parent.position;

            
            OnPointerClick(eventdata);
            
        }else
        {
            if (gamescriptlink.selectedinhand != this)
            {
                Destroy(gameObject);
            }else
            {
                transform.SetParent(parenttransform);
                
            }

        }
        GetComponent<CanvasGroup>().blocksRaycasts = true;
        dontreturn = false;
        //transform.SetParent(gamescriptlink.transform);
    }

    public void setcardnumber(int newcardnumber)
    {
        cardnumber = newcardnumber;
        rawcardnumber = 0;
        needupdate = true;
        
    }
    public void setrawcardnumber(int newcardnumber)
    {
        cardnumber = 0;
        rawcardnumber = newcardnumber;
        needupdate = true;
        Debug.Log("rawcardnumber: " + newcardnumber + " " + needupdate.ToString());
    }
    public void setnumberofcards( int number)
    {
        numberofcards.SetActive(true);
        numberofcards.GetComponent<TextMeshProUGUI>().text = number.ToString();
    }

    // Start is called before the first frame update
    void Start()
    {
        cc = FindObjectOfType<ClientControl>();
        
    }
    public void OnPointerExit (PointerEventData eventData)
    {
        hovering = false;
    }
    public void OnPointerEnter (PointerEventData eventdata)
    {
        hovering = true;
    }
    public void OnPointerClick (PointerEventData eventdata)
    {
        if (gamescriptlink == null)
        {
            return;
        }
        if (eventdata.button == PointerEventData.InputButton.Right)
        {
            Debug.Log("Right clicked on card: "+cardnumber.ToString()+" "+gamescriptlink.ToString());
            gamescriptlink.fullcarddisplay.SetActive(true);
            
            JSONNode card = gamescriptlink.objectsinplay[cardnumber.ToString()];
            Debug.Log(card.ToString());
            Debug.Log(card["CardId"]);

            card carddata = cc.allcards[card["CardId"]];
            while (carddata.levelsfrom > 0)
            {
                
                carddata = cc.allcards[carddata.levelsfrom.ToString()];
            }
            gamescriptlink.displaycards[0].setrawcardnumber ( carddata.CardId);
            int a = 1;
            while (carddata.levelsto > 0)
            {
                Debug.Log(a);
                
                gamescriptlink.displaycards[a].gameObject.SetActive(true);
                gamescriptlink.displaycards[a].setrawcardnumber(carddata.levelsto);
                
                carddata = cc.allcards[carddata.levelsto.ToString()];
                a += 1;
                if (carddata.levelsto == carddata.CardId)
                {
                    break;
                }
            }
            while (a < 3 )
            {
                gamescriptlink.displaycards[a].gameObject.SetActive(false);
                a += 1;
            }
            return;
            
        }
        
        Debug.Log("we clicked: '" + cardnumber.ToString()+"'");
        if (gamescriptlink.targetting)
        {
            Debug.Log("we're targetting");
            if (gamescriptlink.selectedinhand == this)
            {
                Debug.Log("unselecting card");
                gamescriptlink.selectedinhand = null;
                gamescriptlink.targets.Clear();
                gamescriptlink.highlight.Clear();
                gamescriptlink.targetting = false;
                return;
            }
            for (int i = 0; i < gamescriptlink.targetinfo[gamescriptlink.targetindex]["raw"].Count; i++)
            {
                string target = gamescriptlink.targetinfo[gamescriptlink.targetindex]["raw"][i];
                if (target == cardnumber.ToString())
                {
                    Debug.Log("this is a target!");
                    gamescriptlink.clickontarget(cardnumber.ToString());
                    return;
                }else
                {
                    
                    Debug.Log("this is not a target");
                }
            }
            
            
            return;
        }
        if (gamescriptlink.handplayable.TryGetValue(cardnumber.ToString(), out JSONNode value))
        {
            Debug.Log("We clicked a playable card");
            gamescriptlink.dehighlight();
            gamescriptlink.highlighttargets(value);
            gamescriptlink.selectedinhand = this;
            gamescriptlink.targetting = true;
         //   StartCoroutine(gamescriptlink.playcard(cardnumber.ToString()));
        }else
        {
            Debug.Log("we clicked a nonplayable card");
            gamescriptlink.selectedinhand = null;
            gamescriptlink.targets.Clear();
            gamescriptlink.highlight.Clear();
            gamescriptlink.targetting = false;
        }
    }
    
    // Update is called once per frame
    void Update()
    {
        ourcanvas.enabled = parentcanvas.enabled;
        JSONNode objectinplay;
        if (rawcardnumber == 0 && gamescriptlink.objectsinplay.TryGetValue(cardnumber.ToString(), out objectinplay))
        {
            if (needupdate || gamescriptlink.objectsinplay[cardnumber.ToString()]["needupdate"].AsInt > 0)
            {
                updategameobject();
                gamescriptlink.objectsinplay[cardnumber.ToString()]["needupdate"] = 0;
            }
        }else if (needupdate)
        {
            if (rawcardnumber > 0)
            {
                updateraw();
            }
            //needupdate = false;
            
        }
    }
    void updateraw()
    {
        //Debug.Log(gamescriptlink.objectsinplay[cardnumber.ToString()].Keys);
        Debug.Log("working on raw cardnumber");
        if (cc.allcards.TryGetValue(rawcardnumber.ToString(), out card cardexists))
        {

        }
        else
        {

            return;
        }
        string keywordstring = "";
        if (cc.allcards[rawcardnumber.ToString()].keywords.Count > 0)
        {
            keywordstring = string.Join(", ", cc.allcards[rawcardnumber.ToString()].keywords);
            keywordstring += "\n";
        }
        text.text = keywordstring + cc.allcards[rawcardnumber.ToString()].text;
        
        cardname.text = cc.allcards[rawcardnumber.ToString()].name;
        subtype.text = cc.allcards[rawcardnumber.ToString()].subtype;
        Sprite factionsprite = Resources.Load<Sprite>("Sprites/" + (cc.allcards[rawcardnumber.ToString()].faction));
        faction.sprite = factionsprite;

        if (cc.allcards[rawcardnumber.ToString()].CardArt != null)
        {
            Sprite art = Resources.Load<Sprite>("cardart/" + (cc.allcards[rawcardnumber.ToString()].CardArt));
            cardart.sprite = art;
            
        }
        Sprite levelart = Resources.Load<Sprite>("Sprites/level"+cc.allcards[rawcardnumber.ToString()].level );
        level.sprite = levelart;

        spellplate.SetActive(false);
        
            if (cc.allcards[rawcardnumber.ToString()].CardType.Equals("Ship"))
        {
            Debug.Log("it's a ship: " + cardnumber.ToString());
            attack.transform.parent.gameObject.SetActive(true);
            health.transform.parent.gameObject.SetActive(true);

            
            if (cc.allcards[rawcardnumber.ToString()].Attack > 0)
            {
                attack.transform.parent.gameObject.SetActive(true);
                attack.text = cc.allcards[rawcardnumber.ToString()].Attack.ToString();
            }
            else
            {
                attack.transform.parent.gameObject.SetActive(false);
            }
            
            health.text = cc.allcards[rawcardnumber.ToString()].Health.ToString();

            
        }
        else if (cc.allcards[rawcardnumber.ToString()].CardType.Equals("Effect"))
        {
            attack.transform.parent.gameObject.SetActive(false);
            health.transform.parent.gameObject.SetActive(false);
            spellplate.SetActive(false);

        }
        
        needupdate = false;
    }
    void updategameobject()
    {
        string keywords = "";
        if (gamescriptlink.objectsinplay[cardnumber.ToString()]["keyword"].IsObject)
        {
            foreach (string keyword in gamescriptlink.objectsinplay[cardnumber.ToString()]["keyword"].Keys)
            {
                if (keywords.Length > 0)
                {
                    keywords += ", " + keyword + " " + gamescriptlink.objectsinplay[cardnumber.ToString()]["keyword"][keyword];
                }
                else
                {
                    keywords = keyword + " " + gamescriptlink.objectsinplay[cardnumber.ToString()]["keyword"][keyword];
                }
            }
        }
        if (keywords.Length > 0)
        {
            keywords += "\n";
        }
        text.text = keywords + gamescriptlink.objectsinplay[cardnumber.ToString()]["Text"];
        cardname.text = gamescriptlink.objectsinplay[cardnumber.ToString()]["Name"];
        subtype.text = gamescriptlink.objectsinplay[cardnumber.ToString()]["subtype"];
        Sprite levelart = Resources.Load<Sprite>("Sprites/level" + gamescriptlink.objectsinplay[cardnumber.ToString()]["level"]);
        level.sprite = levelart;
        
        Sprite factionimage = Resources.Load<Sprite>("Sprites/" + gamescriptlink.objectsinplay[cardnumber.ToString()]["Faction"]);
        faction.sprite = factionimage;


        if (gamescriptlink.objectsinplay[cardnumber.ToString()]["Cardart"] != null)
        {
            Sprite art = Resources.Load<Sprite>("cardart/" + (gamescriptlink.objectsinplay[cardnumber.ToString()]["Cardart"]));
            cardart.sprite = art;
        }

        if (gamescriptlink.objectsinplay[cardnumber.ToString()]["CardType"].Equals("Ship"))
        {
            
            if (gamescriptlink.objectsinplay[cardnumber.ToString()]["Attack"] > 0)
            {
                attack.transform.parent.gameObject.SetActive(true);
                attack.text = gamescriptlink.objectsinplay[cardnumber.ToString()]["Attack"].ToString();
            }
            else
            {
                attack.transform.parent.gameObject.SetActive(false);
            }
            
            health.text = gamescriptlink.objectsinplay[cardnumber.ToString()]["Health"].ToString();

            
        }
        else if (gamescriptlink.objectsinplay[cardnumber.ToString()]["CardType"].Equals("Effect"))
        {
            attack.transform.parent.gameObject.SetActive(false);
            health.transform.parent.gameObject.SetActive(false);
            spellplate.SetActive(true);
        }
        else if (gamescriptlink.objectsinplay[cardnumber.ToString()]["CardType"].Equals("Station"))
        {
             attack.transform.parent.gameObject.SetActive(false);
            health.transform.parent.gameObject.SetActive(false);
            spellplate.SetActive(false);
        }
        

    }
}
