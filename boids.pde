import java.util.Iterator;
import java.util.HashSet;

int WIDTH = 1280;    // 画面の大きさ
int HEIGHT = 768;   // 画面の大きさ
final boolean FULL_SCREEN = false;  // フルスクリーンモード
final boolean DEBUG = false;  // デバックモード

final int GROUP_COUNT = 16; // 群れのグループ数  

//final float FREE_POINT_COUNT = 1200; // 最初からあるフリーの点の数
final float FREE_POINT_COUNT = 1200; // 最初からあるフリーの点の数
final int RESET_COUNT = 20000;  // ループ間隔
//final int RESET_COUNT = 1500;  // ループ間隔

ArrayList<Boid> boids = new ArrayList<Boid>();
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
ArrayList<Point> freePoints = new ArrayList<Point>();

AreaManager areaMan;

ArrayList<BoidForm> boidForms = new ArrayList<BoidForm>();

int processingMode = 0;
int resetCount = 0;
boolean firstFlg = false; // 動画撮影用のフラグ（最初に１０秒間何もしないかどうかのフラグ)

void setup() {
  if(FULL_SCREEN) {
    size(displayWidth, displayHeight);
  } else {
    size(WIDTH, HEIGHT);
  }
  noStroke();

  // エリアデータを初期化
  areaMan = new AreaManager(displayWidth, displayHeight);

  // フォームデータをロードする
  //boidForms.add(loadFormData("data1.txt"));
  boidForms.add(loadFormData(fish1));
  boidForms.add(loadFormData(fish2));
  //boidForms.add(loadFormData("data2.txt"));
  //boidForms.add(loadFormData("data3.txt"));

  // ボイドを作成(小さい魚)
  //for(int i=0; i < BOID_COUNT; i++) {
  //  makeBoid(30, true, random(0, width), random(0, height), random(-10, 10)/10, random(-10, 10)/10); 
  //}
 
  // フリー点を作成
  for(int i=0; i < FREE_POINT_COUNT; i++) {
    Point p = new Point(random(0, width), random(0, height), random(-1, 1), random(-1, 1));
    freePoints.add(p);
  }

  // 敵配列をセットアップ
  Enemy e = new Enemy();
  enemies.add(e);

}

boolean resetFlg = false;
void keyPressed() {
  
  if(key == 'r') {
    resetFlg = true;
  }

}

int fish1[][] = {
  {0,0},
  {-1,-2},
  {-1,2},
  {-5,-4},
  {-5,4},
  {-9,-5},
  {-9,5},
  {-13,-6},
  {-13,6},
    {-18,-6},
    {-18,6},
    {-22,-6},
    {-22,6},
    {-26,-5},
    {-26,5},
    {-30,-3},
    {-30,3},
    {-34,-1},
    {-34,1},
    {-38,-4},
    {-38,4},
    {-42,-7},
    {-42,-3},
    {-42,0},
    {-42,3},
    {-42,7},
};

int fish2[][] = {
  {0,0},
  {-3,-5},
  {-3,4},
  {-8,-10},
  {-8,8},
  {-13,-14},
  {-13,11},
  {-19,-16},
  {-19,12},
  {-25,-17},
  {-25,13},
  {-28,-8},
  {-29,6},
  {-31,-14},
  {-31,-5},
  {-31,3},
  {-31,11},
  {-37,-6},
  {-37,4},
  {-42,-1},
  {-43,-8},
  {-43,6},
};

// 形状データロード
BoidForm loadFormData(int[][] fishData) {

  BoidForm bf = new BoidForm();
  for(int i = 0; i < fishData.length; i++ ) {
    Form f = new Form();
    f.x = float(fishData[i][0]);
    f.y = float(fishData[i][1]);
    bf.addForm(f);
  }

  return bf;
}


