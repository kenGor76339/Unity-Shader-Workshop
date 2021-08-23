using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GetLight : MonoBehaviour
{
    public Material m;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
        setupLight();
    }
    void setupLight() {
        GameObject[] myObjArray = GameObject.FindGameObjectsWithTag("light");
        Vector4[] v4 = new Vector4[myObjArray.Length];
        Vector4[] color = new Vector4[myObjArray.Length];
        Vector4[] direction = new Vector4[myObjArray.Length];
        float[] intensity = new float[myObjArray.Length];
        float[] range = new float[myObjArray.Length];
        float[] angle = new float[myObjArray.Length];

        for (int i = 0; i < myObjArray.Length; i++)
        {
            v4[i].x = myObjArray[i].GetComponent<Light>().transform.position.x;
            v4[i].y = myObjArray[i].GetComponent<Light>().transform.position.y;
            v4[i].z = myObjArray[i].GetComponent<Light>().transform.position.z;
            v4[i].w = 1;

            color[i] = myObjArray[i].GetComponent<Light>().color;

            intensity[i] = myObjArray[i].GetComponent<Light>().intensity;
            range[i] = myObjArray[i].GetComponent<Light>().range;

            LightType lt = myObjArray[i].GetComponent<Light>().type;
            if (lt.ToString() == "Spot")
            {
                angle[i] = myObjArray[i].GetComponent<Light>().spotAngle;
                direction[i].x = myObjArray[i].GetComponent<Light>().transform.forward.x;
                direction[i].y = myObjArray[i].GetComponent<Light>().transform.forward.y;
                direction[i].z = myObjArray[i].GetComponent<Light>().transform.forward.z;
                direction[i].w = 1;
            }
        }

        m.SetFloatArray("angle_arr",angle);
        m.SetVectorArray("direction_arr", direction);
        m.SetVectorArray("srclight_arr", v4);
        m.SetVectorArray("color_arr", color);
        m.SetFloatArray("intensity_arr", intensity);
        m.SetFloatArray("range_arr", range);
        m.SetInt("srclightAmount", v4.Length);
    }
}
