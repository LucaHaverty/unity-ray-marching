using System.Collections.Generic;
using TreeEditor;
using UnityEngine;
using UnityEngine.UIElements;

namespace Objects
{
    public class RenderedCube : RenderedPrimiative
    {
        public override PrimitiveData GetPrimitiveData()
        {
            return new PrimitiveData(PrimitiveType.Cube, combinationType, smoothAmount,
                    transform.position, transform.localScale, transform.rotation, 0, 0, 0);

        }
    }
}
