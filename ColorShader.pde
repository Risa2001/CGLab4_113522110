public class PhongVertexShader extends VertexShader {
    Vector4[][] main(Object[] attribute, Object[] uniform) {
        Vector3[] aVertexPosition = (Vector3[]) attribute[0];
        Vector3[] aVertexNormal = (Vector3[]) attribute[1];
        Matrix4 MVP = (Matrix4) uniform[0];
        Matrix4 M = (Matrix4) uniform[1];
        Vector4[] gl_Position = new Vector4[3];
        Vector4[] w_position = new Vector4[3];
        Vector4[] w_normal = new Vector4[3];

        for (int i = 0; i < gl_Position.length; i++) {
            gl_Position[i] = MVP.mult(aVertexPosition[i].getVector4(1.0));
            w_position[i] = M.mult(aVertexPosition[i].getVector4(1.0));
            w_normal[i] = M.mult(aVertexNormal[i].getVector4(0.0));
        }

        Vector4[][] result = { gl_Position, w_position, w_normal };

        return result;
    }
}

public class PhongFragmentShader extends FragmentShader {
    Vector4 main(Object[] varying) {
        Vector3 position = (Vector3) varying[0];
        Vector3 w_position = (Vector3) varying[1];
        Vector3 w_normal = (Vector3) varying[2];
        Vector3 albedo = (Vector3) varying[3];
        Vector3 kdksm = (Vector3) varying[4];
        Light light = basic_light;
        Camera cam = main_camera;

        // TODO HW4
        // In this section, we have passed in all the variables you need.
        // Please use these variables to calculate the result of Phong shading
        // for that point and return it to GameObject for rendering
        float Kd = kdksm.x; // 漫反射係數
        float Ks = kdksm.y; // 高光反射係數
        float m = kdksm.z;  // 高光聚焦程度
        
        // 計算光線方向
        Vector3 lightDir = light.transform.position.sub(w_position);
        lightDir.normalize();

        // 計算視線方向
        Vector3 viewDir = cam.transform.position.sub(w_position);
        viewDir.normalize();

        // 計算反射方向
        Vector3 reflectDir = w_normal.mult(2.0 * Vector3.dot(w_normal, lightDir)).sub(lightDir);
        reflectDir.normalize();

        // 環境光
        Vector3 ambient = light.ambient.mult(1,albedo);

        // 漫反射
        float diff = Math.max(Vector3.dot(w_normal, lightDir), 0.0);
        Vector3 diffuse = light.diffuse.mult(1,albedo).mult(diff).mult(Kd);

        // 高光反射
        float spec = (float) Math.pow(Math.max(Vector3.dot(viewDir,reflectDir), 0.0), m);
        Vector3 specular = light.specular.mult(Ks).mult(spec);

        // 總光照
        Vector3 resultColor = ambient.add(diffuse).add(specular);

        // 返回結果（包括 alpha 通道）
        return new Vector4(resultColor.x, resultColor.y, resultColor.z, 1.0);

        //return new Vector4(0.0, 0.0, 0.0, 1.0);
    }
}

public class FlatVertexShader extends VertexShader {
    Vector4[][] main(Object[] attribute, Object[] uniform) {
        Vector3[] aVertexPosition = (Vector3[]) attribute[0];
        Vector3 normal = (Vector3) attribute[1]; // 接收整個三角形的法向量 //*
        Matrix4 MVP = (Matrix4) uniform[0];
        Vector4[] gl_Position = new Vector4[3];

        // TODO HW4
        // Here you have to complete Flat shading.
        // We have instantiated the relevant Material, and you may be missing some
        // variables.
        // Please refer to the templates of Phong Material and Phong Shader to complete
        // this part.

        // Note: Here the first variable must return the position of the vertex.
        // Subsequent variables will be interpolated and passed to the fragment shader.
        // The return value must be a Vector4.

        // Flat Shading 中的頂點位置計算
        for (int i = 0; i < gl_Position.length; i++) {
            gl_Position[i] = MVP.mult(aVertexPosition[i].getVector4(1.0));
        }

        // 計算每個頂點的裁剪空間座標
        for (int i = 0; i < gl_Position.length; i++) {
            gl_Position[i] = MVP.mult(aVertexPosition[i].getVector4(1.0));
        }

        // 將頂點位置作為第一個返回值，其餘為需要插值的變量
        Vector4[][] result = { gl_Position };

        return result;
    }
}

