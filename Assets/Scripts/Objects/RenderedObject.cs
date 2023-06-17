using UnityEngine;

namespace Objects
{
    public abstract class RenderedObject : MonoBehaviour
    {
        public abstract RenderedObjectData GetObjectData();
    }
    
    public struct RenderedObjectData
    {
        int objectType;

        Vector3 position;
        Vector3 scale;
        Vector4 rotation;

        // Properties: use varies depending on objectType
        float p1;
        float p2;
        float p3;

        public RenderedObjectData(int objectType, Vector3 position, Vector3 scale, Quaternion rotation, float p1, float p2, float p3)
        {
            this.objectType = objectType;
            
            this.position = position;
            this.scale = scale;
            this.rotation = new Vector4(-rotation.x, -rotation.y, -rotation.z, rotation.w);
            
            this.p1 = p1;
            this.p2 = p2;
            this.p3 = p3;
        }
    }
}
