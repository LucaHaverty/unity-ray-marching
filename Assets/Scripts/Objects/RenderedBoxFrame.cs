using System.Collections.Generic;
using TreeEditor;
using UnityEngine;
using UnityEngine.UIElements;

namespace Objects
{
    public class RenderedBoxFrame : MonoBehaviour
    {
        [SerializeField] private float edgeThickness;
        public BoxFrame GetObjectData()
        {
            return new BoxFrame(transform.position, transform.localScale, transform.rotation, edgeThickness);
        }
    }

    public struct BoxFrame
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
    }
}
