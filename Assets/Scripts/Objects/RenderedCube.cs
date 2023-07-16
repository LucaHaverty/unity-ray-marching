namespace Objects
{
    public class RenderedCube : RenderedPrimiative
    {
        public override PrimitiveData GetPrimitiveData() {
            var trf = transform;
            return new PrimitiveData(PrimitiveType.Cube, _combinationType, _smoothAmount,
                    trf.position, trf.localScale, trf.rotation, _color);
        }
    }
}
