class TransitionalMode < Requirement
  fatal true

  satisfy { !Tab.for_name("camlp5-606").include?("strict") }

  def message; <<-EOS.undent
    camlp5 must be compiled in transitional mode (instead of --strict mode):
      brew install camlp5
    EOS
  end
end

class Coq83 < Formula
  desc "Proof assistant for higher-order logic"
  homepage "https://coq.inria.fr/"
  url "https://coq.inria.fr/distrib/V8.3pl5/files/coq-8.3pl5.tar.gz"
  version "8.3pl5"
  sha256 "89d185fa3e0d3620703ad4b723ef85695ce427da6235fe91d74fc22d1ffcfd5d"

  depends_on TransitionalMode
  depends_on "objective-caml312"
  depends_on "camlp5-606"

  def install
    camlp5_lib = "#{Formula["camlp5-606"].lib}/ocaml/camlp5"
    system "./configure", "-prefix", prefix,
                          "-mandir", man,
                          "-camlp5dir", camlp5_lib,
                          "-emacslib", "#{lib}/emacs/site-lisp",
                          "-coqdocdir", "#{share}/coq/latex",
                          "-coqide", "no",
                          "-with-doc", "no"
    # Otherwise "mkdir bin" can be attempted by more than one job
    ENV.j1
    system "make", "world"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    Coq's Emacs mode is installed into
      #{lib}/emacs/site-lisp

    To use the Coq Emacs mode, you need to put the following lines in
    your .emacs file:
      (setq auto-mode-alist (cons '("\\.v$" . coq-mode) auto-mode-alist))
      (autoload 'coq-mode "coq" "Major mode for editing Coq vernacular." t)
    EOS
  end

  test do
    system bin/"coqc", "-v"
  end
end
