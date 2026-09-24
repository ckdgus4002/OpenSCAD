// UHK80 키캡 세트 - OpenSCAD / KeyV2 + BOSL2
// 작업 규칙 / 값의 근거 / 건드리면 안 되는 값 / 실측해야 할 값은 전부
// .claude/skills/uhk80-keycaps/SKILL.md 에 있다. 코드를 고치기 전에 먼저 읽을 것.
// (아래 주석의 "SKILL.md N" 은 그 문서의 N 번 항목을 가리킨다)
// 실행 전제: OpenSCAD 개발 스냅샷(2021.01 불가) / 같은 폴더에 KeyV2 폴더 /
//            BOSL2 설치 / 같은 폴더에 DejaVuSansMono-Bold.ttf   (SKILL.md 1)

include <./KeyV2/includes.scad>
include <BOSL2/std.scad>     // 반드시 KeyV2 뒤에 include 할 것.
use <./DejaVuSansMono-Bold.ttf>   // 동봉 폰트. 같은 폴더에 파일이 있어야 한다

// ---------------------------------------------------------------
// 렌더 선택
// ---------------------------------------------------------------
//   형식은 KEY 목록 하나뿐이다. 규칙은 SKILL.md 5
//   세 축(반/행/열) 모두 문자열로 쓴다. 행·열은 "0" 부터 세고, "-1" 은 '그 축 전부' 다

function KEY(hand, row, col) = [hand, row, col];

// 뽑을 키 목록 (한 줄에 하나)
RENDER = [
  KEY("L", "-1", "-1"),
];

// [프린트 베드] 가로 폭만 쓴다. 세로는 넘치면 그냥 줄이 늘어날 뿐이라 안 본다
BED_WIDTH = 190;

PACK_WIDTH   = BED_WIDTH - 3;   // 줄이면 좁고 길게, 늘리면 넓고 짧게
PACK_GAP_X   = 2.0;             // FDM 에서 안 붙게 하는 여유
PACK_PITCH_Y = 21.0;            // 줄 간격 = 키 세로(약 18) + 앞뒤 여유

// 스템 서포트: "tines" | "disable"
STEM_SUPPORT = "disable";

// ---------------------------------------------------------------
// [호밍 돌기 - 에프/제이 앞쪽 가로 바]
// ---------------------------------------------------------------
//   KeyV2 의 keybump() 는 쓰지 않고 아래 homing_bar() 로 직접 그린다.
//   그 이유와 HOMING_EDGE_INSET 의 근거는 SKILL.md 15
HOMING_LENGTH     = 6.0;   // 좌우 방향(mm)
HOMING_WIDTH      = 1.0;   // 앞뒤 방향(mm)
HOMING_HEIGHT     = 0.4;   // 상판에서 실제로 솟는 높이(mm)
HOMING_EDGE_INSET = 1.2;   // 상판 앞 모서리에서 바 중심까지의 거리(mm)

// profiled_base() 안에서 불러야 프로파일 값이 잡힌다
module homing_bar() {
  top_of_key()
    difference() {
      // 바 기둥 - 아래로 1mm 묻는다. 상판 두께(1.5mm)를 안 넘어야
      // 캡 안쪽 빈 공간으로 튀어나오지 않는다
      translate([0, -top_total_key_height() / 2 + HOMING_EDGE_INSET, -1])
        linear_extrude(height = 4)
          offset(r = HOMING_WIDTH / 2, $fn = 24)
            square([max(HOMING_LENGTH - HOMING_WIDTH, 0.01), 0.001], center = true);
      homing_top_cut();
    }
}

// 바 윗면을 상판 곡면과 평행하게 자른다.
// 원기둥 딥을 HOMING_HEIGHT 만큼 들어올린 것을 빼면 된다
// (top_of_key() 좌표계에서 상판 곡면은 z = 딥곡면 + $dish_depth 이다)
module homing_top_cut() {
  if ($dish_type == "cylindrical") {
    w     = top_total_key_width() + $dish_overdraw_width;
    d     = $dish_depth;
    chord = (pow(w, 2) - 4 * pow(d, 2)) / (8 * d);
    rad   = (pow(w, 2) + 4 * pow(d, 2)) / (8 * d);
    // $fa/$fs 를 여기서 못 박는다. 반지름이 커서(1U 기준 약 19mm) 분할이 거칠면
    // 자른 면이 실제 원호보다 위로 떠서 바가 0.03mm 쯤 높아진다
    translate([0, 0, chord + d + HOMING_HEIGHT])
      rotate([90, 0, 0]) cylinder(h = 400, r = rad, center = true, $fa = 0.5, $fs = 0.1);
  } else {
    translate([-200, -200, HOMING_HEIGHT]) cube([400, 400, 200]);
  }
}

// ---------------------------------------------------------------
// [스템 여유 - 프로파일별로 따로 잡는다]
// ---------------------------------------------------------------
//   저/일반은 증상이 정반대라 값을 나눴다. 하나로 묶으면 한쪽이 망가진다.
//   슬롭 표와 근거는 SKILL.md 7
LOW_PROFILE_STEM_SLOP       = 0.45;   // 저프로파일: 바깥 기둥만 줄인다
LOW_PROFILE_STEM_INNER_SLOP = 0.20;   // 안쪽은 그대로. 여기 물림은 문제 없었다
STANDARD_STEM_SLOP          = 0.35;   // 일반 높이: 바깥은 그대로
STANDARD_STEM_INNER_SLOP    = 0.05;   // 안쪽 십자를 좁힌다

// ---------------------------------------------------------------
// [Choc v2 원통 기둥 - 엄지열 전용]
// ---------------------------------------------------------------
//   십자 구멍은 MX 와 규격이 같아 건드리지 않고, 바깥 사각 기둥만 원통으로 깎는다.
//   지름 / 45도 형상 / 음수 slop 의 근거는 SKILL.md 8
CHOC2_BOSS_DIAMETER = 5.45;   // 방진벽 안지름 5.8 기준
CHOC2_BAND_HEIGHT   = 2.2;    // 여기까지가 직선 원통 구간(mm)
CHOC2_BOSS_HEIGHT   = 3.2;    // 다듬는 전체 높이. 저프로파일의 $stem_throw 와 같게 둔다
CHOC2_SLOP          = -0.15;  // 깎기 전 사각 기둥의 여유. 음수 = 기둥을 키운다
CHOC2_FACETS        = 48;
CHOC2_TRIM_BOX      = 12;     // 깎기용 상자 한 변(mm)

