{ Программа "Золотая спираль"
  Автор: Александр Королёв (avkw@bk.ru)
  (Программа рисует аппроксимацию (приближение) по методу Дюрера) }
program golden_spiral;

uses GraphABC;

const
  a = 10946;              // ширина золотого прямоугольника (не менять!)
  b = 6765;               // высота золотого прямоугольника (не менять!)
  x0 = 7921;              // координаты центра спирали (не менять!)
  y0 = 4895;              // координаты центра спирали (не менять!)
  w = 800;                // ширина окна
  h = 800;                // высота окна
  bgc = clBlack;          // цвет фона
  fgc1 = clGold;          // цвет спирали
  fgc2 = clRed;           // цвет квадратов
  fgc3 = clDarkGray;      // цвет линий
  lim = 1;                // минимальный радиус спирали
  mstep = 1;              // шаг масштабирования за 1 кадр (в %)
  delay = 25;             // пауза между кадрами в миллисекундах (0 = выкл.)
  mf = 6.854102;          // масштаб самоподобия фрактала (не менять!)

var
  dx: real := 0;          // сдвиг по оси X
  dy: real := 0;          // сдвиг по оси Y
  m: real := 1 / mf;      // масштаб
  up: boolean := false;   // направление движения
  lin: boolean := false;  // включить линии
  inf: boolean := false;  // включить отладочную информацию
  rot: boolean := false;  // направление вращения спирали
  clr: boolean := true;   // стирать фон при перерисовке

{ Рекурсивная процедура рисования спирали }
procedure spiral(x1, y1, x2, y2: real; angle: integer; rotation: boolean);
begin
  var r, x3, y3, x4, y4, x5, y5: real;
  var new_angle: integer;
  if angle < 0 then
    angle += 360
  else if angle > 270 then
    angle -= 360;
  if rotation then
    new_angle := angle + 90
  else
    new_angle := angle - 90;
  case angle of
    0:
      begin
        r := abs(y1 - y2);
        x3 := x2;
        y3 := y1;
        x4 := x1 - r;
        y4 := y2;
        x5 := x4;
        y5 := y1;
      end;
    90:
      begin
        r := abs(x1 - x2);
        x3 := x1;
        y3 := y2;
        x4 := x2;
        y4 := y1 + r;
        x5 := x1;
        y5 := y4;
      end;
    180:
      begin
        r := abs(y2 - y1);
        x3 := x2;
        y3 := y1;
        x4 := x1 + r;
        y4 := y2;
        x5 := x4;
        y5 := y1;
      end;
    270:
      begin
        r := abs(x2 - x1);
        x3 := x1;
        y3 := y2;
        x4 := x2;
        y4 := y1 - r;
        x5 := x1;
        y5 := y4;
      end;
  end;
  if r < lim then
    exit;
  var x4r := round(x4);
  var y4r := round(y4);
  if lin then
  begin
    var x1r := round(x1);
    var y1r := round(y1);
    SetPenWidth(1);
    SetPenColor(fgc3);
    Line(x1r, y1r, x4r, y4r);
    Line(x1r, y4r, x4r, y1r);
    SetPenColor(fgc2);
    Line(round(x5), round(y5), x4r, y4r)
  end;
  SetPenColor(fgc1);
  SetPenWidth(2);
  Arc(x4r, y4r, round(r), new_angle, angle);
  spiral(x3, y3, x4, y4, new_angle, rotation);
end;

{ Процедура рисования спирали }
procedure draw_spiral;
begin
  LockDrawing;
  if clr then
    ClearWindow(bgc);
  var x := a * m + dx;
  var y := b * m + dy;
  if lin then
  begin
    SetPenColor(fgc2);
    SetPenWidth(1);
    DrawRectangle(round(dx), round(dy), round(x) + 1, round(y) + 1)
  end;
  if rot then
    spiral(x, dy, dx, y, 0, true)
  else
    spiral(dx, dy, x, y, 180, false);
  if inf then
  begin
    SetFontName('Lucida Console');
    SetFontColor(clWhite);
    SetBrushColor(clTransparent);
    var th := TextHeight('X');
    var tw := TextWidth('X');
    TextOut(tw, th, ' dx = ' + round(dx, 2));
    TextOut(tw, th * 2, ' dy = ' + round(dy, 2));
    TextOut(tw, th * 3, '  m = ' + round(m * 100, 2) + '%');
    TextOut(tw, th * 4, ' up = ' + up.ToString);
    TextOut(tw, th * 5, 'lin = ' + lin.ToString);
    TextOut(tw, th * 6, 'rot = ' + rot.ToString);
    TextOut(tw, th * 7, 'clr = ' + clr.ToString);
  end;
  UnlockDrawing
end;

{ Процедура масштабирования рисунка }
procedure scale(x: real);
begin
  m *= x;
  if m > 1 then
    m /= mf
  else if m < 1 / mf then
    m *= mf;
  if rot then
    dx := (x0 - a) * m + Window.Width / 2
  else
    dx := -x0 * m + Window.Width / 2;
  dy := -y0 * m + Window.Height / 2;
  draw_spiral
end;

{ Обработка нажатий клавиш клавиатуры }
procedure keydown(key: integer);
begin
  case key of
    VK_NumPad4: lin := not lin;
    VK_NumPad5: up := not up;
    VK_NumPad6: rot := not rot;
    VK_NumPad7: inf := not inf;
    VK_NumPad8: clr := not clr;
  end
end;

{ Основная программа }
begin
  SetWindowTitle('Золотая спираль (управление: NumPad 4..8)');
  SetWindowSize(w, h);
  Window.CenterOnScreen;
  onkeydown := keydown; 
  while true do
  begin
    if up then
      scale(100 / (100 + mstep))
    else
      scale((100 + mstep) / 100);
    if delay > 0 then
      sleep(delay);
  end
end.