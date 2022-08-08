(local DEBUG false)

(fn log [...]
  (when DEBUG
    (print "[nvim-antifennel] " ...)))

(fn assert-exists [path]
  (when DEBUG
    (assert (vim.loop.fs_access path :R))))

(fn create-file [filename text]
  (local handle (assert (io.open filename :w+)))
  (handle:write text)
  (handle:close))

(fn antifennel-script []
  (local {: source} (debug.getinfo 1))
  (local dirname (string.sub source 2 (* (string.len :/lua/antifennel.lua) -1)))
  (local sep (package.config:sub 1 1))
  (local path (.. dirname (.. :vendor sep :antifennel)))
  (assert-exists path)
  path)

(fn strip-trailing-newlines [str]
  (var ret str)
  ;; Loop because both stdout and antifennel include a trailing newline.
  (while (= "\n" (ret:sub -1))
    (set ret (ret:sub 1 -2)))
  ret)

(fn run-antifennel [filename start-line end-line]
  (local stdout (vim.loop.new_pipe))
  (local stderr (vim.loop.new_pipe))

  (fn on-stdout [?err ?data]
    ;; TODO: Need to handle buffered stdout
    (log (: "on-stdout() with err %s, data %s" :format ?err ?data))
    (when (not= nil ?data)
      (local lines (vim.split (strip-trailing-newlines ?data) "\n"))
      (vim.schedule (fn []
                      ;; Delete existing lines
                      (vim.api.nvim_buf_set_lines 0 start-line end-line true [])
                      ;; Insert text at `start-line`
                      (vim.api.nvim_buf_set_lines 0 start-line start-line true
                                                  lines)))))

  (fn on-stderr [?err ?data]
    (log (: "on-stderr() with err %s, data %s" :format ?err ?data)))

  (fn on-exit [code signal]
    (log (: "on-exit() with exit code %d, signal %d" :format code signal))
    (when (not= 0 code)
      (log (: "spawn failed (exit code %d, signal %d)" :format code signal)))
    (assert (os.remove filename)))

  (vim.loop.spawn (antifennel-script)
                  {:args [filename] :stdio [nil stdout stderr]} on-exit)
  (vim.loop.read_start stdout on-stdout)
  (vim.loop.read_start stderr on-stderr))

;; TODO: Support charwise selection. (can use nvim_buf_set_text?)
(fn run [start-line end-line]
  (let [;; Make it 0-indexed. Don't adjust `end-line` bc it's end-exclusive.
        start-line (- start-line 1)
        input (vim.api.nvim_buf_get_lines 0 start-line end-line true)
        filename (vim.fn.tempname)]
    (create-file filename (table.concat input "\n"))
    (run-antifennel filename start-line end-line)
    ;; Careful adding code here; `run-antifennel` is async.
    ))

{: run}

