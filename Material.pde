public abstract class Material {
    Vector3 albedo = new Vector3(0.9, 0.9, 0.9);  //表示材質的基本反射係數（通常對應於顏色），預設為亮灰色，用於控制物體對光的漫反射比例
    Shader shader;

    Material() {
        // TODO HW4
        // In the Material, pass the relevant attribute variables and uniform variables
        // you need.
        // In the attribute variables, include relevant variables about vertices,
        // and in the uniform, pass other necessary variables.
        // Please note that a Material will be bound to the corresponding Shader.
    }

    abstract Vector4[][] vertexShader(Triangle triangle, Matrix4 M);

    abstract Vector4 fragmentShader(Vector3 position, Vector4[] varing);

    void attachShader(Shader s) { //將指定的著色器物件綁定到當前材質
        shader = s;
    }
}

public class DepthMaterial extends Material { //用於深度緩衝的材質，僅計算深度值
    DepthMaterial() {
        shader = new Shader(new DepthVertexShader(), new DepthFragmentShader());
    }

    Vector4[][] vertexShader(Triangle triangle, Matrix4 M) { //頂點著色器，計算 MVP 變換後的位置
        Matrix4 MVP = main_camera.Matrix().mult(M);
        Vector3[] position = triangle.verts; // 頂點位置
        Vector4[][] r = shader.vertex.main(new Object[] { position }, new Object[] { MVP });
        return r;
    }

    Vector4 fragmentShader(Vector3 position, Vector4[] varing) { //片段著色器，輸出深度值
        return shader.fragment.main(new Object[] { position });
    }
}

public class PhongMaterial extends Material { //用於 Phong 光照模型，包含環境光、漫反射和高光反射
    Vector3 Ka = new Vector3(0.3, 0.3, 0.3); //ambient環境光係數
    float Kd = 0.5; //漫反射係數
    float Ks = 0.5; //高光反射係數
    float m = 20;   //高光反射的聚焦程度

    PhongMaterial() {
        shader = new Shader(new PhongVertexShader(), new PhongFragmentShader());
    }

    Vector4[][] vertexShader(Triangle triangle, Matrix4 M) {
        Matrix4 MVP = main_camera.Matrix().mult(M);  //// 計算 MVP 矩陣
        Vector3[] position = triangle.verts;
        Vector3[] normal = triangle.normal;
        Vector4[][] r = shader.vertex.main(new Object[] { position, normal }, new Object[] { MVP, M });
        return r;
    }

    Vector4 fragmentShader(Vector3 position, Vector4[] varing) {

        /*return shader.fragment
                .main(new Object[] { position, varing[0].xyz(), varing[1].xyz(), albedo, new Vector3(Kd, Ks, m) });*/ //原本的return
        return shader.fragment.main(new Object[] { 
            position, 
            varing[0].xyz(), 
            varing[1].xyz(), 
            albedo, 
            new Vector3(Kd, Ks, m) 
        });
    }

}

public class FlatMaterial extends Material { //用於平面著色，每個三角形只有一個顏色，頂點和片段著色器簡化處理，僅計算平面光照
    FlatMaterial() {
        shader = new Shader(new FlatVertexShader(), new FlatFragmentShader());
    }

    Vector4[][] vertexShader(Triangle triangle, Matrix4 M) {
        Matrix4 MVP = main_camera.Matrix().mult(M);
        Vector3[] position = triangle.verts;

        // TODO HW4
        // pass the uniform you need into the shader.

        /*Vector4[][] r = shader.vertex.main(new Object[] { position }, new Object[] { MVP });
        return r;*/
        
        // 計算三角形的法向量
        Vector3 edge1 = position[1].sub(position[0]);
        Vector3 edge2 = position[2].sub(position[0]);
        Vector3 normal = Vector3.cross(edge1,edge2);
        normal.normalize();

        // 傳遞法向量和 MVP 矩陣到著色器
        Vector4[][] r = shader.vertex.main(new Object[] { position, normal, albedo }, new Object[] { MVP });
        return r;
    }

    Vector4 fragmentShader(Vector3 position, Vector4[] varing) {
        return shader.fragment.main(new Object[] { position, albedo });
    }
}

public class GouraudMaterial extends Material { //Gouraud 光照模型，在頂點著色器計算光照並插值至片段
    GouraudMaterial() {
        shader = new Shader(new GouraudVertexShader(), new GouraudFragmentShader());
    }

    Vector4[][] vertexShader(Triangle triangle, Matrix4 M) {
        Matrix4 MVP = main_camera.Matrix().mult(M);
        Vector3[] position = triangle.verts;
        
        // TODO HW4
        // pass the uniform you need into the shader.
        Vector3 albedo = this.albedo;

        Vector4[][] r = shader.vertex.main(new Object[] { position }, new Object[] { MVP, albedo });
        return r;
    }

    Vector4 fragmentShader(Vector3 position, Vector4[] varing) {
        return shader.fragment.main(new Object[] { position });
    }
}

public enum MaterialEnum { //定義材質類型的枚舉
    DM, FM, GM, PM; //DepthMaterial,FlatMaterial,GouraudMaterial,PhongMaterial
}