void draw() {
  background(0);

  if(firstFlg) {
    firstFlg = false;
    delay(15000); 
  }

  // 敵情報を更新する
  for(Iterator<Enemy> it = enemies.iterator(); it.hasNext(); ) {
    Enemy e = it.next(); 
    e.update();
  } 

  // マウスカーソルの位置を敵として登録
  Enemy me = enemies.get(0);
  me.x = mouseX;
  me.y = mouseY;

  // 敵情報を更新する
  for(Iterator<Enemy> it = enemies.iterator(); it.hasNext(); ) {
    Enemy e = it.next(); 
    e.calcDistance();
  } 

  // ボイドについての処理
  processingBoids();

  // 所属のない点についての処理
  processingFreePoints();

  // リセット処理
  if(processingMode == 0) {

    if(resetFlg || resetCount == RESET_COUNT) { 
      processingMode = 1;

      resetFlg = false;

      for(Iterator<Boid> it = boids.iterator(); it.hasNext(); ) {
        Boid b = it.next(); 
        b.setStatusDie();
      }
    }
    resetCount++;

  } else {
    if(boids.size() == 0) {
      processingMode = 0;
      resetCount = 0;
      releaseFreePoint();
    }
  }

  if(!DEBUG) return;

  fill(255, 255, 255);
  text("count = " + resetCount, 10, 10);
  text("mode = " + processingMode, 10, 30);
  text("boids = " + boids.size(), 10, 50);

  //text("free points : " + freePoints.size(), 10, 10);
  //text("boid  : " + boids.size(), 10, 30);
  //int i=0;
  //for(Iterator<Boid> it = boids.iterator(); it.hasNext(); ) {
  //  Boid b = it.next();
  //  text("boid points : " + b.points.size(), 10, 50 + i * 20 ); 
  //  i++;
  //}

  //int x = areaMan.areas.length;
  //int y = areaMan.areas[0].length;
  //text("x = " + x + "      y = " + y, 10, 10);

  //for(int y = 0; y < areaMan.sizeY; y++ ) {
  //  for(int x = 0; x < areaMan.sizeX; x++ ) {
  //    int cnt = areaMan.areas[x][y].points.size();
  //    text(cnt, 10 + 20 * x, 200 + y * 20);
  //  }
  //}

  //ArrayList<Area> areas = areaMan.extractAreaList();
  //text("over = " + areas.size(), 0, 400);
  //for(int i=0; i < areas.size(); i++) {
  //  Area a = areas.get(i);
  //  text("x = " + a.x + " y = " + a.y + " cnt = " + a.points.size(), 0, 420 + i * 20);
  //}
  //

}

// ボイドの新規作成
Boid makeBoid(int pointCount, boolean pointCountRandom, float x, float y, float vx, float vy) {

  int idx = boids.size();

  // グループと形状の決定
  int group = idx % GROUP_COUNT;
  int type = group % boidForms.size();

  if(pointCountRandom) {
    int cnt = boidForms.get(type).getSize();
    pointCount = cnt + (int)random(-5, 5);
  }

  Boid b = new Boid(boidForms.get(type), pointCount, x, y, vx, vy);
  b.group = group; 

  if(type == 0 ) { 
    makeBoidForm1(b, idx);
  } else if(type == 1) {
    makeBoidForm2(b, idx);
  } else if(type == 2) {
    makeBoidForm3(b, idx);
  }
  boids.add(b);

  return b;
}

// フォーム１の初期値
void makeBoidForm1(Boid b, int idx) {

  b.scale = random(0.5, 1.2); 

  b.maxSpeedX = 3.2;
  b.maxSpeedY = 1;

  b.massDistance = 22;
  b.massCount = 1;

  if((idx % 3) == 0) {
    b.sepDistance = 30; 
    float sepCoeff = random(2.8, 3.2);
    b.sepCoeffX = sepCoeff * 2; 
    b.sepCoeffY = sepCoeff; 
    b.sepCount = 0;
    b.sepCountMax = 640;

    b.coheCoeffX = 0.00002; 
    b.coheCoeffY = 0.0002; 
    b.coheDistance = 80; 
    b.coheDistanceMax = 150; 

    float alignCoeff = 0.0001; 
    b.alignCoeffX = alignCoeff * 1.8;
    b.alignCoeffY = alignCoeff * 0.01;
  } else {
    float sepCoeff = random(2.2, 3.0);
    b.sepCoeffX = sepCoeff * 2; 
    b.sepCoeffY = sepCoeff; 
    b.sepCount = 0;
    b.sepCountMax = 640;

    b.coheCoeffX = 0.002; 
    b.coheCoeffY = 0.0002; 
    b.coheDistance = 80; 
    b.coheDistanceMax = 150; 

    float alignCoeff = 0.008; 
    b.alignCoeffX = alignCoeff * 1.8;
    b.alignCoeffY = alignCoeff * 0.01;
  }
}

