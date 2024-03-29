unit mesh;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs,Vcl.Imaging.Jpeg,Vcl.Imaging.GIFImg,
  GLScene,GLLensFlare,GLVectorTypes,
  GLObjects,GLCrossPlatform,
  GLCoordinates,GLBaseClasses,
  GLWin32Viewer,GLTerrainRenderer,
  GLHeightData, GLMaterial,
  GLSkydome, GLCadencer,
  GLKeyboard,GLUtils,
  GLColor,
  GLTexture,
  GLBitmapFont,
  GLSound,
  GLSMBASS,
  GLVectorGeometry,
  GLState,
  GLFileMP3,
  GLHUDObjects, GLNavigator,
  OpenGLTokens,
  GLVectorLists,
  GLContext,
  GLParticleFX,
  GLGraphics,
  GLPersistentClasses,
  GLPipelineTransformation,
  XOpenGL,
  GLTextureFormat,
  GLRenderContextInfo,
  GLScreen, GLWaterPlane, GLGraph, GLParticles,
  Winapi.OpenGL,
  Vcl.ExtCtrls,
  GLDCE,
  GLVectorFileObjects,
  GLFileMD2,
  GLFile3DS,
  GLEllipseCollision,
  GLProxyObjects,
  GLBehaviours,
  Vcl.StdCtrls,
  GLPerlinPFX,
  GLFireFX, GLThorFX, GLExplosionFx;

type
  TForm1 = class(TForm)
    GLSceneViewer1: TGLSceneViewer;
    GLScene1: TGLScene;
    GLMaterialLibrary1:TGLMaterialLibrary;
    GLBitmapHDS1: TGLBitmapHDS;
    GLTerrainRenderer1: TGLTerrainRenderer;
    GLmoon: TGLSprite;
    GLSkyDome1: TGLSkyDome;
    GLRenderPoint1: TGLRenderPoint;
    GLDummyCube1: TGLDummyCube;
    GLCamera1: TGLCamera;
    GLLensFlare1: TGLLensFlare;
    GLDummyCube2: TGLDummyCube;
    GLLightSource1: TGLLightSource;
    GLCadencer1: TGLCadencer;
    User1: TGLUserInterface;
    GLNavigator1: TGLNavigator;
    GLParticles1: TGLParticles;
    GLDummyCube3: TGLDummyCube;
    Timer1: TTimer;
    Panel1: TPanel;
    GLDCEManager1: TGLDCEManager;
    GLDirectOpenGL1: TGLDirectOpenGL;
    balls: TGLDummyCube;
    GLSphere1: TGLSphere;

    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure GLSceneViewer1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure GLSceneViewer1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GLCadencer1Progress(Sender: TObject; const deltaTime,
      newTime: Double);
    procedure GLParticles1ActivateParticle(Sender: TObject;
      particle: TGLBaseSceneObject);
    procedure GLDummyCube3Progress(Sender: TObject; const deltaTime,
      newTime: Double);
    procedure Timer1Timer(Sender: TObject);
    procedure GLDirectOpenGL1Render(Sender: TObject;
      var rci: TGLRenderContextInfo);
    procedure GLDCEManager1Collision(Sender: TObject; object1,
      object2: TGLBaseSceneObject; CollisionInfo: TDCECollision);

  private
    { Private declarations }
  public
    { Public declarations }

    FCamHeight: Single;
    mx, my: Integer;
    procedure AddBall;

 end;
var
  Form1: TForm1;

implementation

