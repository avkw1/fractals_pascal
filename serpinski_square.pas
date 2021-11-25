{ Программа "Квадрат Серпинского"
  Автор: Александр Королёв (avkw@bk.ru) }
program serpinski_square;

uses GraphABC;

const
  a = 486;          // сторона квадрата
  w = a;            // ширина окна
  h = a;            // высота окна
  bgc = clBlack;    // цвет фона
  fgc = clGreen;    // цвет квадрата
  lim = 2;          // минимальный размер квадрата
  mstep = 1;        // шаг масштабирования за 1 кадр (в %)
  delay = 25;       // пауза между кадрами в миллисекундах (0 = выкл.)
  mf = 3;           // масштаб самоподобия фрактала (не менять!)

var
  dx: real := 0;        // сдвиг по оси X
  dy: real := 0;        // сдвиг по оси Y
  m: real := 1;         // масштаб
  up: boolean := false; // направление движения
  angle: integer := 0;  // угол, в который (из которого) движемся

{ Рекурсивная процедура рисования фрактала }
procedure square(x1, y1, x2, y2: real);
begin
  if (x2 < 0) or (y2 < 0) or (x1 > w) or (y1 > h) then
    exit;
  var len := (x2 - x1) / 3;
  if len < lim then
    exit;
  var x3 := x1 + len;
  var y3 := y1 + len;
  var x4 := x2 - len;
  var y4 := y2 - len;
  fillrectangle(round(x3), round(y3), round(x4), round(y4));
  square(x1, y1, x3, y3);
  square(x3, y1, x4, y3);
  square(x4, y1, x2, y3);
  square(x4, y3, x2, y4);
  square(x4, y4, x2, y2);
  square(x3, y4, x4, y2);
  square(x1, y4, x3, y2);
  square(x1, y3, x3, y4)
end;

{ Процедура рисования квадрата-фрактала }
procedure draw_square;
begin
  LockDrawing;
  ClearWindow(bgc);
  var x := a * m + dx;
  var y := a * m + dy;
  SetBrushColor(fgc);
  fillrectangle(round(dx), round(dy), round(x), round(y));
  SetBrushColor(bgc);
  square(dx, dy, x, y);
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
        dx := 0;
        dy := 0
      end;
    1:
      begin
        dx := a / 2 * (1 - m);
        dy := 0
      end;
    2:
      begin
        dx := a * (1 - m);
        dy := 0
      end;
    3:
      begin
        dx := a * (1 - m);
        dy := dx / 2
      end;
    4:
      begin
        dx := a * (1 - m);
        dy := dx
      end;
    5:
      begin
        dy := a * (1 - m);
        dx := dy / 2;
      end;
    6:
      begin
        dx := 0;
        dy := a * (1 - m)
      end;
    7:
      begin
        dx := 0;
        dy := a / 2 * (1 - m)
      end;
  end;
  draw_square;
end;

{ Обработка нажатий клавиш клавиатуры }
procedure keydown(key: integer);
begin
  case key of
    VK_NumPad5: up := not up;
    VK_NumPad7: angle := 0;
    VK_NumPad8: angle := 1;
    VK_NumPad9: angle := 2;
    VK_NumPad6: angle := 3;
    VK_NumPad3: angle := 4;
    VK_NumPad2: angle := 5;
    VK_NumPad1: angle := 6;
    VK_NumPad4: angle := 7;
  end;
end;

{ Основная программа }
begin
  SetWindowTitle('Квадрат Серпинского (управление: NumPad 1..9)');
  SetWindowSize(w, h);
  Window.IsFixedSize := true;
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
  end;
end.