public class FlatFragmentShader extends FragmentShader {
    Vector4 main(Object[] varying) {
        Vector3 position = (Vector3) varying[0];
        Vector3 albedo = (Vector3) varying[1]; // 接收 albedo
        // TODO HW4
        // Here you have to complete Flat shading.
        // We have instantiated the relevant Material, and you may be missing some
        // variables.
        // Please refer to the templates of Phong Material and Phong Shader to complete
        // this part.

        // Note : In the fragment shader, the first 'varying' variable must be its
        // screen position.
        // Subsequent variables will be received in order from the vertex shader.
        // Additional variables needed will be passed by the material later.

        //return new Vector4(0.0, 0.0, 0.0, 1.0);
        // 計算光照
        Light light = basic_light;
        float intensity = 0.8f; // 假設光照強度為 1.0
        Vector3 finalcolor = light.diffuse.mult(0.5,albedo).mult(intensity);

        return new Vector4(finalcolor.x, finalcolor.y, finalcolor.z, 1.0);
    }
}

public class GouraudVertexShader extends VertexShader {
    Vector4[][] main(Object[] attribute, Object[] uniform) {
        Vector3[] aVertexPosition = (Vector3[]) attribute[0];
        //Vector3 albedo = (Vector3) attribute[1]; // 接收材質的 albedo //*
        Matrix4 MVP = (Matrix4) uniform[0];
        Vector3 albedo = (Vector3) uniform[1]; //*

        Vector4[] gl_Position = new Vector4[3];
        Vector4[] vertexColor = new Vector4[3]; // 用於存儲每個頂點的光照計算結果 //*

        // TODO HW4
        // Here you have to complete Gouraud shading.
        // We have instantiated the relevant Material, and you may be missing some
        // variables.
        // Please refer to the templates of Phong Material and Phong Shader to complete
        // this part.

        // Note: Here the first variable must return the position of the vertex.
        // Subsequent variables will be interpolated and passed to the fragment shader.
        // The return value must be a Vector4.

        for (int i = 0; i < gl_Position.length; i++) {
            // 1. 計算頂點位置
            gl_Position[i] = MVP.mult(aVertexPosition[i].getVector4(1.0));
            
            // 計算光照 (假設光源和相機位置是全局變數)
            Vector3 normal = calculateNormal(aVertexPosition); // 計算法向量
            System.out.println("Normal: " + normal);
            Vector3 lightDir = basic_light.transform.position.sub(aVertexPosition[i]);
            lightDir.normalize();
            float intensity = Math.abs(Vector3.dot(normal, lightDir));
            //Vector3 ambient = basic_light.ambient.mult(1, albedo); // 環境光
            //Vector3 diffuse = basic_light.diffuse.mult(1, albedo).mult(intensity); // 漫反射光
            Vector3 finalcolor = basic_light.diffuse.mult(1,albedo).mult(intensity);
            vertexColor[i] = new Vector4(finalcolor.x, finalcolor.y, finalcolor.z, 1.0);
            //System.out.println("vertexColor[i]: " + vertexColor[i]);
        }

        //Vector4[][] result = { gl_Position };

        Vector4[][] result = { gl_Position, vertexColor };
        return result;
    }
    private Vector3 calculateNormal(Vector3[] verts) {
        Vector3 edge1 = verts[1].sub(verts[0]);
        Vector3 edge2 = verts[2].sub(verts[0]);
        Vector3 result = Vector3.cross(edge1,edge2);
        result.normalize();
        return result;
    }
}

public class GouraudFragmentShader extends FragmentShader {
    Vector4 main(Object[] varying) {
        //Vector3 position = (Vector3) varying[0];

        // TODO HW4
        // Here you have to complete Gouraud shading.
        // We have instantiated the relevant Material, and you may be missing some
        // variables.
        // Please refer to the templates of Phong Material and Phong Shader to complete
        // this part.

        // Note : In the fragment shader, the first 'varying' variable must be its
        // screen position.
        // Subsequent variables will be received in order from the vertex shader.
        // Additional variables needed will be passed by the material later.

        return new Vector4(0.0, 0.0, 0.0, 1.0);
        //System.out.println("Varying Length: " + varying.length);
        //System.out.println("Varying[1]: " + varying[1]);
        //Vector4 interpolatedColor = (Vector4) varying[1]; // 接收到插值後的顏色

        // 返回插值後的顏色，帶上 alpha 通道
        //return new Vector4(interpolatedColor.x, interpolatedColor.y, interpolatedColor.z, interpolatedColor.w);
    }
}
