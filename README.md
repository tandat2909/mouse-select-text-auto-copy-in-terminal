# term-autocopy

[![Release](https://img.shields.io/github/v/release/tandat2909/mouse-select-text-auto-copy-in-terminal?label=phiên%20bản)](https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases/latest)
[![Lượt cài bản mới nhất](https://img.shields.io/github/downloads/tandat2909/mouse-select-text-auto-copy-in-terminal/latest/install.sh?label=lượt%20cài%20bản%20mới)](https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases/latest)
[![Tổng lượt tải](https://img.shields.io/github/downloads/tandat2909/mouse-select-text-auto-copy-in-terminal/total?label=tổng%20lượt%20tải)](https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases)
[![CI](https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/actions/workflows/ci.yml/badge.svg)](https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/actions/workflows/ci.yml)
[![Platform](https://img.shields.io/badge/Linux-X11%20%7C%20Ubuntu%20Wayland-blue)](#hệ-điều-hành-hỗ-trợ)

> Bôi đen bằng chuột trong terminal là **tự copy vào clipboard** — bấm `Ctrl+V` ở bất kỳ đâu để dán, giống cách Claude Code CLI và nhiều terminal khác đang làm.
>
> *Select text with the mouse in your Linux terminal and it is copied to the clipboard automatically (X11, and Ubuntu/GNOME on Wayland).*

Mặc định trên Linux, bôi đen chỉ đưa chữ vào vùng chọn **PRIMARY** (dán bằng chuột giữa). `term-autocopy` chép luôn sang **CLIPBOARD** nên `Ctrl+V` dùng được ngay, kèm một popup nhỏ báo đã copy.

```
✓ Đã copy (28 ký tự, 4 khoảng trắng)
✓ Đã copy (230 ký tự, 35 khoảng trắng, 5 dòng)
```

## Tính năng

- Chỉ áp dụng cho **cửa sổ terminal** — bôi đen trong trình duyệt hay app khác không ghi đè clipboard.
- Hỗ trợ sẵn: GNOME Terminal, Ptyxis (terminal mặc định Ubuntu 25.10+), GNOME Console, xfce4-terminal, MATE Terminal, Tilix, Terminator, Konsole, kitty, Alacritty, foot, xterm, urxvt, WezTerm, Ghostty, Black Box.
- Chạy được cả **X11** lẫn **Ubuntu / GNOME trên Wayland** (qua GNOME Shell extension) — trình cài đặt tự chọn.
- Popup "✓ Đã copy" hiện cạnh con trỏ chuột, tự tắt sau 1 giây (có thể tắt).
- Nhẹ: chỉ thức dậy khi có thay đổi vùng chọn, gần như 0% CPU.
- Tự khởi động khi đăng nhập.

## Yêu cầu

| Phiên đăng nhập | Cách chạy | Cần có |
|---|---|---|
| **X11 (Xorg)** | Chương trình chạy nền `term-autocopy` | `python3`, PyGObject (GTK 3), `xprop` — trình cài đặt tự cài nếu thiếu |
| **Wayland + GNOME 45+** (Ubuntu 24.04 trở lên) | GNOME Shell extension | Không cần cài thêm gì |

Kiểm tra phiên hiện tại:

```sh
echo $XDG_SESSION_TYPE    # x11 hoặc wayland
gnome-shell --version     # nếu dùng GNOME
```

## Hệ điều hành hỗ trợ

### Ubuntu

| Phiên bản | GNOME | Mặc định | Hỗ trợ |
|---|---|---|---|
| **26.04 LTS** | 50 | Wayland (không còn phiên Xorg) | ✅ extension |
| **25.10** | 49 | Wayland (không còn phiên Xorg) | ✅ extension |
| **24.04 LTS** | 46 | Wayland | ✅ extension — hoặc phiên "Ubuntu on Xorg" dùng bản X11 |
| **22.04 LTS** | 42 | Wayland | ⚠️ chỉ phiên **"Ubuntu on Xorg"** (GNOME 42 quá cũ cho extension) |
| 20.04 LTS | 3.36 | Xorg | ✅ bản X11 |

Ubuntu 22.04: ở màn hình đăng nhập, bấm biểu tượng ⚙️ góc dưới phải → chọn **"Ubuntu on Xorg"** → đăng nhập → chạy lệnh cài.

### ✅ Đã kiểm tra thực tế

| Hệ điều hành | Desktop | Phiên | Cách kiểm tra |
|---|---|---|---|
| Linux Mint 22.3 (Zena) | Cinnamon 6.6 | X11 | Dùng hằng ngày trên máy thật |
| Ubuntu 26.04 LTS | GNOME Shell 50.1 | Wayland | GNOME Shell chạy headless trong Docker, terminal `foot` |
| Ubuntu 25.10 | GNOME Shell 49.0 | Wayland | GNOME Shell chạy headless trong Docker, terminal `foot` |
| Ubuntu 24.04 LTS | GNOME Shell 46.0 | Wayland | GNOME Shell chạy headless trong Docker, terminal `foot` |
| Ubuntu 24.04 LTS | — | — | Trình cài đặt: tự cài thư viện, cài, gỡ (Docker + GitHub Actions) |

Với các bản Ubuntu, bài kiểm tra chạy trên GNOME Shell thật: extension được nạp; bôi đen khi đang ở terminal thì được copy và hiện popup; bôi đen ở ngoài terminal thì không ghi đè clipboard; tắt extension thì ngừng copy. Vùng chọn được tạo bằng lệnh bên trong GNOME thay vì kéo chuột, vì môi trường headless không có chuột.

### 🟡 Dự kiến chạy được (chưa kiểm tra)

**Phiên X11** — trình cài đặt tự cài thư viện cho các distro dưới đây:

| Distro | Trình quản lý gói | Ví dụ |
|---|---|---|
| Debian / Ubuntu | `apt` | Debian 11+, Linux Mint 20+, Pop!_OS, Zorin OS, elementary OS, MX Linux, Kali |
| Fedora / Red Hat | `dnf` | Fedora, Rocky Linux 8–9, AlmaLinux 8–9, RHEL 8–9 |
| Arch | `pacman` | Arch Linux, Manjaro, EndeavourOS, Garuda |
| openSUSE | `zypper` | openSUSE Leap, Tumbleweed (tên gói zypper chưa được kiểm chứng) |

Desktop dùng được với X11: Cinnamon, Xfce, MATE, LXQt/LXDE, Budgie, KDE Plasma (phiên X11), GNOME (phiên "on Xorg"), i3, bspwm, Openbox…

**Phiên Wayland + GNOME 45 trở lên** — cùng extension như Ubuntu: Fedora Workstation 39+, Debian 13, RHEL / Rocky / AlmaLinux 10, Arch với GNOME…

### ↪️ Wayland với desktop khác

- **KDE Plasma (Wayland):** đã có sẵn, không cần cài — chuột phải biểu tượng Clipboard ở khay hệ thống → Cấu hình → bật **"Đồng bộ nội dung của clipboard và vùng chọn"**.
- **Sway, Hyprland và các desktop wlroots:** thêm vào file cấu hình lệnh chạy khi khởi động `wl-paste --primary --watch wl-copy` (gói `wl-clipboard`). Lệnh này áp dụng cho mọi cửa sổ, không riêng terminal.

### ❌ Không hỗ trợ

- GNOME cũ hơn 45 trên Wayland (dùng phiên Xorg thay thế).
- **macOS**, **Windows**, **WSL/WSLg**.
- Máy chủ không có giao diện đồ hoạ (chỉ SSH).

## Cài đặt nhanh

```sh
curl -fsSL https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases/latest/download/install.sh | sh
```

Script tự nhận biết phiên đăng nhập:

**Phiên X11:**

1. Kiểm tra và cài thư viện còn thiếu (có thể hỏi mật khẩu `sudo`).
2. Tải `term-autocopy` từ [GitHub Releases](https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases) và **kiểm tra mã SHA256** — sai mã là dừng, không cài.
3. Cài vào `~/.local/bin/`, tạo file tự khởi động `~/.config/autostart/term-autocopy.desktop`.
4. Chạy tool ngay, không cần đăng xuất.

**Ubuntu / GNOME trên Wayland:**

1. Kiểm tra GNOME Shell từ 45 trở lên.
2. Tải GNOME Shell extension (kiểm tra SHA256), cài vào `~/.local/share/gnome-shell/extensions/term-autocopy@tandat2909.github.io/` và bật lên.
3. **Đăng xuất rồi đăng nhập lại** — Wayland không cho nạp extension mới khi đang chạy.

Không cần `sudo`. Kiểm tra extension sau khi đăng nhập lại: `gnome-extensions info term-autocopy@tandat2909.github.io`

Cài **một phiên bản cụ thể** (xem danh sách ở trang [Releases](https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases)):

```sh
curl -fsSL https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases/latest/download/install.sh | TERM_AUTOCOPY_VERSION=v1.1.0 sh
```

Kiểm tra phiên bản đang cài: `term-autocopy --version` (X11) hoặc `gnome-extensions info term-autocopy@tandat2909.github.io` (Wayland). Chạy lại lệnh cài là **cập nhật** lên bản mới nhất.

Muốn đọc script trước khi chạy:

```sh
curl -fsSL https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases/latest/download/install.sh -o install.sh
less install.sh
sh install.sh
```

## Cài thủ công

```sh
# Ubuntu / Debian / Linux Mint
sudo apt install python3 python3-gi gir1.2-gtk-3.0 x11-utils

git clone https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal.git
cd mouse-select-text-auto-copy-in-terminal
sh install.sh
```

## Gỡ cài đặt

```sh
curl -fsSL https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases/latest/download/install.sh | sh -s -- --uninstall
```

## Tuỳ chỉnh

Hai bản dùng chung các biến môi trường dưới đây.

**Bản X11:** đặt biến trong dòng `Exec=` của file `~/.config/autostart/term-autocopy.desktop`, ví dụ:

```ini
Exec=env TERM_AUTOCOPY_NOTIFY=0 /home/<user>/.local/bin/term-autocopy
```

| Biến | Ý nghĩa |
|---|---|
| `TERM_AUTOCOPY_NOTIFY=0` | Tắt popup "Đã copy", vẫn auto copy |
| `TERM_AUTOCOPY_CLASSES="kitty,alacritty"` | Chỉ áp dụng cho các app có `WM_CLASS` / app id này (X11: xem bằng lệnh `xprop WM_CLASS` rồi click vào cửa sổ) |
| `TERM_AUTOCOPY_CLASSES="*"` | Áp dụng cho mọi cửa sổ |

Thời gian hiện popup và màu sắc: sửa `TOAST_MS` và phần `CSS` trong file `~/.local/bin/term-autocopy`.

Khởi động lại sau khi sửa:

```sh
pkill -f "^python3 .*term-autocopy"; setsid term-autocopy &
```

**Bản Ubuntu / GNOME Wayland:** tạo file `~/.config/environment.d/term-autocopy.conf` rồi đăng xuất và đăng nhập lại:

```ini
TERM_AUTOCOPY_NOTIFY=0
TERM_AUTOCOPY_CLASSES=org.gnome.Ptyxis,kitty
```

Trên Wayland, danh sách dùng **app id** của cửa sổ (ví dụ `org.gnome.Terminal`, `org.gnome.Ptyxis`, `kitty`). Màu popup nằm trong `stylesheet.css` của extension.

## Lưu ý

- **tmux / vim / Claude Code CLI / htop…** bật chế độ chuột nên giữ luôn thao tác bôi đen. Giữ phím **Shift** khi kéo chuột để terminal tự bôi đen, khi đó tool vẫn copy bình thường.
- **Terminal tích hợp của VS Code** không thuộc phạm vi tool; bật `"terminal.integrated.copyOnSelection": true` trong settings của VS Code.

## Phát hành phiên bản mới (dành cho người duy trì)

Dự án dùng [Semantic Versioning](https://semver.org/lang/vi/): `MAJOR.MINOR.PATCH`.

1. Sửa `VERSION = "x.y.z"` trong file `term-autocopy` **và** `"version-name": "x.y.z"` trong `gnome-extension/term-autocopy@tandat2909.github.io/metadata.json`.
2. Chuyển mục `## [Unreleased]` trong `CHANGELOG.md` thành `## [x.y.z] - YYYY-MM-DD`, thêm link so sánh ở cuối file.
3. Commit, tạo tag và push:
   ```sh
   git commit -am "Release vx.y.z"
   git tag -a vx.y.z -m "vx.y.z"
   git push origin main vx.y.z
   ```
4. GitHub Actions (`.github/workflows/release.yml`) tự động: kiểm tra tag khớp `VERSION`, chạy ShellCheck, tạo `SHA256SUMS`, đóng gói extension thành file zip, tạo Release với ghi chú lấy từ `CHANGELOG.md` và đính kèm `term-autocopy`, `install.sh`, `term-autocopy@tandat2909.github.io.shell-extension.zip`, `SHA256SUMS`.

**Về số lượt tải:** badge đếm số lần tải file từ GitHub Releases (mỗi lần cài bằng lệnh một dòng tải `install.sh` một lần). GitHub chỉ cung cấp **tổng số** và **số theo từng phiên bản**, không chia theo tháng. Muốn xem số theo tháng thì ghi lại số liệu định kỳ:

```sh
curl -s https://api.github.com/repos/tandat2909/mouse-select-text-auto-copy-in-terminal/releases \
  | python3 -c "import json,sys; [print(r['tag_name'], a['name'], a['download_count']) for r in json.load(sys.stdin) for a in r['assets']]"
```

## Cách hoạt động

**X11:** tool lắng nghe sự kiện thay đổi vùng chọn PRIMARY của X11 (qua GTK). Khi bạn bôi đen xong (chờ 150 ms để kéo chuột xong), nó kiểm tra cửa sổ đang focus có phải terminal không (dựa vào `WM_CLASS` qua `xprop`), nếu đúng thì đặt nội dung vào CLIPBOARD và hiện popup.

**Wayland:** vì lý do bảo mật, Wayland không cho chương trình chạy nền đọc vùng chọn hay biết cửa sổ nào đang focus. Vì vậy trên GNOME, tính năng được làm thành **GNOME Shell extension** chạy bên trong GNOME Shell: nó nghe sự kiện `owner-changed` của vùng chọn PRIMARY, kiểm tra app id của cửa sổ đang focus, rồi đặt nội dung vào CLIPBOARD và hiện popup — cùng logic với bản X11.

## Cấu trúc dự án

```
term-autocopy                     bản X11 (Python/GTK)
gnome-extension/term-autocopy@tandat2909.github.io/
    extension.js                  bản Wayland (GNOME Shell extension)
    metadata.json, stylesheet.css
install.sh                        trình cài đặt, tự chọn bản phù hợp
```
