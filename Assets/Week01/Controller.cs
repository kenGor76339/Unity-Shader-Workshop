using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Controller : MonoBehaviour
{
    public Material mat;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        float time = Time.time;
        
        if (mat != null)
        {
            time = Mathf.Abs(Mathf.Sin(time));
            mat.SetFloat("_Amount",time);
        }
    }
}
