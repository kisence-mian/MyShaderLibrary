using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Mirror : MonoBehaviour {

    Camera mirCam;

    public void OnWillRanderObject()
    {
        Camera cam = Camera.main;
        mirCam.CopyFrom(cam);

        mirCam.transform.parent = transform;
        Camera.main.transform.parent = transform;

        Vector3 mPos = mirCam.transform.localPosition;

        mPos.y *= -1;
        mirCam.transform.localPosition = mPos;

        Vector3 rt = Camera.main.transform.localEulerAngles;

        Camera.main.transform.parent = null;

        mirCam.transform.localEulerAngles = new Vector3(-rt.x, rt.y, -rt.z);
    }
}
