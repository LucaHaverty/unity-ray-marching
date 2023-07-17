using UnityEngine;
using UnityEngine.Serialization;

namespace Objects
{
    public abstract class RenderedPrimiative : MonoBehaviour {
        [SerializeField] protected Color _color;
        [SerializeField] protected CombinationType _combinationType;
        [SerializeField] protected float _smoothAmount;
        
        public abstract PrimitiveData GetPrimitiveData();
    }
    
    public struct PrimitiveData {
        private PrimitiveType _primitiveType;
        
        private CombinationType _combinationType;
        private float _smoothAmount;

        private Vector3 _position;
        private Vector3 _scale;
        private Vector4 _rotation;

        private Color _color;

        // Properties: use varies depending on objectType
        private float _p1;
        private float _p2;
        private float _p3;

        public PrimitiveData(PrimitiveType primitiveType, CombinationType combinationType, float smoothAmount,
                Vector3 position, Vector3 scale, Quaternion rotation, Color color, float p1 = 0, float p2 = 0, float p3 = 0)
        {
            _primitiveType = primitiveType;
            
            _combinationType = combinationType;
            _smoothAmount = smoothAmount;
            
            _position = position;
            _scale = scale;
            _rotation = new Vector4(-rotation.x, -rotation.y, -rotation.z, rotation.w);

            _color = color;
            
            _p1 = p1;
            _p2 = p2;
            _p3 = p3;
        }

        public static int GetSize()
        {
            return System.Runtime.InteropServices.Marshal.SizeOf(typeof(PrimitiveData));
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
        BoxFrame,
        Torus,
        Octahedron
    }
}
