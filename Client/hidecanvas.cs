using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class hidecanvas : MonoBehaviour
{

    public Canvas parentcanvas;
    public Canvas ourcanvas;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        ourcanvas.enabled = parentcanvas.enabled;
        
    }
}