if (CHOC2_BOSS_DIAMETER > 5.5 - CHOC2_SLOP * 2)
  echo(str("경고: CHOC2_BOSS_DIAMETER(", CHOC2_BOSS_DIAMETER, ") 가 깎기 전 기둥 세로(",
           5.5 - CHOC2_SLOP * 2, ") 보다 크다. CHOC2_SLOP 을 더 내려야 한다"));

// 남길 기둥 형상 (BOSL2 cyl 의 음수 chamfer = 위쪽을 45도로 바깥으로 벌린다).
// epsilon 은 위아래로 살짝 더 내미는 값. 면이 정확히 겹칠 때 생기는 연산 오류를 막는다
module choc2_boss(epsilon = 0) {
  flare = CHOC2_BOSS_HEIGHT - CHOC2_BAND_HEIGHT + epsilon;
  down(epsilon)
    cyl(h = CHOC2_BOSS_HEIGHT + 2 * epsilon, d = CHOC2_BOSS_DIAMETER,
        chamfer2 = -flare, anchor = BOTTOM, $fn = CHOC2_FACETS);
}

// 사각 기둥에서 위 형상의 바깥을 잘라낸다. 십자 구멍은 이미 뚫려 있으니 그대로 남는다.
// 상자가 옆 기둥까지 먹으면 안 된다 -> 스템 간격 하한은 SKILL.md 11
module choc2_trim(stems) {
  for (position = stems)
    move(position)
      difference() {
        down(0.02)
          cuboid([CHOC2_TRIM_BOX, CHOC2_TRIM_BOX, CHOC2_BOSS_HEIGHT + 0.04],
                 anchor = BOTTOM);
        choc2_boss(0.02);
      }
}

// ---------------------------------------------------------------
// 공통
// ---------------------------------------------------------------
// $stem_support_type 은 include <settings.scad> 가 덮어쓰므로 cap() 안에서 정한다
$stabilizer_type = "disable";   // 2U 이상 자동 스태빌 스템 차단.
                                //   엄지 2U / 시프트 스태빌은 아래 상수로 직접 준다

FONT_ENGLISH = "DejaVu Sans Mono:style=Bold";   // 위 use<> 로 동봉된 폰트
// SIZE_LATIN 3.2 기준 세로획이 Book 0.44mm / Bold 0.64mm (렌더 실측).
// 0.4 노즐 압출폭 0.42mm 로 Book 은 한 줄에 겨우 걸치고, Bold 는 1.5 줄이라 홈이 뚜렷하다
FONT_HANGUL  = "Apple SD Gothic Neo:style=Bold";
// 한글이 비어 보이면 Help > Font List 에서 이름 확인 후 FONT_HANGUL 교체

// 각인 글자 크기(mm). 글자가 길어도 크기를 줄이지 않는다 - 대신 약어를 쓴다
SIZE_WORD             = 3.2;
SIZE_LATIN            = 3.2;
SIZE_HANGUL           = 2.8;
SIZE_SYMBOL           = 3.0;   // 숫자열처럼 위/아래 두 벌
SIZE_ICON             = 3.2;   // ctrl / opt / cmd / fn (모서리)
SIZE_BACKSPACE_DELETE = 4.0;
SIZE_SPACE            = 4.2;
SIZE_ARROW            = 2.8;
SIZE_SIDE             = 3.0;   // 측면(Mod)

// 각인 위치. 1칸 = 상판 폭(세로는 높이)의 1/3.5
POS_CENTER         = [ 0.00,  0.00];
POS_TOP_LEFT       = [-0.90, -0.85];   // 쌍자음
POS_TOP_RIGHT      = [ 0.90, -0.85];   // 한글
POS_BOTTOM_LEFT    = [-0.90,  0.85];   // 알파벳
POS_TOP            = [ 0.00, -0.85];   // 시프트 심볼
POS_BOTTOM         = [ 0.00,  0.85];   // 기본 심볼, F키 번호
POS_ICON_TOP_LEFT  = [-1.05, -0.88];
POS_ICON_TOP_RIGHT = [ 1.05, -0.88];

// 플러시(가장자리) 정렬 - oem 상판 폭 기준
ADVANCE_RATIO = 0.79;    // 모노스페이스 글자당 폭 / 크기 비율 (실측)
MARGIN        = 1.3;     // 상판 가장자리 여백 (mm)
TOP_HEIGHT    = 14.05;   // oem 상판 세로 (mm)

function top_width(width) = 18.05 + 19.05 * (width - 1) - 5.8;   // oem 상판 폭 (mm)

function flush_x(width, text, size, to_right) =
  let (text_width = ADVANCE_RATIO * size * len(text),
       offset     = top_width(width) / 2 - MARGIN - text_width / 2)
  (to_right ? 1 : -1) * 3.5 * offset / top_width(width);

function resolve_position(align, width, text, size) =
  !is_string(align) ? align :
  align == "wl" ? [flush_x(width, text, size, false), 0.85] :
  align == "wr" ? [flush_x(width, text, size, true),  0.85] : [0, 0];

// 각인 한 벌 = [글자, 위치("wl"|"wr"|[x,y]), 크기, 폰트(0=영문 1=한글)]
function WORD(text, align = POS_CENTER, size = SIZE_WORD) = [[text, align, size, 0]];
function ICON(text, align = POS_CENTER, size = SIZE_ICON) = [[text, align, size, 0]];
function SYMBOL(shift, main) = [[shift, POS_TOP,    SIZE_SYMBOL, 0],
                                [main,  POS_BOTTOM, SIZE_SYMBOL, 0]];
function ALPHA(latin, hangul) = [[latin,  POS_BOTTOM_LEFT, SIZE_LATIN,  0],
                                 [hangul, POS_TOP_RIGHT,   SIZE_HANGUL, 1]];
function ALPHA_DOUBLE(latin, hangul, double_hangul) =
  concat(ALPHA(latin, hangul), [[double_hangul, POS_TOP_LEFT, SIZE_HANGUL, 1]]);
function SIDE(text) = [[text, POS_CENTER, SIZE_SIDE, 0]];

