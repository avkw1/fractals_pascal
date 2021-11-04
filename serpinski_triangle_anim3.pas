{ Программа "Треугольник Серпинского 3"
  Автор: Александр Королёв (avkw@bk.ru) }
program serpinski_triangle_anim3;

uses GraphABC;

const
  w = 513;        // ширина окна
  h = 444;        // высота окна
  cx1 = 256;      // координата x1
  cx2 = 512;      // координата x2
  cy2 = 443;      // координата y2
  bgc = clBlack;  // цвет фона
  fgc = clOrange; // цвет треугольника
  lim = 3;        // минимальный размер треугольника
  mstep = 1;      // шаг масштабирования за 1 кадр (в %)
  delay = 25;     // пауза между кадрами в миллисекундах (0 = выкл.)
  mf = 2;         // масштаб самоподобия фрактала (не менять!)

var
  dx: real := 0;        // сдвиг по оси X
  dy: real := 0;        // сдвиг по оси Y
  m: real := 1;         // масштаб
  up: boolean := false; // направление движения
  angle: integer := 1;  // угол, в который (из которого) движемся

{ Рекурсивная процедура рисования фрактала }
procedure triangle(x1, y1, x2, y2, x3, y3: real);
begin
  if (x2 < 0) or (y2 < 0) or (x3 > w) or (y1 > h) then
    exit;
  var x4 := (x3 + x1) / 2;
  var y4 := (y3 + y1) / 2;
  var x5 := (x1 + x2) / 2;
  var y6 := (y2 + y3) / 2;
  var x4r := round(x4);
  var y4r := round(y4);
  MoveTo(x4r, y4r);
  LineTo(round(x5), round(y4));
  LineTo(round(x1), round(y6));
  LineTo(x4r, y4r);
  if (x5 - x4) < lim then
    exit;
  triangle(x1, y1, x5, y4, x4, y4);
  triangle(x5, y4, x2, y2, x1, y6);
  triangle(x4, y4, x1, y6, x3, y3)
end;

{ Процедура рисования треугольника-фрактала }
procedure draw_triangle;
begin
  LockDrawing;
  ClearWindow(bgc);
  var x1 := cx1 * m + dx;
  var x2 := cx2 * m + dx;
  var y2 := cy2 * m + dy;
  var x1r := round(x1);
  var y1r := round(dy);
  MoveTo(x1r, y1r);
  LineTo(round(x2), round(y2));
  LineTo(round(dx), round(y2));
  LineTo(x1r, y1r);
  triangle(x1, dy, x2, y2, dx, y2);
  UnlockDrawing
end;

{ Процедура масштабирования рисунка }
procedure scale(x: real);
begin
  m *= x;
  if m > mf then
    m /= mf
  else if m < 1 then
    m *= mf;
  case angle of
    0:
      begin
        dx := cx1 * (1 - m);
        dy := 0
      end;
    1:
      begin
        dx := cx2 * (1 - m);
        dy := cy2 * (1 - m)
      end;
    2:
      begin
        dx := 0;
        dy := cy2 * (1 - m)
      end;
  end;
  draw_triangle;
end;

{ Обработка нажатий клавиш клавиатуры }
procedure keydown(key: integer);
begin
  case key of
    VK_Up: angle := 0;
    VK_Down: up := not up;
    VK_Left: angle := 2;
    VK_Right: angle := 1;
  end;
end;

{ Основная программа }
begin
  SetWindowTitle('Треугольник Серпинского 3 (управление: стрелки)');
  SetWindowSize(w, h);
  Window.IsFixedSize := true;
  Window.CenterOnScreen;
  SetPenColor(fgc);
  onkeydown := keydown; 
  while true do
  begin
    if up then
      scale(100 / (100 + mstep))
    else
      scale((100 + mstep) / 100);
    if delay > 0 then
      sleep(delay);
  end;
end.