using UnityEngine;

namespace Objects
{
    public abstract class RenderedPrimiative : MonoBehaviour
    {
        [SerializeField] protected CombinationType combinationType;
        public abstract PrimitiveData GetPrimitiveData();
    }
    
    public struct PrimitiveData
    {
        private PrimitiveType primitiveType;
        private CombinationType combinationType;

        private Vector3 position;
        private Vector3 scale;
        private Vector4 rotation;

        // Properties: use varies depending on objectType
        private float p1;
        private float p2;
        private float p3;

        public PrimitiveData(PrimitiveType primitiveType, CombinationType combinationType,
                Vector3 position, Vector3 scale, Quaternion rotation, float p1, float p2, float p3)
        {
            this.primitiveType = primitiveType;
            this.combinationType = combinationType;
            
            this.position = position;
            this.scale = scale;
            this.rotation = new Vector4(-rotation.x, -rotation.y, -rotation.z, rotation.w);
            
            this.p1 = p1;
            this.p2 = p2;
            this.p3 = p3;
        }

        public static int GetSize()
        {
            return (sizeof(int) * 2) + (sizeof(float) * 13);
        }
    }
    
    public enum CombinationType
    {
        Union,
        Intersection,
        Subtraction,
        SmoothUnion,
        SmoothIntersection,
        SmoothSubtraction
    }

    public enum PrimitiveType
    {
        Sphere,
        Cube,
        BoxFrame
    }
}
