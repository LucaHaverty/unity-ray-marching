using UnityEngine;
using UnityEngine.Serialization;

namespace Objects
{
    public class RenderedBoxFrame : RenderedPrimiative
    {
        [SerializeField] private float _edgeThickness = 0.1f;
        public override PrimitiveData GetPrimitiveData() {
            var trf = transform;
            
            return new PrimitiveData(PrimitiveType.BoxFrame, _combinationType, _smoothAmount, 
                trf.position, trf.localScale, trf.rotation, _color, p1: _edgeThickness);
        }
    }
}
