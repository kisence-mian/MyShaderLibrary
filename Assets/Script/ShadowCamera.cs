using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowCamera : MonoBehaviour {

    Camera cam;
    RenderTexture rt;
	// Use this for initialization
	void Start () {
        GameObject go = new GameObject("Cam");
        cam = go.AddComponent<Camera>();

        cam.clearFlags = CameraClearFlags.Depth;

        cam.orthographic = true;
        cam.orthographicSize = 10;
        cam.aspect = 1;
        cam.backgroundColor = new Color(1, 1, 1, 0);
        cam.transform.position = transform.position;
        cam.transform.rotation = transform.rotation;
        cam.transform.SetParent(transform);

        rt = new RenderTexture(1024, 1024, 0);
        rt.wrapMode = TextureWrapMode.Clamp;

        cam.targetTexture = rt;
        cam.cullingMask = LayerMask.GetMask("ShadowCaster");
        cam.SetReplacementShader(Shader.Find("MyShaderLib/Render2Texture"), "RenderType");

        cam.Render();

    }
	
	// Update is called once per frame
	void Update () {
		
	}
}