{$R *.dfm}
procedure TForm1.FormCreate(Sender:TObject);
begin
  SetGLSceneMediaDir();//GLUtils
  // 8 MB height data cache
  // Note this is the data size in terms of elevation samples, it does not
  // take into account all the data required/allocated by the renderer
  GLBitmapHDS1.MaxPoolSize := 8 * 1024 * 1024;
  GLBitmapHDS1.Picture.LoadFromFile('terrain.bmp');
  GLTerrainRenderer1.Direction.SetVector(0, 1, 0);
  GLTerrainRenderer1.TilesPerTexture := 256/GLTerrainRenderer1.TileSize;
  //load the texture maps
  GLmoon.Material.Texture.Image.LoadFromFile('moon.bmp');
  //GLSun.Material.Texture.Image.LoadFromFile('sun.bmp');
  GLSceneViewer1.Buffer.BackgroundColor := clWhite;
  FCamHeight  :=20;
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
var
Color:TGIFColor; //Vcl.Imaging.Jpeg,Vcl.Imaging.GIFImg
begin
  case Key of
    'w', 'W':
      with GLMaterialLibrary1.Materials[0].Material do
      begin
        if PolygonMode = pmLines then
          PolygonMode := pmFill
        else
          PolygonMode := pmLines;
      end;
    '+':
      if GLCamera1.DepthOfView < 2000 then
      begin
        GLCamera1.DepthOfView := GLCamera1.DepthOfView * 1.2;
        with GLSceneViewer1.Buffer.FogEnvironment do
        begin
          FogEnd := FogEnd * 1.2;
          FogStart := FogStart * 1.2;
        end;
      end;
    '-':
      if GLCamera1.DepthOfView > 300 then
      begin
        GLCamera1.DepthOfView := GLCamera1.DepthOfView / 1.2;
        with GLSceneViewer1.Buffer.FogEnvironment do
        begin
          FogEnd := FogEnd / 1.2;
          FogStart := FogStart / 1.2;
        end;
      end;
    '*':
      with GLTerrainRenderer1 do
        if CLODPrecision > 20 then
          CLODPrecision := Round(CLODPrecision * 0.8);
    '/':
      with GLTerrainRenderer1 do
        if CLODPrecision < 1000 then
          CLODPrecision := Round(CLODPrecision * 1.2);
    '8':
      with GLTerrainRenderer1 do
        if QualityDistance > 40 then
          QualityDistance := Round(QualityDistance * 0.8);
    '9':
      with GLTerrainRenderer1 do
        if QualityDistance < 1000 then
          QualityDistance := Round(QualityDistance * 1.2);
    'n', 'N':
      with GLSkyDome1 do
        if Stars.Count = 0 then
        begin
          // turn on 'night' mode
          Color.Red := 0;
          Color.Green := 0;
          Color.Blue := 8;
          Bands[0].StopColor.AsWinColor := TGIFColorMap.RGB2Color(Color);
          Color.Red := 0;
          Color.Green := 0;
          Color.Blue := 0;
          Bands[0].StartColor.AsWinColor := TGIFColorMap.RGB2Color(Color);
          Color.Red := 0;
          Color.Green := 0;
          Color.Blue := 16;
          Bands[1].StopColor.AsWinColor := TGIFColorMap.RGB2Color(Color);
          Color.Red := 0;
          Color.Green := 0;
          Color.Blue := 8;
          Bands[1].StartColor.AsWinColor := TGIFColorMap.RGB2Color(Color);
          with Stars do
          begin
            AddRandomStars(700, clWhite, True); // many white stars
            Color.Red := 255;
            Color.Green := 100;
            Color.Blue := 100;
            AddRandomStars(100, TGIFColorMap.RGB2Color(Color), True);
            // some redish ones
            Color.Red := 100;
            Color.Green := 100;
            Color.Blue := 255;
            AddRandomStars(100, TGIFColorMap.RGB2Color(Color), True);
            // some blueish ones
            Color.Red := 255;
            Color.Green := 255;
            Color.Blue := 100;
            AddRandomStars(100, TGIFColorMap.RGB2Color(Color), True);
            // some yellowish ones
          end;
          GLSceneViewer1.Buffer.BackgroundColor := clBlack;
          with GLSceneViewer1.Buffer.FogEnvironment do
          begin
            FogColor.AsWinColor := clBlack;
            FogStart := -FogStart; // Fog is used to make things darker
          end;
          //GLmoon.Visible := True;
          //GLSun.Visible := False;
          GLLensFlare1.Visible := False;
        end;
    'd', 'D':
      with GLSkyDome1 do
        if Stars.Count > 0 then
        begin
          // turn on 'day' mode
          Bands[1].StopColor.Color := clrNavy;
          Bands[1].StartColor.Color := clrBlue;
          Bands[0].StopColor.Color := clrBlue;
          Bands[0].StartColor.Color := clrWhite;
          Stars.Clear;
          GLSceneViewer1.Buffer.BackgroundColor := clWhite;
          with GLSceneViewer1.Buffer.FogEnvironment do
          begin
            FogColor.AsWinColor := clWhite;
            FogStart := -FogStart;
          end;
          GLSceneViewer1.Buffer.FogEnvironment.FogStart := 0;
          GLMoon.Visible := False;
         // GLSun.Visible := True;
        end;
    't':
      with GLSkyDome1 do
      begin
        if sdoTwinkle in Options then
          Options := Options - [sdoTwinkle]
        else
          Options := Options + [sdoTwinkle];
      end;
    'l':
      with GLLensFlare1 do
       GLLensFlare1.Visible:= (not Visible); //sun
  end;
  Key := #0;
