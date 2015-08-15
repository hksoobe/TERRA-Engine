Unit TERRA_UILabel;

{$I terra.inc}

Interface
Uses TERRA_String, TERRA_Object, TERRA_UIWidget, TERRA_UIDimension, TERRA_Vector2D, TERRA_Color, TERRA_Font, TERRA_Viewport;

Type
  UILabel = Class;

  CaptionProperty = Class(StringProperty)
    Protected
      _Text:TERRAString;
      _Owner:UILabel;

    Public
      Constructor Create(Const Name:TERRAString; Const InitValue:TERRAString; Owner:UILabel);

      Procedure SetBlob(Const Value:TERRAString); Override;

      Property Text:TERRAString Read _Text;
  End;


  UILabel = Class(UIWidget)
    Protected
      _Caption:CaptionProperty;

      _TextRect:Vector2D;
      _PreviousFont:TERRAFont;

      Function GetLocalizationKey: TERRAString;

      Procedure UpdateSprite(View:TERRAViewport); Override;

    Public
      Constructor Create(Const Name:TERRAString; Parent:UIWidget; X,Y,Z:Single; Const Width, Height:UIDimension; Const Text:TERRAString);

      Procedure UpdateRects; Override;

      Function SupportDrag(Mode:UIDragMode):Boolean; Override; 

      Function GetSize:Vector2D; Override;

			Procedure OnLanguageChange(); Override;

      Property Caption:CaptionProperty Read _Caption;
      Property LocalizationKey:TERRAString Read GetLocalizationKey;
  End;

Implementation
Uses TERRA_Localization, TERRA_FontRenderer;

Constructor UILabel.Create(const Name:TERRAString; Parent:UIWidget; X,Y,Z:Single; Const Width, Height:UIDimension; Const Text:TERRAString);
Begin
  Inherited Create(Name, Parent);

  Self.SetRelativePosition(VectorCreate2D(X,Y));
  Self.Layer := Z;

  Self.Width := Width;
  Self.Height := Height;


  _Caption := CaptionProperty(Self.AddProperty(CaptionProperty.Create('caption', Text, Self), False));
End;

Function UILabel.GetLocalizationKey: TERRAString;
Begin
  If StringFirstChar(_Caption.Value) = Ord('#') Then
  Begin
    Result := StringCopy(Caption.Value, 2, MaxInt);
  End Else
    Result := '';
End;

Function UILabel.GetSize: Vector2D;
Begin
  If (_NeedsUpdate) Then
    Self.UpdateRects();

  Result := Inherited GetSize;
End;

Procedure UILabel.OnLanguageChange;
Begin
  Self.Caption.SetBlob(Self._Caption._Value);
End;

Procedure UILabel.UpdateRects;
Var
  Fnt:TERRAFont;
Begin
  Inherited;

(*TODO  Fnt := Self.GetFont();

  If ((_NeedsUpdate) Or (Fnt<>_PreviousFont)) And (Assigned(FontRenderer)) Then
  Begin
    _TextRect := FontRenderer.GetTextRect(_Caption.Value, 1.0);
    _PreviousFont := Fnt;
    _NeedsUpdate := False;
  End;*)
End;

{ CaptionProperty }
Constructor CaptionProperty.Create(const Name, InitValue: TERRAString; Owner: UILabel);
Begin
  Inherited Create(Name, InitValue);
  _Owner := Owner;
End;

Procedure CaptionProperty.SetBlob(const Value: TERRAString);
Var
  S, S2:TERRAString;
  It:StringIterator;
Begin
  _Value := Value;
  _Owner._NeedsUpdate := True;

  S := Value;
  _Text := '';
  Repeat
    If StringCharPosIterator(UIMacroBeginChar, S, It, True) Then
    Begin
      It.Split(S2, S);
      _Text := _Text + S2;

      S2 := StringGetNextSplit(S, UIMacroEndChar);

      S2 := _Owner.ResolveMacro(S2);

      _Text := _Text + S2 + ' ';
    End Else
    Begin
      _Text := _Text + S;
      Break;
    End;

  Until False;

  S := ConvertFontCodes(S);
End;

Procedure UILabel.UpdateSprite;
Var
  TextRect:Vector2D;
  TextArea:Vector2D;
Begin
  If _Sprite = Nil Then
    _Sprite := FontSprite.Create();

  Self._Caption.SetBlob(_Caption.Value);

  Self.FontRenderer.SetFont(FontManager.Instance.DefaultFont);
  Self.FontRenderer.SetColor(Self.GetColor());

  TextArea := VectorCreate2D(Trunc(Self.GetDimension(Self.Width, uiDimensionWidth)),  Trunc(Self.GetDimension(Self.Height, uiDimensionHeight)));
  TextRect := Self.FontRenderer.GetTextRect(Self.Caption._Text);

  Self.FontRenderer.DrawTextToSprite(View, (TextArea.X - TextRect.X) * 0.5,  (TextArea.Y - TextRect.Y) * 0.5, Self.GetLayer(), Self.Caption._Text, FontSprite(_Sprite));

  _Sprite.SetTransform(Self.Transform);
End;

Function UILabel.SupportDrag(Mode: UIDragMode): Boolean;
Begin
  Result := (Mode = UIDrag_Move);
End;

End.