using System.Collections.Generic;
using TreeEditor;
using UnityEngine;

namespace Objects
{
    public class RenderedSphere : RenderedPrimiative
    {
        public override PrimitiveData GetPrimitiveData()
        {
            return new PrimitiveData(PrimitiveType.Sphere, combinationType, 
                    transform.position, new Vector3(), new Quaternion(), transform.localScale.x/2, 0, 0);
        }
    }
}
