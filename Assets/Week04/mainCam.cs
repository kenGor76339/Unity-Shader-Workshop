using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class mainCam : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Camera cam = this.GetComponent<Camera>();
        if (cam.targetTexture != null)
        {
            Shader.SetGlobalTexture("ABC", cam.targetTexture);
        }
    }
}
