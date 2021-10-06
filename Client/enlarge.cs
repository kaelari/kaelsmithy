using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;

public class enlarge : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    public cardinplay cardinplay;
    public GameObject textfield;

    public void OnPointerEnter(PointerEventData eventdata)
    {
        //print("MouseEntered");
        transform.localScale = new Vector2(1.05f, 1.05f);
        
        Canvas canvas = gameObject.GetComponent<Canvas>();
        canvas.overrideSorting = false;
        canvas.sortingOrder = 5;
        if (cardinplay != null)
        {
            textfield.SetActive(true);

        }
    }

    public void OnPointerExit(PointerEventData eventdata)
    {
        //print("MouseExited");
        transform.localScale = new Vector2(1.0f, 1.0f);
        Canvas canvas = gameObject.GetComponent<Canvas>();
        canvas.sortingOrder = 1;
        canvas.overrideSorting = false;
        if (cardinplay != null)
        {
            //textfield.SetActive(false);

        }
    }

}