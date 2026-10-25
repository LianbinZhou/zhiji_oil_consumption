"""
智记能耗 - 应用图标生成脚本（v4：按作者提供的 SVG 精确复刻）

设计（来自作者给的 SVG 参考，坐标一一对应 viewBox 0 0 512 512）：
  1. 纯橙底 #FF7A45（不用渐变）
  2. 修长油滴：腰部内收（贝塞尔控制点在内侧），底部半圆 r=146
     外轮廓用 24px 白描边，不填充
  3. 透视公路：左右路基 + 中间虚线，**穿过油滴边界**（不裁剪）
  4. 方正极简小车：薄荷绿 #86EFAC，硬朗梯形车顶 + 负空间车窗 + 白芯轮子

分层（手机桌面最小 48px）：
  ≥144  完整：油滴 + 公路 + 小车
  96    油滴 + 公路
  48/72 实心油滴（只有轮廓，保证一眼可辨）

版权：Pillow 从零绘制，不含任何 AI 生成素材、无水印。

用法：python tools/gen_icon.py
"""

import math
import os

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

C_BG = (255, 122, 69, 255)      # #FF7A45 纯橙
C_WHITE = (255, 255, 255, 255)
C_CAR = (134, 239, 172, 255)    # #86EFAC 薄荷绿

BASE = 512


def _cubic(p0, p1, p2, p3, n):
    out = []
    for i in range(n + 1):
        t = i / n
        mt = 1 - t
        x = mt**3 * p0[0] + 3 * mt**2 * t * p1[0] + 3 * mt * t**2 * p2[0] + t**3 * p3[0]
        y = mt**3 * p0[1] + 3 * mt**2 * t * p1[1] + 3 * mt * t**2 * p2[1] + t**3 * p3[1]
        out.append((x, y))
    return out


def drop_outline(n=48):
    """闭合路径：尖顶 → 左腰（内收）→ 底部半圆 → 右腰 → 回到尖顶"""
    tip = (256, 50)
    left_anchor = (110, 340)

    left = _cubic(tip, (200, 140), (110, 230), left_anchor, n)

    bottom = []
    for i in range(n + 1):
        a = math.pi - (i / n) * math.pi
        bottom.append((256 + 146 * math.cos(a), 340 + 146 * math.sin(a)))

    right = [(512 - x, y) for (x, y) in reversed(left)]

    return left + bottom[1:] + right



def offset_closed(pts, dist):
    """闭合路径沿法线偏移（首尾循环取邻居，避免开口处的尖刺）"""
    n = len(pts)
    out = []
    for i in range(n):
        px, py = pts[(i - 1) % n]
        nx_, ny_ = pts[(i + 1) % n]
        dx, dy = nx_ - px, ny_ - py
        length = math.hypot(dx, dy) or 1
        ox, oy = -dy / length, dx / length
        out.append((pts[i][0] + ox * dist, pts[i][1] + oy * dist))
    return out


def stroke_closed(d, pts, width, color):
    """把闭合路径画成环带（比 ImageDraw.line 平滑）"""
    half = width / 2
    outer = offset_closed(pts, half)
    inner = offset_closed(pts, -half)
    d.polygon(outer + list(reversed(inner)), fill=color)


def draw_car(d, s=1.0):
    """方正极简小车（坐标直接来自参考 SVG）"""
    def sc(pts):
        return [(x * s, y * s) for (x, y) in pts]

    d.polygon(sc([(215, 370), (228, 345), (272, 345), (295, 370)]), fill=C_CAR)

    d.rounded_rectangle(
        [195 * s, 370 * s, 315 * s, 394 * s],
        radius=4 * s,
        fill=C_CAR,
    )

    # 负空间车窗：用背景色挖
    d.polygon(sc([(228, 365), (233, 350), (252, 350), (252, 365)]), fill=C_BG)
    d.polygon(sc([(258, 365), (258, 350), (272, 350), (277, 365)]), fill=C_BG)

    for cx in (220, 290):
        d.ellipse(
            [cx * s - 11 * s, 394 * s - 11 * s, cx * s + 11 * s, 394 * s + 11 * s],
            fill=C_CAR,
        )
        d.ellipse(
            [cx * s - 4 * s, 394 * s - 4 * s, cx * s + 4 * s, 394 * s + 4 * s],
            fill=C_WHITE,
        )


