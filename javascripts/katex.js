/*
 * KaTeX 自动渲染 + 全局宏
 * 改这里可以给所有页面加自定义命令，例如 $\xor$、$\R$
 */
const katexMacros = {
  "\\R": "\\mathbb{R}",
  "\\N": "\\mathbb{N}",
  "\\Z": "\\mathbb{Z}",
  "\\Q": "\\mathbb{Q}",
  "\\C": "\\mathbb{C}",
  "\\eps": "\\varepsilon",
  "\\xor": "\\oplus",
  "\\bigO": "\\mathcal{O}",
  "\\st": "\\;\\text{s.t.}\\;",
};

function renderMath() {
  if (typeof renderMathInElement === "undefined") return;
  renderMathInElement(document.body, {
    delimiters: [
      { left: "$$", right: "$$", display: true },
      { left: "\\[", right: "\\]", display: true },
      { left: "$", right: "$", display: false },
      { left: "\\(", right: "\\)", display: false },
    ],
    ignoredTags: [
      "script",
      "noscript",
      "style",
      "textarea",
      "pre",
      "code",
      "option",
    ],
    macros: katexMacros,
    throwOnError: false,
  });
}

// document$ 由 Material 主题提供，兼容「instant loading」无刷新跳转
if (typeof document$ !== "undefined") {
  document$.subscribe(renderMath);
} else {
  document.addEventListener("DOMContentLoaded", renderMath);
}