// フォーム2の初期値
void makeBoidForm2(Boid b, int idx) {

  b.scale = random(0.4, 1.0); 

  b.maxSpeedX = 2.0;
  b.maxSpeedY = 1.0;

  b.massDistance = 22;
  b.massCount = 1;

  if((idx % 3) == 0) {
    b.sepDistance = 30; 
    float sepCoeff = random(2.8, 3.2);
    b.sepCoeffX = sepCoeff * 2; 
    b.sepCoeffY = sepCoeff; 
    b.sepCount = 0;
    b.sepCountMax = 640;

    b.coheCoeffX = 0.00002; 
    b.coheCoeffY = 0.0002; 
    b.coheDistance = 80; 
    b.coheDistanceMax = 150; 

    float alignCoeff = 0.0001; 
    b.alignCoeffX = alignCoeff * 1.8;
    b.alignCoeffY = alignCoeff * 0.01;
  } else {
    float sepCoeff = random(2.2, 3.0);
    b.sepCoeffX = sepCoeff * 1.2; 
    b.sepCoeffY = sepCoeff; 
    b.sepCount = 0;
    b.sepCountMax = 640;

    b.coheCoeffX = 0.002; 
    b.coheCoeffY = 0.0001; 
    b.coheDistance = 80; 
    b.coheDistanceMax = 150; 

    float alignCoeff = 0.008; 
    b.alignCoeffX = alignCoeff * 1.8;
    b.alignCoeffY = alignCoeff * 0.01;
  }
}

// フォーム3の初期値
void makeBoidForm3(Boid b, int idx) {

  b.scale = random(0.6, 1.0); 

  b.maxSpeedX = 1.0;
  b.maxSpeedY = 1.6;

  b.massDistance = 20;
  b.massCount = 1;

  if((idx % 3) == 0) {
    b.sepDistance = 30; 
    float sepCoeff = random(3.2, 5.2);
    b.sepCoeffX = sepCoeff; 
    b.sepCoeffY = sepCoeff * 4; 
    b.sepCount = 0;
    b.sepCountMax = 640;

    b.coheCoeffX = 0.00001; 
    b.coheCoeffY = 0.0003; 
    b.coheDistance = 60; 
    b.coheDistanceMax = 180; 

    float alignCoeff = 0.0001; 
    b.alignCoeffX = alignCoeff * 0.01;
    b.alignCoeffY = alignCoeff * 1.8;
  } else {
    float sepCoeff = random(2.4, 3.2);
    b.sepCoeffX = sepCoeff; 
    b.sepCoeffY = sepCoeff * 4; 
    b.sepCount = 0;
    b.sepCountMax = 640;

    b.coheCoeffX = 0.0001; 
    b.coheCoeffY = 0.003; 
    b.coheDistance = 60; 
    b.coheDistanceMax = 180; 

    float alignCoeff = 0.008; 
    b.alignCoeffX = alignCoeff * 0.01;
    b.alignCoeffY = alignCoeff * 1.8;
  }
}

// ボイドの処理
void processingBoids() {

  // 形状がある場合の処理
  for(Iterator<Boid> it = boids.iterator(); it.hasNext(); ) {
    Boid b = it.next(); 

    // 群れの処理
    controlBoid(b);

    // スピードの制御
    b.updateSpeed();

    // 外敵の処理
    avoidEnemies(b);

    // もし、１つも点を従えていない場合はボイドを削除
    if(b.points.size() == 0) {
      it.remove();
      continue;
    }
  
    // ボイドに点が多すぎる場合は点を離脱させる
    leaveBoid(b);

    // 移動処理
    b.move();

    // 描画処理
    b.draw();
  }
}

// ボイドに点が多すぎる時に点を離脱させ、ボイドを削除する処理
void leaveBoid(Boid target) {

  if(target.isDie() && (frameCount%5) == 0) {  // TODO パラメータ化する
    int idx = target.points.size() - 1;
    Point p = target.points.get(idx);
    target.points.remove(idx);
    p.deleteParent();
    freePoints.add(p);
    p.vx = -p.vx;
    p.vy = -p.vy;
  }
}

// 指定ボイドの全ての点を解放する
void releasePoint(Boid target) {

  // 所属点を全て解放する
  for(Iterator<Point> pit = target.points.iterator(); pit.hasNext(); ) {
    Point p = pit.next();
    pit.remove();
    p.deleteParent();
    freePoints.add(p);
  }
  
}

// フリーポイントを全てリセットする
void releaseFreePoint() {
  for(Iterator<Point> it = freePoints.iterator(); it.hasNext(); ) {
    Point p = it.next();
    p.deleteParent();
  }
}


// 外敵との衝突判定
void avoidEnemies(Boid target) {

  for(Iterator<Enemy> it = enemies.iterator(); it.hasNext(); ) {
    Enemy e = it.next();
    // 敵とボイドの衝突判定
    decisionBoid(e, target);
    // 敵と点の衝突判定
    decisionBoidPoint(e, target);
  }

}

// ボイドと敵の判定
void decisionBoid(Enemy e, Boid target) {

  float dx = e.x - target.x;
  float dy = e.y - target.y;
  float dis = sqrt(dy * dy + dx * dx);

  if(dis < 50) {    // TODO パラメータ化する
    float vx = (e.x - e.prevX);
    float vy = (e.y - e.prevY);
    target.vx -= (vx / dis) * 2.0;
    target.vy -= (vy / dis) * 1.3;
  }
}