end;

procedure TForm1.GLSceneViewer1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  GLCamera1.MoveAroundTarget((my - Y) * 0.5, (mx - X) * 0.5);
  mx:=x; my:=y;
end;

procedure TForm1.GLSceneViewer1MouseMove(Sender:TObject;Shift:TShiftState;X,

  Y:Integer);
begin
  if ssLeft in Shift then
      GLCamera1.MoveAroundTarget(my-y, mx-x);
   if ssRight in Shift then
      GLCamera1.MoveTargetInEyeSpace((y-my)*0.05,(mx-x)*0.05, 0);
   mx:=x; my:=y;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Panel1.Caption:=Format('%d particles, %.1f FPS',
						 [GLParticles1.Count, GLSceneViewer1.FramesPerSecond]);
	GLSceneViewer1.ResetPerformanceMonitor;
end;

procedure TForm1.GLCadencer1Progress(Sender: TObject; const deltaTime,
  newTime: Double);
var
  speed:single;i:integer;
begin
   	GLParticles1.CreateParticle;
   if IsKeyDown(VK_SHIFT) then
    speed := 15 * deltaTime
  else
    speed := deltaTime;
  with GLCamera1.Position do
  begin
    if IsKeyDown(VK_UP) then
      GLDummyCube1.Translate(-X * speed, 0, -Z * speed);
    if IsKeyDown(VK_DOWN) then
      GLDummyCube1.Translate(X * speed, 0, Z * speed);
    if IsKeyDown(VK_LEFT) then
      GLDummyCube1.Translate(-Z * speed, 0, X * speed);
    if IsKeyDown(VK_RIGHT) then
      GLDummyCube1.Translate(Z * speed, 0, -X * speed);
    if IsKeyDown(VK_PRIOR) then
      FCamHeight := FCamHeight + 10 * speed;
    if IsKeyDown(VK_NEXT) then
      FCamHeight := FCamHeight - 10 * speed;
    if IsKeyDown(VK_ESCAPE) then
      Close;
    if IsKeyDown(VK_F1)then
    AddBall;
  end;
  // don't drop through terrain!
  with GLDummyCube1.Position do
    Y := GLTerrainRenderer1.InterpolatedHeight(AsVector) + FCamHeight;
end;

procedure TForm1.GLDCEManager1Collision(Sender: TObject; object1,object2: TGLBaseSceneObject;CollisionInfo: TDCECollision);
var
v: TAffineVector;
begin
   if GLTerrainRenderer1.Tag=1 then
  begin
    v:=AffineVectorMake(VectorSubtract(GLTerrainRenderer1.AbsolutePosition,GLparticles1.AbsolutePosition));
    NormalizeVector(v);
    ScaleVector(v,400);
    GetOrCreateDCEDynamic(GLParticles1).StopAbsAccel;
    GetOrCreateDCEDynamic(GLParticles1).ApplyAbsAccel(v);
  end;
