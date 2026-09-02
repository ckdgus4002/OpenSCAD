// UHK80 키캡 세트 - OpenSCAD / KeyV2 + BOSL2
//
// 필요:
//   1) OpenSCAD 개발 스냅샷 (2021.01 불가)
//   2) KeyV2 폴더 안에 이 파일을 둘 것
//   3) BOSL2 (라이브러리 폴더에 설치. rect / ring / cumsum 등 2D/리스트 유틸)
//   4) 같은 폴더에 DejaVuSansMono.ttf
//      맥 기본 폰트에는 DejaVu 가 없어 cmd/opt/ctrl/bksp/del/space/화살표 각인이 깨진다

// [프로파일 - 저/일반 2단]
//   저프로파일(치클렛, g20) : 윗줄 esc~f13/eject, 양손 엄지열 4개.
//                             전부 g20_row(3) 고정 + low_profile_settings() 로 평면화한다.
//                             low_profile_settings() 이 $top_tilt / $top_skew /
//                             $total_depth 를 전부 덮어쓰므로 g20 의 행(row) 번호는
//                             결과에 영향이 없다.
//                             -> 저프로파일 키는 위치와 무관하게 전부 같은 높이/같은 평면
//   일반 높이 OEM           : 나머지 전부. 행별 oem_row(1~5).
//                             이쪽은 행마다 높이/기울기가 실제로 달라진다.
//                             oem_row 번호는 '위에서 아래로' 0,1,2,3,4 다.
//                             0 과 5 는 같은 값이라(라이브러리 편의용 중복),
//                             0 을 저프로파일 표식으로 쓰는 이 파일은 숫자열에 5 를 쓴다.
//                             행별 높이와 그 근거는 OEM_ROW_DEPTH 주석 참조
//   * 한 행에 저/일반이 섞이면 키마다 profile 오버라이드를 준다
//   * 윗줄(esc~f13)은 일반 높이 한 벌도 따로 만든다
//     (LEFT_ROW_9 / RIGHT_ROW_8). 갈아 끼우기용 예비
//
// [스템 서포트]  STEM_SUPPORT
//   "tines"   = 스템 십자 양옆을 얇은 가지가 잡아준다 (KeyV2 기본값)
//   "disable" = 서포트 없음. 잘 뽑히면 이게 제일 편하다(후처리 없음)
//   원저자가 서포트를 권한 건 "스템이 프린트 중 베드에서 떨어질 때"의 해결책이다.
//
// [엄지열 스위치 - 카일 Choc v2]
//   엄지 키 4개(LEFT_ROW_7 mod/space, RIGHT_ROW_7 space x2)는 Choc v2(PG1353) 를 쓴다.
//   Choc v2 는 스템이 MX 십자라 십자 구멍은 그대로 둬도 된다. 다른 건 바깥이다.
//   십자 둘레에 원통형 방진벽(dust wall)이 서 있어서(안지름 실측 5.8mm),
//   MX 기본 사각 기둥은 그 안으로 못 들어가고 방진벽 위에 걸터앉는다.
//   그러면 십자가 1mm 남짓밖에 안 물려 캡이 흔들린다 -> 기둥을 원통으로 깎는다.
//   윗줄 저프로파일(오테뮤)은 손대지 않는다. 수치/근거는 CHOC2_* 주석 참조
//   [중요] 엄지 2U 두 자리는 스위치 1개가 아니라 스템 자리가 3개다.
//     가운데가 Choc v2 스위치, 양옆이 스태빌라이저. THUMB_2U_STEMS_LEFT/_RIGHT 주석 참조
//
// [각인 규칙 - 맥북 한글 자판 기준]
//   문자키   : 영문 좌하단 / 한글 우상단 / 쌍자음 좌상단
//   숫자/기호: 시프트 심볼 위 + 기본 아래 (가운데)
//   단어키   : 왼쪽 반 = 좌하단 플러시, 오른쪽 반 = 우하단 플러시
//   아이콘   : ctrl / opt / cmd 는 word 반대편 상단 모서리,
//              bksp / del / space / 화살표는 가운데
//   윗줄 F키 : 맥 특수기능 아이콘(위) + f1~f12(아래).
//              f13 은 특수기능이 없어 윗줄을 비우고 아래에 f13 만
//   도형 각인: fn=지구본, menu=보조메뉴, F키 아이콘 12종.
//              전부 폰트가 아니라 직접 그린 도형이다. 폰트 이모지는 선이 0.1mm대라
//              0.4 노즐 FDM 에서 사라진다. 여기 도형은 선폭/간격이 전부 0.4mm 이상
//   약어     : 1.25U(상판 17.0mm)에 "command"(17.7) "control"(17.7) "option"(15.2)이
//              3.2mm 글자로 안 들어가 cmd/ctrl/opt 유지. 칸이 되는 곳은 약어 안 씀
//   측면(Mod): 넘패드 숫자 (7 8 9 0 1 2 3 4 5 6 .), nlk = / * + - ent
//
// [호밍(에프/제이)] 상판 앞쪽에 가로 바를 돋운다. 수치는 HOMING_* 주석 참조
// [우측 시프트] 순정은 이 자리가 키 2개다 - [1.25U 우측 시프트] + [1U 키].
//               합이 2.25U 라서 캡 하나로 두 칸을 덮고, 스위치 2개에 각각
//               스템을 꽂는다(듀얼 스템). 좌표/근거는 RIGHT_SHIFT_STEMS 주석 참조
// [좌측 시프트] 같은 2.25U 지만 스위치는 1개다. 대신 양옆에 스태빌라이저가 있어
//               스템 자리는 3개다 -> LEFT_SHIFT_STEMS
// [엄지열 2U]   순정이 4각형 사다리꼴이다. 바깥쪽 옆면 하나가 앞뒤 전체에 걸쳐
//               비스듬히 서 있어서, 앞쪽이 뒤쪽보다 짧다.
//               직사각형으로 뽑으면 케이스에 걸려 안 들어간다.
//               THUMB_TAPER_* 로 그 옆면을 비스듬히 깎는다
//
// [주의]
//   - 스템은 항상 아래, 상판은 항상 위로 놓고 출력한다 (뒤집기 옵션 없음)
//   - 스태빌라이저 스템은 전역으로 끈다($stabilizer_type). 2U 이상 스태빌은
//     자동 생성에 맡기지 않고 THUMB_2U_STEMS_* / LEFT_SHIFT_STEMS 로 직접 준다
//   - 가는 각인은 0.4 노즐에서 가늘게 나올 수 있다. 시험 출력 권장
//
// [실측으로 확정해야 하는 값 - 여기만 캘리퍼로 재면 된다]
//   THUMB_TAPER_FRONT / THUMB_TAPER_BACK : 순정 엄지 2U 사다리꼴의 기울기
//   THUMB_2U_STEM_SHIFT                  : 엄지 2U 스템 무리의 좌우 치우침
//   RIGHT_SHIFT_DEPTH_TRIM               : 우측 시프트 높이 미세조정
//   위 세 값의 근거와 재는 방법은 각 상수 주석에 적어 뒀다

include <./includes.scad>
include <BOSL2/std.scad>     // 반드시 KeyV2 뒤에 include 할 것.
                             //   BOSL2 가 LEFT / RIGHT 를 전역 상수로 쓰므로
                             //   이 파일의 반쪽 배열은 LEFT_HALF / RIGHT_HALF 로 둔다
use <./DejaVuSansMono.ttf>   // 동봉 폰트. 같은 폴더에 파일이 있어야 한다

// ---------------------------------------------------------------
// 렌더 선택
// ---------------------------------------------------------------
//   "pack"    베드 맞춤 배치. 프린트용. 항상 전체 키를 깐다
//   "all"     키보드 배열 그대로 (왼쪽 + 오른쪽)
//   [행, 열]  all 배열에서 일부만 뽑는다. 0 이거나 안 적으면 그 축은 '전부'
//               [3]      -> 3행 전체   ([3, 0] 과 같다)
//               [0, 3]   -> 3열 전체
//               [3, 2]   -> 3행 2열 한 개
//             행/열 모두 1부터. 열은 빈자리(GAP, 스위치 없음)도 세어서 매긴다
//             좌우 반쪽 양쪽에 함께 걸리고, 위치는 all 배열 그대로 유지된다
//             (원점으로 끌어오지 않는다. 어차피 슬라이서가 베드에 앉힌다)
//   [KEY(..), ...]
//             키를 하나씩 골라 담는다. 원하는 만큼 몇 개든 뽑을 수 있다
//               KEY(반, 행, 열)
//                 반 = "L" 왼쪽(LEFT_ROW_n) / "R" 오른쪽(RIGHT_ROW_n)
//                 행 = 그 반쪽의 행 번호 n (1부터)
//                 열 = 그 행에서 몇 번째 키인지 (1부터. GAP 도 세어서 매긴다)
//             이때의 배치는 아래 PACK_SELECTED 가 정한다