// ---------------------------------------------------------------
// 우측 시프트 - 스위치 2개를 캡 하나로 덮는다 (듀얼 스템)
// ---------------------------------------------------------------
//   순정에서 이 자리는 키 2개([1.25U 시프트] + [1U])다. 2.25U 캡 하나로 두 칸을 덮고
//   스위치 2개에 각각 스템을 꽂는다. 간격은 배열 고정값 - 줄이지 말 것 (SKILL.md 9)
RIGHT_SHIFT_PITCH = 21.43125;   // 두 스위치 중심 간격 = 1.125U. 배열 고정값
RIGHT_SHIFT_LEFT  = -9.525;     // 캡 중심 -> 좌측(1.25U 시프트) 스위치 = -0.5U
RIGHT_SHIFT_STEMS = [[RIGHT_SHIFT_LEFT, 0],
                     [RIGHT_SHIFT_LEFT + RIGHT_SHIFT_PITCH, 0]];

// -- 물림은 스템 간격 말고 여기서 푼다 (SKILL.md 9)
RIGHT_SHIFT_INNER_SLOP = 0.20;   // 이 키만 십자 슬롯을 KeyV2 기본값으로 되돌려 헐겁게

// ---------------------------------------------------------------
// 좌측 시프트 - 스템 3개 (가운데 스위치 + 양옆 스태빌라이저)
// ---------------------------------------------------------------
//   2.25U 한 칸 = 가운데 스위치 1개 + 양옆 스태빌. 11.9 = 체리 규격 23.8 의 절반.
//   헐겁다고 줄이지 말 것 (SKILL.md 10)
LEFT_SHIFT_STAB_PITCH = 11.9;   // 캡 중심 -> 스태빌 스템 중심 (mm)
LEFT_SHIFT_STEMS      = [[-LEFT_SHIFT_STAB_PITCH, 0], [0, 0], [LEFT_SHIFT_STAB_PITCH, 0]];

// ---------------------------------------------------------------
// 엄지열 2U - 스템 3개 (가운데 스위치 + 양옆 스태빌라이저)
// ---------------------------------------------------------------
//   스템 자리가 3개다. 가운데 = Choc v2 스위치, 양옆 = 스태빌라이저 하우징.
//   간격은 여기만 고치면 된다. 근거 / 하한 / 실측법은 SKILL.md 11
THUMB_STAB_PITCH = 11.9;   // 캡 중심 -> 스태빌 스템 중심 (mm)

// ---------------------------------------------------------------
// [엄지 2U 스템 무리의 좌우 치우침]
// ---------------------------------------------------------------
//   순정은 캡 중심과 스위치 중심이 어긋나 있어 스템 3개를 통째로 옮긴다.
//   양수 = 사다리꼴 쪽으로, 음수 = 곧은 변 쪽으로 민다.
//   순정 캡 밑면 실측(곧은 변 안쪽 벽 -> 가까운 스템 1.1mm)에서 계산한 값이다. 계산은 SKILL.md 11
THUMB_2U_STEM_SHIFT = -1.25;

// outer: -1 = 왼손(바깥이 왼쪽) / +1 = 오른손(바깥이 오른쪽)
function thumb_2u_stems(outer) =
  [ for (x = [-THUMB_STAB_PITCH, 0, THUMB_STAB_PITCH])
      [x + outer * THUMB_2U_STEM_SHIFT, 0] ];

THUMB_2U_STEMS_LEFT  = thumb_2u_stems(-1);
THUMB_2U_STEMS_RIGHT = thumb_2u_stems(+1);

if (THUMB_STAB_PITCH < (CHOC2_TRIM_BOX + CHOC2_BOSS_DIAMETER) / 2)
  echo(str("경고: THUMB_STAB_PITCH(", THUMB_STAB_PITCH, ") 가 ",
           (CHOC2_TRIM_BOX + CHOC2_BOSS_DIAMETER) / 2,
           " 보다 좁다. choc2_trim 상자가 옆 기둥을 깎아먹는다"));

// ---------------------------------------------------------------
// [엄지 2U 사다리꼴 - 바깥 옆면 하나를 통째로 눕힌다]
// ---------------------------------------------------------------
//   순정 엄지 2U 는 4각형 사다리꼴이다. 바깥 옆면 하나가 앞뒤 전체에 걸쳐 눕는다.
//   직사각형이나 모서리만 자른 모양으로는 케이스에 안 들어간다.
//   순정 왼손 엄지 2U 밑면 실측. 오른손은 좌우 대칭이라 같은 값을 쓴다. 조정법은 SKILL.md 12
THUMB_2U_BACK_LENGTH  = 36.8;   // 윗변(뒤, 가장 긴 변)
THUMB_2U_FRONT_LENGTH = 31.0;   // 아랫변(앞)
THUMB_TAPER_FRONT = THUMB_2U_BACK_LENGTH - THUMB_2U_FRONT_LENGTH;   // 앞쪽 끝에서 안으로 들어오는 양 (mm)
THUMB_TAPER_BACK  = 0.0;        // 뒤쪽 끝에서 안으로 들어오는 양 (mm)

// 밑면 길이가 윗변 실측과 같아지도록 역산한다
THUMB_2U_WIDTH = 1 + (THUMB_2U_BACK_LENGTH - cap_bottom_unit(-1)) / 19.05;

// 캡 밑면(플레이트에 닿는 쪽) 치수
function cap_bottom_unit(profile)      = (profile == -1) ? 18.16 : 18.05;
function cap_bottom_x(profile, width)  = cap_bottom_unit(profile) + 19.05 * (width - 1);
function cap_bottom_y(profile)         = cap_bottom_unit(profile);
// 옆면이 위로 갈수록 안으로 좁아지는 각도. 한쪽당 $width_difference/2 만큼 좁아진다
function cap_side_lean(profile, depth) = atan(((profile == -1) ? 2 : 5.8) / 2 / depth);

// side: -1 = 바깥이 왼쪽(왼손) / +1 = 바깥이 오른쪽(오른손)
module thumb_taper_cut(width, side, profile) {
  W = cap_bottom_x(profile, width);
  H = cap_bottom_y(profile);
  D = (profile == -1) ? LOW_PROFILE_DEPTH : OEM_ROW_DEPTH[profile];

  front = [side * (W / 2 - THUMB_TAPER_FRONT), -H / 2];   // 앞 모서리 위
  back  = [side * (W / 2 - THUMB_TAPER_BACK),   H / 2];   // 뒤 모서리 위

  // 자르는 선을 '캡 중심이 항상 왼쪽(로컬 +y)' 이 되는 방향으로 잡는다.
  // 그래야 아래의 상자 위치와 눕히는 부호를 좌우 공통으로 쓸 수 있다
  start = (side > 0) ? front : back;
  end   = (side > 0) ? back  : front;
  angle = atan2(end[1] - start[1], end[0] - start[0]);
  lean  = cap_side_lean(profile, D);
  BIG   = 120;

