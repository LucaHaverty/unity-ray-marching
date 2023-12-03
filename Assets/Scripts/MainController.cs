using Objects;
using UnityEngine;

[ExecuteAlways]
public class MainController : MonoBehaviour {
    [SerializeField] private Material _material;
    
    [SerializeField] private Settings _settings;

    private ComputeBuffer _shaderCamBuffer;

    private UseAsCam _cam;

    private void OnRenderImage(RenderTexture src, RenderTexture dest) {
        SendData();
        Graphics.Blit(src, dest, _material);
    }

    private void SendData() {
        _shaderCamBuffer ??= new ComputeBuffer(1, sizeof(float) * 9);
        
        if (_cam == null)
            _cam = FindObjectOfType<UseAsCam>();

        _shaderCamBuffer.SetData(new[] {_cam.GetObjectData()});
        
        _material.SetBuffer(Shader.PropertyToID("Cam"), _shaderCamBuffer);
        _material.SetFloat(Shader.PropertyToID("Time"), Time.time);
        
        _settings.ApplySettings(_material);
    }
}
