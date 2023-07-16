using TMPro;
using UnityEngine;

public class FPSDiaplay : MonoBehaviour {
    [SerializeField] private TextMeshProUGUI _text;

    void Update()
    {
        _text.text = ((int)(1f / Time.unscaledDeltaTime)).ToString();
    }
}
