using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraDepth : MonoBehaviour {

	// Use this for initialization
	void Awake() {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;        
    }
	
	// Update is called once per frame
	void Update () {
		
	}
}
