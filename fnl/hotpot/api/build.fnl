(local builder (require :hotpot_build))
(local fennel (let [f (require :hotpot.api.fennel)
                    latest (f.latest)]
                latest))

(fn maybe-load-hotpotfile [file]
  (if (vim.loop.fs_access file :r)
    (fennel.dofile hotpotfile {:env (builder.make-env-proxy)})
    {}))

(fn default-build []
  (local builder (require :hotpot_build))
  (local env (builder.make-env-proxy))
  (env.compile-dir "fnl" "lua"))

(fn build [hotpotfile]
  (local hotpotfile (or hotpotfile "hotpotfile.fnl"))
  (local spec (maybe-load-hotpotfile hotpotfile))
  (if spec.build
    (spec.build)
    (default-build)))

{: build}
