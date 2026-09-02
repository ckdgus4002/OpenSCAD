// =============================================================
//  Parametric Honeycomb Shower Basket  (BOSL2)
//  200(W) x 120(D) x 75(H) + 받침대 20mm = 총 높이 95mm
//  require: BOSL2  https://github.com/BelfrySCAD/BOSL2
// =============================================================
include <BOSL2/std.scad>

/* [기본 치수 (mm)] */
// 너비 (X)
width  = 200;
// 깊이 (Y)
depth  = 120;
// 몸통 높이 (Z) ※ 받침대 제외
height = 75;

/* [두께] */
// ★ 기본 두께 (벽 / 바닥 / 벌집 살 공통) — 여기만 바꾸면 전체가 따라감
thickness = 4;
// 벽 두께
wall     = thickness;
// 바닥판 두께
floor_th = thickness;
// 바깥 모서리 라운드 반경
corner_r = 10;

/* [벌집 패턴] */
// 육각 구멍 크기 (마주보는 면 사이 거리)
hex_size = 13;
// 육각 사이 살 두께
hex_web  = thickness;

/* [테두리 / 보강] */
rim_h        = 7;
base_band    = 9;
floor_margin = 6;

/* [손잡이] */
handles  = true;
handle_w = 62;
handle_h = 20;
// 손잡이 구멍 모서리 라운드 반경 (양쪽 면)
edge_r   = 1.0;
// 손잡이 구멍 둘레에 벌집을 뚫지 않고 남길 여유 (클수록 테두리가 두꺼워짐)
handle_margin = 5;

/* [바닥 받침대] */
feet   = true;
feet_h = 20;   // 엄지손가락이 들어갈 높이
// 받침대 반경. hex_size/2 = 육각 셀에 딱 내접
feet_r = hex_size / 2;

// 받침대 배치 = [ 육각 줄 j , 오른쪽 절반의 가로 칸 i 목록 ]
//   j : 0 = 정중앙 줄, + 위쪽 / - 아래쪽.
//       두께를 바꾸면 격자가 변해 줄 수가 줄 수 있음 -> 없는 줄은 가장 바깥 줄로 자동 보정
//   i : 오른쪽 방향 칸 번호. 왼쪽은 자동으로 좌우 대칭 배치됨 (항상 대칭 보장)
//       짝수 줄은 i=0 이 정중앙, 홀수 줄은 i=0 이 중앙에서 반 칸 오른쪽
//       -> 짝수 줄에 0 을 넣으면 정중앙 1개가 생김
foot_layout = [
    [-4, [1, 4]],   // 아래줄  : 좌우 대칭 4개
    [ 0, [0, 3]],   // 가운데줄: 정중앙 1개 + 좌우 2개 = 3개
    [ 4, [1, 4]]    // 위줄    : 좌우 대칭 4개
];

/* [Hidden] */
// 상단 비드 반경. wall/2 = 완전한 반원 마감
bead_r = wall / 2;
// 하단 바깥 모서리 라운드 반경
bot_r  = 1.2;
$fn = 48;

R       = hex_size / sqrt(3);               // 육각 외접원 반경
Rp      = R + hex_web / sqrt(3);            // 살 두께 포함 피치용 반경
dxg     = Rp * sqrt(3);                     // 육각 격자 가로 피치 (한 칸)
dyg     = Rp * 1.5;                         // 육각 격자 세로 피치 (한 줄)
fh      = feet ? feet_h : 0;
total_h = height + fh;
mesh_h  = height - rim_h - base_band;
mesh_z  = (base_band + height - rim_h) / 2;
hz      = height - rim_h - 5 - handle_h / 2; // 손잡이 중심 높이

// -------------------------------------------------------------
//  육각 격자 좌표
//  꼭짓점이 위를 향하게 배치 -> 서포트 없이 출력 가능
//  중심이 영역 안에 있는 것만 -> 가장자리 얇은 조각 방지
// -------------------------------------------------------------
function hex_centers(w, h) =
    let(dx = Rp * sqrt(3), dy = Rp * 1.5,
        nx = ceil(w / dx / 2) + 1, ny = ceil(h / dy / 2) + 1)
    [for (j = [-ny : ny], i = [-nx : nx])
        let(px = i * dx + ((j % 2 == 0) ? 0 : dx / 2), py = j * dy)
        if (abs(px) <= w / 2 && abs(py) <= h / 2) [px, py]];

floor_w = width - 2 * (wall + floor_margin);
floor_d = depth - 2 * (wall + floor_margin);
fc      = hex_centers(floor_w, floor_d);

// 실제로 존재하는 육각 줄의 최대 번호 (두께에 따라 달라짐)
jmax = floor(floor_d / 2 / dyg);

// foot_layout 을 좌표로 펼침. 줄 번호는 범위 안으로 클램프하고,
// 가로는 오른쪽 절반만 지정한 뒤 ±로 미러링 -> 두께가 바뀌어도 항상 좌우 대칭
foot_ref = [for (r = foot_layout, i = r[1], sx = [1, -1])
    let(j = min(jmax, max(-jmax, r[0])))
    [sx * (i * dxg + ((j % 2 == 0) ? 0 : dxg / 2)), j * dyg]];

foot_idx = unique([for (t = foot_ref) min_index([for (c = fc) norm(c - t)])]);
foot_pts = [for (i = foot_idx) fc[i]];

