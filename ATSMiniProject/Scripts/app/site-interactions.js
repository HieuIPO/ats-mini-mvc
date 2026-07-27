(function () {
    "use strict";

    function eyeIcon(isVisible) {
        if (isVisible) {
            return "<svg viewBox=\"0 0 24 24\" aria-hidden=\"true\"><path d=\"M3 3l18 18M10.6 10.7a2 2 0 002.7 2.7M9.9 4.2A10.8 10.8 0 0112 4c5 0 8.5 4 9.5 6.2a4.3 4.3 0 010 3.6 12.2 12.2 0 01-2 3M6.6 6.6A13.3 13.3 0 002.5 10.2a4.3 4.3 0 000 3.6C3.5 16 7 20 12 20a10.8 10.8 0 004.1-.8\"/></svg>";
        }

        return "<svg viewBox=\"0 0 24 24\" aria-hidden=\"true\"><path d=\"M2.5 10.2a4.3 4.3 0 000 3.6C3.5 16 7 20 12 20s8.5-4 9.5-6.2a4.3 4.3 0 000-3.6C20.5 8 17 4 12 4S3.5 8 2.5 10.2zM12 15.5a3.5 3.5 0 110-7 3.5 3.5 0 010 7z\"/></svg>";
    }

    function initializePasswordToggles() {
        var passwordInputs = document.querySelectorAll("input[type=\"password\"]");
        passwordInputs.forEach(function (input) {
            if (input.closest(".password-input-wrap")) {
                return;
            }

            var wrapper = document.createElement("div");
            wrapper.className = "password-input-wrap";
            input.parentNode.insertBefore(wrapper, input);
            wrapper.appendChild(input);

            var button = document.createElement("button");
            button.type = "button";
            button.className = "password-toggle";
            button.setAttribute("aria-label", "Hiện mật khẩu");
            button.setAttribute("aria-pressed", "false");
            button.title = "Hiện mật khẩu";
            button.innerHTML = eyeIcon(false);
            wrapper.appendChild(button);

            button.addEventListener("click", function () {
                var showPassword = input.type === "password";
                input.type = showPassword ? "text" : "password";
                button.setAttribute("aria-label", showPassword ? "Ẩn mật khẩu" : "Hiện mật khẩu");
                button.setAttribute("aria-pressed", showPassword ? "true" : "false");
                button.title = showPassword ? "Ẩn mật khẩu" : "Hiện mật khẩu";
                button.innerHTML = eyeIcon(showPassword);
                input.focus({ preventScroll: true });
            });
        });
    }

    function initializeHeroCarousel() {
        var hero = document.querySelector("[data-hero-carousel]");
        if (!hero) {
            return;
        }

        var slides = Array.prototype.slice.call(hero.querySelectorAll(".career-hero-slide"));
        var controls = Array.prototype.slice.call(hero.querySelectorAll("[data-hero-index]"));
        var toggle = hero.querySelector("[data-hero-toggle]");
        if (slides.length < 2 || controls.length !== slides.length) {
            return;
        }

        var activeIndex = 0;
        var timer = null;
        var manuallyPaused = false;

        function pauseIcon() {
            return "<svg viewBox=\"0 0 24 24\" aria-hidden=\"true\"><path d=\"M8 5v14M16 5v14\"/></svg>";
        }

        function playIcon() {
            return "<svg viewBox=\"0 0 24 24\" aria-hidden=\"true\"><path d=\"M8 5l11 7-11 7V5z\"/></svg>";
        }

        function updateToggle() {
            if (!toggle) {
                return;
            }

            var label = manuallyPaused
                ? "Tiếp tục trình chiếu ảnh"
                : "Tạm dừng trình chiếu ảnh";
            toggle.setAttribute("aria-label", label);
            toggle.setAttribute("title", label);
            toggle.setAttribute("aria-pressed", manuallyPaused ? "true" : "false");
            toggle.innerHTML = manuallyPaused ? playIcon() : pauseIcon();
        }

        function activate(index) {
            activeIndex = (index + slides.length) % slides.length;
            slides.forEach(function (slide, slideIndex) {
                slide.classList.toggle("is-active", slideIndex === activeIndex);
            });
            controls.forEach(function (control, controlIndex) {
                var isActive = controlIndex === activeIndex;
                control.classList.toggle("is-active", isActive);
                if (isActive) {
                    control.setAttribute("aria-current", "true");
                } else {
                    control.removeAttribute("aria-current");
                }
            });
        }

        function stop() {
            if (timer) {
                window.clearInterval(timer);
                timer = null;
            }
        }

        function start() {
            stop();
            if (!manuallyPaused && !document.hidden) {
                timer = window.setInterval(function () {
                    activate(activeIndex + 1);
                }, 6500);
            }
        }

        controls.forEach(function (control) {
            control.addEventListener("click", function () {
                activate(parseInt(control.getAttribute("data-hero-index"), 10));
                start();
            });
        });

        if (toggle) {
            toggle.addEventListener("click", function () {
                manuallyPaused = !manuallyPaused;
                updateToggle();
                start();
            });
        }

        document.addEventListener("visibilitychange", start);
        updateToggle();
        start();
    }

    function initializeScrollReveal() {
        var selector = [
            "[data-reveal]",
            ".career-stats-grid > *",
            ".section-heading",
            ".featured-job",
            ".career-cta-inner > *",
            ".job-card",
            ".application-row",
            ".candidate-panel",
            ".ats-table-card",
            ".admin-panel",
            ".admin-filter-panel",
            ".page-header"
        ].join(",");
        var targets = Array.prototype.slice.call(document.querySelectorAll(selector));
        if (!targets.length) {
            return;
        }

        if (!("IntersectionObserver" in window)) {
            targets.forEach(function (target) {
                target.classList.add("scroll-reveal", "is-visible");
            });
            return;
        }

        var observer = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) {
                    entry.target.classList.add("is-visible");
                    observer.unobserve(entry.target);
                }
            });
        }, {
            threshold: 0.12,
            rootMargin: "0px 0px -36px 0px"
        });

        targets.forEach(function (target, index) {
            target.classList.add("scroll-reveal");
            target.style.setProperty("--reveal-delay", Math.min(index % 4, 3) * 70 + "ms");
            observer.observe(target);
        });
    }

    function initializeAvatarPreview() {
        var input = document.querySelector("[data-avatar-input]");
        var preview = document.querySelector("[data-avatar-preview]");
        if (!input || !preview) {
            return;
        }

        var fallback = document.querySelector("[data-avatar-fallback]");
        var fileName = document.querySelector("[data-avatar-file-name]");
        var objectUrl = null;

        input.addEventListener("change", function () {
            var file = input.files && input.files[0];
            if (!file) {
                return;
            }

            if (objectUrl) {
                URL.revokeObjectURL(objectUrl);
            }
            objectUrl = URL.createObjectURL(file);
            preview.src = objectUrl;
            preview.classList.remove("d-none");
            if (fallback) {
                fallback.classList.add("d-none");
            }
            if (fileName) {
                fileName.textContent = file.name;
            }
        });
    }

    function initializeNavbarAvatar() {
        var avatar = document.querySelector("[data-candidate-avatar-image]");
        if (!avatar) {
            return;
        }

        avatar.addEventListener("error", function () {
            avatar.hidden = true;
        });
    }

    function initializeCvFileName() {
        var input = document.querySelector("[data-cv-input]");
        var fileName = document.querySelector("[data-cv-file-name]");
        if (!input || !fileName) {
            return;
        }

        input.addEventListener("change", function () {
            var file = input.files && input.files[0];
            fileName.textContent = file ? file.name : "Chưa chọn tệp";
        });
    }

    function initializeAutoDismissAlerts() {
        var alerts = document.querySelectorAll("[data-auto-dismiss=\"true\"]");
        alerts.forEach(function (alertElement) {
            window.setTimeout(function () {
                if (!document.body.contains(alertElement)) {
                    return;
                }

                if (window.bootstrap && window.bootstrap.Alert) {
                    window.bootstrap.Alert.getOrCreateInstance(alertElement).close();
                } else {
                    alertElement.remove();
                }
            }, 5000);
        });
    }

    function initializeAdminSidebar() {
        var shell = document.querySelector(".admin-shell");
        var toggle = document.querySelector("[data-sidebar-toggle]");
        if (!shell || !toggle) {
            return;
        }

        var storageKey = "ats-admin-sidebar-collapsed";
        var isCollapsed = false;
        try {
            isCollapsed = window.localStorage.getItem(storageKey) === "true";
        } catch (error) {
            isCollapsed = false;
        }

        function applyState() {
            shell.classList.toggle("sidebar-collapsed", isCollapsed);
            toggle.setAttribute("aria-expanded", isCollapsed ? "false" : "true");
            toggle.setAttribute("aria-label", isCollapsed ? "Mở rộng thanh chức năng" : "Thu gọn thanh chức năng");
            toggle.title = isCollapsed ? "Mở rộng thanh chức năng" : "Thu gọn thanh chức năng";
        }

        toggle.addEventListener("click", function () {
            isCollapsed = !isCollapsed;
            applyState();
            try {
                window.localStorage.setItem(storageKey, String(isCollapsed));
            } catch (error) {
                return;
            }
        });

        applyState();
    }

    function initializeActionMenus() {
        var menus = Array.prototype.slice.call(document.querySelectorAll(".job-actions-dropdown"));
        if (!menus.length) {
            return;
        }

        menus.forEach(function (menu) {
            menu.addEventListener("toggle", function () {
                if (!menu.open) {
                    return;
                }

                menus.forEach(function (otherMenu) {
                    if (otherMenu !== menu) {
                        otherMenu.removeAttribute("open");
                    }
                });
            });
        });

        document.addEventListener("click", function (event) {
            if (event.target.closest(".job-actions-dropdown")) {
                return;
            }

            menus.forEach(function (menu) {
                menu.removeAttribute("open");
            });
        });
    }

    function initializeConfirmDialogs() {
        var dialog = document.querySelector("[data-confirm-dialog]");
        if (!dialog) {
            return;
        }

        var title = dialog.querySelector("[data-confirm-title]");
        var message = dialog.querySelector("[data-confirm-message]");
        var cancelButton = dialog.querySelector("[data-confirm-cancel]");
        var submitButton = dialog.querySelector("[data-confirm-submit]");
        var pendingForm = null;
        var approvedForm = null;

        function closeDialog() {
            pendingForm = null;
            if (typeof dialog.close === "function") {
                dialog.close();
            } else {
                dialog.removeAttribute("open");
            }
        }

        document.addEventListener("submit", function (event) {
            var form = event.target;
            if (!form.matches("[data-confirm=\"true\"]")) {
                return;
            }

            if (approvedForm === form) {
                approvedForm = null;
                return;
            }

            event.preventDefault();
            pendingForm = form;
            title.textContent = form.getAttribute("data-confirm-title") || "Xác nhận thao tác";
            message.textContent = form.getAttribute("data-confirm-message") || "Bạn có chắc chắn muốn thực hiện thao tác này?";
            submitButton.textContent = form.getAttribute("data-confirm-action") || "Xác nhận";
            submitButton.classList.toggle("btn-danger", form.getAttribute("data-confirm-danger") === "true");
            submitButton.classList.toggle("btn-primary", form.getAttribute("data-confirm-danger") !== "true");

            if (typeof dialog.showModal === "function") {
                dialog.showModal();
            } else {
                dialog.setAttribute("open", "open");
            }
            cancelButton.focus();
        });

        cancelButton.addEventListener("click", closeDialog);
        dialog.addEventListener("cancel", function () {
            pendingForm = null;
        });
        submitButton.addEventListener("click", function () {
            if (!pendingForm) {
                return;
            }

            var form = pendingForm;
            approvedForm = form;
            closeDialog();
            if (typeof form.requestSubmit === "function") {
                form.requestSubmit();
            } else {
                form.submit();
            }
        });
    }

    function savedJobButtons(form) {
        var buttons = Array.prototype.slice.call(form.querySelectorAll(".job-save-button"));
        if (form.id) {
            buttons = buttons.concat(Array.prototype.slice.call(
                document.querySelectorAll('[form="' + form.id + '"]')
            ));
        }

        return buttons;
    }

    function updateSavedJobButton(button, saved) {
        var jobTitle = button.getAttribute("data-job-title") || "tin tuyển dụng";
        var visibleLabel = saved ? "Bỏ lưu" : "Lưu tin";
        button.classList.toggle("is-saved", saved);
        button.setAttribute("aria-pressed", saved ? "true" : "false");
        button.setAttribute("aria-label", visibleLabel + " " + jobTitle);
        button.setAttribute("title", visibleLabel);

        var hiddenLabel = button.querySelector(".visually-hidden");
        if (hiddenLabel) {
            hiddenLabel.textContent = visibleLabel;
        }
    }

    function announceSavedJob(message, isError) {
        var feedback = document.querySelector("[data-saved-job-feedback]");
        if (!feedback) {
            feedback = document.createElement("div");
            feedback.className = "job-save-feedback";
            feedback.setAttribute("data-saved-job-feedback", "");
            feedback.setAttribute("role", "status");
            feedback.setAttribute("aria-live", "polite");
            document.body.appendChild(feedback);
        }

        feedback.classList.toggle("is-error", Boolean(isError));
        feedback.textContent = message;
        feedback.classList.add("is-visible");
        window.clearTimeout(feedback.hideTimer);
        feedback.hideTimer = window.setTimeout(function () {
            feedback.classList.remove("is-visible");
        }, 2200);
    }

    function initializeSavedJobForms() {
        if (!window.fetch) {
            return;
        }

        document.addEventListener("submit", function (event) {
            var form = event.target;
            if (!form.matches("[data-saved-job-form]") || form.getAttribute("data-busy") === "true") {
                return;
            }

            event.preventDefault();
            form.setAttribute("data-busy", "true");
            var buttons = savedJobButtons(form);
            buttons.forEach(function (button) {
                button.disabled = true;
                button.classList.add("is-loading");
                button.setAttribute("aria-busy", "true");
            });

            fetch(form.action, {
                method: "POST",
                body: new FormData(form),
                credentials: "same-origin",
                headers: {
                    "X-Requested-With": "XMLHttpRequest",
                    "Accept": "application/json"
                }
            }).then(function (response) {
                if (!response.ok) {
                    throw new Error("Saved job request failed.");
                }

                return response.json();
            }).then(function (result) {
                var saved = Boolean(result.saved);
                form.action = saved
                    ? form.getAttribute("data-unsave-url")
                    : form.getAttribute("data-save-url");
                buttons.forEach(function (button) {
                    updateSavedJobButton(button, saved);
                });

                if (!saved && form.getAttribute("data-remove-card-on-unsave") === "true") {
                    var card = form.closest(".candidate-saved-job-card");
                    if (card) {
                        card.remove();
                        var count = document.querySelector("[data-saved-jobs-count]");
                        if (count) {
                            var currentCount = parseInt(count.textContent, 10);
                            count.textContent = Number.isNaN(currentCount)
                                ? document.querySelectorAll(".candidate-saved-job-card").length
                                : Math.max(0, currentCount - 1);
                        }
                    }
                }

                announceSavedJob(saved ? "Đã lưu tin tuyển dụng" : "Đã bỏ lưu tin tuyển dụng", false);
            }).catch(function () {
                announceSavedJob("Không thể cập nhật tin đã lưu. Vui lòng thử lại.", true);
            }).then(function () {
                form.removeAttribute("data-busy");
                buttons.forEach(function (button) {
                    button.disabled = false;
                    button.classList.remove("is-loading");
                    button.removeAttribute("aria-busy");
                });
            });
        });
    }

    document.addEventListener("DOMContentLoaded", function () {
        initializePasswordToggles();
        initializeHeroCarousel();
        initializeScrollReveal();
        initializeAvatarPreview();
        initializeNavbarAvatar();
        initializeCvFileName();
        initializeAutoDismissAlerts();
        initializeAdminSidebar();
        initializeActionMenus();
        initializeConfirmDialogs();
        initializeSavedJobForms();
    });
}());