  translate([start[0], start[1], 0])
    rotate([0, 0, angle])          // 자르는 선을 로컬 +x 축에 맞춘다
      rotate([-lean, 0, 0])        // 옆면과 같은 각도로 눕힌다 (위로 갈수록 더 깎인다)
        translate([-BIG / 2, -BIG, -BIG / 2])
          cube([BIG, BIG, BIG]);
}

// ===============================================================
// 도형 각인 (폰트 대신 직접 그린 아이콘)
// ===============================================================
//   [중요] 선폭/간격은 전부 0.4mm 이상. 남는 살이 노즐폭 미만이면 슬라이서가 통째로 건너뛴다.
//   BOSL2 도형 표기와 나머지 규칙은 SKILL.md 14

// -- f24 지구본 -------------------------------------------------
GLOBE_RADIUS    = 1.6;   // 지름 3.2 = SIZE_ICON
GLOBE_THICKNESS = 0.5;   // 외곽 선폭

module globe2d() {
  $fn = 48;
  ring(r = GLOBE_RADIUS, ring_width = -GLOBE_THICKNESS);   // 외곽 원
  intersection() {
    circle(GLOBE_RADIUS - GLOBE_THICKNESS / 2);
    union() {
      rect([2 * GLOBE_RADIUS, 0.45]);                      // 적도
      rect([0.45, 2 * GLOBE_RADIUS]);                      // 중앙 자오선
      difference() {                                       // 곡선 자오선(양쪽)
        scale([0.55, 1]) circle(GLOBE_RADIUS - 0.22);
        scale([0.38, 1]) circle(GLOBE_RADIUS - 0.55);
      }
    }
  }
}

// f24 키 좌하단 모서리. 맥북 fn/Globe 키와 같은 자리.
// ctrl/opt/cmd 의 POS_ICON_TOP_RIGHT [1.05, -0.88] 을 좌하단으로 뒤집은 값이다
// (도형 좌표계는 각인 좌표계와 y 부호가 반대다)
GLOBE_POSITION = [-top_width(1.25) / 3.5 * 1.05, -TOP_HEIGHT / 3.5 * 0.88];

// -- 보조메뉴(우클릭) -------------------------------------------
//   문서(가로줄 3개) + 오른쪽 아래 마우스 커서
MENU_WIDTH          = 3.7;
MENU_HEIGHT         = 4.3;
MENU_THICKNESS      = 0.50;   // 문서 외곽 선폭
MENU_RADIUS         = 0.4;
MENU_LINE_COUNT     = 3;
MENU_LINE_WIDTH     = 1.6;    // 좌우 안쪽 여백 0.55씩
MENU_LINE_THICKNESS = 0.50;
MENU_LINE_PITCH     = 1.0;    // 줄 사이 남는 살 0.5
MENU_CURSOR_SCALE   = 1.6;    // 커서 배율. 줄이면 꼬리(약 0.49mm)가 사라진다
MENU_CURSOR_X       = 1.45;   // 커서 끝점 x. 문서 오른쪽 테두리에 물려 얇은 살을 없앤다
MENU_CURSOR_Y       = -0.9;

// 마우스 커서 윤곽 (끝점 = 원점, 아래로 뻗음)
MENU_CURSOR = [[0,0], [0,-1.05], [0.26,-0.80], [0.46,-1.22],
               [0.74,-1.08], [0.54,-0.68], [0.82,-0.62]];

// 문서+커서 전체를 상판 정중앙에 맞추는 보정.
// 0.82 / 1.22 는 MENU_CURSOR 윤곽의 오른쪽 끝과 아래쪽 끝이다
MENU_BOUNDS_X = [min(-MENU_WIDTH  / 2, MENU_CURSOR_X),
                 max( MENU_WIDTH  / 2, MENU_CURSOR_X + 0.82 * MENU_CURSOR_SCALE)];
MENU_BOUNDS_Y = [min(-MENU_HEIGHT / 2, MENU_CURSOR_Y - 1.22 * MENU_CURSOR_SCALE),
                 max( MENU_HEIGHT / 2, MENU_CURSOR_Y)];
MENU_POSITION = [-(MENU_BOUNDS_X[0] + MENU_BOUNDS_X[1]) / 2,
                 -(MENU_BOUNDS_Y[0] + MENU_BOUNDS_Y[1]) / 2];

module menu2d() {
  $fn = 32;
  difference() {                                    // 문서 테두리
    rect([MENU_WIDTH, MENU_HEIGHT], rounding = MENU_RADIUS);
    rect([MENU_WIDTH - 2 * MENU_THICKNESS, MENU_HEIGHT - 2 * MENU_THICKNESS],
         rounding = max(MENU_RADIUS - MENU_THICKNESS, 0.05));
  }
  for (line = [0 : MENU_LINE_COUNT - 1])            // 내부 가로줄
    back((line - (MENU_LINE_COUNT - 1) / 2) * MENU_LINE_PITCH)
      rect([MENU_LINE_WIDTH, MENU_LINE_THICKNESS]);
  move([MENU_CURSOR_X, MENU_CURSOR_Y])              // 커서
    scale(MENU_CURSOR_SCALE) polygon(MENU_CURSOR);
}

// -- 맥 F키 특수기능 아이콘 12종 --------------------------------
//   전부 원점 기준으로 가운데를 맞춰 그렸다. 크기는 3~4mm 대.
ICON_THICKNESS = 0.45;   // 이 그룹의 기본 선폭

module sun2d(radius, ray_length) {    // f1/f2 밝기. 링 + 8방향 광선
  $fn = 40;
  ring(r = radius, ring_width = -ICON_THICKNESS);
  for (angle = [0 : 45 : 359])
    rotate(angle) right(radius + 0.5 + ray_length / 2)
      rect([ray_length, ICON_THICKNESS]);
}

module mission_control2d() {          // f3 미션 컨트롤. 창 3개
  $fn = 24;
  right(1.35) rect([1.1, 2.8], rounding = 0.3);
  for (dy = [0.83, -0.83]) move([-0.95, dy]) rect([1.9, 1.15], rounding = 0.3);
}

module search2d() {                   // f4 스팟라이트. 돋보기
  $fn = 40;
  move([-0.17, 0.17]) {
    ring(r = 1.0, ring_width = -ICON_THICKNESS);
    rotate(-45) right(1.15) rect([1.0, ICON_THICKNESS]);
  }
}