// 点と敵の判定
void decisionBoidPoint(Enemy e, Boid target) {

  for(Iterator<Point> it = target.points.iterator(); it.hasNext(); ) {
    Point p = it.next();
    
    float dx = e.x - p.x;
    float dy = e.y - p.y;
    float dis = sqrt(dy * dy + dx * dx);

    if(dis < 10) {      // TODO パラメータ化する

      // 力の強さを判定
      if(e.distance < 300) continue;

      // ボイドから点を分散させる
      p.deleteParent();
      freePoints.add(p);
      target.resetFormFlg = true;
      it.remove();

      float vx = (e.x - e.prevX);
      float vy = (e.y - e.prevY);
      p.fx -= (vx / dis) * 2.0;
      p.fy -= (vy / dis) * 1.2;
    }
  }
}


// ボイド群の処理
void controlBoid(Boid target) {

  float mx = 0;
  float my = 0;
  int mcount = 0;

  float sx = 0;
  float sy = 0;
  int scount = 0;

  float cx = 0;
  float cy = 0;
  int ccount = 0;

  float ax = 0;
  float ay = 0;
  int acount = 0;

  for(Iterator<Boid> it = boids.iterator(); it.hasNext(); ) {

    Boid b = it.next(); 

    if(b == target) continue;
    
    // 距離を算出 
    float dx = b.x - target.x;
    float dy = b.y - target.y;
    float distance = sqrt(dy * dy + dx * dx);
 
    // 近くで固まり過ぎている時
    if(distance < target.massDistance) { 
      mx -= (dx / distance);
      my -= (dy / distance);
      mcount++; 
    }

    // 近すぎる時(separation)
    if(distance < target.sepDistance) {
      sx -= (dx / distance);
      sy -= (dy / distance);
      scount++;
    } 

    // 遠すぎる時(coherence)
    if(distance > target.coheDistance && distance <= target.coheDistanceMax && target.group == b.group) {
      cx += b.x;
      cy += b.y;
      ccount++;   
    }

    // 丁度いい距離の時(alignment)
    if(distance >= target.sepDistance && distance <= target.coheDistance && target.group == b.group) {
      ax += b.vx;
      ay += b.vy;
      acount++;
    }
  }

  // 固まり過ぎている場合の処理
  if(mcount >= target.massCount) {
    target.vx += mx * target.sepCoeffX;   
    target.vy += my * target.sepCoeffY;   
  }

  // 近すぎるボイドがいた時の処理
  if(target.sepCount == 0) {
    if(scount > 0) { 
      target.vx += sx * target.sepCoeffX; 
      target.vy += sy * target.sepCoeffY; 
      target.sepCount = target.sepCountMax;
    }
  } else {
    // 近すぎる処理をスキップする
    target.sepCount--;
  }

  // 遠すぎる場合
  if(ccount > 0) {
    target.vx += ((cx / (float)ccount) - target.x) * target.coheCoeffX;  
    target.vy += ((cy / (float)ccount) - target.y) * target.coheCoeffY;
  }

  // 丁度いい距離の時野処理  
  if(acount > 0) {
    target.vx += ((ax / (float)acount) - target.vx) * target.alignCoeffX;
    target.vy += ((ay / (float)acount) - target.vy) * target.alignCoeffY;
  }
}

// 所属のない点についての処理
void processingFreePoints() {

  // 所属エリアクリア
  areaMan.clear();

  // 所属のない点について処理
  for(Iterator<Point> it = freePoints.iterator(); it.hasNext(); ) {
    Point p = it.next();

    // 所属の決まった点については削除する
    if(p.boid != null) {
      it.remove();
      continue;
    }

    // 群衆処理(所属のない点同士) 
    controlBoidOfFreePoint(p);

    // 群衆処理(ボイドとの関係)
    //controlBoidOfFreePoint2(p);

    // 移動スピードの更新
    p.updateSpeed();

    // 外敵の処理
    decisionFreePoint(p);

    // 合流処理
    if(p.isJoin()) {
      boolean joinFlg = joinBoids(p);
      if(joinFlg) {
        it.remove();
        continue;
      }
    }

    // 移動処理    
    p.move();

    // 描画処理
    p.draw();

    // エリア登録
    if(p.isJoin()) {
      areaMan.addPoint(p);
    }
  }

  // 新しいボイドの作成を検討する
  if(processingMode == 0) {
    makeNewBoidForArea();
  }
}

