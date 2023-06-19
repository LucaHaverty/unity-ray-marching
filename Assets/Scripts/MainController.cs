using System;
using System.Collections;
using System.Collections.Generic;
using Objects;
using Unity.VisualScripting;
using UnityEngine;
using Object = System.Object;

[ExecuteAlways]
public class MainController : MonoBehaviour
{
    [SerializeField] private Material material;
    [SerializeField] private Transform sceneStructure;
 
    private ComputeBuffer renderedObjectBuffer;
    private ComputeBuffer shaderCamBuffer;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        SendObjectData();
        Graphics.Blit(null, dest, material);
        DisposeBuffers();
    }

    private void SendObjectData()
    {
        List<ShaderCam> shaderCam = new List<ShaderCam>();
        foreach(var cam in FindObjectsOfType<UseAsCam>())
            shaderCam.Add(cam.GetObjectData());
        shaderCamBuffer = new ComputeBuffer(Math.Max(1, shaderCam.Count), sizeof(float) * 9);
        
        shaderCamBuffer.SetData(shaderCam);

        material.SetBuffer(Shader.PropertyToID("Cam"), shaderCamBuffer);

        List<PrimitiveData> renderedObjects = new List<PrimitiveData>();
        foreach (Transform renderedObject in sceneStructure)
        {
            if (renderedObject.gameObject.activeSelf)
                renderedObjects.Add(renderedObject.GetComponent<RenderedPrimiative>().GetPrimitiveData());
        }

        renderedObjectBuffer = new ComputeBuffer(Mathf.Max(1, renderedObjects.Count), PrimitiveData.GetSize());
        
        renderedObjectBuffer.SetData(renderedObjects);
        
        material.SetBuffer(Shader.PropertyToID("Primitives"), renderedObjectBuffer);
        material.SetInt(Shader.PropertyToID("ObjectCount"), renderedObjects.Count); 
        material.SetFloat(Shader.PropertyToID("Time"), Time.time);
        
    }

    private void DisposeBuffers()
    {
        renderedObjectBuffer.Dispose();
        shaderCamBuffer.Dispose();
    }
}
