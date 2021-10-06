using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class scroller : MonoBehaviour
{
    [SerializeField]
    private ScrollRect _scrollRectComponent;
    [SerializeField]
    RectTransform _container;
    

    public void scroll (BaseEventData foo)
    {
        
        Debug.Log(foo);
        

    }

    
    
   
}
