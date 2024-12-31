class Light extends GameObject {
    Vector3 light_color;
    float intensity;   //光源的強度
    Vector3 ambient;     // 環境光強度
    Vector3 diffuse;     // 漫反射光強度
    Vector3 specular;    // 高光強度

    Light() {
        light_color = new Vector3(0.8, 0.8, 0.8);  //光的顏色
        intensity = 1.0f;  //光的強度
        transform.position = new Vector3(10.0, 10.0, -10.0);
        ambient = new Vector3(0.2, 0.2, 0.2);      // 環境光默認較弱
        diffuse = new Vector3(0.8, 0.8, 0.8);      // 漫反射強度
        specular = new Vector3(1.0, 1.0, 1.0);     // 高光強度
        name = "Light";
    }
}
