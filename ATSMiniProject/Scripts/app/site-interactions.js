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

    document.addEventListener("DOMContentLoaded", function () {
        initializePasswordToggles();
        initializeHeroCarousel();
        initializeScrollReveal();
        initializeAvatarPreview();
        initializeNavbarAvatar();
    });
}());
