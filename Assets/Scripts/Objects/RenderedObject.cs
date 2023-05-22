using UnityEngine;

namespace Objects
{
    /*public abstract class RenderedObject : MonoBehaviour
    {
        
    }*/
    public abstract class RenderedObject<T> : MonoBehaviour
    {
        public abstract T GetObjectData();
    }

    public interface ObjDataHolder { }
}
