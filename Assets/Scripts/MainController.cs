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
 
    private ComputeBuffer spheresBuffer;
    private ComputeBuffer cubesBuffer;
    private ComputeBuffer boxFramesBuffer;

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
        List<Sphere> spheres = new List<Sphere>();
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
        material.SetInt(Shader.PropertyToID("NumBoxFrames"), boxFrames.Count);
        
        material.SetInt(Shader.PropertyToID("NumObjects"), spheres.Count + cubes.Count + boxFrames.Count);
    }

    private void DisposeBuffers()
    {
        spheresBuffer.Dispose();
        cubesBuffer.Dispose();
        boxFramesBuffer.Dispose();
    }
}