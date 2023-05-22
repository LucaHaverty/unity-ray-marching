using System.Collections.Generic;
using TreeEditor;
using UnityEngine;

namespace Objects
{
    public class RenderedSphere : MonoBehaviour
    {
        public Sphere GetObjectData()
        {
            return new Sphere(transform.position, transform.localScale.x / 2f);
        }
    }

    public struct Sphere
    {
        public Vector3 position;
        public float radius;

        public Sphere(Vector3 position, float radius)
        {
            this.position = position;
            this.radius = radius;
        }
    }
}