// 点について群衆シミュレーションを実施  
void controlBoidOfFreePoint(Point target) {

  float sx = 0;
  float sy = 0;
  int scount = 0;

  float cx = 0;
  float cy = 0;
  int ccount = 0;

  float ax = 0;
  float ay = 0;
  int acount = 0;

  for(Iterator<Point> it = freePoints.iterator(); it.hasNext(); ) {
    Point p = it.next();
    
    if(p == target) continue; 

    // 距離を算出
    float dx = p.x - target.x;
    float dy = p.y - target.y;
    float distance = sqrt(dy * dy + dx * dx);

    // 近すぎる時（separation)
    if(distance < 12) {         // TODO パラメータ化すること！
      sx -= (dx / distance);
      sy -= (dy / distance);
      scount++;
    }

    // 遠すぎる時(coherence) {
    if(distance >= 50 && distance < 80) {
      cx += p.x;
      cy += p.y;
      ccount++;
    }

    // 丁度いい距離の時(alignment)
    if(distance >= 12 && distance < 50) {
      ax += p.vx;
      ay += p.vy;
      acount++;
    }
  }

  // 近すぎる時の処理
  if(scount > 0) {
    target.vx += sx * 0.1;
    target.vy += sy * 0.1;
  }

  // 遠すぎる時の処理
  if(ccount > 0) {
    target.vx += ((cx / (float)ccount) - target.x) * 0.0001;
    target.vy += ((cy / (float)ccount) - target.y) * 0.0001;
  }
  
  // 丁度いい距離の時の処理
  if(acount > 0) {
    target.vx += ((ax / (float)acount) - target.vx) * 0.01;
    target.vy += ((ay / (float)acount) - target.vy) * 0.01;
  }
}

// 点について群衆シミュレーションを実施  
void controlBoidOfFreePoint2(Point target) {

  float sx = 0;
  float sy = 0;
  int scount = 0;

  float cx = 0;
  float cy = 0;
  int ccount = 0;

  float ax = 0;
  float ay = 0;
  int acount = 0;

  for(Iterator<Boid> it = boids.iterator(); it.hasNext(); ) {
    Boid b = it.next();
    
    // 距離を算出
    float dx = b.x - target.x;
    float dy = b.y - target.y;
    float distance = sqrt(dy * dy + dx * dx);

    // 近すぎる時（separation)
    if(distance < 15) {         // TODO パラメータ化すること！
      sx -= (dx / distance);
      sy -= (dy / distance);
      scount++;
    }

    // 遠すぎる時(coherence) {
    if(distance >= 50 && distance < 80) {
      cx += b.x;
      cy += b.y;
      ccount++;
    }

    // 丁度いい距離の時(alignment)
    if(distance >= 15 && distance < 50) {
      ax += b.vx;
      ay += b.vy;
      acount++;
    }
  }

  // 近すぎる時の処理
  if(scount > 0) {
    target.vx += sx * 0.1;
    target.vy += sy * 0.1;
  }

  // 遠すぎる時の処理
  if(ccount > 0) {
    target.vx += ((cx / (float)ccount) - target.x) * 0.0001;
    target.vy += ((cy / (float)ccount) - target.y) * 0.0001;
  }
  
  // 丁度いい距離の時の処理
  if(acount > 0) {
    target.vx += ((ax / (float)acount) - target.vx) * 0.01;
    target.vy += ((ay / (float)acount) - target.vy) * 0.01;
  }
}

// 集中している点がある場合は新しいボイドの作成を検討する
void makeNewBoidForArea() {

  // 一カ所に点が集まりすぎている時は
  // 新しいボイドの作成を検討する
  ArrayList<Area> areas = areaMan.extractAreaList();
  for(Iterator<Area> it = areas.iterator(); it.hasNext(); ) {
    Area a = it.next();

    Boid boid = makeBoid(0, false, a.pointX, a.pointY, a.pointVx, a.pointVy);

    // 点を追加する
    for(Iterator<Point> pit = a.points.iterator(); pit.hasNext(); ) {
      Point p = pit.next();
      boid.addPoint(p);
    }
  }
}

// 合流処理
boolean joinBoids(Point p) {
  boolean joinFlg = false;
  int i = 0;
  for(Iterator<Boid> it = boids.iterator(); it.hasNext(); ) {
    Boid b = it.next();
    
    if(b.status != 0) continue;

    float dx = b.x - p.x;
    float dy = b.y - p.y;
    float dis = sqrt(dy * dy + dx * dx);

    if(dis < 30) {  // TODO パラメータ化する
      b.addPoint(p);
      b.resetFormFlg = true;
      joinFlg = true;
      break;
    }
    i++;
  }
  return joinFlg;
}