function KEY(hand, row, col) = [hand, row, col];

// 뽑을 키 목록 (한 줄에 키 하나)
RENDER = [
  KEY("L", 4, 5),    // F            호밍
  KEY("R", 4, 2),    // J            호밍
  KEY("L", 7, 1),    // 왼손   mod   2U, 저프로파일 + Choc v2
  KEY("R", 7, 2),    // 오른손 space 2U, 저프로파일 + Choc v2
  KEY("L", 5, 1),    // 왼쪽   shift 2.25U
  KEY("R", 5, 6),    // 오른쪽 shift 2.25U, 듀얼 스템
  KEY("L", 1, 5),    // F4
  KEY("R", 1, 1),    // F7
  KEY("R", 1, 2),    // F8
  KEY("R", 1, 3),    // F9
  KEY("R", 1, 4),    // F10
  KEY("R", 1, 5),    // F11
  KEY("R", 1, 7),    // Eject
];

// KEY 목록으로 골랐을 때의 배치
//   true  = pack (프린트용으로 촘촘히 다시 깐다)
//   false = 키보드 배열 그대로 그 자리에
PACK_SELECTED = true;

// [프린트 베드] 자기 프린터 크기로 바꿀 것. pack 배치가 여기에 맞춰 잡힌다
BED = [160, 300];

PACK_WIDTH   = BED[0] - 3;   // 배치 최대 가로 폭. 줄이면 좁고 길게, 늘리면 넓고 짧게
PACK_GAP_X   = 2.0;          // 키 사이 좌우 간격. FDM 에서 안 붙게 하는 여유
PACK_PITCH_Y = 21.0;         // 줄 간격 = 키 세로(약 18) + 앞뒤 여유

// 스템 서포트: "tines" | "disable"
STEM_SUPPORT = "disable";

// ---------------------------------------------------------------
// [호밍 돌기 - 에프/제이 앞쪽 가로 바]
// ---------------------------------------------------------------
//   KeyV2 의 keybump() 는 바를 이 좌표에 놓는다:
//     y = -top_total_key_height()/2 + $key_bump_edge
//   바의 굵기는 반지름 0.5(지름 1.0)이므로 바가 차지하는 구간은
//     [ $key_bump_edge - 0.5 , $key_bump_edge + 0.5 ]  (앞 모서리 기준)
//
//   [중요] 기본값 $key_bump_edge = 0.4 이 문제였다.
//     0.4 - 0.5 = -0.1  ->  바의 앞쪽 절반이 상판 앞 모서리 '밖으로' 0.1mm 삐져나온다.
//     그래서 돌기가 모서리에 걸터앉은 것처럼 보인 것이다.
//
//   -- HOMING_EDGE_INSET 의 근거
//     0.5(바 반폭) + 0.7(앞 모서리에 남길 여유) = 1.2
//     -> 바는 앞 모서리에서 0.7 ~ 1.7mm 구간에 놓인다. 0.4 노즐 기준 앞쪽에
//        1.75줄분의 살이 남아 모서리가 뭉개지지 않는다.
//     -> 글자("F"/"J", POS_BOTTOM_LEFT)의 중심은 앞 모서리에서 3.6mm 지점이고
//        글자 아랫변은 약 2.4mm 지점이라, 바와 글자 사이가 아직 0.7mm 남는다.
//     더 올리고 싶으면 이 값만 키우면 된다. 0.9 아래로 내리면 다시 모서리를 문다
//
//   [중요] KeyV2 의 keybump() 는 쓰지 않고 아래 homing_bar() 로 직접 그린다. 이유:
//     (1) 굵기(반지름 0.5 고정)와 길이($font_size)를 바꿀 방법이 없다
//     (2) 높이 이름이 실제와 다르다. $key_bump_depth 에 로드 반지름 0.5 가 더해져
//         '0.5' 로 두면 실제 돌출은 1.0mm 다
//     (3) 윗면이 수평이라, 좌우로 파인 원기둥 딥 위에서는 바의 양끝이
//         가운데보다 약 0.24mm 낮아진다. 바가 낮아질수록 양끝이 사라진다
//     아래 모듈은 HOMING_HEIGHT 가 곧 실제 돌출이고, 윗면을 상판 곡면과
//     평행하게 깎아 바 전체가 같은 높이로 솟는다
//
//   -- 높이 고르기
//     실제 키캡 수준은 0.4mm 다. 너무 밋밋하면 0.6~0.7 이 무난하다.
//     길이/폭은 그대로 두는 게 좋다
HOMING_LENGTH     = 6.0;   // 바 길이(mm). 좌우 방향
HOMING_WIDTH      = 1.0;   // 바 폭(mm). 앞뒤 방향
HOMING_HEIGHT     = 0.4;   // 상판에서 실제로 솟는 높이(mm)
HOMING_EDGE_INSET = 1.2;   // 상판 앞 모서리에서 바 중심까지의 거리(mm)

// 호밍 바 본체. profiled_base() 안에서 불러야 프로파일 값이 잡힌다
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
//   두 프로파일은 증상이 정반대라 값을 나눴다. 하나로 묶으면 한쪽이 망가진다.
//     저프로파일(profile 0, 오테뮤 로우프로파일) : 꽉 껴서 안 올라옴 -> 바깥을 줄인다
//     일반 높이  (profile 1~5, 체리)             : 헐거워 잘 안 물림 -> 안쪽을 좁힌다
//
//   -- [바깥 기둥] $stem_slop : 하우징 구멍과의 마찰
//     outer_cherry_stem(slop) = [7.2 - slop*2, 5.5 - slop*2]
//     7.2 x 5.5 는 기둥이 아니라 하우징 구멍의 공칭치수이고, 기둥은 그 안으로
//     미끄러져 들어가는 슬라이딩 핏이다(눌리면 3.6mm 만큼 구멍 속에 들어간다).
//     여기가 뻑뻑하면 마찰이 스프링(50~70gf)을 이겨 누른 채로 안 올라온다.
//       0.35 -> 6.50 x 4.80   KeyV2 기본. 체리는 문제 없음
//       0.45 -> 6.30 x 4.60   사방 0.1mm 여유          [현재 저프로파일]
//       0.55 -> 6.10 x 4.40   그래도 뻑뻑하면. 대신 캡이 살짝 흔들릴 수 있음
//
//   -- [안쪽 십자] $stem_inner_slop : 캡이 스위치를 '무는' 힘
//     cherry_cross(slop) = 가로날 [4.03 + slop, 1.25 + slop/3] / 세로날 [1.15 + slop/3, ...]
//     무는 슬롯 폭은 slop/3 만큼만 변한다 (값을 0.3 움직여야 0.1mm).
//       0.20   슬롯 1.317/1.217   가로날 4.23   KeyV2 기본. 헐거웠던 값
//       0.05   슬롯 1.267/1.167   가로날 4.08   [현재 일반 높이]
//       0.00   슬롯 1.250/1.150   가로날 4.03   이 노브의 한계
//     * slop 을 내리면 슬롯 두께뿐 아니라 가로날 길이도 같이 짧아진다.
//       0 근처까지 내리면 팔 끝이 슬롯 끝에 먼저 닿아 오히려 안 들어갈 수 있으니
//       0.05 -> 0.0 한 단계씩 시험 출력할 것. 0 으로도 헐거우면 슬라이서 XY 보정을
//       -0.05mm 주거나 functions.scad 의 두께 항을 직접 손대야 한다.
LOW_PROFILE_STEM_SLOP       = 0.45;   // 저프로파일: 바깥 기둥만 줄인다
LOW_PROFILE_STEM_INNER_SLOP = 0.20;   // 안쪽은 그대로. 여기 물림은 문제 없었다
STANDARD_STEM_SLOP          = 0.35;   // 일반 높이: 바깥은 그대로
STANDARD_STEM_INNER_SLOP    = 0.05;   // 안쪽 십자를 좁힌다

