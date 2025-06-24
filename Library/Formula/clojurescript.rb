class Clojurescript < Formula
  desc "Clojure to JS compiler"
  homepage "https://github.com/clojure/clojurescript"
  url "https://github.com/clojure/clojurescript/releases/download/r1.7.48/cljs.jar"
  version "1.7.48"
  sha256 "91d56866aa0d91b09673598b37f6cc59682b11f79e25cef4b6d058df87cd54b3"
  head "https://github.com/clojure/clojurescript.git"


  def install
    libexec.install "cljs.jar"
    bin.write_jar_script libexec/"cljs.jar", "cljsc"
  end

  def caveats; <<-EOS.undent
    This formula is useful if you need to use the ClojureScript compiler directly.
    For a more integrated workflow, Leiningen with lein-cljsbuild is recommended.
    EOS
  end

  test do
    (testpath/"t.cljs").write <<-EOF.undent
    (ns hello)
    (defn ^:export greet [n]
      (str "Hello " n))
    EOF

    system "#{bin}/cljsc", testpath/"t.cljs"
  end
end