// フリー点と敵の判定
void decisionFreePoint(Point p) {

  for(Iterator<Enemy> it = enemies.iterator(); it.hasNext(); ) {
    Enemy e = it.next();

    float dx = e.x - p.x;
    float dy = e.y - p.y;
    float dis = sqrt(dy * dy + dx * dx);

    if(dis < 20) {                // TODO パラメータ化
      float vx = (e.x - p.x);
      float vy = (e.y - p.y);
      p.fx -= (vx / dis) * 2.0;
      p.fy -= (vy / dis) * 1.2;
    }
  }
}

// ボイドクラス
class Boid {
  float x, y;   // 座標
  float vx, vy; // 移動ベクトル
  float scale;  // スケール値
  float angle;  // 角度
 
  int group;        // グループID 

  float maxSpeedX;    // 最大移動速度
  float maxSpeedY;    // 最大移動速度
  float attenuationSpeedRateX;    // 移動速度の減衰率
  float attenuationSpeedRateY;    // 移動速度の減衰率

  float massDistance; // 近すぎて固まっているかどうかの距離
  int massCount;      // 近すぎて固まっている処理を行う最小数

  float sepDistance;  // 近すぎるかどうかの距離
  float sepCoeffX;    // 近すぎた時に移動速度に影響を与える係数
  float sepCoeffY;    // 近すぎた時に移動速度に影響を与える係数
  int sepCount;       // 近すぎるかどうかのボイド的行動を行う間隔をカウント
  int sepCountMax;    // 近すぎる時のボイド的行動を行う間隔

  float coheDistance; // 遠すぎるかどうかの距離
  float coheDistanceMax; // 影響範囲の最大距離
  float coheCoeffX;   // 遠すぎた時の移動速度に影響を与える係数 
  float coheCoeffY;   // 遠すぎた時の移動速度に影響を与える係数 
 
  float alignCoeffX;  // 丁度いい距離の時の移動速度に影響を与える係数
  float alignCoeffY;  // 丁度いい距離の時の移動速度に影響を与える係数

  BoidForm form;  // 形状データ
  boolean resetFormFlg; // 形状データの更新フラグ

  ArrayList<Point> points = new ArrayList<Point>(); // 点配列
  
  int lifeCount;  // ボイドが形成されてからのカウンタ
  int life;       // ボイドの寿命

  int status;     // ステータス 0 : 通常 1 : 死

  // 初期処理（新しく作る場合）
  Boid(BoidForm form, int pointCount, float x, float y, float vx, float vy) {
    this.form = form;
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.scale = 1.0;
    this.resetFormFlg = false;
    this.attenuationSpeedRateX = 0.998; 
    this.attenuationSpeedRateY = 0.993; 
    this.lifeCount = 0;
    this.life = (int)random(7000, 12000);
    this.status = 0;

    // 形状を作成
    makeForm(pointCount);
  }

  // 個体の形状を作成
  private void makeForm(int pointCount) {
    // 形状を合わせてポイントの座標をセットする
    for(int i=points.size(); i < pointCount; i++ ) {
      int formIdx = i % form.forms.size();

      Form data = form.getForm(formIdx);
      float lx = data.x; 
      float ly = data.y;
    
      // 形状データよりも点が多い場合は元の形から少しズレた位置を点の位置とする
      // TODO ランダムではなく、点の間を補間するような形にしたい、またはオプション的な形状を追加したい
      lx += (float)(i / form.forms.size()) * random(-10, 10);
      ly += (float)(i / form.forms.size()) * random(-10, 10);

      Point p = new Point(this, lx, ly);
      points.add(p);
    }
  }

  // 点を追加する
  public void addPoint(Point p) {
    int formIdx = points.size() % form.forms.size();

    Form data = form.getForm(formIdx);
    p.lx = data.x;
    p.ly = data.y;
    p.boid = this;
    points.add(p);
  } 

  // 移動速度の更新
  public void updateSpeed() {
    // 速度を減衰する
    vx *= attenuationSpeedRateX; 
    vy *= attenuationSpeedRateY;

    // 左右の端でたまっている状態を回避
    if( abs(vx) <= 0.2 && (x < 10 || x > (width - 10)) ) {
      if(x < 10) vx += 0.2;
      if(x > (width - 10) ) vx -= 0.2;
    }

    // 速度の制限する
    vx = constrain(vx, -maxSpeedX, maxSpeedX);
    vy = constrain(vy, -maxSpeedY, maxSpeedY);
  }

  // 状態を変化させる
  private void updateStatus() {
    // 所属する点が多すぎるか判定
    if(points.size() > (form.forms.size() * 4.8)) {
      status = 1;
    }

    // 寿命を超えているか判定
    if(lifeCount > life) {
      status = 1;
    }
  }

  public void setStatusDie() {
    status = 1;
  }

