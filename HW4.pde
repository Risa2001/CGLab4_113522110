import javax.swing.JFileChooser;
import javax.swing.filechooser.FileNameExtensionFilter;

public Vector4 renderer_size;
static public float GH_FOV = 45.0f;
static public float GH_NEAR_MIN = 1e-3f;
static public float GH_NEAR_MAX = 1e-1f;
static public float GH_FAR = 1000.0f;
static public Vector3 AMBIENT_LIGHT = new Vector3(0.3, 0.3, 0.3);

public boolean debug = false;  //紀錄是否啟用除錯模式

public float[] GH_DEPTH;  //深度緩衝區（depth buffer），用於儲存每個像素的深度值，實現深度檢測
public PImage renderBuffer; //渲染緩衝區，用於儲存渲染結果（影像數據）

Engine engine;
Camera main_camera; //負責控制觀察視角
Vector3 cam_position;
Vector3 lookat; //攝影機的觀察目標點
float speed = 0.1f; // 相機移動速度

Light basic_light;

void setup() {
    size(1000, 600);
    renderer_size = new Vector4(20, 50, 520, 550);
    cam_position = new Vector3(0, 0, -10);
    lookat = new Vector3(0, 0, 0);
    setDepthBuffer();
    main_camera = new Camera();
    engine = new Engine();
    engine.renderer.addGameObject(basic_light);
    engine.renderer.addGameObject(main_camera);

}

void setDepthBuffer(){ //深度緩衝區初始化
    renderBuffer = new PImage(int(renderer_size.z - renderer_size.x) , int(renderer_size.w - renderer_size.y));
    GH_DEPTH = new float[int(renderer_size.z - renderer_size.x) * int(renderer_size.w - renderer_size.y)];
    for(int i = 0 ; i < GH_DEPTH.length;i++){
        GH_DEPTH[i] = 1.0; //每個像素的深度值初始為 1.0（代表最遠距離）
        renderBuffer.pixels[i] = color(1.0*250);  //初始化緩衝區顏色為灰色（250 色階的灰）
    }
}

void draw() {
    background(255);

    engine.run();
    cameraControl();
}

String selectFile() {  //導入obj檔案的function
    JFileChooser fileChooser = new JFileChooser();
    fileChooser.setCurrentDirectory(new File("."));
    fileChooser.setFileSelectionMode(JFileChooser.FILES_ONLY);
    FileNameExtensionFilter filter = new FileNameExtensionFilter("Obj Files", "obj");
    fileChooser.setFileFilter(filter);

    int result = fileChooser.showOpenDialog(null);
    if (result == JFileChooser.APPROVE_OPTION) {
        String filePath = fileChooser.getSelectedFile().getAbsolutePath();
        return filePath;
    }
    return "";
}

void cameraControl() {
    // TODO HW3 (Optional)
    // You can write your own camera control function here.
    // Use setPositionOrientation(Vector3 position,Vector3 lookat) to modify the
    // ViewMatrix.
    // Hint : Use keyboard event and mouse click event to change the position of the
    // camera.
    if (keyPressed) {
        if (key == 'w') cam_position.z += speed;  // 向前
        if (key == 's') cam_position.z -= speed;  // 向後
        if (key == 'a') cam_position.x -= speed;  // 向左
        if (key == 'd') cam_position.x += speed;  // 向右
        if (key == 'q') cam_position.y += speed;  // 向上
        if (key == 'e') cam_position.y -= speed;  // 向下
    }
    main_camera.setPositionOrientation(cam_position, lookat);

}
