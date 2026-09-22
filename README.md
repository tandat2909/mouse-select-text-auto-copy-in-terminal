# term-autocopy

[![Release](https://img.shields.io/github/v/release/tandat2909/mouse-select-text-auto-copy-in-terminal?label=phiên%20bản)](https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases/latest)
[![Lượt cài bản mới nhất](https://img.shields.io/github/downloads/tandat2909/mouse-select-text-auto-copy-in-terminal/latest/term-autocopy?label=lượt%20cài%20bản%20mới)](https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases/latest)
[![Tổng lượt tải](https://img.shields.io/github/downloads/tandat2909/mouse-select-text-auto-copy-in-terminal/total?label=tổng%20lượt%20tải)](https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases)
[![CI](https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/actions/workflows/ci.yml/badge.svg)](https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/actions/workflows/ci.yml)
[![Platform](https://img.shields.io/badge/Linux-X11-blue)](#hệ-điều-hành-hỗ-trợ)

> Bôi đen bằng chuột trong terminal là **tự copy vào clipboard** — bấm `Ctrl+V` ở bất kỳ đâu để dán, giống cách Claude Code CLI và nhiều terminal khác đang làm.
>
> *Select text with the mouse in your Linux terminal and it is copied to the clipboard automatically (X11).*

Mặc định trên Linux, bôi đen chỉ đưa chữ vào vùng chọn **PRIMARY** (dán bằng chuột giữa). `term-autocopy` chép luôn sang **CLIPBOARD** nên `Ctrl+V` dùng được ngay, kèm một popup nhỏ báo đã copy.

```
✓ Đã copy (28 ký tự, 4 khoảng trắng)
✓ Đã copy (230 ký tự, 35 khoảng trắng, 5 dòng)
```

## Tính năng

- Chỉ áp dụng cho **cửa sổ terminal** — bôi đen trong trình duyệt hay app khác không ghi đè clipboard.
- Hỗ trợ sẵn: GNOME Terminal, xfce4-terminal, MATE Terminal, Tilix, Terminator, Konsole, kitty, Alacritty, xterm, urxvt, WezTerm, Ghostty.
- Popup "✓ Đã copy" hiện cạnh con trỏ chuột, tự tắt sau 1 giây (có thể tắt).
- Nhẹ: chỉ thức dậy khi có thay đổi vùng chọn, gần như 0% CPU.
- Tự khởi động khi đăng nhập.

## Yêu cầu

- Linux dùng **X11 (Xorg)** — chưa hỗ trợ Wayland.
- `python3`, PyGObject (GTK 3), `xprop`. Trình cài đặt tự cài nếu thiếu (apt, dnf, pacman, zypper).

Kiểm tra đang dùng X11 hay Wayland:

```sh
echo $XDG_SESSION_TYPE   # cần ra "x11"
```

## Hệ điều hành hỗ trợ

Tool chạy được trên **Linux có phiên đăng nhập X11 (Xorg)**, có Python 3 và GTK 3. Yếu tố quyết định là **X11**, không phải tên distro.

### ✅ Đã kiểm tra thực tế

| Hệ điều hành | Desktop | Phiên | Python / GTK |
|---|---|---|---|
| Linux Mint 22.3 (Zena, nền Ubuntu 24.04) | Cinnamon 6.6 | X11 | Python 3.12, GTK 3.24 |

### 🟡 Dự kiến chạy được (chưa kiểm tra)

Trình cài đặt tự cài thư viện cho các distro dưới đây. Chỉ cần đăng nhập bằng phiên **X11**.

| Distro | Trình quản lý gói | Ví dụ |
|---|---|---|
| Debian / Ubuntu | `apt` | Ubuntu 20.04+, Debian 11+, Linux Mint 20+, Pop!_OS, Zorin OS, elementary OS, MX Linux, Kali |
| Fedora / Red Hat | `dnf` | Fedora, Rocky Linux 8–9, AlmaLinux 8–9, RHEL 8–9 |
| Arch | `pacman` | Arch Linux, Manjaro, EndeavourOS, Garuda |
| openSUSE | `zypper` | openSUSE Leap, Tumbleweed (tên gói zypper chưa được kiểm chứng) |

Distro khác (Alpine, Void, Gentoo, NixOS…): tự cài `python3`, PyGObject (GTK 3), `xprop`, rồi chạy `install.sh`.

**Desktop dùng được** khi chạy phiên X11: Cinnamon, Xfce, MATE, LXQt/LXDE, Budgie, KDE Plasma (phiên X11), GNOME (phiên "on Xorg"), i3, bspwm, Openbox…

### ⚠️ Lưu ý về Wayland

Nhiều distro mới mặc định đăng nhập bằng **Wayland** — tool **không chạy** trên Wayland:

- **Ubuntu 22.04+ và Fedora (bản GNOME), KDE Plasma 6:** mặc định là Wayland. Ở màn hình đăng nhập, bấm biểu tượng ⚙️ và chọn **"Ubuntu on Xorg"**, **"GNOME on Xorg"** hoặc **"Plasma (X11)"**.
- **GNOME 49 trở lên** và **RHEL 10 / Rocky 10 / AlmaLinux 10** đã bỏ phiên X11 → không dùng được, trừ khi cài desktop khác có X11 (Xfce, MATE, Cinnamon…).

Kiểm tra phiên hiện tại: `echo $XDG_SESSION_TYPE` (cần ra `x11`).

### ❌ Không hỗ trợ

- Phiên **Wayland** (xem trên).
- **macOS**, **Windows**, **WSL/WSLg**.
- Máy chủ không có giao diện đồ hoạ (chỉ SSH).

## Cài đặt nhanh

```sh
curl -fsSL https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases/latest/download/install.sh | sh
```

Script sẽ:

1. Kiểm tra và cài thư viện còn thiếu (có thể hỏi mật khẩu `sudo`).
2. Tải `term-autocopy` từ [GitHub Releases](https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases) và **kiểm tra mã SHA256** — sai mã là dừng, không cài.
3. Cài vào `~/.local/bin/`.
4. Tạo file tự khởi động `~/.config/autostart/term-autocopy.desktop`.
5. Chạy tool ngay, không cần đăng xuất.

Cài **một phiên bản cụ thể** (xem danh sách ở trang [Releases](https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases)):

```sh
curl -fsSL https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases/latest/download/install.sh | TERM_AUTOCOPY_VERSION=v1.0.0 sh
```

Kiểm tra phiên bản đang cài: `term-autocopy --version`. Chạy lại lệnh cài là **cập nhật** lên bản mới nhất.

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

Đặt biến môi trường trong dòng `Exec=` của file `~/.config/autostart/term-autocopy.desktop`, ví dụ:

```ini
Exec=env TERM_AUTOCOPY_NOTIFY=0 /home/<user>/.local/bin/term-autocopy
```

| Biến | Ý nghĩa |
|---|---|
| `TERM_AUTOCOPY_NOTIFY=0` | Tắt popup "Đã copy", vẫn auto copy |
| `TERM_AUTOCOPY_CLASSES="kitty,alacritty"` | Chỉ áp dụng cho các app có `WM_CLASS` này (xem bằng lệnh `xprop WM_CLASS` rồi click vào cửa sổ) |
| `TERM_AUTOCOPY_CLASSES="*"` | Áp dụng cho mọi cửa sổ |

Thời gian hiện popup và màu sắc: sửa `TOAST_MS` và phần `CSS` trong file `~/.local/bin/term-autocopy`.

Khởi động lại sau khi sửa:

```sh
pkill -f "^python3 .*term-autocopy"; setsid term-autocopy &
```

## Lưu ý

- **tmux / vim / Claude Code CLI / htop…** bật chế độ chuột nên giữ luôn thao tác bôi đen. Giữ phím **Shift** khi kéo chuột để terminal tự bôi đen, khi đó tool vẫn copy bình thường.
- **Terminal tích hợp của VS Code** không thuộc phạm vi tool; bật `"terminal.integrated.copyOnSelection": true` trong settings của VS Code.

## Phát hành phiên bản mới (dành cho người duy trì)

Dự án dùng [Semantic Versioning](https://semver.org/lang/vi/): `MAJOR.MINOR.PATCH`.

1. Sửa `VERSION = "x.y.z"` trong file `term-autocopy`.
2. Chuyển mục `## [Unreleased]` trong `CHANGELOG.md` thành `## [x.y.z] - YYYY-MM-DD`, thêm link so sánh ở cuối file.
3. Commit, tạo tag và push:
   ```sh
   git commit -am "Release vx.y.z"
   git tag -a vx.y.z -m "vx.y.z"
   git push origin main vx.y.z
   ```
4. GitHub Actions (`.github/workflows/release.yml`) tự động: kiểm tra tag khớp `VERSION`, chạy ShellCheck, tạo `SHA256SUMS`, tạo Release với ghi chú lấy từ `CHANGELOG.md` và đính kèm `term-autocopy`, `install.sh`, `SHA256SUMS`.

**Về số lượt tải:** badge đếm số lần tải file từ GitHub Releases (mỗi lần cài tải `term-autocopy` một lần). GitHub chỉ cung cấp **tổng số** và **số theo từng phiên bản**, không chia theo tháng. Muốn xem số theo tháng thì ghi lại số liệu định kỳ:

```sh
curl -s https://api.github.com/repos/tandat2909/mouse-select-text-auto-copy-in-terminal/releases \
  | python3 -c "import json,sys; [print(r['tag_name'], a['name'], a['download_count']) for r in json.load(sys.stdin) for a in r['assets']]"
```

## Cách hoạt động

Tool lắng nghe sự kiện thay đổi vùng chọn PRIMARY của X11 (qua GTK). Khi bạn bôi đen xong (chờ 150 ms để kéo chuột xong), nó kiểm tra cửa sổ đang focus có phải terminal không (dựa vào `WM_CLASS` qua `xprop`), nếu đúng thì đặt nội dung vào CLIPBOARD và hiện popup.