// ---------------------------------------------------------------
// [Choc v2 원통 기둥 - 엄지열 전용]
// ---------------------------------------------------------------
//   십자 구멍(cherry_cross)은 MX 와 규격이 같으므로 건드리지 않는다.
//   바깥 사각 기둥만 원통으로 깎아 방진벽 안으로 들어가게 한다.
//   * 2U 의 스태빌라이저 기둥에도 똑같이 먹는다(choc2_trim 이 스템 전체를 돈다).
//     스태빌 하우징에 방진벽이 없더라도 원통이 사각보다 작으니 손해는 없다.
//     어차피 캡을 붙잡는 건 십자다
//
//   -- CHOC2_BOSS_DIAMETER 를 고른 근거
//     방진벽 안지름 실측 5.8. 목표는 '출력된 지름 5.55' (간극 0.25).
//     0.4 노즐 FDM 은 바깥 지름이 0.1mm 안팎 크게 나오므로 설계값은 5.45.
//     밑동 두세 층은 코끼리발로 더 굵어지지만 그래도 5.8 을 안 넘는 선이다.
//     * 방향이 비대칭이라 일부러 작은 쪽으로 틀리게 잡았다.
//       헐거우면 좀 흔들릴 뿐이지만, 크면 아예 안 들어가 다시 뽑아야 한다.
//       이 기둥은 안내(가이드)고, 캡을 붙잡는 건 십자다
//     * 슬라이서 코끼리발 보정을 켜 둘 것. 이 캡은 기둥 밑면이 첫 층이라
//       보정값이 그대로 진입 지름에 먹는다
//     * 나중에 고칠 일이 생기면: 흔들리면 5.55, 안 들어가면 5.35. 0.1 단위면 된다
//
//   -- 형상: 아래는 원통, CHOC2_BAND_HEIGHT 위로는 45도로 벌어져 사각 기둥에 합류
//     여기에 수직 단차(턱)를 두면 그 자리가 허공 오버행이라 출력이 지저분하고,
//     방진벽이 생각보다 높으면 턱에 걸려 십자가 끝까지 안 들어간다.
//     45도면 서포트 없이 깔끔히 뽑히고, 벽이 높아도 쐐기처럼 캡을 가운데로 잡는다
//
//   -- CHOC2_SLOP 이 음수인 이유
//     outer_cherry_stem 은 slop 이 클수록 기둥이 작아진다. 기본값 0.35 면
//     기둥 세로가 4.8mm 뿐이라 5.45 원통을 깎아낼 살이 없다.
//     음수로 두어 깎기 전 기둥을 7.5 x 5.8 까지 키운다.
//     최종 치수는 원통이 정하니 헐거움에는 영향이 없다
CHOC2_BOSS_DIAMETER = 5.45;   // 원통 기둥 지름(mm). 방진벽 안지름 5.8 기준
CHOC2_BAND_HEIGHT   = 2.2;    // 여기까지가 직선 원통 구간(mm)
CHOC2_BOSS_HEIGHT   = 3.2;    // 다듬는 전체 높이. 저프로파일의 $stem_throw 와 같게 둔다
CHOC2_SLOP          = -0.15;  // 깎기 전 사각 기둥의 여유. 음수 = 기둥을 키운다
CHOC2_FACETS        = 48;
CHOC2_TRIM_BOX      = 12;     // 깎기용 상자 한 변(mm). 1U 안쪽 공간 안에 들어간다

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
// 스템이 여러 개면 각 자리마다 상자를 놓는다. 상자끼리 겹치는 건 상관없지만,
// 상자가 옆 기둥까지 먹으면 안 된다 -> 스템 간격 하한은 THUMB_STAB_PITCH 주석 참조
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

FONT_ENGLISH = "DejaVu Sans Mono:style=Book";   // 위 use<> 로 동봉된 폰트
FONT_HANGUL  = "Apple SD Gothic Neo:style=Bold";
// 한글이 비어 보이면 Help > Font List 에서 이름 확인 후 FONT_HANGUL 교체

// 각인 글자 크기(mm). 글자가 길어도 크기를 줄이지 않는다 - 대신 약어를 쓴다
SIZE_WORD             = 3.2;
SIZE_LATIN            = 3.2;
SIZE_HANGUL           = 2.8;
SIZE_SYMBOL           = 3.0;   // 숫자열처럼 위/아래 두 벌
SIZE_ICON             = 3.2;   // ctrl / opt / cmd (모서리)
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
//   WORD         단어               ICON  아이콘
//   SYMBOL       시프트+기본 두 벌   ALPHA 영문+한글
//   ALPHA_DOUBLE 영문+한글+쌍자음
//   SIDE         측면(Mod). KeyV2 의 $front_legends 로 들어간다
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
//   [중요] 이 자리는 순정에서 키가 2개다.
//     UHK 80 은 UHK 60 대비 우측 시프트/컨트롤이 1U 씩 줄어서,
//     [1.25U 우측 시프트] + [그 옆 1U 키] 두 칸으로 나뉜다.
//     합이 2.25U 라서 2.25U 캡 하나로 두 칸을 덮고,
//     스위치 2개에 각각 스템을 꽂는다. -> $stem_positions = RIGHT_SHIFT_STEMS
//     (좌측 시프트 LEFT_ROW_5 는 같은 2.25U 지만 스위치 1개 -> 중앙 스템 1개)
//
//   -- 스템 간격은 배열 고정값이다. 임의로 바꾸면 안 된다
//     두 칸이 맞붙어 있으므로 스위치 중심 간격 = (1.25U + 1U)/2 = 1.125U,
//     즉 캡 폭(2.25U)의 정확히 절반이다.
//     좌우 분할이 1.25+1 이든 1+1.25 든 결과는 같다.
//
//   -- 캡 중심 기준 스템 좌표 (캡 좌측 끝 = -1.125U)
//     좌 = 1.25U 시프트 중심 = -1.125U + 0.625U = -0.5U
//     우 = 1U 키 중심        = -1.125U + 1.75U  = +0.625U
//
//   -- 주의: 물림이 헐겁다고 간격을 줄이지 말 것
//     간격을 줄이면, 좌측 스템이 물린 상태에서 우측 스템이 자기 스위치를
//     찾아가며 캡을 오른쪽으로 끌고 간다. 왼쪽은 '/' 키캡에 막혀 있어서
//     어긋남이 전부 '우측 삐져나옴'으로 나타난다.
//     물림은 간격이 아니라 $stem_inner_slop (이 키는 RIGHT_SHIFT_INNER_SLOP) 으로 잡는다.
//     예전에 조이려고 0.43mm 줄여 뒀다가 캡이 우측으로 약 0.2mm 밀렸고,
//     배열 고정값으로 되돌려 정렬을 바로잡았다.
RIGHT_SHIFT_PITCH = 21.43125;   // 두 스위치 중심 간격 = 1.125U. 배열 고정값
RIGHT_SHIFT_LEFT  = -9.525;     // 캡 중심 -> 좌측(1.25U 시프트) 스위치 = -0.5U
RIGHT_SHIFT_STEMS = [[RIGHT_SHIFT_LEFT, 0],
                     [RIGHT_SHIFT_LEFT + RIGHT_SHIFT_PITCH, 0]];

