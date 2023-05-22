using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class RotationTest : MonoBehaviour
{
    public Transform objectA;
    public Transform objectB;
    void Start()
    {
        
    }

    void Update()
    {
        Quaternion q = transform.rotation;
        objectA.position = transform.forward;

        Vector4 r = new Vector4(q.x, q.y, q.z, q.w);
        Vector3 p = new Vector3(0, 0, 1);
        
        //Vector4 p4 = new Vector4(0, p.x, p.y, p.z);
        r = new Vector4(r.x, -r.y, -r.z, -r.w);
        p = q * p;
        objectB.position = p;
    }
}
