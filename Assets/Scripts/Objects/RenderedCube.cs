using System.Collections.Generic;
using TreeEditor;
using UnityEngine;
using UnityEngine.UIElements;

namespace Objects
{
    public class RenderedCube : RenderedObject
    {
        public override RenderedObjectData GetObjectData()
        {
            return new RenderedObjectData(1, transform.position, transform.localScale, transform.rotation, 0, 0, 0);

        }
    }

    /*public struct Cube
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
    }*/
}