def draw_icon(size=512, ss=4):
    """ss 倍超采样后缩小，得到平滑边缘（Pillow 直接按目标尺寸画会有锯齿）"""
    big = size * ss
    img = Image.new("RGBA", (big, big), C_BG)
    d = ImageDraw.Draw(img)
    s = big / BASE

    raw = drop_outline()
    pts = [(x * s, y * s) for (x, y) in raw]

    if size < 96:
        d.polygon(pts, fill=C_WHITE)
        return img.resize((size, size), Image.LANCZOS)

    road = max(int(12 * s), 1)

    # 公路（穿过油滴边界，不裁剪）
    d.line([(188 * s, 444 * s), (230 * s, 234 * s)], fill=C_WHITE, width=road)
    d.line([(324 * s, 444 * s), (282 * s, 234 * s)], fill=C_WHITE, width=road)

    if size >= 144:
        # 中间虚线
        dash_w = max(int(8 * s), 1)
        dash, gap = 16 * s, 16 * s
        y = 428 * s
        y_end = 260 * s
        while y > y_end:
            d.line([(256 * s, y), (256 * s, max(y - dash, y_end))],
                   fill=C_WHITE, width=dash_w)
            y -= dash + gap

        draw_car(d, s)

    # 油滴描边：沿路径等宽画线（缩放法做不到上下等宽）
    # 采样点不能太密，否则 Pillow 的 line 在接缝处会有毛刺
    stroke_w = max(int(19 * s), 2)
    d.line(pts + [pts[0]], fill=C_WHITE, width=stroke_w, joint="curve")
    # 尖顶是锐角，两条等宽带子在顶点交叉会留一个 V 形缺口；
    # 补一个半径=半线宽的圆，等效 SVG 的 stroke-linejoin="round"
    tr = stroke_w / 2
    d.ellipse([256 * s - tr, 50 * s - tr, 256 * s + tr, 50 * s + tr], fill=C_WHITE)

    return img.resize((size, size), Image.LANCZOS)


def main():
    for folder, px in {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }.items():
        out_dir = os.path.join(ROOT, "android", "app", "src", "main", "res", folder)
        os.makedirs(out_dir, exist_ok=True)
        icon = draw_icon(px)
        icon.save(os.path.join(out_dir, "ic_launcher.png"), "PNG")
        icon.save(os.path.join(out_dir, "ic_launcher_round.png"), "PNG")
        print(f"  android {folder}: {px}x{px}")

    for path, px in [
        (os.path.join(ROOT, "ohos", "AppScope", "resources", "base", "media", "app_icon.png"), 216),
        (os.path.join(ROOT, "ohos", "entry", "src", "main", "resources", "base", "media", "icon.png"), 216),
    ]:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        draw_icon(px).save(path, "PNG")
        print(f"  ohos {os.path.relpath(path, ROOT)}: {px}x{px}")

    dist = os.path.join(ROOT, "dist")
    os.makedirs(dist, exist_ok=True)
    draw_icon(512).save(os.path.join(dist, "preview_icon_512.png"), "PNG")

    strip = Image.new("RGBA", (620, 240), (245, 245, 245, 255))
    x = 24
    for px in (48, 72, 96, 144, 192):
        small = draw_icon(px)
        strip.paste(small, (x, (240 - px) // 2), small)
        x += px + 24
    strip.save(os.path.join(dist, "preview_icon_sizes.png"), "PNG")

    print("  preview: dist/preview_icon_512.png, preview_icon_sizes.png")
    print("done")


if __name__ == "__main__":
    main()