// ---------------------------------------------------------------
// [우측 시프트 높이 - 낮추지 않는다]
// ---------------------------------------------------------------
//   [중요] "폭이 넓어서 높아진 것인가?" 를 먼저 계산으로 확인했다. 답은 '일부만'이다.
//
//   -- 왜 폭이 높이에 영향을 주는가
//     OEM 은 $dish_type = "cylindrical" 이고, 이 딥은 캡 '폭' 전체를 현으로 삼는
//     원기둥이다(KeyV2 dishes/cylindrical.scad).
//       rad = (W^2 + 4d^2) / 8d,  chord = (W^2 - 4d^2) / 8d
//     W 가 커지면 원기둥 반지름이 급격히 커져서 딥이 평평해진다.
//     그래서 모서리 근처가 1U 보다 덜 파이고, 그만큼 높아진다.
//       1U   (상판폭 12.25) : 앞모서리 x끝에서 딥 깊이 -0.306mm
//       2.25U(상판폭 36.06) : 같은 지점에서        -0.108mm
//
//   -- 그런데 캡 '최고점' 차이는 그만큼 크지 않다
//     최고점은 앞모서리가 아니라 앞/옆 라운드 모서리 위에 잡히고,
//     거기서는 딥이 덜 파인 이득과 $top_tilt 로 앞이 들리는 이득이 상쇄된다.
//     ZXCV 행 기준 최고점을 계산하면
//       1U 10.340 / 1.5U 10.366 / 1.75U 10.377 / 2.25U 10.393  (mm)
//     -> 2.25U 가 1U 보다 높은 건 +0.053mm 뿐이다.
//
//   -- 결론: 0 으로 되돌려 뒀다 (2026-09 원복)
//     측정한 0.15mm 중 형상으로 설명되는 건 약 1/3(0.05mm)뿐이었고,
//     나머지 0.1mm 는 코드가 만든 게 아니라 아래 둘 중 하나였다.
//       (1) 듀얼 스템이라 두 스위치에 동시에 물리면서 캡이 끝까지 안 내려앉는다
//       (2) 출력 오차 (첫 층 눌림 / 코끼리발 / XY 보정)
//     둘 다 캡 형상이 아니라 조립/출력 쪽 문제라, 모델에서 미리 깎아 두면
//     원인이 사라졌을 때 이 키만 혼자 낮아진다. 그래서 0 으로 되돌리고
//     ZXCV 행 전체와 같은 높이로 둔다.
//     * 0.15 를 넣으면 폭에 의한 +0.053mm 이득까지 상쇄돼
//       같은 행 1U 보다 오히려 약 0.1mm 낮아졌다.
//
//   -- 다시 조정해야 할 때
//     순정 1U 키캡과 이 캡을 나란히 꽂고, 상판 앞 가운데에 자를 걸쳐 틈을 본다.
//     높으면 이 값을 키우고, 낮으면 줄인다. 0.05 단위면 충분하다.
//     다만 먼저 스템이 끝까지 들어갔는지부터 확인할 것 (위 (1) 번 원인)
RIGHT_SHIFT_DEPTH_TRIM = 0.00;   // 우측 시프트만 $total_depth 를 이만큼 낮춘다(mm)

// -- [우측 시프트가 혼자 높은 이유 - 물림이지 높이가 아니다] (2026-09)
//   증상: 다른 캡은 전부 순정보다 낮은데 이 키만 순정보다 높다. 방향이 반대다.
//   모델에는 원인이 없다. key.scad 를 뒤져도 스템 '개수'가 높이에 관여하는 코드는
//   없고, 스템 형상은 1U 와 완전히 같다. 즉 캡이 덜 들어가서 걸려 있는 것이다.
//
//   왜 이 키만: 여기만 스템 2개가 '진짜 스위치 2개'에 동시에 물린다.
//     1개면 살짝 비틀어 밀어 넣을 수 있지만, 2개는 좌우/회전이 동시에 맞아야
//     들어간다. 거기에 STANDARD_STEM_INNER_SLOP 을 일부러 좁혀 뒀으니
//     조금만 어긋나도 중간에 쐐기처럼 박힌다.
//     좌측 시프트는 2.25U 로 폭이 같지만 진짜 스위치는 1개(양옆은 스태빌)라 안 걸린다.
//   * 간격(RIGHT_SHIFT_PITCH)은 배열 고정값이라 건드리면 안 된다. 물림은 여기서 푼다.
//   * 그래도 걸리면 슬라이서 XY 보정을 -0.05 준다
RIGHT_SHIFT_INNER_SLOP = 0.20;   // 이 키만 십자 슬롯을 KeyV2 기본값으로 되돌려 헐겁게
LEFT_SHIFT_DEPTH_TRIM  = 0.00;   // 좌측 시프트도 높으면 여기에. 형상상으로는 +0.05 감

// ---------------------------------------------------------------
// 좌측 시프트 - 스템 3개 (가운데 스위치 + 양옆 스태빌라이저)
// ---------------------------------------------------------------
//   2.25U 한 칸이지만 스위치는 가운데 1개뿐이고, 양옆에는 플레이트에 끼운
//   스태빌라이저 하우징이 있다. 셋 다 머리가 MX 십자라 캡 쪽은 똑같이
//   십자 구멍을 세 군데 뚫으면 된다.
//
//   -- 간격의 근거
//     체리 규격 스태빌라이저는 2U / 2.25U / 2.75U 가 전부 중심간 23.8mm 로 같다.
//     엄지 2U(THUMB_STAB_PITCH)와 같은 값인 게 우연이 아니다.
//     그 절반이 11.9 다. 실물이 다르면 순정 시프트 캡을 뒤집어
//     바깥 두 스템의 중심간 거리를 재고 그 절반을 넣을 것
//
//   -- 헐겁다고 간격을 줄이지 말 것
//     우측 시프트 / 엄지 2U 와 같은 이유다. 물림은 $stem_inner_slop 으로 잡는다
LEFT_SHIFT_STAB_PITCH = 11.9;   // 캡 중심 -> 스태빌 스템 중심 (mm)
LEFT_SHIFT_STEMS      = [[-LEFT_SHIFT_STAB_PITCH, 0], [0, 0], [LEFT_SHIFT_STAB_PITCH, 0]];

// ---------------------------------------------------------------
// 엄지열 2U - 스템 3개 (가운데 스위치 + 양옆 스태빌라이저)
// ---------------------------------------------------------------
//   [중요] 순정 엄지 2U 자리는 스템 자리가 3개다.
//     가운데 = Choc v2 스위치 (파란 십자)
//     양옆   = 플레이트에 끼운 스태빌라이저 하우징. 위를 철사가 잇는다
//     셋 다 머리가 MX 십자라 캡 쪽은 같은 십자 구멍을 세 군데 뚫으면 된다.
//     -> $stem_positions = THUMB_2U_STEMS_LEFT / THUMB_2U_STEMS_RIGHT
//     좌우 반쪽에 하나씩, 총 두 자리(LEFT_ROW_7 의 2U mod, RIGHT_ROW_7 의 2U space)
//
//   -- 간격 THUMB_STAB_PITCH  * 여기만 고치면 된다
//     11.9 = MX / 카일 2U 스태빌라이저 표준값(중심간 23.8mm)의 절반이다.
//     실물이 다르면 순정 캡을 뒤집어 바깥 두 스템의 중심간 거리를 캘리퍼로 재고,
//     그 절반을 넣을 것.
//     사진만으로는 원근 때문에 확정이 안 된다. 첫 출력 전에 한 번 재는 게 맞다
//
//   -- 우측 시프트와 같은 주의사항
//     헐겁다고 간격을 줄이면 안 된다. 스태빌 스템이 캡을 한쪽으로 끌고 가
//     뻑뻑해지거나 캡이 삐뚤어진다. 물림은 $stem_inner_slop 으로 잡는다
//
//   -- 하한
//     choc2_trim 의 상자(한 변 CHOC2_TRIM_BOX)가 옆 기둥을 먹으면 안 되므로
//     간격은 (CHOC2_TRIM_BOX + CHOC2_BOSS_DIAMETER) / 2 보다 커야 한다.
//     아래에서 검사한다
//
//   -- 사진으로 확인했다 (2026-09 기준)
//     빈 자리 사진에서 Choc v2 하우징 가로(약 14mm)를 자로 삼아 재면
//     스위치 중심에서 양옆 스태빌 하우징 중심까지가 약 11.8mm 다. 지금 값이 맞다.
//     즉 '안 맞는다'의 원인은 간격이 아니라 아래의 좌우 치우침이다
THUMB_STAB_PITCH = 11.9;   // 캡 중심 -> 스태빌 스템 중심 (mm)

