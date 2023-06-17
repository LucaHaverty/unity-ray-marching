using System.Collections.Generic;
using TreeEditor;
using UnityEngine;
using UnityEngine.UIElements;

namespace Objects
{
    public class RenderedBoxFrame : RenderedObject
    {
        [SerializeField] private float edgeThickness;
        public override RenderedObjectData GetObjectData()
        {
            return new RenderedObjectData(2, transform.position, transform.localScale, transform.rotation, edgeThickness, 0, 0);
        }
    }
    
    /*public struct BoxFrame
    {
        public Vector3 position;
        public Vector3 scale;
        public Vector4 rotation;
        public float edgeThickness;

        public BoxFrame(Vector3 position, Vector3 scale, Quaternion rotation, float edgeThickness)
        {
            this.position = position;
            this.scale = scale;
            this.rotation = new Vector4(-rotation.x, -rotation.y, -rotation.z, rotation.w);
            this.edgeThickness = edgeThickness;
        }
    }*/
}
