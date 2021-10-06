using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class closeonclick : MonoBehaviour
{
    public void clicked()
    {
        Destroy(this.transform.parent.gameObject);
    }
    public void killthis()
    {
        Destroy(this.gameObject);
    }
    public void deactivate()
    {
        this.gameObject.SetActive(false);
    }
    public void close()
    {
        this.gameObject.SetActive(false);
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