module microphone2d() {               // f5 받아쓰기. 마이크
  $fn = 40;
  back(0.75) rect([0.85, 2.0], rounding = 0.425);                   // 몸통
  ring(r = 1.35, ring_width = -ICON_THICKNESS, angle = [180, 360]); // 아래 아치(반원)
  fwd(1.45) rect([ICON_THICKNESS, 0.6]);                            // 받침 기둥
}

module moon2d() {                     // f6 방해금지. 초승달
  $fn = 48;
  move([0.3, 0.05])
    difference() { circle(1.65); move([0.80, 0.45]) circle(1.45); }
}

module triangle2d() { polygon([[0, 0.95], [0, -0.95], [1.25, 0]]); }   // 오른쪽 삼각형

module fast_forward2d() { for (dx = [-1.475, 0.225]) right(dx) triangle2d(); }  // f9
module rewind2d()       { xflip() fast_forward2d(); }                          // f7

module play_pause2d() {               // f8 재생/일시정지
  left(1.575) triangle2d();
  for (dx = [0.375, 1.325]) right(dx) rect([0.5, 1.9]);
}

module speaker2d() {
  polygon([[-0.90,-0.42], [-0.28,-0.42], [0.42,-1.25],
           [ 0.42, 1.25], [-0.28, 0.42], [-0.90, 0.42]]);
}

module volume2d(arc_count) {          // f10/f11/f12 음량. 아치 arc_count 개
  $fn = 48;
  x_max = (arc_count == 0) ? 0.42 : 0.55 + 0.95 + (arc_count - 1) * 0.85;
  left((-0.90 + x_max) / 2) {
    speaker2d();
    for (arc = count(arc_count))      // 아치 사이 살 0.4
      right(0.55) ring(r = 0.95 + arc * 0.85,
                       ring_width = -ICON_THICKNESS, angle = [-38, 38]);
  }
}

module function_key2d(name) {
  if      (name == "f1")  sun2d(0.70, 0.45);   // 밝기 낮춤
  else if (name == "f2")  sun2d(0.70, 0.80);   // 밝기 높임
  else if (name == "f3")  mission_control2d();
  else if (name == "f4")  search2d();
  else if (name == "f5")  microphone2d();
  else if (name == "f6")  moon2d();
  else if (name == "f7")  rewind2d();
  else if (name == "f8")  play_pause2d();
  else if (name == "f9")  fast_forward2d();
  else if (name == "f10") volume2d(0);         // 음소거
  else if (name == "f11") volume2d(1);         // 음량 낮춤
  else if (name == "f12") volume2d(3);         // 음량 높임
}

// F키 아이콘은 번호 각인(POS_BOTTOM)의 반대편인 상판 위쪽에 놓는다
FUNCTION_KEY_POSITION = [0, TOP_HEIGHT / 3.5 * 0.85];

// -- 도형 각인 깊이 ---------------------------------------------
//   문자 각인($inset_legend_depth)은 minkowski 안쪽에서 잘려 실제로 더 깊게 파인다.
//   도형은 캡을 다 만든 뒤 바깥에서 빼는 방식이라 그 보정이 없어, 여기서 직접 준다.
SHAPE_DEPTH_LOW_PROFILE = 0.45;   // 저프로파일. 상판이 얇아 이 이상은 뚫릴 위험
SHAPE_DEPTH_STANDARD    = 1.00;   // 일반 높이. 상판 1.5mm 중 1.0 -> 아래 0.5mm 남는다

module shape_at(position, profile) {
  depth = (profile == -1) ? SHAPE_DEPTH_LOW_PROFILE : SHAPE_DEPTH_STANDARD;
  top_of_key()
    translate([position[0], position[1], -depth])
      linear_extrude(depth + $dish_depth + 0.01)
        children();
}

module shape_cut(kind, profile) {
  if      (kind == "globe") shape_at(GLOBE_POSITION, profile) globe2d();
  else if (kind == "menu")  shape_at(MENU_POSITION,  profile) menu2d();
  else                      shape_at(FUNCTION_KEY_POSITION, profile) function_key2d(kind);
}

// ---------------------------------------------------------------
// 캡 프로파일
// ---------------------------------------------------------------
// (1) 저프로파일 치클렛
LOW_PROFILE_DEPTH     = 4.1;
LOW_PROFILE_MINKOWSKI = 0.8;
LOW_PROFILE_DISH      = 0.5;

// 이름을 low_profile 로 하면 KeyV2 의 같은 이름 모듈과 겹치므로 _settings 를 붙였다
module low_profile_settings() {
  $top_tilt = 0;  $top_skew = 0;
  $dish_depth = LOW_PROFILE_DISH;  $minkowski_radius = LOW_PROFILE_MINKOWSKI;
  $total_depth = LOW_PROFILE_DEPTH;
  $keytop_thickness = 0.4;
  $stem_throw = 3.2;
  $inset_legend_depth = 0.1;   // minkowski 보정이 더해져 실제로는 0.5mm 파인다
  children();
}

// (2) 일반 높이 OEM
//   상판 1.5mm / 각인 1.0mm.
//   행별 값은 $total_depth 이고, 실제로 재는 높이와 다르다.
//   기준은 '상판 앞모서리(하단) 높이' 다. 캡 바닥에서 상판 앞쪽 모서리까지.
//   행마다 틸트가 달라 보정치가 일정하지 않고, 아래 OEM_ROW_TILT 를 고치면 보정치도 바뀐다.
//   지금 값 기준 렌더 실측 (앞모서리 − $total_depth):
//     row 0 -0.270 / row 1 +0.155 / row 2 +0.480 / row 3 +1.080 / row 4 +1.996
//   넣을 값 = 순정 앞모서리 실측 − 그 행의 보정치 (SKILL.md 16)
//   oem_row 는 위에서 아래로 0~4. 그 번호를 그대로 인덱스로 쓴다.
//   저프로파일 표식은 -1 이라 0 이 비지 않는다.
//   행 번호 근거는 SKILL.md 16
OEM_ROW_DEPTH = [11.12, 9.24, 8.52, 8.82, 9.82];
//               ^0     ^1    ^2    ^3    ^4
//             숫자열/F행 QWERTY 홈행 ZXCV 아랫줄

