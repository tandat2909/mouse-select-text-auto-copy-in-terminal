// Terminal Auto Copy — GNOME Shell extension (GNOME 45+).
//
// Bôi đen bằng chuột trong terminal -> tự copy vào clipboard (Ctrl+V).
// Chạy bên trong GNOME Shell nên dùng được trên Wayland, nơi chương trình
// chạy nền không được phép đọc vùng chọn hay biết cửa sổ nào đang focus.
//
// Tuỳ chỉnh bằng biến môi trường của phiên đăng nhập, ví dụ trong
// ~/.config/environment.d/term-autocopy.conf:
//     TERM_AUTOCOPY_CLASSES=org.gnome.Ptyxis,kitty   (hoặc * cho mọi cửa sổ)
//     TERM_AUTOCOPY_NOTIFY=0                          (tắt popup "Đã copy")

import GLib from 'gi://GLib';
import Meta from 'gi://Meta';
import St from 'gi://St';
import Clutter from 'gi://Clutter';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

// WM_CLASS (X11) hoặc app_id (Wayland) của các terminal phổ biến, viết thường
const DEFAULT_CLASSES = [
    'org.gnome.terminal', 'gnome-terminal-server', 'gnome-terminal',
    'org.gnome.ptyxis', 'org.gnome.ptyxis.devel', 'ptyxis',
    'org.gnome.console', 'kgx',
    'xfce4-terminal', 'mate-terminal', 'com.gexperts.tilix', 'tilix',
    'terminator', 'org.kde.konsole', 'konsole', 'kitty', 'alacritty',
    'foot', 'footclient', 'xterm', 'urxvt', 'org.wezfurlong.wezterm', 'wezterm',
    'com.mitchellh.ghostty', 'com.raggesilver.blackbox', 'blackbox',
];
const DEBOUNCE_MS = 150; // chờ người dùng thả chuột / ngừng kéo
const TOAST_MS = 1000;

export default class TermAutoCopyExtension extends Extension {
    enable() {
        const env = GLib.getenv('TERM_AUTOCOPY_CLASSES');
        this._classes = new Set(
            (env ? env.split(',') : DEFAULT_CLASSES)
                .map(c => c.trim().toLowerCase())
                .filter(c => c.length > 0));
        this._notify = GLib.getenv('TERM_AUTOCOPY_NOTIFY') !== '0';

        this._clipboard = St.Clipboard.get_default();
        this._selection = global.display.get_selection();
        this._ownerChangedId = this._selection.connect('owner-changed', (_sel, type) => {
            if (type === Meta.SelectionType.SELECTION_PRIMARY)
                this._schedule();
        });
    }

    disable() {
        if (this._ownerChangedId)
            this._selection.disconnect(this._ownerChangedId);
        this._ownerChangedId = 0;
        this._selection = null;
        if (this._debounceId)
            GLib.source_remove(this._debounceId);
        this._debounceId = 0;
        this._hideToast();
        this._clipboard = null;
        this._classes = null;
    }

    _schedule() {
        if (this._debounceId)
            GLib.source_remove(this._debounceId);
        this._debounceId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, DEBOUNCE_MS, () => {
            this._debounceId = 0;
            this._copy();
            return GLib.SOURCE_REMOVE;
        });
    }

    _isTerminal(win) {
        if (this._classes.has('*'))
            return true;
        if (!win)
            return false;
        const ids = [
            win.get_wm_class(),
            win.get_wm_class_instance(),
            win.get_gtk_application_id(),
            win.get_sandboxed_app_id?.(),
        ];
        return ids.some(id => id && this._classes.has(id.toLowerCase()));
    }

    _copy() {
        if (!this._isTerminal(global.display.focus_window))
            return;
        this._clipboard.get_text(St.ClipboardType.PRIMARY, (_clip, text) => {
            if (!text || !this._clipboard)
                return;
            this._clipboard.set_text(St.ClipboardType.CLIPBOARD, text);
            console.debug(`term-autocopy: copied ${text.length} chars`);
            if (this._notify)
                this._showToast(text);
        });
    }

    _showToast(text) {
        this._hideToast();

        const chars = [...text];
        const spaces = chars.filter(c => /\s/.test(c) && c !== '\n' && c !== '\r').length;
        const lines = text.split('\n').length;
        let info = `${chars.length} ký tự, ${spaces} khoảng trắng`;
        if (lines > 1)
            info += `, ${lines} dòng`;

        const label = new St.Label({
            text: `✓ Đã copy (${info})`,
            style_class: 'term-autocopy-toast',
        });
        Main.layoutManager.uiGroup.add_child(label);

        const [px, py] = global.get_pointer();
        const monitor = Main.layoutManager.currentMonitor;
        const [, width] = label.get_preferred_width(-1);
        const [, height] = label.get_preferred_height(-1);
        let x = px + 14;
        let y = py + 18;
        if (monitor) {
            x = Math.min(x, monitor.x + monitor.width - width - 4);
            y = Math.min(y, monitor.y + monitor.height - height - 4);
        }
        label.set_position(Math.max(0, x), Math.max(0, y));

        this._toast = label;
        this._toastId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, TOAST_MS, () => {
            this._toastId = 0;
            label.ease({
                opacity: 0,
                duration: 200,
                mode: Clutter.AnimationMode.EASE_OUT_QUAD,
                onComplete: () => {
                    if (this._toast === label)
                        this._hideToast();
                },
            });
            return GLib.SOURCE_REMOVE;
        });
    }

    _hideToast() {
        if (this._toastId)
            GLib.source_remove(this._toastId);
        this._toastId = 0;
        this._toast?.destroy();
        this._toast = null;
    }
}
