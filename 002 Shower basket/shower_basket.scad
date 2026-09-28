include <BOSL2/std.scad>

/* [기본 치수 (mm)] */
width  = 275;
depth  = 120;
height = 75;

/* [두께] */
corner_r = 10;
thickness = 4;
wall     = thickness;
floor_th = thickness;

/* [벌집 패턴] */
hex_size = 13;
hex_web  = thickness;

/* [테두리 / 보강] */
rim_h        = 7;
base_band    = 9;
floor_margin = 6;

/* [손잡이] */
handles  = true;
handle_w = 62;
handle_h = 20;
edge_r   = 1.0;
handle_margin = 5;

/* [바닥 받침대] */
feet   = true;
feet_h = 20;
feet_r = hex_size / 2;

foot_layout = [
    [-4, [2, 6]],
    [ 0, [0, 5]],
    [ 4, [2, 6]]
];

/* [Hidden] */
bead_r = wall / 2;
bot_r  = 10;
$fn = 48;

R       = hex_size / sqrt(3);
Rp      = R + hex_web / sqrt(3);
dxg     = Rp * sqrt(3);
dyg     = Rp * 1.5;
fh      = feet ? feet_h : 0;
total_h = height + fh;
mesh_h  = height - rim_h - base_band;
mesh_z  = (base_band + height - rim_h) / 2;
hz      = height - rim_h - 5 - handle_h / 2;

function hex_centers(w, h) =
    let(dx = Rp * sqrt(3), dy = Rp * 1.5,
        nx = ceil(w / dx / 2) + 1, ny = ceil(h / dy / 2) + 1)
    [for (j = [-ny : ny], i = [-nx : nx])
        let(px = i * dx + ((j % 2 == 0) ? 0 : dx / 2), py = j * dy)
        if (abs(px) <= w / 2 && abs(py) <= h / 2) [px, py]];

floor_w = width - 2 * (wall + floor_margin);
floor_d = depth - 2 * (wall + floor_margin);
fc      = hex_centers(floor_w, floor_d);

jmax = floor(floor_d / 2 / dyg);

foot_ref = [for (r = foot_layout, i = r[1], sx = [1, -1])
    let(j = min(jmax, max(-jmax, r[0])))
    [sx * (i * dxg + ((j % 2 == 0) ? 0 : dxg / 2)), j * dyg]];

foot_idx = unique([for (t = foot_ref) min_index([for (c = fc) norm(c - t)])]);
foot_pts = [for (i = foot_idx) fc[i]];

foot_err = max([for (t = foot_ref) min([for (c = fc) norm(c - t)])]);

module hexprism(t) { linear_extrude(t, center = true) hexagon(r = R, align_tip = BACK); }

module hexcut(w, h, t) {
    intersection() {
        for (c = hex_centers(w + 2 * R, h + 2 * R)) move(c) hexprism(t);
        cuboid([w, h, t]);
    }
}

module wall_mesh_fb() {
    up(mesh_z) xrot(90) hexcut(width - 2 * corner_r + dxg, mesh_h, depth + 2);
}

module wall_mesh_lr() {
    difference() {
        up(mesh_z) yrot(90) zrot(90) hexcut(depth - 2 * corner_r + dxg, mesh_h, width + 2);
        if (handles) handle_keepout(handle_margin);
    }
}

module floor_mesh() {
    up(floor_th / 2)
    intersection() {
        for (i = idx(fc)) if (!in_list(i, foot_idx)) move(fc[i]) hexprism(floor_th + 2);
        cuboid([floor_w, floor_d, floor_th + 2]);
    }
}

module handle_keepout(grow) {
    r = handle_h / 2 + grow;
    up(hz) hull() ycopies(spacing = handle_w - handle_h, n = 2)
        cyl(r = r, h = width + 8, orient = RIGHT);
}

module handle_cut() {
    prof_w = handle_w; prof_h = handle_h;
    up(hz) xcopies(spacing = width - wall, n = 2) zrot(90) xrot(90)
    union() {
        down(wall / 2)
            offset_sweep(rect([prof_w, prof_h], rounding = prof_h / 2), height = wall,
                         bottom = os_circle(r = -edge_r), top = os_circle(r = -edge_r),
                         steps = 8);
        up(wall / 2)     linear_extrude(4) offset(r = edge_r) rect([prof_w, prof_h], rounding = prof_h / 2);
        down(wall / 2 + 4) linear_extrude(4) offset(r = edge_r) rect([prof_w, prof_h], rounding = prof_h / 2);
    }
}

module bottom_edge_mask() {
    difference() {
        linear_extrude(bot_r) offset(delta = 2) rect([width, depth], rounding = corner_r);
        offset_sweep(rect([width, depth], rounding = corner_r), height = bot_r * 2,
                     bottom = os_circle(r = bot_r), steps = 8);
    }
}

module top_bead() {
    up(height - bead_r)
        path_sweep(circle(r = bead_r, $fn = 20),
                   path3d(rect([width - wall, depth - wall], rounding = max(corner_r - wall / 2, bead_r + wall / 2))),
                   closed = true);
}

module basket_feet() {
    for (p = foot_pts)
        move([p.x, p.y, 0])
            cyl(r1 = feet_r * 0.8, r2 = feet_r, h = fh + 0.6, anchor = BOT);
}

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
