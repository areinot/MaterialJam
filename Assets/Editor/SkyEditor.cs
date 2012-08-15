using UnityEngine;
using UnityEditor;
using System.Collections;

public class SkyEditor : EditorWindow {
	
	string	myString = "hihihi";
	bool	groupEnabled;
	bool	myBool = true;
	float	myFloat = 1.23f;
	Cubemap	DIM;
	Cubemap SIM;
	
	[MenuItem("Window/Marmoset Sky Editor")]
	public static void ShowWindow() {
		EditorWindow.GetWindow(typeof(SkyEditor));
	}
	
	void OnGUI() {
		GUILayout.Label("Base Settings", EditorStyles.boldLabel);
		myString = EditorGUILayout.TextField("Text Field", myString);
		
		groupEnabled = EditorGUILayout.BeginToggleGroup("Optional Settings", groupEnabled);
			myBool = EditorGUILayout.Toggle( "Toggle", myBool );
			myFloat = EditorGUILayout.Slider( "Slider", myFloat, 0, 10 );
		EditorGUILayout.EndToggleGroup();
		EditorGUILayout.ObjectField(DIM,typeof(Cubemap));
	}
}