// ---------------------------------------------------------------
// [엄지 2U 스템 무리의 좌우 치우침]  [중요] 실측해서 확정할 값
// ---------------------------------------------------------------
//   순정 엄지 2U 는 캡의 기하학적 중심과 스위치 중심이 일치하지 않는다.
//   (바깥쪽은 케이스 모서리에 맞춰 잘려 있고, 안쪽은 옆 1U 키와 맞물린다)
//   그래서 스템 3개를 통째로 좌우로 옮겨 준다.
//
//   -- 부호 규칙
//     양수 = 스템을 '바깥쪽'(케이스 모서리 쪽)으로 민다
//            -> 스위치는 고정이므로 결과적으로 캡이 '안쪽'으로 밀린다
//     왼손 2U 는 바깥이 왼쪽, 오른손 2U 는 바깥이 오른쪽이다. 좌우 대칭이므로
//     값 하나만 두고 아래 thumb_2u_stems() 가 반쪽에 맞춰 부호를 뒤집는다
//
//   -- 값을 정확히 재는 방법 (30초)
//     순정 엄지 2U 캡을 뒤집어 놓고, 가운데 십자 중심에서
//     '안쪽 끝'까지의 거리 a 와 '바깥쪽 끝'까지의 거리 b 를 캘리퍼로 잰다.
//     THUMB_2U_STEM_SHIFT = (b - a) / 2   (a = b 면 0. 바깥이 더 길면 양수)
//   * 지금 값은 사진에서 읽은 임시값이다. 실물로 한 번 재고 고치는 게 맞다
THUMB_2U_STEM_SHIFT = 1.0;

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
//   [중요] 순정 엄지 2U 는 4각형 사다리꼴이다. 5각형(모서리만 자른 모양)이 아니다.
//     바깥쪽 옆면 하나가 앞뒤 전체에 걸쳐 비스듬히 서 있어서
//     '앞쪽이 짧고 뒤쪽이 긴' 사다리꼴이 된다. 나머지 세 변은 평범하다.
//     모서리만 잘라 놓으면 바깥 옆면 위쪽이 그대로 남아 케이스에 걸린다.
//
//   -- 자르는 양은 밑면 기준, 원래 직사각형에서 안으로 얼마나 들어오는지다.
//     앞뒤 두 점을 직선으로 잇는다 -> 변이 4개뿐인 사다리꼴
//
//   -- 기본값의 근거
//     순정 캡을 위에서 찍은 사진에서 바깥 옆면 외곽선을 행마다 추적하면,
//     기울기가 깊이 1mm 당 약 0.40mm (약 22도) 로 일정하게 나온다.
//     캡 깊이 18.16mm 를 곱하면 앞뒤 차이가 약 7.3mm 다. 여유를 보태 7.5.
//     뒤쪽은 옆 1U 키와 맞물리는 쪽이라 안 깎는다
//   * 그래도 걸리면 FRONT 를 키운다. 앞뒤가 반대로 보이면 두 값을 맞바꾼다.
//     0.5 단위면 충분하다
//
//   -- 자른 면은 옆면과 같은 각도로 눕힌다
//     수직으로 자르면 그 면만 다른 각도가 되어 눈에 띈다.
//     아래 thumb_taper_cut() 이 프로파일의 $width_difference / $total_depth 에서
//     옆면 기울기를 구해 같은 각도로 눕힌다
THUMB_TAPER_FRONT = 7.5;   // 앞쪽 끝에서 안으로 들어오는 양 (mm)
THUMB_TAPER_BACK  = 0.0;   // 뒤쪽 끝에서 안으로 들어오는 양 (mm)

// 엄지 2U 폭(U). 사다리꼴로도 안 들어가면 여기를 1.9 등으로 줄여 캡을 짧게 만든다
THUMB_2U_WIDTH = 2;

// 캡 밑면(플레이트에 닿는 쪽) 치수
function cap_bottom_unit(profile)      = (profile == 0) ? 18.16 : 18.05;
function cap_bottom_x(profile, width)  = cap_bottom_unit(profile) + 19.05 * (width - 1);
function cap_bottom_y(profile)         = cap_bottom_unit(profile);
// 옆면이 위로 갈수록 안으로 좁아지는 각도. 한쪽당 $width_difference/2 만큼 좁아진다
function cap_side_lean(profile, depth) = atan(((profile == 0) ? 2 : 5.8) / 2 / depth);

