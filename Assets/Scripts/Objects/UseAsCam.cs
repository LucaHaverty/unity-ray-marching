using UnityEngine;

namespace Objects
{
    public class UseAsCam : MonoBehaviour
    {
        public Vector2 viewAngleDeg;
        public ShaderCam GetObjectData() {
            var trf = transform;
            
            return new ShaderCam(trf.position, trf.rotation, viewAngleDeg);
        }
    }

    public struct ShaderCam
    {
        public Vector3 position;
        public Vector4 rotation;
        public Vector2 viewAngle;

        public ShaderCam(Vector3 position, Quaternion rotation, Vector2 viewAngle)
        {
            this.position = position;
            this.rotation = new Vector4(rotation.x, rotation.y, rotation.z, rotation.w);
            this.viewAngle = viewAngle;

        }
    }
}
