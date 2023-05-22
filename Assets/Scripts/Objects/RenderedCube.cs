using System.Collections.Generic;
using TreeEditor;
using UnityEngine;
using UnityEngine.UIElements;

namespace Objects
{
    public class RenderedCube : MonoBehaviour
    {
        public Cube GetObjectData()
        {
            return new Cube(transform.position, transform.localScale, transform.rotation);
        }
    }

    public struct Cube
    {
        public Vector3 position;
        public Vector3 scale;
        public Vector4 rotation;

        public Cube(Vector3 position, Vector3 scale, Quaternion rotation)
        {
            this.position = position;
            this.scale = scale;
            this.rotation = new Vector4(-rotation.x, -rotation.y, -rotation.z, rotation.w);
        }
    }
}