// foot_layout 의 i 가 줄 범위를 벗어나면 조용히 엉뚱한 칸으로 붙으므로 경고
foot_err = max([for (t = foot_ref) min([for (c = fc) norm(c - t)])]);

module hexprism(t) { linear_extrude(t, center = true) hexagon(r = R, align_tip = BACK); }

module hexcut(w, h, t) {
    intersection() {
        for (c = hex_centers(w, h)) move(c) hexprism(t);
        cuboid([w, h, t]);
    }
}

// -------------------------------------------------------------
//  아래 모듈들은 "몸통 바닥 중심"이 원점인 좌표계 기준
// -------------------------------------------------------------

// 앞/뒤 벽 벌집
module wall_mesh_fb() {
    up(mesh_z) xrot(90) hexcut(width - 2 * corner_r, mesh_h, depth + 2);
}

// 좌/우 벽 벌집 (손잡이 주변은 통짜로 남김)
module wall_mesh_lr() {
    difference() {
        up(mesh_z) yrot(90) zrot(90) hexcut(depth - 2 * corner_r, mesh_h, width + 2);
        if (handles) handle_keepout(handle_margin);
    }
}

// 바닥 벌집. 받침대가 놓이는 육각은 뚫지 않아 통짜 패드가 됨
module floor_mesh() {
    up(floor_th / 2)
    intersection() {
        for (i = idx(fc)) if (!in_list(i, foot_idx)) move(fc[i]) hexprism(floor_th + 2);
        cuboid([floor_w, floor_d, floor_th + 2]);
    }
}

// 손잡이 주변 벌집 제외 영역
// 손잡이 구멍을 handle_margin 만큼 부풀린 캡슐 하나뿐
// -> 손잡이 좌/우/위쪽도 벌집이 그대로 뚫림
module handle_keepout(grow) {
    r = handle_h / 2 + grow;
    up(hz) hull() ycopies(spacing = handle_w - handle_h, n = 2)
        cyl(r = r, h = width + 8, orient = RIGHT);
}

// 손잡이 구멍. 벽 두께 구간에서 양쪽 면으로 벌어지는 필렛 -> 모서리 둥글게
module handle_cut() {
    prof_w = handle_w; prof_h = handle_h;
    up(hz) xcopies(spacing = width - wall, n = 2) zrot(90) xrot(90)
    union() {
        down(wall / 2)
            offset_sweep(rect([prof_w, prof_h], rounding = prof_h / 2), height = wall,
                         bottom = os_circle(r = -edge_r), top = os_circle(r = -edge_r),
                         steps = 8);
        // 벽 바깥으로 연장해 확실히 관통
        up(wall / 2)     linear_extrude(4) offset(r = edge_r) rect([prof_w, prof_h], rounding = prof_h / 2);
        down(wall / 2 + 4) linear_extrude(4) offset(r = edge_r) rect([prof_w, prof_h], rounding = prof_h / 2);
    }
}

// 하단 바깥 모서리 라운드용 마스크 (이 부분을 깎아냄)
module bottom_edge_mask() {
    difference() {
        linear_extrude(bot_r) offset(delta = 2) rect([width, depth], rounding = corner_r);
        offset_sweep(rect([width, depth], rounding = corner_r), height = bot_r * 2,
                     bottom = os_circle(r = bot_r), steps = 8);
    }
}

// 상단면 반원 비드 (벽 두께 전체를 감싸는 불노즈 마감)
module top_bead() {
    up(height - bead_r)
        path_sweep(circle(r = bead_r, $fn = 20),
                   path3d(rect([width - wall, depth - wall], rounding = corner_r - bead_r)),
                   closed = true);
}

// 받침대. 채워진 육각 셀에 내접하는 원기둥, 아래로 갈수록 좁아져 오버행 없음
module basket_feet() {
    for (p = foot_pts)
        move([p.x, p.y, 0])
            cyl(r1 = feet_r * 0.8, r2 = feet_r, h = fh + 0.6, anchor = BOT);
}

// -------------------------------------------------------------
//  조립
// -------------------------------------------------------------
up(fh)
diff()
rect_tube(size = [width, depth], wall = wall, h = height - bead_r,
          rounding = corner_r, anchor = BOT) {
    position(BOT) cuboid([width, depth, floor_th], rounding = corner_r, edges = "Z", anchor = BOT);
    position(BOT) top_bead();
    tag("remove") position(BOT) wall_mesh_fb();
    tag("remove") position(BOT) wall_mesh_lr();
    tag("remove") position(BOT) floor_mesh();
    if (handles) tag("remove") position(BOT) handle_cut();
    tag("remove") position(BOT) bottom_edge_mask();
}

if (feet) basket_feet();

echo(str("== ", width, " x ", depth, " x ", height, " + 받침대 ", fh,
         " = 총 높이 ", total_h, " mm / 받침대 ", len(foot_pts), "개 =="));
echo(str("   받침대 좌표 = ", foot_pts));
if (foot_err > 0.01)
    echo(str("!! 경고: foot_layout 이 격자를 벗어나 ", foot_err,
             "mm 만큼 보정됨. i 값을 줄이세요 (현재 줄 범위 j = -", jmax, " ~ ", jmax, ")"));
