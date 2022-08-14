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

(fn run-antifennel [filename]
  (local cmd (.. (antifennel-script) " " filename))
  (local lines [])
  (with-open [fh (io.popen cmd)]
    (each [line (fh:lines)]
      (table.insert lines line)))
  ;; Remove last line if it's empty
  (when (= "" (. lines (length lines)))
    (table.remove lines))
  lines)

(fn replace-lines [start-line end-line lines]
  ;; Delete existing lines
  (vim.api.nvim_buf_set_lines 0 start-line end-line true [])
  ;; Insert text at `start-line`
  (vim.api.nvim_buf_set_lines 0 start-line start-line true lines))

;; TODO: Support charwise selection. (can use nvim_buf_set_text?)
(fn run [start-line end-line]
  (let [;; Make it 0-indexed. Don't adjust `end-line` bc it's end-exclusive.
        start-line (- start-line 1)
        input (vim.api.nvim_buf_get_lines 0 start-line end-line true)
        filename (vim.fn.tempname)]
    (create-file filename (table.concat input "\n"))
    (local lines (run-antifennel filename))
    (replace-lines start-line end-line lines)
    (os.remove filename)))

{: run}