// side: -1 = 바깥이 왼쪽(왼손) / +1 = 바깥이 오른쪽(오른손)
module thumb_taper_cut(width, side, profile, depth_trim = 0) {
  W = cap_bottom_x(profile, width);
  H = cap_bottom_y(profile);
  D = ((profile == 0) ? LOW_PROFILE_DEPTH : OEM_ROW_DEPTH[profile]) - depth_trim;

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
//   [중요] 공통 규칙: 선폭/간격을 전부 0.4mm 이상으로 잡는다.
//     각인은 '파인 홈'이라 홈과 홈 사이 남는 살이 0.4(노즐폭) 미만이면
//     슬라이서가 통째로 건너뛴다. 아래 수치를 줄일 거면 시험 출력으로 확인할 것.
//
//   BOSL2 도형 표기
//     rect([가로, 세로])                       중심 기준 사각형. rounding= 은 모서리 반지름
//     ring(r = 바깥반지름, ring_width = -두께)  고리
//     여기에 angle = [시작각, 끝각] 을 주면 그 구간만 남는 원호가 된다

// -- fn 지구본 --------------------------------------------------
GLOBE_RADIUS    = 1.6;   // cmd 아이콘과 비슷한 크기
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

// fn 키(1.25U) 우상단 모서리. POS_ICON_TOP_RIGHT 과 같은 위치 규칙
// (도형 좌표계는 각인 좌표계와 y 부호가 반대다)
GLOBE_POSITION = [top_width(1.25) / 3.5 * 1.05, TOP_HEIGHT / 3.5 * 0.88];

// -- 보조메뉴(우클릭) -------------------------------------------
//   문서(가로줄 3개) + 오른쪽 아래 마우스 커서
MENU_WIDTH          = 3.7;    // 문서 가로
MENU_HEIGHT         = 4.3;    // 문서 세로
MENU_THICKNESS      = 0.50;   // 문서 외곽 선폭
MENU_RADIUS         = 0.4;    // 문서 모서리 라운드
MENU_LINE_COUNT     = 3;      // 문서 안쪽 가로줄
MENU_LINE_WIDTH     = 1.6;    // 가로줄 길이 (좌우 안쪽 여백 0.55씩)
MENU_LINE_THICKNESS = 0.50;
MENU_LINE_PITCH     = 1.0;    // 가로줄 피치 (줄 사이 남는 살 0.5)
MENU_CURSOR_SCALE   = 1.6;    // 커서 배율. 줄이면 꼬리(약 0.49mm)가 사라진다
MENU_CURSOR_X       = 1.45;   // 커서 끝점 x. 문서 오른쪽 테두리에 물려 얇은 살을 없앤다
MENU_CURSOR_Y       = -0.9;   // 커서 끝점 y

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

module speaker2d() {                  // 스피커 본체
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
  depth = (profile == 0) ? SHAPE_DEPTH_LOW_PROFILE : SHAPE_DEPTH_STANDARD;
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
//   depth_trim = 이 키만 $total_depth 를 이만큼 낮춘다(mm)
module low_profile_settings(depth_trim = 0) {
  $top_tilt = 0;  $top_skew = 0;
  $dish_depth = LOW_PROFILE_DISH;  $minkowski_radius = LOW_PROFILE_MINKOWSKI;
  $total_depth = LOW_PROFILE_DEPTH - depth_trim;
  $keytop_thickness = 0.4;
  $stem_throw = 3.2;
  $inset_legend_depth = 0.1;   // minkowski 보정이 더해져 실제로는 0.5mm 파인다
  children();
}

// (2) 일반 높이 OEM
//   상판을 1.5mm 로 두껍게 잡고 각인을 1.0 까지 판다 (아래 0.5mm 가 남는다).
//   0.8 로도 보이긴 하지만 1.0 이 그림자가 확실히 짙다.
//
//   -- [행별 높이] KeyV2 oem.scad 원본 값을 그대로 옮겨 적은 표다. 보정 없음
//     oem.scad 원본:  row 0(=5) 11.20 / row 1 9.45 / row 2 9.00 / row 3 9.25 / row 4 9.25
//                     틸트        -3   /        +1  /        +6  /        +9  /        +10
//
//   -- 행 번호는 '위에서 아래로' 0 -> 4 다 (2026-09 정정)
//     한동안 숫자열을 1행으로 잡아 전체가 한 칸씩 밀려 있었다.
//     그 탓에 홈행에 3행(9.25)이 걸려 '홈행이 QWERTY보다 높다 = 계단이 뒤집혔다'로
//     보였고, 그걸 잡으려고 3행을 1.2mm 내려 8.05 로 써 뒀었다.
//     라이브러리는 멀쩡했고, 밀림만 바로잡으면 홈행(2행 9.00)이 자동으로 가장 낮다.
//
//   -- 번호가 위에서 아래라는 근거 (실물 OEM 규격표와 대조)
//     실물 OEM 공표치 - 높이 / 기울기 / 해당 줄:
//       11.8 / 음(-)   숫자열      <- oem_row 0(=5) : 11.20 / -3   음의 기울기 일치
//        9.8 / 살짝    QWERTY      <- oem_row 1     :  9.45 / +1
//        9.6 / 최소    홈행 ASDF   <- oem_row 2     :  9.00 / +6   양쪽 다 최저
//       10.0 / 위로    ZXCV        <- oem_row 3     :  9.25 / +9
//                                     oem_row 4     :  9.25 / +10  (아랫줄, ZXCV 와 동급)
//     다섯 줄 중 '숫자열만 기울기가 음수'라는 건 이 프로파일의 지문 같은 특징인데
//     oem_row 0/5 에만 -3 이 있다. 최저 행이 홈행인 것도 양쪽이 같다.
//     -> row 0 이 맨 윗줄이 맞다. (예전에 sa.scad 로 확인하려 했는데,
//        sa.scad 는 반대 규칙(1이 맨 위)이라 근거가 안 된다. 라이브러리가
//        프로파일마다 규칙이 다르다 - cherry/sa 는 1이 맨 위, oem/dcs 는 0이 맨 위)
//     같은 출처의 Cherry 표(9.81/-1, 7.85/+1, 7.22/+5, 8.59/+12)를 cherry.scad
//     (9.8/0, 7.45/+2.5, 6.55/+5, 7.35/+11.5)와 대보면 기울기가 거의 그대로 맞는다.
//     즉 이 출처는 같은 규격을 옮긴 것이고, 대조 근거로 쓸 만하다.
//
//   -- 배열 인덱스
//     0 은 이 파일에서 저프로파일 표식이라 못 쓴다. oem.scad 가 0 과 5 를 같게
//     처리하므로 숫자열은 5 를 쓴다. 그래서 유효 인덱스는 1~5 다
//   * 나중에 미세조정할 일이 생기면 이 배열만 건드리면 된다
OEM_ROW_DEPTH = [undef, 9.45, 9.00, 9.25, 9.25, 11.20];
//               ^0     ^1    ^2    ^3    ^4    ^5(=원본 0행)
//             (미사용) QWERTY 홈행  ZXCV  아랫줄  숫자열/F행

// ---------------------------------------------------------------
// [OEM 캡 높이 - $stem_inset 과 OEM_HEIGHT_BIAS]
// ---------------------------------------------------------------
//   oem.scad 는 $stem_inset = 1.2 로 스템 구멍 입구를 캡 안쪽으로 끌어올린다.
//   구멍이 위로 가면 캡은 십자에 물리려고 그만큼 더 내려앉는다.
//     완성 높이 = $total_depth - $stem_inset
//   KeyV2 자신도 cherry.scad 에서 이 관계를 명시적으로 보정한다
//   ($stem_inset 이 0 이면 $total_depth 에서 0.6 을 빼서 최종 높이를 맞춘다).
//   0 으로 두면 물림(십자 맞물림)은 그대로인 채 치마만 길어지고 캡이 그만큼 올라온다.
//   실물 MX 키캡도 치마가 스위치를 감싼다.
//
//   -- 높이를 다시 맞출 때
//     순정과 대보고 남는 차이를 OEM_HEIGHT_BIAS 에만 더한다.
//     OEM_ROW_DEPTH(행 계단)와 OEM_STEM_INSET(치마 길이)은 건드리지 말 것
OEM_STEM_INSET  = 0;     // KeyV2 원본은 1.2. 0 = 캡이 그만큼 올라오고 치마가 길어진다
OEM_HEIGHT_BIAS = 0.30;  // 모든 OEM 캡을 이만큼 더 높인다(mm). 계단 모양은 그대로다

//   depth_trim = 이 키만 $total_depth 를 이만큼 낮춘다(mm)
module standard_profile_settings(row, depth_trim = 0) {
  $keytop_thickness   = 1.5;
  $inset_legend_depth = 1.0;
  $stem_inset         = OEM_STEM_INSET;
  $total_depth        = OEM_ROW_DEPTH[row] + OEM_HEIGHT_BIAS - depth_trim;
  children();
}

module profiled_base(profile, depth_trim = 0) {
  // g20_row 의 인자 3 은 형식상 넣는 값이다. g20 에서 행에 따라 달라지는 건
  // $top_tilt / $total_depth 뿐인데 low_profile_settings() 이 둘 다 덮어쓰므로,
  // 여기에 어떤 행 번호를 넣어도 결과는 같다 (평평한 치클렛)
  if (profile == 0) g20_row(3) low_profile_settings(depth_trim) children();
  else              oem_row(profile) standard_profile_settings(profile, depth_trim) children();
}

module key_body(profile, width, depth_trim = 0) {
  // $stem_inset 은 스템만 올리는 값이 아니다. key.scad 의
  // dished() -> envelope(depth_difference, $stem_inset) 에서 캡 바닥면도 같이
  // 잘라내므로, 스템과 캡 바닥이 늘 같은 높이로 함께 움직인다.
  // 지금 값과 그 근거는 OEM_STEM_INSET 주석 참조.
  // 물림 자체는 $stem_inner_slop (STANDARD_STEM_INNER_SLOP) 으로 잡는다
  profiled_base(profile, depth_trim) u(width) cherry() key();
}

// ---------------------------------------------------------------
// 키 한 벌 = KEYCAP(...). 이름 있는 인자라 순서를 외울 필요도,
// undef 로 자리를 채울 필요도 없다. 안 쓰는 인자는 그냥 생략한다.
// ---------------------------------------------------------------
//   width   : 폭(U)
//   top     : 상판 각인 (WORD / ICON / SYMBOL / ALPHA / ALPHA_DOUBLE / concat)
//   side    : 측면(Mod) 각인 (SIDE)
//   stems   : 스템 위치 배열. 개수 제한 없다. 생략하면 중앙 스템 1개
//               RIGHT_SHIFT_STEMS (2개) / LEFT_SHIFT_STEMS (3개)
//               THUMB_2U_STEMS_LEFT / _RIGHT (3개)
//   shape   : 도형 각인 이름 ("globe" | "menu" | "f1"~"f12")
//   profile : 이 키만 다른 프로파일 (0=저프로파일, 1~5=oem 행). 생략하면 행 기본값
//   homing  : true = 호밍 바
//   choc2   : true = Choc v2 스위치. 바깥 기둥을 원통으로 깎는다 (엄지열 전용).
//             스템이 여러 개면 전부에 적용된다
//   depth_trim : 이 키만 캡 높이($total_depth)를 이만큼 낮춘다 (mm)
//   inner_slop : 이 키만 십자 슬롯 여유($stem_inner_slop)를 따로 준다.
//                생략하면 프로파일 기본값. 스템이 여러 개라 안 들어갈 때 푼다
//   taper   : 사다리꼴로 만든다. -1 = 바깥이 왼쪽 / +1 = 바깥이 오른쪽
//             0(기본) = 직사각형. THUMB_TAPER_* 주석 참조
function KEYCAP(width = 1, top = [], side = [], stems = undef, shape = undef,
                profile = undef, homing = false, choc2 = false,
                depth_trim = 0, taper = 0, inner_slop = undef) =
  [width, top, side, stems, shape, profile, homing, choc2, depth_trim, taper,
   inner_slop];

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
  depth_trim   = is_undef(key[8]) ? 0 : key[8];
  taper        = is_undef(key[9]) ? 0 : key[9];
  inner_slop   = key[10];

  // 서포트/스템 여유는 호출 시점 스코프에서 정해야 확실히 먹는다
  // (settings.scad 가 top-level 값을 덮어쓴다)
  $stem_support_type = STEM_SUPPORT;
  // Choc v2 는 기둥을 원통으로 깎으므로, 깎기 전 사각 기둥이 원통보다 커야 한다.
  // 최종 바깥 치수는 CHOC2_BOSS_DIAMETER 가 정하니 이 값은 헐거움에 영향을 주지 않는다
  $stem_slop       = choc2 ? CHOC2_SLOP :
                     (profile == 0) ? LOW_PROFILE_STEM_SLOP : STANDARD_STEM_SLOP;
  $stem_inner_slop = !is_undef(inner_slop) ? inner_slop :
                     (profile == 0) ? LOW_PROFILE_STEM_INNER_SLOP
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
      key_body(profile, width, depth_trim);
      if (!is_undef(shape)) profiled_base(profile, depth_trim) u(width) shape_cut(shape, profile);
      if (choc2)            choc2_trim(stems);
      // 사다리꼴 옆면은 캡을 다 만든 뒤 바깥에서 잘라낸다.
      // 바깥 스템(y = 0 축 위)은 잘리는 영역 밖이다
      if (taper != 0)       thumb_taper_cut(width, taper, profile, depth_trim);
    }
    // 호밍 바는 잘라내기가 끝난 뒤에 얹는다
    if (homing) profiled_base(profile, depth_trim) u(width) homing_bar();
  }
}

