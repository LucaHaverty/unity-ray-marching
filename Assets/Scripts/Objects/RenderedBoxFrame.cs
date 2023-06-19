using System.Collections.Generic;
using TreeEditor;
using UnityEngine;
using UnityEngine.UIElements;

namespace Objects
{
    public class RenderedBoxFrame : RenderedPrimiative
    {
        [SerializeField] private float edgeThickness;
        public override PrimitiveData GetPrimitiveData()
        {
            return new PrimitiveData(PrimitiveType.BoxFrame, combinationType, smoothAmount, 
                    transform.position, transform.localScale, transform.rotation, edgeThickness, 0, 0);
        }
    }
}