// 행별 기울기(도). 앞이 들리는 쪽이 +.
//   oem_row() 가 주는 KeyV2 값(-3 / +1 / +6 / +9 / +10)을 standard_profile_settings() 에서 덮어쓴다.
//   순정 캡의 앞모서리-뒤모서리 차이를 재서 역산한 값이다 (실측값은 SKILL.md 19).
//   1도당 앞뒤 차이 약 0.205mm. 이 값과 OEM_ROW_DEPTH 는 같이 움직인다 -
//   기울기를 바꾸면 앞모서리 높이도 따라 바뀌므로 depth 를 다시 맞춰야 한다
OEM_ROW_TILT = [-2.65, 1.50, 4.50, 9.87, 18.08];

// ---------------------------------------------------------------
// [OEM 캡 높이 - $stem_inset]
// ---------------------------------------------------------------
//   완성 높이 = $total_depth - $stem_inset.
//   높이 손잡이는 OEM_ROW_DEPTH 하나다 (SKILL.md 16)
OEM_STEM_INSET = 0;   // KeyV2 원본은 1.2. 0 = 캡이 그만큼 올라오고 치마가 길어진다

module standard_profile_settings(row) {
  $keytop_thickness   = 1.5;
  $inset_legend_depth = 1.0;
  $stem_inset         = OEM_STEM_INSET;
  $total_depth        = OEM_ROW_DEPTH[row];
  $top_tilt           = OEM_ROW_TILT[row];
  children();
}

module profiled_base(profile) {
  // g20_row 의 인자 3 은 형식상 값이다. low_profile_settings() 이 덮어써 결과가 같다
  if (profile == -1) g20_row(3) low_profile_settings() children();
  else              oem_row(profile) standard_profile_settings(profile) children();
}

module key_body(profile, width) {
  // $stem_inset 은 스템뿐 아니라 캡 바닥면도 같이 올린다 (key.scad 의 envelope, SKILL.md 16).
  // 물림은 $stem_inner_slop 으로 잡는다 (SKILL.md 7)
  profiled_base(profile) u(width) cherry() key();
}

// ---------------------------------------------------------------
// 키 하나 = KEYCAP(...). 이름 있는 인자라 안 쓰는 인자는 생략한다.
//   인자별 설명은 SKILL.md 17
// ---------------------------------------------------------------
function KEYCAP(width = 1, top = [], side = [], stems = undef, shape = undef,
                profile = undef, homing = false, choc2 = false,
                taper = 0, inner_slop = undef) =
  [width, top, side, stems, shape, profile, homing, choc2, taper, inner_slop];

function GAP(width = 1) = KEYCAP(width, undef);   // 스위치 없는 자리. 폭만 차지한다
function cap_width(key) = key[0];
function is_gap(key)    = is_undef(key[1]);

module cap(key, base_profile) {
  width        = cap_width(key);
  top_legends  = key[1];
  side_legends = key[2];
  stems        = is_undef(key[3]) ? [[0, 0]] : key[3];   // 생략하면 중앙 1개
  shape        = key[4];
  profile      = is_undef(key[5]) ? base_profile : key[5];
  homing       = key[6];
  choc2        = key[7];
  taper        = is_undef(key[8]) ? 0 : key[8];
  inner_slop   = key[9];

  // 서포트/스템 여유는 호출 시점 스코프에서 정해야 확실히 먹는다
  // (settings.scad 가 top-level 값을 덮어쓴다)
  $stem_support_type = STEM_SUPPORT;
  // Choc v2 는 기둥을 원통으로 깎으므로, 깎기 전 사각 기둥이 원통보다 커야 한다.
  // 최종 바깥 치수는 CHOC2_BOSS_DIAMETER 가 정하니 이 값은 헐거움에 영향을 주지 않는다
  $stem_slop       = choc2 ? CHOC2_SLOP :
                     (profile == -1) ? LOW_PROFILE_STEM_SLOP : STANDARD_STEM_SLOP;
  $stem_inner_slop = !is_undef(inner_slop) ? inner_slop :
                     (profile == -1) ? LOW_PROFILE_STEM_INNER_SLOP
                                    : STANDARD_STEM_INNER_SLOP;
  $legends = [for (legend = top_legends)
    [legend[0], resolve_position(legend[1], width, legend[0], legend[2]), legend[2],
     legend[3] == 1 ? FONT_HANGUL : FONT_ENGLISH]];
  $front_legends = [for (legend = side_legends)
    [legend[0], resolve_position(legend[1], width, legend[0], legend[2]), legend[2],
     FONT_ENGLISH]];
  $stem_positions = stems;

  union() {
    difference() {
      key_body(profile, width);
      if (!is_undef(shape)) profiled_base(profile) u(width) shape_cut(shape, profile);
      // 캡 안쪽 빈 공간 안에서만 깎는다. 2U 바깥 스템은 옆벽과 가까워 상자가 벽까지 먹는다
      if (choc2) intersection() { profiled_base(profile) u(width) inner_shape(); choc2_trim(stems); }
      // 사다리꼴 옆면은 캡을 다 만든 뒤 바깥에서 잘라낸다
      if (taper != 0)       thumb_taper_cut(width, taper, profile);
    }
    // 호밍 바는 잘라내기가 끝난 뒤에 얹는다
    if (homing) profiled_base(profile) u(width) homing_bar();
  }
}

// ---------------------------------------------------------------
// 키 배열. 행 = [기본프로파일(-1=저프로파일, 0~4=oem행), [키...]]
// ---------------------------------------------------------------

// 윗줄 F행. 저프로파일은 FUNCTION_ROW_LOW 키뿐이고 나머지는 일반 높이다 (SKILL.md 2)
FUNCTION_ROW_LOW = ["f1", "f4", "f11", "eject"];

function is_low_key(name) = len([for (n = FUNCTION_ROW_LOW) if (n == name) 1]) > 0;

function function_profile(name) = is_low_key(name) ? -1 : undef;

// sides = 앞에서부터 키마다 측면(Mod) 각인. 모자라면 나머지 키는 측면 없음
function function_row(names, sides = []) =
  [for (i = idx(names))
     KEYCAP(1, WORD(names[i], POS_BOTTOM), i < len(sides) ? sides[i] : [],
            shape = names[i], profile = function_profile(names[i]))];

function function_row_left() =
  concat([KEYCAP(1, WORD("esc"))],
         function_row(["f1", "f2", "f3", "f4", "f5", "f6"]));

