using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class dropzone : MonoBehaviour, IDropHandler, IPointerEnterHandler
{
    gamecontroller gamescriptlink;
    public bool iscard = false;
    public void OnPointerEnter(PointerEventData eventData)
    {
        //Debug.Log("Entered");
    }
    public void OnDrop(PointerEventData eventData)
    {
        cardinhand cardinhandscript = eventData.pointerDrag.GetComponent<cardinhand>();
        
        highlight foobar;
        if (iscard)
        {
            if (foobar = gameObject.transform.parent.gameObject.GetComponent<highlight>())
            {
                if (gamescriptlink.checktarget(foobar.l))
                {
                    gamescriptlink.clickontarget(foobar.l);
                    cardinhandscript.dontreturn = true;
                }
                

            }else
            {
                Debug.Log("error, no foobar");
            }
        }
        else
        {
            if (foobar = GetComponent<highlight>())
            {
                if (gamescriptlink.checktarget(foobar.l))
                {
                    gamescriptlink.clickontarget(foobar.l);
                    cardinhandscript.dontreturn = true;
                }

            }
            
        }


    }
        // Start is called before the first frame update
        

    // Update is called once per frame
    void Update()
    {
        
    }
    void Start()
    {
        gamescriptlink = GetComponentInParent<gamecontroller>();
    }
}