  // 寿命を超えているか判定
  public boolean isDie() {
    boolean flg = false;
    if(status == 1) {
      flg = true;
    }
    return flg;
  }

  // 移動処理
  public void move() {

    // 形状の再作成処理
    if(resetFormFlg) { 
      resetLocalPosition(); 
      resetFormFlg = false;
    }

    // 移動ベクトルから角度算出 
    angle = degrees(atan2(vx, vy));

    // 移動処理
    x += vx;
    y += vy;
 
    // 壁判定
    decisionWall();

    // 各点の移動処理
    for(Iterator<Point> it = points.iterator(); it.hasNext(); ) {
      Point p = it.next(); 
      // 移動処理
      p.move();
    }

    // 状態の更新
    updateStatus();

    lifeCount++; 
  }

  // 壁判定
  private void decisionWall() {
    if( x < 0 ) {
      vx = -vx;
      x = 0;
    }
    if( x > width ) {
      vx = -vx;
      x = width;
    }

    if( y < 0 ) {
      vy = -vy;
      y = 0;
    }
    if( y > height) {
      vy = -vy;
      y = height;
    }
  }

  // 各点のローカル座標を改めて設定する
  private void resetLocalPosition() { 
    for(int i=0; i < points.size(); i++ ) {
      // 各点のローカル座標を書き換える
      Point p = points.get(i);
      int formIdx = i % form.getSize();
      p.lx = form.getForm(formIdx).x;
      p.ly = form.getForm(formIdx).y;
    }
  } 

  // 描画処理
  public void draw() {
    // 各点
    for(Iterator<Point> it = points.iterator(); it.hasNext(); ) {
      Point p = it.next(); 
      p.draw();
    }

    if(!DEBUG) return; 

    stroke(255, 255, 255);
    strokeWeight(1);
    noFill();
    ellipse(x, y, 50, 50);
  }
}

// 点クラス
class Point {
  Boid boid;
  float x, y;   // 最終的なグローバル座標
  float vx, vy; // 移動量
  float fx, fy; // 外力
  float gx, gy; // グローバル座標
  float lx, ly; // ローカル座標 
  int freeCount; // 所属なしになってからの経過時間 
  int freeStatusCount;  //  
  boolean joinFlg;

  final float attenuationSpeedRateX = 0.9999;  // 移動スピードの減衰率
  final float attenuationSpeedRateY = 0.995;
  final float maxSpeedX = 3;  // 最高移動スピード 
  final float maxSpeedY = 2; 

  final float pointSize = 2;  // 点の大きさ
  
  // 初期処理
  Point(float x, float y, float vx, float vy) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.lx = 0;
    this.ly = 0; 
    this.boid = null;
    this.freeCount = 0;
    this.freeStatusCount = 160 + (int)random(300); 
    this.joinFlg = false;
  }

  // 初期処理
  Point(Boid boid, float lx, float ly) {
    this.lx = lx;
    this.ly = ly; 
    this.boid = boid;
    calcGlobal();
    this.x = this.gx;
    this.y = this.gy;
    this.freeCount = 0;
    this.freeStatusCount = 160 + (int)random(300); 
    this.joinFlg = false;
  }

  // 所属を削除
  public void deleteParent() {
    this.boid = null;
    this.freeCount = 0;
    this.freeStatusCount = 160 + (int)random(300); 
    this.joinFlg = false;
  }

  // 参加可否
  public boolean isJoin() {
    return joinFlg;
  }

  // 移動スピードの更新
  public void updateSpeed() {
    // 速度を減衰する
    if(vx > (maxSpeedX*0.5)) {
      vx *= 0.75;
    } else {
      vx *= attenuationSpeedRateX; 
    }
    if(vy > (maxSpeedY*0.5)) {
      vy *= 0.70;
    } else {
      vy *= attenuationSpeedRateY;
    }
    
    // 速度の制限する
    vx = constrain(vx, -maxSpeedX, maxSpeedX);
    vy = constrain(vy, -maxSpeedY, maxSpeedY);
  }

  // 移動処理
  public void move() {
    // 所属しているか判定
    if(boid != null) {
      // グローバル座標を算出
      calcGlobal();
      // グローバル座標との差分を算出し、移動量とする 
      calcDiff();
    } else {
      // 移動処理
      updateXy();
      // 壁判定
      decisionWall(); 

      if(freeCount > freeStatusCount) {
        joinFlg = true;
      }
      freeCount++;
    }
  }

  // 壁判定
  private void decisionWall() {
    if(x < 0) {
      vx *= -1.0;
      x = 0;
    }
    if(x > width) {
      vx *= -1.0;
      x = width;
    }
    if(y < 0) {
      vy *= -1.0;
      y = 0;
    }
    if(y > height) {
      vy *= -1.0;
      y = height;
    }
  }
  
  // 移動量を算出する
  private void calcDiff() {
    // 現在の座標とグローバル座標との差分を算出し、移動量とする
    vx = (gx - x) / 12;
    vy = (gy - y) / 12;
 
    // 座標更新　 
    updateXy();
  }

  // 座標更新
  private void updateXy() {

    // 移動量を変化 
    vx += fx; 
    vy += fy;
   
    // 座標を算出
    x += vx;
    y += vy;

    // 外力を減退させる
    fx *= 0.62;
    fy *= 0.62;
  }

  // グローバル座標を算出 
  private void calcGlobal() { 
    float rlx = lx + random(-5, 5);
    float rly = ly + random(-5, 5);

    // スケーリング
    rlx *= boid.scale;
    rly *= boid.scale;

    // 距離算出
    float dis = sqrt(rly * rly + rlx * rlx);

    // 回転処理
    gx = (sin(radians(boid.angle)) * rlx + cos(radians(boid.angle)) * rly);
    gy = (cos(radians(boid.angle)) * rlx - sin(radians(boid.angle)) * rly);

    // 平行移動
    gx += boid.x;
    gy += boid.y;
  }

  // 描画処理
  public void draw() {
    fill(255, 255, 255);
    ellipse(x, y, pointSize, pointSize);
  } 
}

