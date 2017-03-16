using UnityEngine;
using System.Collections;

public class BeatingHeart : MonoBehaviour
{
    public Material m;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, m);
    }
}
