using System.Collections.Generic;
using TreeEditor;
using UnityEngine;

namespace Objects
{
    public class RenderedSphere : RenderedObject
    {
        public override RenderedObjectData GetObjectData()
        {
            return new RenderedObjectData(0, transform.position, new Vector3(), new Quaternion(), transform.localScale.x/2, 0, 0);
        }
    }

    /*public struct Sphere
    {
        public Vector3 position;
        public float radius;

        public Sphere(Vector3 position, float radius)
        {
            this.position = position;
            this.radius = radius;
        }
    }*/
}
