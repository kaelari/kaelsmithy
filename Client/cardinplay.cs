using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using SimpleJSON;
using UnityEngine.EventSystems;

public class cardinplay : MonoBehaviour, IPointerClickHandler
{
    bool needupdate = false;
    public int cardnumber;

    public TextMeshProUGUI cardname;
    public TextMeshProUGUI text;
    public TextMeshProUGUI cost;
    public TextMeshProUGUI attack;
    public TextMeshProUGUI health;
    public TextMeshProUGUI resistance;
    public TextMeshProUGUI armor;
    public Image attacktype;
    public Image cardart;
    public List<Image> thresh;
    public Canvas parentcanvas;
    public Canvas ourcanvas;
    public gamecontroller gamescriptlink;
    public highlight highlight;
    public Image highlightimage;
    public Image level;
    public Image SS;
    public Image faction;
    public Color highlightcolor;

    ClientControl cc;
    int lane = 0;
    public void setcardnumber(int newcardnumber)
    {

        cardnumber = newcardnumber;
        needupdate = true;
        highlight.cardnumber = newcardnumber.ToString();
    }
    // Start is called before the first frame update
    void Start()
    {
        cc = FindObjectOfType<ClientControl>();
        highlight.gamescriptlink = gamescriptlink;
        
    }
    public void OnPointerClick (PointerEventData eventdata)
    {

        if (eventdata.button == PointerEventData.InputButton.Right)
        {
            Debug.Log("Right clicked on card: " + cardnumber.ToString() + " " + gamescriptlink.ToString());
            gamescriptlink.fullcarddisplay.SetActive(true);

            JSONNode card = gamescriptlink.objectsinplay[cardnumber.ToString()];
            Debug.Log(card.ToString());
            Debug.Log(card["CardId"]);

            card carddata = cc.allcards[card["CardId"]];
            while (carddata.levelsfrom > 0)
            {

                carddata = cc.allcards[carddata.levelsfrom.ToString()];
            }
            gamescriptlink.displaycards[0].setrawcardnumber(carddata.CardId);
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
            while (a < 3)
            {
                gamescriptlink.displaycards[a].gameObject.SetActive(false);
                a += 1;
            }
            return;

        }
        if (!gamescriptlink.targetting && gamescriptlink.handplayable.TryGetValue(cardnumber.ToString(), out JSONNode value))
        {
            gamescriptlink.dehighlight();
            gamescriptlink.highlighttargets(value);
            gamescriptlink.selectedinplay = this;
            gamescriptlink.targetting = true;
        }
        else
        {
            if (gamescriptlink.objectsinplay[cardnumber.ToString()]["owner"].AsInt == gamescriptlink.weare)
            {
                gamescriptlink.clickontarget("l" + lane.ToString());
            }
            else
            {
                gamescriptlink.clickontarget("ol" + lane.ToString());
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        ourcanvas.enabled = parentcanvas.enabled;
        if (!gamescriptlink.objectsinplay.TryGetValue(cardnumber.ToString(), out JSONNode test))
        {
            Debug.Log("no object in play?! "+cardnumber.ToString());
            return;
        }
        if (gamescriptlink.handplayable.TryGetValue(cardnumber.ToString(), out JSONNode foo))
        {

            if (gamescriptlink.turn == gamescriptlink.weare && gamescriptlink.targetting == false && gamescriptlink.handplayable.TryGetValue(cardnumber.ToString(), out JSONNode value))
            {
                
               highlightimage.color = highlightcolor;
               

            }
        }
        if (needupdate || gamescriptlink.objectsinplay[cardnumber.ToString()]["needupdate"] > 0)
        {
            // we should do something here
            if (gamescriptlink.objectsinplay[cardnumber.ToString()]["lane"] != null)
            {
                lane = gamescriptlink.objectsinplay[cardnumber.ToString()]["lane"];
                Debug.Log("cards: " + gamescriptlink.objectsinplay[cardnumber.ToString()].ToString());
                if (gamescriptlink.objectsinplay[cardnumber.ToString()]["owner"] == gamescriptlink.weare)
                {
                    highlight.lane = "lane" + lane.ToString();
                } else
                {
                    highlight.lane = "olane" + lane.ToString();
                }

            }
            Sprite levelart = Resources.Load<Sprite>("Sprites/level" + gamescriptlink.objectsinplay[cardnumber.ToString()]["level"]);
            level.sprite = levelart;
            Sprite factionart = Resources.Load<Sprite>("Sprites/" + gamescriptlink.objectsinplay[cardnumber.ToString()]["Faction"]);
            faction.sprite = factionart;

            if (gamescriptlink.objectsinplay[cardnumber.ToString()]["ss"].AsInt > 0   )
            {
                if (gamescriptlink.objectsinplay[cardnumber.ToString()]["keyword"]["Fast"] != null)
                {
                    if (gamescriptlink.objectsinplay[cardnumber.ToString()]["keyword"]["Fast"] >0 )
                    {
                        SS.gameObject.SetActive(false);
                    }else
                    {
                        SS.gameObject.SetActive(true);
                    }
                }
                else
                {
                    SS.gameObject.SetActive(true);
                }
            }else
            {
                SS.gameObject.SetActive( false);
            }
            if (gamescriptlink.objectsinplay[cardnumber.ToString()]["Cardart"] != null)
            {
                Sprite art = Resources.Load<Sprite>("cardart/" + (gamescriptlink.objectsinplay[cardnumber.ToString()]["Cardart"]));
                cardart.sprite = art;
            }
            
            if (gamescriptlink.objectsinplay[cardnumber.ToString()]["Attack"] > 0)
            {
                attack.transform.parent.gameObject.SetActive(true);
                if (cc.allcards.TryGetValue(gamescriptlink.objectsinplay[cardnumber.ToString()]["CardId"].ToString(), out card basecard)) {
                    if (basecard.Attack > gamescriptlink.objectsinplay[cardnumber.ToString()]["Attack"])
                    {
                        attack.text = "<color=red>" + gamescriptlink.objectsinplay[cardnumber.ToString()]["Attack"].ToString() + "</color>";
                    } else if (basecard.Attack < gamescriptlink.objectsinplay[cardnumber.ToString()]["Attack"])
                    {
                        attack.text = "<color=blue>" + gamescriptlink.objectsinplay[cardnumber.ToString()]["Attack"].ToString() + "</color>";
                    }
                    else
                    {

                        attack.text = gamescriptlink.objectsinplay[cardnumber.ToString()]["Attack"].ToString();
                    }
                } else
                {
                    attack.text = gamescriptlink.objectsinplay[cardnumber.ToString()]["Attack"].ToString();

                }
            }
            else
            {
                attack.transform.parent.gameObject.SetActive(false);
            }


            string keywords = "";
            if (gamescriptlink.objectsinplay[cardnumber.ToString()]["keyword"].IsObject)
            {
                Debug.Log("it's an object! " + gamescriptlink.objectsinplay[cardnumber.ToString()]["keyword"].ToString());
                foreach (string keyword in gamescriptlink.objectsinplay[cardnumber.ToString()]["keyword"].Keys)
                {
                    if (gamescriptlink.objectsinplay[cardnumber.ToString()]["keyword"][keyword] > 0)
                    {
                        if (keywords.Length > 0)
                        {
                            keywords += ", ";
                        }
                        keywords += keyword;
                        if (gamescriptlink.objectsinplay[cardnumber.ToString()]["keyword"][keyword] > 1)
                        {
                            keywords += " " + gamescriptlink.objectsinplay[cardnumber.ToString()]["keyword"][keyword];
                        }
                    }else
                    {
                        if (keywords.Length > 0)
                        {
                            keywords += ", ";
                        }
                        keywords += "<s><color=red>" + keyword + "</color></s>";
                            
                    }
                }
            }
            if (keywords.Length > 0)
            {
                keywords += "\n";
            }


            if (gamescriptlink.objectsinplay[cardnumber.ToString()]["Text"] != null  || keywords != null)
            {
                text.text = keywords + gamescriptlink.objectsinplay[cardnumber.ToString()]["Text"];
            }
            if (gamescriptlink.objectsinplay[cardnumber.ToString()]["Name"] != null)
            {
                cardname.text = gamescriptlink.objectsinplay[cardnumber.ToString()]["Name"];
            }

            
            health.text = gamescriptlink.objectsinplay[cardnumber.ToString()]["Health"].ToString();
           
            if (gamescriptlink.objectsinplay[cardnumber.ToString()]["AttackType"] == 1)
            {
                Sprite icon = Resources.Load<Sprite>("Sprites/rocket");
                attacktype.sprite = icon;
            }
            if (gamescriptlink.objectsinplay[cardnumber.ToString()]["AttackType"] == 2)
            {
                Sprite icon = Resources.Load<Sprite>("Sprites/beam");
                attacktype.sprite = icon;
            }
            
            needupdate = false;
            gamescriptlink.objectsinplay[cardnumber.ToString()]["needupdate"] = 0;
        }
    }
}