// 敵クラス
class Enemy {
  float x, y;
  float prevX, prevY;
  float distance;

  public void update() {
    prevX = x;
    prevY = y;
  }

  public void calcDistance() {
    float dx = x - prevX;
    float dy = y - prevY;
    distance = (dy * dy + dx * dx); 
  }
}

// 距離クラス
class Distance {
  float dx, dy;
  float distance;
}

// エリアの管理クラス
class AreaManager {
  Area[][] areas; 
  final int areaSize = 100; // エリアサイズ
  final int extractCount = 10;  // エリアごとの抽出数
  int sizeX;
  int sizeY;
  HashSet<Area> areaSet = new HashSet<Area>();

  // 初期化処理
  AreaManager(int w, int h) {
    sizeX = (w / areaSize) + 1; 
    sizeY = (h / areaSize) + 1; 
    areas = new Area[sizeX][sizeY]; 

    for(int x = 0; x < sizeX; x++ ) {
      for(int y = 0; y < sizeY; y++ ) {
        areas[x][y] = new Area();
      }
    }
  }

  // クリア処理
  public void clear() {
    for(int x = 0; x < sizeX; x++ ) {
      for(int y = 0; y < sizeY; y++ ) {
        areas[x][y].clear(); 
      }
    }
  }

  // 登録処理
  public void addPoint(Point p) {
    int x = (int)p.x / areaSize;
    int y = (int)p.y / areaSize;
    if(x >= sizeX) return;
    if(y >= sizeY) return; 
    areas[x][y].add(p, x, y); 
  }

  // 抽出処理
  public ArrayList<Area> extractAreaList() {
    ArrayList<Area> areaList = new ArrayList<Area>(); 

    for(int x = 0; x < sizeX; x++ ) {
      for(int y = 0; y < sizeY; y++ ) {
        if(areas[x][y].points.size() >= extractCount) {
          areaList.add(areas[x][y]);
        }
      }
    }

    return areaList;
  }
}

// エリアクラス 
class Area {
  ArrayList<Point> points;
  int x, y;
  float totalPointX, totalPointY;
  float pointX, pointY;
  float totalVx, totalVy;
  float pointVx, pointVy;

  // 初期処理
  Area() {
    points = new ArrayList<Point>();
  }

  // クリア
  public void clear() {
    points.clear();
    totalPointX = 0;
    totalPointY = 0;
    totalVx = 0;
    totalVy = 0;
  }

  // 追加
  public void add(Point p, int x, int y) {
    this.x = x;
    this.y = y;
    points.add(p);

    int pointSize = points.size();
    this.totalPointX += p.x;
    this.totalPointY += p.y;
    this.pointX = totalPointX / pointSize;
    this.pointY = totalPointY / pointSize;
    this.totalVx += p.vx;
    this.totalVy += p.vy;
    this.pointVx = totalVx / pointSize; 
    this.pointVy = totalVy / pointSize; 
  }
}

// ボイドの形状クラス
class BoidForm {
  ArrayList<Form> forms;

  BoidForm() {
    forms = new ArrayList<Form>();
  }

  public Form getForm(int idx) {
    return forms.get(idx);
  }

  public int getSize() {
    return forms.size();
  }

  public void addForm(Form f) {
    forms.add(f);
  }
}

// 形状クラス
class Form {
  float x, y;
}
