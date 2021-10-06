using SimpleJSON;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class deckselector : MonoBehaviour
{
    public ClientControl cc;
    public GameObject deckprefab;
    public GameObject deckcontainer;

    public void updateview ()
    {
        Debug.Log("updating view!");
        foreach (Transform child in deckcontainer.transform)
        {
           Destroy(child.gameObject);
            Debug.Log("destroyed something: " + child.gameObject);
        }


        foreach (JSONNode foo in  cc.decks.Values)
        {
            GameObject go = Instantiate(deckprefab, deckcontainer.transform);
            Debug.Log("Made deck! " + foo["deckname"]);
            deckname dn = go.GetComponent<deckname>();
            dn.changename(foo["deckname"]);
            dn.deckid = foo["deckid"];
        }
    }

    public void close()
    {
        this.gameObject.SetActive(false);
    }
    // Start is called before the first frame update
    void OnEnable()
    {
        updateview();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