end;

procedure TForm1.GLDirectOpenGL1Render(Sender: TObject;
  var rci: TGLRenderContextInfo);
var
  i: integer;
  p, n: TAffineVector;
begin
  //To use this you will need to enable the debug define in the
  //GLEllipseCollision.pas, if you do, don't forget to clear the
  //triangle list! -> SetLength(debug_tri,0);
  rci.GLStates.PointSize := 5.0;
  for i := 0 to High(debug_tri)do
    with debug_tri[i] do
    begin
      glColor3f(0, 0, 0);
      glBegin(GL_LINE_STRIP);
        glVertex3f(p1.X, p1.Y, p1.Z);
        glVertex3f(p2.X, p2.Y, p2.Z);
        glVertex3f(p3.X, p3.Y, p3.Z);
      glEnd;
      CalcPlaneNormal(p1, p2, p3, n);
      ScaleVector(n, 0.25);
      p.X := (p1.X + p2.X + p3.X) / 3;
      p.Y := (p1.Y + p2.Y + p3.Y) / 3;
      p.Z := (p1.Z + p2.Z + p3.Z) / 3;
      glColor3f(0, 0, 1);
      glBegin(GL_LINE_STRIP);
        glVertex3f(p.X, p.Y, p.Z);
        glVertex3f(p.X + n.X, p.Y + n.Y, p.Z + n.Z);
      glEnd;
      glBegin(GL_POINTS);
        glVertex3f(p.X + n.X, p.Y + n.Y, p.Z + n.Z);
      glEnd;
    end; //}
end;

procedure TForm1.GLDummyCube3Progress(Sender:TObject;const deltaTime,newTime: Double);
begin
  with TGLCustomSceneObject(Sender) do begin
		if newTime-TagFloat>900 then
			GLParticles1.KillParticle(TGLCustomSceneObject(Sender));
	end;
end;

procedure TForm1.GLParticles1ActivateParticle(Sender: TObject;particle: TGLBaseSceneObject);
var
  alpha,x,z,y,S:Single;
  i:Integer;
begin
	with particle do begin
    for i:=0 to GLParticles1.Count-1 do
    Tag :=1;//set the identifier of a particle
    S:=(100+Random(900))/500;
    Scale.SetVector(s, s, s);
    Position.SetPoint(Random(40)-Random(40),Random(70),Random(40)-Random(40));


    Children[0].Position.SetPoint(y+2*random,0,z+2*random);
    Children[0].Position.SetPoint(random,0,random);
    alpha:=Random*3*PI;
		x:=10*Random;            //width
    SinCosine(alpha,x*x,y,z);//curve
    {GetOrCreateInertia(particle).PitchSpeed:=Random(-500);}
  end;
  with GetOrCreateDCEDynamic(particle)do
  begin
    Manager  :=GLDCEManager1;
    Friction :=0.1;
    SlideOrBounce:=csbSlide;
    Size.Assign(particle.Scale);
  end;
  TGLCustomSceneObject(particle).TagFloat:=GLCadencer1.CurrentTime;
  end;

procedure TForm1.AddBall;
var
  Ball: TGLSphere;
  S: Single;
begin
  Ball  := TGLSphere(Balls.AddNewChild(TGLSphere));
  with Ball do
  begin
    Tag := 1; //set the identifier of a ball
    Radius := 1;
    S := (100 + Random(900)) / 500;
    Scale.SetVector(s, s, s);
    Position.SetPoint(
         Random(40) - Random(40),
         4 + Random(10),
         Random(40) - Random(40));
    Material.FrontProperties.Diffuse.SetColor(
        (100 + Random(900)) / 1000,
        (100 + Random(900)) / 1000,
        (100 + Random(900)) / 1000);
  end;
  with GetOrCreateDCEDynamic(Ball)do
  begin
    Manager := GLDCEManager1;
    BounceFactor := 0.75;
    Friction := 0.1;
    SlideOrBounce := csbBounce;
    Size.Assign(Ball.Scale);
  end;
end;


end.




