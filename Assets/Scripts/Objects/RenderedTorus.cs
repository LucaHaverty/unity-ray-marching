using UnityEngine;

namespace Objects
{
    public class RenderedTorus : RenderedPrimiative
    {
        [SerializeField] private float _thickness = 0.15f;
        public override PrimitiveData GetPrimitiveData() {
            var trf = transform;
            
            return new PrimitiveData(PrimitiveType.Torus, _combinationType, _smoothAmount, 
                    trf.position, new Vector3(trf.localScale.x*0.5f, _thickness), trf.rotation, _color);
        }
    }
}
