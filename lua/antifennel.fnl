(fn create-file [filename text]
  (local handle (assert (io.open filename :w+)))
  (handle:write text)
  (handle:close))

(fn antifennel-script []
  (local {: source} (debug.getinfo 1))
  (local dirname (string.sub source 2 (* (string.len :/lua/antifennel.lua) -1)))
  (local sep (package.config:sub 1 1))
  (local path (.. dirname (.. :vendor sep :antifennel)))
  path)

(fn replace-lines [start-line end-line lines]
  ;; Remove last line if it's empty
  (when (= "" (. lines (length lines)))
    (table.remove lines))
  ;; Delete existing lines
  (vim.api.nvim_buf_set_lines 0 start-line end-line true [])
  ;; Insert text at `start-line`
  (vim.api.nvim_buf_set_lines 0 start-line start-line true lines))

;; TODO: Support charwise selection. (can use nvim_buf_set_text?)
(fn run [start-line end-line]
  ;; Make it 0-indexed. Don't adjust `end-line` bc it's used as end-exclusive.
  (local start-line (- start-line 1))
  (local tmpfile (vim.fn.tempname))
  (local lua-chunk (-> (vim.api.nvim_buf_get_lines 0 start-line end-line true)
                       (table.concat "\n")))
  (create-file tmpfile lua-chunk)
  ;; NOTE: Not using `io.popen` as it seems to pipe its stderr into nvim's
  ;; stderr, messing up the nvim TUI.
  (local cmd (.. (antifennel-script) " " (vim.fn.shellescape tmpfile)))
  (local lines (vim.fn.systemlist cmd))
  (if (= 0 vim.v.shell_error)
      (replace-lines start-line end-line lines)
      (vim.api.nvim_err_writeln (.. "[nvim-antifennel] "
                                    (table.concat lines "\n"))))
  (os.remove tmpfile))

{: run}

