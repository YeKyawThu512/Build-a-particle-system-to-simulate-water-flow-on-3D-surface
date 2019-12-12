unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, GLScene, GLCoordinates, GLObjects,
  GLWin32Viewer, GLCrossPlatform, GLBaseClasses;

type
  TForm2 = class(TForm)
    GLScene1: TGLScene;
    GLSceneViewer1: TGLSceneViewer;
    GLDummyCube1: TGLDummyCube;
    GLCamera1: TGLCamera;
    GLLightSource1: TGLLightSource;
    GLDirectOpenGL1: TGLDirectOpenGL;
    GLSphere1: TGLSphere;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

end.
