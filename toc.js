// Populate the sidebar
//
// This is a script, and not included directly in the page, to control the total size of the book.
// The TOC contains an entry for each page, so if each page includes a copy of the TOC,
// the total size of the page becomes O(n**2).
class MDBookSidebarScrollbox extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = '<ol class="chapter"><li class="chapter-item "><a href="index.html">Home</a></li><li class="chapter-item affix "><li class="part-title">src</li><li class="chapter-item "><a href="src/interfaces/index.html">❱ interfaces</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="src/interfaces/IOVMClient.sol/interface.IOVMClient.html">IOVMClient</a></li><li class="chapter-item "><a href="src/interfaces/IOVMGateway.sol/interface.IOVMGateway.html">IOVMGateway</a></li></ol></li><li class="chapter-item "><a href="src/libraries/index.html">❱ libraries</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="src/libraries/DataTypes.sol/enum.ExecMode.html">ExecMode</a></li><li class="chapter-item "><a href="src/libraries/DataTypes.sol/enum.GPUModel.html">GPUModel</a></li><li class="chapter-item "><a href="src/libraries/DataTypes.sol/struct.Requirement.html">Requirement</a></li><li class="chapter-item "><a href="src/libraries/DataTypes.sol/enum.Arch.html">Arch</a></li><li class="chapter-item "><a href="src/libraries/DataTypes.sol/struct.Specification.html">Specification</a></li><li class="chapter-item "><a href="src/libraries/DataTypes.sol/struct.Commitment.html">Commitment</a></li><li class="chapter-item "><a href="src/libraries/Errors.sol/error.TransferFailed.html">TransferFailed</a></li><li class="chapter-item "><a href="src/libraries/Errors.sol/error.RequestNotExpired.html">RequestNotExpired</a></li><li class="chapter-item "><a href="src/libraries/Errors.sol/error.InvalidRequesterOrCallback.html">InvalidRequesterOrCallback</a></li><li class="chapter-item "><a href="src/libraries/Errors.sol/error.CallbackAddressIsNotContract.html">CallbackAddressIsNotContract</a></li><li class="chapter-item "><a href="src/libraries/Events.sol/event.TaskRequestSent.html">TaskRequestSent</a></li><li class="chapter-item "><a href="src/libraries/Events.sol/event.TaskRequestCanceled.html">TaskRequestCanceled</a></li><li class="chapter-item "><a href="src/libraries/Events.sol/event.TaskResponseSet.html">TaskResponseSet</a></li><li class="chapter-item "><a href="src/libraries/Events.sol/event.SpecificationUpdated.html">SpecificationUpdated</a></li><li class="chapter-item "><a href="src/libraries/Events.sol/event.ResponseRecorded.html">ResponseRecorded</a></li></ol></li><li class="chapter-item "><a href="src/OVMClient.sol/abstract.OVMClient.html">OVMClient</a></li><li class="chapter-item "><a href="src/OVMGateway.sol/contract.OVMGateway.html">OVMGateway</a></li></ol>';
        // Set the current, active page, and reveal it if it's hidden
        let current_page = document.location.href.toString();
        if (current_page.endsWith("/")) {
            current_page += "index.html";
        }
        var links = Array.prototype.slice.call(this.querySelectorAll("a"));
        var l = links.length;
        for (var i = 0; i < l; ++i) {
            var link = links[i];
            var href = link.getAttribute("href");
            if (href && !href.startsWith("#") && !/^(?:[a-z+]+:)?\/\//.test(href)) {
                link.href = path_to_root + href;
            }
            // The "index" page is supposed to alias the first chapter in the book.
            if (link.href === current_page || (i === 0 && path_to_root === "" && current_page.endsWith("/index.html"))) {
                link.classList.add("active");
                var parent = link.parentElement;
                if (parent && parent.classList.contains("chapter-item")) {
                    parent.classList.add("expanded");
                }
                while (parent) {
                    if (parent.tagName === "LI" && parent.previousElementSibling) {
                        if (parent.previousElementSibling.classList.contains("chapter-item")) {
                            parent.previousElementSibling.classList.add("expanded");
                        }
                    }
                    parent = parent.parentElement;
                }
            }
        }
        // Track and set sidebar scroll position
        this.addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
                sessionStorage.setItem('sidebar-scroll', this.scrollTop);
            }
        }, { passive: true });
        var sidebarScrollTop = sessionStorage.getItem('sidebar-scroll');
        sessionStorage.removeItem('sidebar-scroll');
        if (sidebarScrollTop) {
            // preserve sidebar scroll position when navigating via links within sidebar
            this.scrollTop = sidebarScrollTop;
        } else {
            // scroll sidebar to current active section when navigating via "next/previous chapter" buttons
            var activeSection = document.querySelector('#sidebar .active');
            if (activeSection) {
                activeSection.scrollIntoView({ block: 'center' });
            }
        }
        // Toggle buttons
        var sidebarAnchorToggles = document.querySelectorAll('#sidebar a.toggle');
        function toggleSection(ev) {
            ev.currentTarget.parentElement.classList.toggle('expanded');
        }
        Array.from(sidebarAnchorToggles).forEach(function (el) {
            el.addEventListener('click', toggleSection);
        });
    }
}
window.customElements.define("mdbook-sidebar-scrollbox", MDBookSidebarScrollbox);