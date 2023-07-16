using System;
using System.Collections.Generic;
using JetBrains.Annotations;
using Objects;
using UnityEngine;

[ExecuteAlways]
public class MainController : MonoBehaviour {
    [SerializeField] private Material _material;
    [SerializeField] private Transform _sceneStructure;

    private ComputeBuffer _renderedObjectBuffer;
    private ComputeBuffer _shaderCamBuffer;

    private UseAsCam _cam;

    private void OnRenderImage(RenderTexture src, RenderTexture dest) {
        SendObjectData();

        Graphics.Blit(null, dest, _material);
        DisposeBuffers();
    }

    private void SendObjectData() {
        if (_shaderCamBuffer == null)
            _shaderCamBuffer = new ComputeBuffer(1, sizeof(float) * 9);
        
        if (_cam == null)
            _cam = FindObjectOfType<UseAsCam>();

        _shaderCamBuffer.SetData(new[] {_cam.GetObjectData()});
        
        _material.SetBuffer(Shader.PropertyToID("Cam"), _shaderCamBuffer);

        List<PrimitiveData> renderedObjects = new List<PrimitiveData>();
        foreach (Transform renderedObject in _sceneStructure) {
            if (renderedObject.gameObject.activeSelf)
                renderedObjects.Add(renderedObject.GetComponent<RenderedPrimiative>().GetPrimitiveData());
        }

        _renderedObjectBuffer = new ComputeBuffer(Mathf.Max(1, renderedObjects.Count), PrimitiveData.GetSize());

        _renderedObjectBuffer.SetData(renderedObjects);

        _material.SetInt(Shader.PropertyToID("ObjectCount"), renderedObjects.Count);
        _material.SetBuffer(Shader.PropertyToID("Primitives"), _renderedObjectBuffer);
        _material.SetFloat(Shader.PropertyToID("Time"), Time.time);
    }

    private void DisposeBuffers() {
        _renderedObjectBuffer.Dispose();
    }
}
