"""%sym / %%sym -- 把 Octave 的運算結果用 LaTeX 渲染。

octave_kernel 只對「圖」走 rich display，其餘一律當純文字送出，所以在
notebook 裡只會看到 ASCII/Unicode 拼出來的排版。這個 magic 改走同資料夾的
to_latex() 取得 LaTeX 原始碼，再用 IPython 的 Math 顯示。

to_latex() 支援三種型別：sym 運算式、數值矩陣／向量（含複數）、以及
control 套件的 tf/ss 模型，所以本章每個範例的結果都能渲染。

參數可以是變數名，也可以是任意 Octave 運算式，例如：
    %sym eig(A)
    %sym A*M - M*LAMBDA
"""

from IPython.display import Math
from metakernel import Magic


class SymLatexMagic(Magic):

    def _render(self, expr):
        expr = expr.strip().rstrip(";").strip()
        if not expr:
            return
        out = self.kernel.octave_engine.eval(
            "disp(to_latex(%s))" % expr, silent=True)
        tex = (out or "").strip()
        # 第一次載入 symbolic 套件會印一行 banner，濾掉非 LaTeX 的雜訊
        lines = [l for l in tex.splitlines()
                 if l.strip() and not l.startswith("Symbolic pkg")]
        tex = "\n".join(lines).strip()
        if not tex or "error" in tex.lower():
            self.kernel.Error(
                "%%sym: 無法取得 '%s' 的 LaTeX。"
                "請確認 to_latex.m 在同資料夾、且該變數已經算出來了（要先跑計算那格）。"
                "Octave 回應：%s" % (expr, tex or "(空)"))
            return
        self.kernel.Display(Math(tex))

    def line_sym(self, expr):
        r"""
        %sym EXPR - 把 symbolic 運算式以 LaTeX 渲染

        Example:
            %sym Ez
        """
        self._render(expr)

    def cell_sym(self):
        r"""
        %%sym - 每行一個 symbolic 運算式，逐一以 LaTeX 渲染

        Example:
            %%sym
            Ez
            roc
        """
        for line in self.code.splitlines():
            self._render(line)
        self.evaluate = False


def register_magics(kernel):
    kernel.register_magics(SymLatexMagic)
