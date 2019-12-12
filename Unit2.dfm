object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 323
  ClientWidth = 505
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GLSceneViewer1: TGLSceneViewer
    Left = 0
    Top = 0
    Width = 505
    Height = 323
    Camera = GLCamera1
    Buffer.BackgroundColor = clSkyBlue
    FieldOfView = 145.595214843750000000
    PenAsTouch = False
    Align = alClient
    TabOrder = 0
  end
  object GLScene1: TGLScene
    Left = 16
    Top = 16
    object GLCamera1: TGLCamera
      DepthOfView = 100.000000000000000000
      FocalLength = 50.000000000000000000
      TargetObject = GLSphere1
      Direction.Coordinates = {BD31DF3E48EF143F15C92FBF00000000}
      Up.Coordinates = {52C5E13E82EC063FCDFA393F00000000}
    end
    object GLSphere1: TGLSphere
      Radius = 0.500000000000000000
    end
    object GLDummyCube1: TGLDummyCube
      CubeSize = 1.000000000000000000
    end
    object GLLightSource1: TGLLightSource
      ConstAttenuation = 1.000000000000000000
      SpotCutOff = 180.000000000000000000
    end
    object GLDirectOpenGL1: TGLDirectOpenGL
      UseBuildList = False
      Blend = False
    end
  end
end