// ---------------------------------------------------------------
// 키 배열. 행 = [기본프로파일(0=저프로파일, 1~5=oem행), [키...]]
// ---------------------------------------------------------------

// 윗줄 F행은 저프로파일(LEFT_ROW_1 / RIGHT_ROW_1)과
// 일반 높이 예비(LEFT_ROW_9 / RIGHT_ROW_8)가 같은 키 목록을 공유한다
function function_row(names) =
  [for (name = names) KEYCAP(1, WORD(name, POS_BOTTOM), shape = name)];

FUNCTION_ROW_LEFT  = concat([KEYCAP(1, WORD("esc"))],
                            function_row(["f1", "f2", "f3", "f4", "f5", "f6"]));
FUNCTION_ROW_RIGHT = concat(function_row(["f7", "f8", "f9", "f10", "f11", "f12"]),
                            [KEYCAP(1.5, WORD("eject")),
                             GAP(1),
                             KEYCAP(1, WORD("f13", POS_BOTTOM))]);   // 특수기능이 없어
                                                                     //   윗줄은 비움

// -- 왼쪽 ------------------------------------------------------
LEFT_ROW_1 = [0, FUNCTION_ROW_LEFT];

LEFT_ROW_2 = [5, [ KEYCAP(1, SYMBOL("~", "`")),
                   KEYCAP(1, SYMBOL("!", "1")),
                   KEYCAP(1, SYMBOL("@", "2")),
                   KEYCAP(1, SYMBOL("#", "3")),
                   KEYCAP(1, SYMBOL("$", "4")),
                   KEYCAP(1, SYMBOL("%", "5")),
                   KEYCAP(1, SYMBOL("^", "6")) ]];

LEFT_ROW_3 = [1, [ KEYCAP(1.5, WORD("tab", "wl")),
                   KEYCAP(1, ALPHA_DOUBLE("Q", "ㅂ", "ㅃ")),
                   KEYCAP(1, ALPHA_DOUBLE("W", "ㅈ", "ㅉ"), SIDE("mup")),
                   KEYCAP(1, ALPHA_DOUBLE("E", "ㄷ", "ㄸ")),
                   KEYCAP(1, ALPHA_DOUBLE("R", "ㄱ", "ㄲ")),
                   KEYCAP(1, ALPHA_DOUBLE("T", "ㅅ", "ㅆ")) ]];

LEFT_ROW_4 = [2, [ KEYCAP(1.75, WORD("caps lock", "wl")),
                   KEYCAP(1, ALPHA("A", "ㅁ"), SIDE("mlt")),
                   KEYCAP(1, ALPHA("S", "ㄴ"), SIDE("clk")),
                   KEYCAP(1, ALPHA("D", "ㅇ"), SIDE("mrt")),
                   KEYCAP(1, ALPHA("F", "ㄹ"), homing = true),
                   KEYCAP(1, ALPHA("G", "ㅎ")) ]];

// 좌측 시프트: 2.25U 한 칸 = 스위치 1개 + 양옆 스태빌라이저 -> 스템 3개
LEFT_ROW_5 = [3, [ KEYCAP(2.25, WORD("shift", "wl"), stems = LEFT_SHIFT_STEMS,
                          depth_trim = LEFT_SHIFT_DEPTH_TRIM),
                   KEYCAP(1, ALPHA("Z", "ㅋ")),
                   KEYCAP(1, ALPHA("X", "ㅌ"), SIDE("mdn")),
                   KEYCAP(1, ALPHA("C", "ㅊ")),
                   KEYCAP(1, ALPHA("V", "ㅍ")),
                   KEYCAP(1, ALPHA("B", "ㅠ")) ]];

LEFT_ROW_6 = [4, [ KEYCAP(1.25, WORD("fn", "wl"), shape = "globe"),
                   KEYCAP(1.25, concat(ICON("⌃", POS_ICON_TOP_RIGHT),
                                       WORD("ctrl", "wl"))),
                   KEYCAP(1.25, concat(ICON("⌥", POS_ICON_TOP_RIGHT),
                                       WORD("opt", "wl"))),
                   GAP(1.5),
                   KEYCAP(1.5, concat(ICON("⌘", POS_ICON_TOP_RIGHT),
                                      WORD("command", "wl"))) ]];

// 엄지열 - 저프로파일. 행 기본값 4 를 무시하도록 키마다 profile 오버라이드 0
//   2U 는 스템 3개 (스위치 + 스태빌 2), 사다리꼴. 1U 는 중앙 1개, 직사각형
//   왼손 2U 는 바깥이 왼쪽이므로 taper = -1, 스템도 왼쪽으로 치우친다
LEFT_ROW_7 = [4, [ KEYCAP(THUMB_2U_WIDTH, WORD("mod"), stems = THUMB_2U_STEMS_LEFT,
                          profile = 0, choc2 = true, taper = -1),
                   KEYCAP(1, ICON("␣", POS_CENTER, SIZE_SPACE),
                          profile = 0, choc2 = true) ]];

// 키 클러스터 모듈용 (1U x 3, Cherry 스위치, 일반 높이)
LEFT_ROW_8 = [4, [ KEYCAP(1, WORD("mod")),
                   KEYCAP(1, concat(ICON("⌘", POS_ICON_TOP_RIGHT),
                                    WORD("cmd", POS_BOTTOM))),
                   KEYCAP(1, ICON("␣", POS_CENTER, SIZE_SPACE)) ]];

// 윗줄 일반 높이 한 벌 (왼쪽). 행 기본 profile 5 = 숫자열과 같은 OEM 최상단 행.
//   F행은 숫자열 바로 위 단이라 실제 OEM 세트도 같은 캡을 쓴다.
//   저프로파일 원본은 LEFT_ROW_1 에 그대로 있고, 이건 갈아 끼우기용 예비 세트다.
LEFT_ROW_9 = [5, FUNCTION_ROW_LEFT];

// -- 오른쪽 ----------------------------------------------------
RIGHT_ROW_1 = [0, FUNCTION_ROW_RIGHT];

RIGHT_ROW_2 = [5, [ KEYCAP(1, SYMBOL("&", "7"), SIDE("nlk")),
                    KEYCAP(1, SYMBOL("*", "8"), SIDE("=")),
                    KEYCAP(1, SYMBOL("(", "9"), SIDE("/")),
                    KEYCAP(1, SYMBOL(")", "0"), SIDE("*")),
                    KEYCAP(1, SYMBOL("_", "-")),
                    KEYCAP(1, SYMBOL("+", "=")),
                    KEYCAP(1.5, ICON("⌫", POS_CENTER,
                                     SIZE_BACKSPACE_DELETE)),   // backspace
                    GAP(1),
                    KEYCAP(1, shape = "menu") ]];                // 보조메뉴(우클릭)

RIGHT_ROW_3 = [1, [ KEYCAP(1, ALPHA("Y", "ㅛ")),
                    KEYCAP(1, ALPHA("U", "ㅕ"), SIDE("7")),
                    KEYCAP(1, ALPHA("I", "ㅑ"), SIDE("8")),
                    KEYCAP(1, ALPHA_DOUBLE("O", "ㅐ", "ㅒ"), SIDE("9")),
                    KEYCAP(1, ALPHA_DOUBLE("P", "ㅔ", "ㅖ"), SIDE("-")),
                    KEYCAP(1, SYMBOL("{", "[")),
                    KEYCAP(1, SYMBOL("}", "]")),
                    KEYCAP(1, SYMBOL("|", "\\")),
                    GAP(1),
                    KEYCAP(1, ICON("⌦", POS_CENTER,
                                   SIZE_BACKSPACE_DELETE)) ]];   // delete (forward)

RIGHT_ROW_4 = [2, [ KEYCAP(1, ALPHA("H", "ㅗ")),
                    KEYCAP(1, ALPHA("J", "ㅓ"), SIDE("4"), homing = true),
                    KEYCAP(1, ALPHA("K", "ㅏ"), SIDE("5")),
                    KEYCAP(1, ALPHA("L", "ㅣ"), SIDE("6")),
                    KEYCAP(1, SYMBOL(":", ";"), SIDE("+")),
                    KEYCAP(1, SYMBOL("\"", "'")),
                    KEYCAP(1.75, WORD("return", "wr")),
                    GAP(1), GAP(1) ]];

