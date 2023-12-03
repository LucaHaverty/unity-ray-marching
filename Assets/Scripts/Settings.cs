using System;
using UnityEngine;

[Serializable]
public struct Settings {
    private static readonly int RENDER_GRID_ID = Shader.PropertyToID("RenderGrid");
    private static readonly int GRID_WIDTH_ID = Shader.PropertyToID("GridWidth");

    public bool RenderGrid;
    public float GridWidth;

    public void ApplySettings(Material material) {
        material.SetInt(RENDER_GRID_ID, RenderGrid ? 1 : 0);
        material.SetFloat(GRID_WIDTH_ID, GridWidth);
    }
}
