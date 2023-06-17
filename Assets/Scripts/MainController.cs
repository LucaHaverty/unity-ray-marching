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
    [SerializeField] private Shader shader;

    [SerializeField] private Material material;
 
    private ComputeBuffer renderedObjectBuffer;
    /*private ComputeBuffer cubesBuffer;
    private ComputeBuffer boxFramesBuffer;*/
    private ComputeBuffer shaderCamBuffer;

    void OnValidate()
    {
        /*if (spheresBuffer == null || !spheresBuffer.IsValid())
        {
            if(spheresBuffer != null && !spheresBuffer.IsValid())
                spheresBuffer.Release();
            spheresBuffer = new ComputeBuffer(1, sizeof(float) * 4, ComputeBufferType.Structured);
        }*/
    }

    private void OnDisable()
    {
        //spheresBuffer.Dispose();
    }

    private void Start()
    {
        
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        SendObjectData();
        Graphics.Blit(null, dest, material);
        DisposeBuffers();
    }

    public void SendObjectData()
    {
        /*List<Sphere> spheres = new List<Sphere>();
        foreach(var sphere in FindObjectsOfType<RenderedSphere>())
            spheres.Add(sphere.GetObjectData());
        spheresBuffer = new ComputeBuffer(Mathf.Max(1, spheres.Count), sizeof(float) * 4);
        
        spheresBuffer.SetData(spheres);
        
        material.SetBuffer(Shader.PropertyToID("Spheres"), spheresBuffer);
        material.SetInt(Shader.PropertyToID("NumSpheres"), spheres.Count);
        
        List<Cube> cubes = new List<Cube>();
        foreach(var cube in FindObjectsOfType<RenderedCube>())
            cubes.Add(cube.GetObjectData());
        cubesBuffer = new ComputeBuffer(Math.Max(1, cubes.Count), sizeof(float) * 10);
        
        cubesBuffer.SetData(cubes);
        
        material.SetBuffer(Shader.PropertyToID("Cubes"), cubesBuffer);
        material.SetInt(Shader.PropertyToID("NumCubes"), cubes.Count);
        
        List<BoxFrame> boxFrames = new List<BoxFrame>();
        foreach(var boxFrame in FindObjectsOfType<RenderedBoxFrame>())
            boxFrames.Add(boxFrame.GetObjectData());
        boxFramesBuffer = new ComputeBuffer(Math.Max(1, boxFrames.Count), sizeof(float) * 11);
        
        boxFramesBuffer.SetData(boxFrames);

        material.SetBuffer(Shader.PropertyToID("BoxFrames"), boxFramesBuffer);
        material.SetInt(Shader.PropertyToID("NumBoxFrames"), boxFrames.Count);*/
        
        List<ShaderCam> shaderCam = new List<ShaderCam>();
        foreach(var cam in FindObjectsOfType<UseAsCam>())
            shaderCam.Add(cam.GetObjectData());
        shaderCamBuffer = new ComputeBuffer(Math.Max(1, shaderCam.Count), sizeof(float) * 9);
        
        shaderCamBuffer.SetData(shaderCam);

        material.SetBuffer(Shader.PropertyToID("Cam"), shaderCamBuffer);

        List<RenderedObjectData> renderedObjects = new List<RenderedObjectData>();
        foreach(var renderedObject in FindObjectsOfType<RenderedObject>())
            renderedObjects.Add(renderedObject.GetObjectData());
        renderedObjectBuffer = new ComputeBuffer(Mathf.Max(1, renderedObjects.Count), sizeof(int) + sizeof(float) * 13);
        
        renderedObjectBuffer.SetData(renderedObjects);
        
        material.SetBuffer(Shader.PropertyToID("Objects"), renderedObjectBuffer);
        material.SetInt(Shader.PropertyToID("NumObjects"), renderedObjects.Count); 
        
    }

    private void DisposeBuffers()
    {
        renderedObjectBuffer.Dispose();
        /*spheresBuffer.Dispose();
        cubesBuffer.Dispose();
        boxFramesBuffer.Dispose();*/
        shaderCamBuffer.Dispose();
    }
}
