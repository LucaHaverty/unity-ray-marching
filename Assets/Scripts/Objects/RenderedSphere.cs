using UnityEngine;

namespace Objects
{
    public class RenderedSphere : RenderedPrimiative
    {
        public override PrimitiveData GetPrimitiveData() {
            var trf = transform;
            
            return new PrimitiveData(PrimitiveType.Sphere, _combinationType, _smoothAmount,
                    trf.position, new Vector3(), new Quaternion(), _color, p1:trf.localScale.x*0.5f);
        }
    }
}
