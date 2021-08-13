(local fennel (let [f (require :hotpot.api.fennel)
                   latest (f.latest)]
                   latest))
(assert fennel "hotpot-build requires hotpot!")

(local uv vim.loop)

(fn compile-file [fnl-path lua-path]
  ; take a fnl file, write a lua file
  ; will create dirs for lua-path if they do not exist
  (fn e [...] (.. "hotpot-build#compile-file: " (string.format ...)))

  (assert (string.match fnl-path "%.fnl$") (e "not fnl file: %s" fnl-path))
  (assert (string.match lua-path "%.lua$") (e "not lua file: %s" lua-path))

  (let [path (string.match lua-path "(.+)/.+%.lua$")]
    (vim.fn.mkdir path :p))

  (with-open [f-in (assert (io.open fnl-path :r)
                           (e "could not open in-file: %s" fnl-path))
              f-out (assert (io.open lua-path :w)
                            (e "could not open out-file: %s" lua-path))]
             (print :compile-file fnl-path :-> lua-path)
             ; this can and will spew an error on buid failure
             (local lines (fennel.compile-string (f-in:read "*a")))
             (f-out:write lines)))

(fn compile-dir [in-dir out-dir]
  ; take a dir, recursively find all the .fnl files and compile them
  ; into a mirror'd layout in target dir
  (fn e [...] (.. "hotpot-build#compile-dir: " (string.format ...)))
  (assert (uv.fs_access in-dir :r) (e "%s missing" in-dir))

  (print :compile-dir in-dir :=> out-dir)
  (let [scanner (uv.fs_scandir in-dir)]
    (each [name type #(uv.fs_scandir_next scanner)]
      (match type
        "directory" (do
                      (local out-down (.. out-dir :/ name))
                      (local in-down (.. in-dir :/ name))
                      (vim.fn.mkdir out-down :p)
                      (compile-dir in-down out-down))
        "file" (if (string.match name "%.fnl$")
                 (let [out-file (.. out-dir :/ (string.gsub name ".fnl$" ".lua"))
                       in-file  (.. in-dir :/ name)]
                   (compile-file in-file out-file)))))))


(fn copy-file [from to]
  (print from to))

(fn make-env-proxy []
  ;; Creates an env table containing our own functions,
  ;; but also proxies out to the real _G env.
  ;; We don't want to just insert the functions as globals because they will
  ;; leak outside the build module.
  (local env {: compile-dir
              : compile-file
              : copy-file})
  (setmetatable env {:__index (fn [table key]
                                (or (. _G key) nil))}))

{: make-env-proxy}

