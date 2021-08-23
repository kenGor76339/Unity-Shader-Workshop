using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CalNormal : MonoBehaviour
{
    Material m;
    int[] tri;
    Vector3[] meshVertices;
    // Start is called before the first frame update
    void Start()
    {
        m = this.GetComponent<Material>();
        tri = this.GetComponent<MeshFilter>().sharedMesh.triangles;
        meshVertices = this.GetComponent<MeshFilter>().sharedMesh.normals;
        Vector4[] normals = new Vector4[meshVertices.Length];
        
    }

    // Update is called once per frame
    void Update()
    {
        

    }
}
