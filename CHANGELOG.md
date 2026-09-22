# Changelog

Mọi thay đổi đáng chú ý của dự án được ghi ở đây.
Định dạng theo [Keep a Changelog](https://keepachangelog.com/vi/1.1.0/), phiên bản theo [Semantic Versioning](https://semver.org/lang/vi/).

## [Unreleased]

## [1.0.0] - 2026-09-22

### Thêm mới
- Bôi đen bằng chuột trong terminal là tự copy vào clipboard (`Ctrl+V` dán được ngay).
- Chỉ áp dụng cho cửa sổ terminal; hỗ trợ sẵn GNOME Terminal, xfce4-terminal, MATE Terminal, Tilix, Terminator, Konsole, kitty, Alacritty, xterm, urxvt, WezTerm, Ghostty.
- Popup "✓ Đã copy" cạnh con trỏ chuột, hiển thị số ký tự, số khoảng trắng và số dòng.
- Tuỳ chỉnh qua biến môi trường `TERM_AUTOCOPY_CLASSES`, `TERM_AUTOCOPY_NOTIFY`.
- Lệnh `term-autocopy --version`.
- Trình cài đặt một dòng `install.sh`: tự cài thư viện (apt, dnf, pacman, zypper), kiểm tra SHA256, tự khởi động khi đăng nhập, gỡ bằng `--uninstall`, chọn phiên bản bằng `TERM_AUTOCOPY_VERSION`.

[Unreleased]: https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/tandat2909/mouse-select-text-auto-copy-in-terminal/releases/tag/v1.0.0
