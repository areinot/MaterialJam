using UnityEngine;
using System.Collections;

public class TestScript : MonoBehaviour {
	public Cubemap globalDIM;
	public Cubemap globalSIM;
	// Use this for initialization
	void Start () {
		Shader.SetGlobalTexture("_DIMCube",globalDIM);
		Shader.SetGlobalTexture("_SIMCube",globalSIM);
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