RIGHT_ROW_5 = [3, [ KEYCAP(1, ALPHA("N", "ㅜ")),
                    KEYCAP(1, ALPHA("M", "ㅡ"), SIDE("1")),
                    KEYCAP(1, SYMBOL("<", ","), SIDE("2")),
                    KEYCAP(1, SYMBOL(">", "."), SIDE("3")),
                    KEYCAP(1, SYMBOL("?", "/"), SIDE("ent")),
                    // 순정 [1.25U 시프트]+[1U] 두 칸을 한 캡으로 덮는다
                    //   -> 스위치 2개, 듀얼 스템. 높이는 행 기본값 그대로다
                    //      (RIGHT_SHIFT_DEPTH_TRIM 주석 참조)
                    KEYCAP(2.25, WORD("shift", "wr"), stems = RIGHT_SHIFT_STEMS,
                           depth_trim = RIGHT_SHIFT_DEPTH_TRIM,
                           inner_slop = RIGHT_SHIFT_INNER_SLOP),
                    KEYCAP(1, ICON("▲", POS_CENTER, SIZE_ARROW)),
                    GAP(1) ]];

// 아랫줄. 저프로파일은 RIGHT_ROW_7 엄지열뿐이고 이 행은 전부 일반 높이다
RIGHT_ROW_6 = [4, [ KEYCAP(1.5, ICON("␣", POS_CENTER, SIZE_SPACE)),
                    KEYCAP(1.5, ICON("␣", POS_CENTER, SIZE_SPACE),
                           SIDE("0")),                          // Mod: 넘패드 0
                    KEYCAP(1.25, concat(ICON("⌘", POS_ICON_TOP_LEFT),
                                        WORD("cmd", "wr")), SIDE(".")),
                    KEYCAP(1.25, concat(ICON("⌥", POS_ICON_TOP_LEFT),
                                        WORD("opt", "wr")), SIDE("ent")),
                    GAP(1.25),
                    KEYCAP(1, ICON("◀", POS_CENTER, SIZE_ARROW)),
                    KEYCAP(1, ICON("▼", POS_CENTER, SIZE_ARROW)),
                    KEYCAP(1, ICON("▶", POS_CENTER, SIZE_ARROW)) ]];

// 엄지열 - 저프로파일 (profile 오버라이드 0)
//   2U 는 스템 3개 (스위치 + 스태빌 2), 사다리꼴. 1U 는 중앙 1개, 직사각형
//   오른손 2U 는 바깥이 오른쪽이므로 taper = +1, 스템도 오른쪽으로 치우친다
RIGHT_ROW_7 = [4, [ KEYCAP(1, ICON("␣", POS_CENTER, SIZE_SPACE),
                           profile = 0, choc2 = true),
                    KEYCAP(THUMB_2U_WIDTH, ICON("␣", POS_CENTER, SIZE_SPACE),
                           stems = THUMB_2U_STEMS_RIGHT, profile = 0, choc2 = true,
                           taper = 1) ]];

// 윗줄 일반 높이 한 벌 (오른쪽). LEFT_ROW_9 와 한 세트
RIGHT_ROW_8 = [5, FUNCTION_ROW_RIGHT];

LEFT_HALF  = [LEFT_ROW_1, LEFT_ROW_2, LEFT_ROW_3, LEFT_ROW_4, LEFT_ROW_5,
              LEFT_ROW_6, LEFT_ROW_7, LEFT_ROW_8, LEFT_ROW_9];
RIGHT_HALF = [RIGHT_ROW_1, RIGHT_ROW_2, RIGHT_ROW_3, RIGHT_ROW_4,
              RIGHT_ROW_5, RIGHT_ROW_6, RIGHT_ROW_7, RIGHT_ROW_8];

// ---------------------------------------------------------------
// 배치 / 생성
// ---------------------------------------------------------------
UNIT_PITCH   = 20;   // 1U 당 가로 간격
ROW_PITCH    = 22;   // 행 간격
RIGHT_HALF_X = 8 * UNIT_PITCH;

// RENDER 로 키를 걸러낸다
//   "pack" / "all"      전부 통과
//   [행, 열]            그 행/열만. 0 이나 생략(undef)은 그 축 '전부'
//   [KEY(..), ...]      목록에 있는 키만 (반쪽까지 구분한다)
function pick_axis(value) = is_undef(value) ? 0 : value;

// 첫 원소가 또 리스트면 KEY 목록, 숫자면 [행, 열]
function is_key_list(sel) = is_list(sel) && len(sel) > 0 && is_list(sel[0]);

function in_key_list(hand, r, i) =
  len([for (k = RENDER)
         if (k[0] == hand && k[1] == r + 1 && k[2] == i + 1) 1]) > 0;

function selected(hand, r, i) =
  !is_list(RENDER)    ? true :
  is_key_list(RENDER) ? in_key_list(hand, r, i) :
  let (want_row = pick_axis(RENDER[0]),
       want_col = pick_axis(RENDER[1]))
  (want_row == 0 || want_row == r + 1) &&
  (want_col == 0 || want_col == i + 1);

module half(rows, origin_x, origin_y = 0, hand = "L") {
  for (r = idx(rows)) {
    base_profile = rows[r][0];
    row          = rows[r][1];
    // 행 안에서의 누적 x (U 단위)
    x_offsets    = [0, each cumsum([for (key = row) cap_width(key)])];
    for (i = idx(row)) {
      key = row[i];
      if (!is_gap(key) && selected(hand, r, i))
        translate([origin_x + (x_offsets[i] + cap_width(key) / 2) * UNIT_PITCH,
                   origin_y - r * ROW_PITCH, 0])
          cap(key, base_profile);
    }
  }
}

// ---------------------------------------------------------------
// pack 배치 (RENDER="pack") - 프린트용 촘촘한 재배치
//   키보드 모양을 버리고 왼쪽부터 채워 나가다, 한 줄이 PACK_WIDTH 를 넘으면
//   다음 줄로 내린다. 빈 공간이 거의 없어 베드를 잘 활용한다.
//   실제 크기는 렌더할 때 콘솔에 찍힌다. 베드를 넘으면 경고가 뜨는데, 그럴 땐
//   PACK_WIDTH 를 조정하거나 RENDER 에 행/열을 지정해(예: [3]) 나눠서 출력한다.
//   * pack 이 까는 대상은 RENDER 가 고른 키다.
//     "pack" 이면 전체, [KEY(..), ...] 목록이면 그 키들만 깐다
// ---------------------------------------------------------------

// 키 바닥 footprint 폭(mm). 1U=18.05, 그 뒤로 1U(19.05)씩. 저/일반 공통
function footprint_width(width) = 19.05 * width - 1.0;

// 뽑을 키를 한 줄 리스트로 [키데이터, 행기본프로파일].
// GAP(스위치 없는 자리)과 RENDER 가 안 고른 키는 제외한다
function half_keys(hand, rows) =
  [ for (r = idx(rows))
      for (i = idx(rows[r][1]))
        if (!is_gap(rows[r][1][i]) && selected(hand, r, i))
          [rows[r][1][i], rows[r][0]] ];

ALL_KEYS = concat(half_keys("L", LEFT_HALF), half_keys("R", RIGHT_HALF));

FOOTPRINT_WIDTHS = [for (entry = ALL_KEYS) footprint_width(cap_width(entry[0]))];

// 왼쪽부터 채우다 PACK_WIDTH 넘으면 다음 줄. 각 키 중심좌표 리스트 반환
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
         " mm / 베드 ", BED[0], " x ", BED[1], " mm"));
if (PACK_SIZE_X > BED[0] || PACK_SIZE_Y > BED[1])
  echo("경고: pack 배치가 베드를 넘는다. PACK_WIDTH 를 조정하거나 RENDER=[행] 으로 나눠서 출력할 것");

if (!is_list(RENDER) && RENDER != "pack" && RENDER != "all")
  echo(str("경고: RENDER(", RENDER, ") 를 모르겠다. ",
           "\"pack\" / \"all\" / [행, 열] / [KEY(..), ...] 중 하나여야 한다"));

if (is_key_list(RENDER) && len(ALL_KEYS) == 0)
  echo("경고: RENDER 의 KEY 목록에 걸리는 키가 하나도 없다. 반/행/열을 확인할 것");

if (RENDER == "pack" || (is_key_list(RENDER) && PACK_SELECTED)) {
  pack();
} else {                      // "all" / [행, 열] / KEY 목록(PACK_SELECTED=false)
  half(LEFT_HALF,  0,            hand = "L");
  half(RIGHT_HALF, RIGHT_HALF_X, hand = "R");
}
