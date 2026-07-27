(function () {
    "use strict";

    function initializeEditor(editor) {
        var surface = editor.querySelector("[data-editor-surface]");
        var input = editor.querySelector("[data-editor-input]");
        var counter = editor.querySelector("[data-editor-count]");
        var form = editor.closest("form");
        if (!surface || !input || !form) {
            return;
        }

        function syncValue() {
            var length = surface.textContent.trim().length;
            input.value = surface.innerHTML.trim();
            if (counter) {
                counter.textContent = length.toLocaleString("vi-VN") + " / 20.000";
                counter.classList.toggle("is-over-limit", length > 20000);
            }
        }

        editor.querySelectorAll("[data-editor-command]").forEach(function (button) {
            button.addEventListener("mousedown", function (event) {
                event.preventDefault();
            });
            button.addEventListener("click", function () {
                surface.focus();
                document.execCommand(button.getAttribute("data-editor-command"), false, null);
                syncValue();
            });
        });

        editor.querySelectorAll("[data-editor-block]").forEach(function (button) {
            button.addEventListener("mousedown", function (event) {
                event.preventDefault();
            });
            button.addEventListener("click", function () {
                surface.focus();
                document.execCommand("formatBlock", false, button.getAttribute("data-editor-block"));
                syncValue();
            });
        });

        surface.addEventListener("input", syncValue);
        surface.addEventListener("paste", function (event) {
            event.preventDefault();
            var clipboard = event.clipboardData || window.clipboardData;
            document.execCommand("insertText", false, clipboard ? clipboard.getData("text/plain") : "");
        });
        surface.addEventListener("drop", function (event) {
            event.preventDefault();
        });
        form.addEventListener("submit", syncValue);
        syncValue();
    }

    document.addEventListener("DOMContentLoaded", function () {
        document.querySelectorAll("[data-rich-editor]").forEach(initializeEditor);
    });
}());