function function_row_right() =
  concat(function_row(["f7", "f8", "f9", "f10", "f11", "f12"],
                      [SIDE("nlk"), SIDE("="), SIDE("/"), SIDE("*")]),
         [KEYCAP(1.5, WORD("eject"), profile = function_profile("eject")),
          GAP(1),
          KEYCAP(1, WORD("f13", POS_BOTTOM))]);   // f13 은 특수기능이 없어 아이콘 없이 번호만

// -- 왼쪽 ------------------------------------------------------
LEFT_ROW_1 = [0, function_row_left()];

LEFT_ROW_2 = [0, [ KEYCAP(1, SYMBOL("~", "`")),
                   KEYCAP(1, SYMBOL("!", "1")),
                   KEYCAP(1, SYMBOL("@", "2")),
                   KEYCAP(1, SYMBOL("#", "3")),
                   KEYCAP(1, SYMBOL("$", "4")),
                   KEYCAP(1, SYMBOL("%", "5")),
                   KEYCAP(1, SYMBOL("^", "6")) ]];

LEFT_ROW_3 = [1, [ KEYCAP(1.5, WORD("tab", "wl")),
                   KEYCAP(1, ALPHA_DOUBLE("Q", "ㅂ", "ㅃ")),
                   KEYCAP(1, ALPHA_DOUBLE("W", "ㅈ", "ㅉ")),
                   KEYCAP(1, ALPHA_DOUBLE("E", "ㄷ", "ㄸ")),
                   KEYCAP(1, ALPHA_DOUBLE("R", "ㄱ", "ㄲ")),
                   KEYCAP(1, ALPHA_DOUBLE("T", "ㅅ", "ㅆ")) ]];

LEFT_ROW_4 = [2, [ KEYCAP(1.75, WORD("caps lock", "wl")),
                   KEYCAP(1, ALPHA("A", "ㅁ")),
                   KEYCAP(1, ALPHA("S", "ㄴ")),
                   KEYCAP(1, ALPHA("D", "ㅇ")),
                   KEYCAP(1, ALPHA("F", "ㄹ"), homing = true),
                   KEYCAP(1, ALPHA("G", "ㅎ")) ]];

// 좌측 시프트: 2.25U 한 칸 = 스위치 1개 + 양옆 스태빌라이저 -> 스템 3개
LEFT_ROW_5 = [3, [ KEYCAP(2.25, WORD("shift", "wl"), stems = LEFT_SHIFT_STEMS),
                   KEYCAP(1, ALPHA("Z", "ㅋ")),
                   KEYCAP(1, ALPHA("X", "ㅌ")),
                   KEYCAP(1, ALPHA("C", "ㅊ")),
                   KEYCAP(1, ALPHA("V", "ㅍ")),
                   KEYCAP(1, ALPHA("B", "ㅠ")) ]];

LEFT_ROW_6 = [4, [ KEYCAP(1.25, ICON("fn", POS_ICON_TOP_RIGHT), shape = "globe"),
                   KEYCAP(1.25, concat(ICON("⌃", POS_ICON_TOP_RIGHT),
                                       WORD("ctrl", "wl"))),
                   KEYCAP(1.25, concat(ICON("⌥", POS_ICON_TOP_RIGHT),
                                       WORD("opt", "wl"))),
                   GAP(1.5),
                   KEYCAP(1.5, concat(ICON("⌘", POS_ICON_TOP_RIGHT),
                                      WORD("command", "wl"))) ]];

// 엄지열 - 저프로파일. 행 기본값 4 를 무시하도록 키마다 profile = -1 로 덮어쓴다
//   2U 는 스템 3개 (스위치 + 스태빌 2), 사다리꼴. 1U 는 중앙 1개, 직사각형
//   왼손 2U 는 사다리꼴이 왼쪽이라 taper = -1. 스템은 곧은 변(오른쪽)으로 치우친다
LEFT_ROW_7 = [4, [ KEYCAP(THUMB_2U_WIDTH, WORD("numpad"), stems = THUMB_2U_STEMS_LEFT,
                          profile = -1, choc2 = true, taper = -1),
                   KEYCAP(1, ICON("␣", POS_CENTER, SIZE_SPACE),
                          profile = -1, choc2 = true) ]];

// -- 오른쪽 ----------------------------------------------------
RIGHT_ROW_1 = [0, function_row_right()];

RIGHT_ROW_2 = [0, [ KEYCAP(1, SYMBOL("&", "7"), SIDE("7")),
                    KEYCAP(1, SYMBOL("*", "8"), SIDE("8")),
                    KEYCAP(1, SYMBOL("(", "9"), SIDE("9")),
                    KEYCAP(1, SYMBOL(")", "0"), SIDE("-")),
                    KEYCAP(1, SYMBOL("_", "-")),
                    KEYCAP(1, SYMBOL("+", "=")),
                    KEYCAP(1.5, ICON("⌫", POS_CENTER,
                                     SIZE_BACKSPACE_DELETE)),   // backspace
                    GAP(1),
                    KEYCAP(1, shape = "menu") ]];                // 보조메뉴(우클릭)

RIGHT_ROW_3 = [1, [ KEYCAP(1, ALPHA("Y", "ㅛ")),
                    KEYCAP(1, ALPHA("U", "ㅕ"), SIDE("4")),
                    KEYCAP(1, ALPHA("I", "ㅑ"), SIDE("5")),
                    KEYCAP(1, ALPHA_DOUBLE("O", "ㅐ", "ㅒ"), SIDE("6")),
                    KEYCAP(1, ALPHA_DOUBLE("P", "ㅔ", "ㅖ"), SIDE("+")),
                    KEYCAP(1, SYMBOL("{", "[")),
                    KEYCAP(1, SYMBOL("}", "]")),
                    KEYCAP(1, SYMBOL("|", "\\")),
                    GAP(1),
                    KEYCAP(1, ICON("⌦", POS_CENTER,
                                   SIZE_BACKSPACE_DELETE)) ]];   // delete (forward)

RIGHT_ROW_4 = [2, [ KEYCAP(1, ALPHA("H", "ㅗ")),
                    KEYCAP(1, ALPHA("J", "ㅓ"), SIDE("1"), homing = true),
                    KEYCAP(1, ALPHA("K", "ㅏ"), SIDE("2")),
                    KEYCAP(1, ALPHA("L", "ㅣ"), SIDE("3")),
                    KEYCAP(1, SYMBOL(":", ";"), SIDE("ent")),
                    KEYCAP(1, SYMBOL("\"", "'")),
                    KEYCAP(1.75, WORD("return", "wr")),
                    GAP(1), GAP(1) ]];

RIGHT_ROW_5 = [3, [ KEYCAP(1, ALPHA("N", "ㅜ")),
                    KEYCAP(1, ALPHA("M", "ㅡ"), SIDE("0")),
                    KEYCAP(1, SYMBOL("<", ","), SIDE("0")),
                    KEYCAP(1, SYMBOL(">", "."), SIDE(".")),
                    KEYCAP(1, SYMBOL("?", "/"), SIDE("ent")),
                    // 순정 [1.25U 시프트] + [1U] 두 칸을 한 캡으로. 스위치 2개, 듀얼 스템
                    KEYCAP(2.25, WORD("shift", "wr"), stems = RIGHT_SHIFT_STEMS,
                           inner_slop = RIGHT_SHIFT_INNER_SLOP),
                    KEYCAP(1, ICON("▲", POS_CENTER, SIZE_ARROW)),
                    GAP(1) ]];

// 아랫줄. 두 번째 스페이스만 저프로파일이고 나머지는 일반 높이다
RIGHT_ROW_6 = [4, [ KEYCAP(1.5, ICON("␣", POS_CENTER, SIZE_SPACE)),
                    KEYCAP(1.5, ICON("␣", POS_CENTER, SIZE_SPACE), profile = -1),
                    KEYCAP(1.25, concat(ICON("⌘", POS_ICON_TOP_LEFT),
                                        WORD("cmd", "wr"))),
                    KEYCAP(1.25, concat(ICON("⌥", POS_ICON_TOP_LEFT),
                                        WORD("opt", "wr"))),
                    GAP(1.25),
                    KEYCAP(1, ICON("◀", POS_CENTER, SIZE_ARROW)),
                    KEYCAP(1, ICON("▼", POS_CENTER, SIZE_ARROW)),
                    KEYCAP(1, ICON("▶", POS_CENTER, SIZE_ARROW)) ]];

// 엄지열 - 저프로파일
//   2U 는 스템 3개 (스위치 + 스태빌 2), 사다리꼴. 1U 는 중앙 1개, 직사각형
//   오른손 2U 는 사다리꼴이 오른쪽이라 taper = +1. 스템은 곧은 변(왼쪽)으로 치우친다
RIGHT_ROW_7 = [4, [ KEYCAP(1, ICON("␣", POS_CENTER, SIZE_SPACE),
                           profile = -1, choc2 = true),
                    KEYCAP(THUMB_2U_WIDTH, ICON("␣", POS_CENTER, SIZE_SPACE),
                           stems = THUMB_2U_STEMS_RIGHT, profile = -1, choc2 = true,
                           taper = 1) ]];

LEFT_HALF  = [LEFT_ROW_1, LEFT_ROW_2, LEFT_ROW_3, LEFT_ROW_4, LEFT_ROW_5,
              LEFT_ROW_6, LEFT_ROW_7];
RIGHT_HALF = [RIGHT_ROW_1, RIGHT_ROW_2, RIGHT_ROW_3, RIGHT_ROW_4,
              RIGHT_ROW_5, RIGHT_ROW_6, RIGHT_ROW_7];

// ---------------------------------------------------------------
// 배치 / 생성
// ---------------------------------------------------------------
// 형식은 위 [렌더 선택] 참조
// 축 하나가 맞는지. "-1" / 생략 은 '그 축 전부'
function axis_match(want, got) =
  is_undef(want) || want == "-1" || want == got;

function selected(hand, r, i) =
  len([for (k = RENDER)
         if (axis_match(k[0], hand) &&
             axis_match(k[1], str(r)) &&
             axis_match(k[2], str(i))) 1]) > 0;

// ---------------------------------------------------------------
// pack 배치 - 고른 키를 원점부터 촘촘히 다시 깐다 (프린트용)
//   키보드 모양을 버리고 왼쪽부터 채우다 PACK_WIDTH 를 넘으면 다음 줄로 내린다.
// ---------------------------------------------------------------

// 키 바닥 footprint 폭(mm). 1U=18.05, 그 뒤로 1U(19.05)씩. 저/일반 공통
function footprint_width(width) = 19.05 * width - 1.0;

// 뽑을 키를 한 줄 리스트로 [키데이터, 행기본프로파일]
function half_keys(hand, rows) =
  [ for (r = idx(rows))
      for (i = idx(rows[r][1]))
        if (!is_gap(rows[r][1][i]) && selected(hand, r, i))
          [rows[r][1][i], rows[r][0]] ];

ALL_KEYS = concat(half_keys("L", LEFT_HALF), half_keys("R", RIGHT_HALF));

FOOTPRINT_WIDTHS = [for (entry = ALL_KEYS) footprint_width(cap_width(entry[0]))];

// 각 키 중심좌표 리스트를 돌려준다
function pack_positions(i, cursor_x, row) =
  i >= len(FOOTPRINT_WIDTHS) ? [] :
  let (x      = cursor_x + FOOTPRINT_WIDTHS[i] / 2,
       point  = [x, -row * PACK_PITCH_Y],
       next_x = cursor_x + FOOTPRINT_WIDTHS[i] + PACK_GAP_X,
       wrap   = (i + 1 < len(FOOTPRINT_WIDTHS)) &&
                (next_x + FOOTPRINT_WIDTHS[i + 1] > PACK_WIDTH))
  concat([point], pack_positions(i + 1, wrap ? 0 : next_x, wrap ? row + 1 : row));

PACK_POSITIONS = pack_positions(0, 0, 0);

PACK_SIZE_X = len(ALL_KEYS) == 0 ? 0 :
              max([for (i = idx(ALL_KEYS))
                     PACK_POSITIONS[i][0] + FOOTPRINT_WIDTHS[i] / 2]);
PACK_SIZE_Y = len(ALL_KEYS) == 0 ? 0 :
              -min([for (point = PACK_POSITIONS) point[1]]) + 18.05;

module pack() {
  for (i = idx(ALL_KEYS))
    translate([PACK_POSITIONS[i][0], PACK_POSITIONS[i][1], 0])
      cap(ALL_KEYS[i][0], ALL_KEYS[i][1]);
}

// ---------------------------------------------------------------
// dispatch
// ---------------------------------------------------------------
echo(str("키 ", len(ALL_KEYS), "개 / pack 배치 약 ",
         round(PACK_SIZE_X), " x ", round(PACK_SIZE_Y),
         " mm / 베드 폭 ", BED_WIDTH, " mm"));

pack();
