{
  config,
  lib,
  pkgs,
  ...
}: let
  yaziGlow = pkgs.writeTextFile {
    name = "glow.yazi";
    destination = "/main.lua";
    text = ''
      local M = {}

      function M:peek(job)
      	local child = Command("glow")
      		:args({
      			"--style",
      			"dark",
      			"--width",
      			tostring(job.area.w),
      			tostring(job.file.url),
      		})
      		:env("CLICOLOR_FORCE", "1")
      		:stdout(Command.PIPED)
      		:stderr(Command.PIPED)
      		:spawn()

      	if not child then
      		return require("code").peek(job)
      	end

      	local limit = job.area.h
      	local i, lines = 0, ""
      	repeat
      		local next, event = child:read_line()
      		if event == 1 then
      			return require("code").peek(job)
      		elseif event ~= 0 then
      			break
      		end

      		i = i + 1
      		if i > job.skip then
      			lines = lines .. next
      		end
      	until i >= job.skip + limit

      	child:start_kill()
      	if job.skip > 0 and i < job.skip + limit then
      		ya.manager_emit("peek", { math.max(0, i - limit), only_if = job.file.url, upper_bound = true })
      	else
      		lines = lines:gsub("\t", string.rep(" ", PREVIEW.tab_size))
      		ya.preview_widgets(job, { ui.Text.parse(lines):area(job.area) })
      	end
      end

      function M:seek(job)
      	require("code").seek(job, job.units)
      end

      return M
    '';
  };
  yaziHexyl = pkgs.writeTextFile {
    name = "hexyl.yazi";
    destination = "/main.lua";
    text = ''
      local M = {}

      function M:peek(job)
      	local child
      	local l = self.file.cha.len
      	if l == 0 then
      		child = Command("hexyl")
      			:args({
      				tostring(job.file.url),
      			})
      			:stdout(Command.PIPED)
      			:stderr(Command.PIPED)
      			:spawn()
      	else
      		child = Command("hexyl")
      			:args({
      				"--border",
      				"none",
      				"--terminal-width",
      				tostring(job.area.w),
      				tostring(job.file.url),
      			})
      			:stdout(Command.PIPED)
      			:stderr(Command.PIPED)
      			:spawn()
      	end

      	local limit = job.area.h
      	local i, lines = 0, ""
      	repeat
      		local next, event = child:read_line()
      		if event == 1 then
      			ya.err(tostring(event))
      		elseif event ~= 0 then
      			break
      		end

      		i = i + 1
      		if i > job.skip then
      			lines = lines .. next
      		end
      	until i >= job.skip + limit

      	child:start_kill()
      	if job.skip > 0 and i < job.skip + limit then
      		ya.manager_emit("peek", { math.max(0, i - limit), only_if = job.file.url, upper_bound = true })
      	else
      		lines = lines:gsub("\t", string.rep(" ", PREVIEW.tab_size))
      		ya.preview_widgets(job, { ui.Text.parse(lines):area(job.area) })
      	end
      end

      function M:seek(units)
      	require("code").seek(job, units)
      end

      return M
    '';
  };
  yaziMiller = pkgs.writeTextFile {
    name = "miller.yazi";
    destination = "/main.lua";
    text = ''
      local M = {}

      function M:peek()
      	local child = Command("mlr")
      			:args({
      				"--icsv",
      				"--opprint",
      				"-C",
      				"--key-color",
      				"darkcyan",
      				"--value-color",
      				"grey70",
      				"cat",
      				tostring(self.file.url),
      			})
      			:stdout(Command.PIPED)
      			:stderr(Command.PIPED)
      			:spawn()

      	local limit = self.area.h
      	local i, lines = 0, ""
      	repeat
      		local next, event = child:read_line()
      		if event == 1 then
      			ya.err(tostring(event))
      		elseif event ~= 0 then
      			break
      		end

      		i = i + 1
      		if i > self.skip then
      			lines = lines .. next
      		end
      	until i >= self.skip + limit

      	child:start_kill()
      	if self.skip > 0 and i < self.skip + limit then
      		ya.manager_emit(
      			"peek",
      			{ tostring(math.max(0, i - limit)), only_if = tostring(self.file.url), upper_bound = "" }
      		)
      	else
      		lines = lines:gsub("\t", string.rep(" ", PREVIEW.tab_size))
      		ya.preview_widgets(self, { ui.Paragraph.parse(self.area, lines) })
      	end
      end

      function M:seek(units)
      	local h = cx.active.current.hovered
      	if h and h.url == self.file.url then
      		local step = math.floor(units * self.area.h / 10)
      		ya.manager_emit("peek", {
      			tostring(math.max(0, cx.active.preview.skip + step)),
      			only_if = tostring(self.file.url),
      		})
      	end
      end

      return M
    '';
  };
  smartEnterPlugin = pkgs.writeTextFile {
    name = "smart-enter.yazi";
    destination = "/main.lua";
    text = ''
      --- @sync entry
      return {
        entry = function()
          local h = cx.active.current.hovered
          ya.manager_emit(h and h.cha.is_dir and "enter" or "open", { hovered = true })
        end,
      }
    '';
  };
in {
  home.packages = with pkgs; [
    zoxide
    yazi
    ffmpegthumbnailer
    jq
    poppler
    fzf
    imagemagick
    wl-clipboard
    glow
    hexyl
    miller
    sc-im
  ];

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    plugins = {
      glow = yaziGlow;
      hexyl = yaziHexyl;
      miller = yaziMiller;
      "smart-enter" = smartEnterPlugin;
    };
    settings = {
      manager = {
        ratio = [1 4 3];
        sort_by = "alphabetical";
        sort_sensitive = true;
        sort_reverse = false;
        sort_dir_first = false;
        linemode = "mtime";
        show_hidden = true;
        show_symlink = true;
      };
      preview = {
        tab_size = 2;
        max_width = 600;
        max_height = 900;
        cache_dir = "";
        image_filter = "triangle";
        image_quality = 75;
        sixel_fraction = 15;
        ueberzug_scale = 1;
        ueberzug_offset = [0 0 0 0];
      };
      opener = {
        edit = [
          {
            run = "$EDITOR \"$@\"";
            block = true;
            for = "unix";
          }
          {
            run = "code \"%*\"";
            orphan = true;
            for = "windows";
          }
        ];
        spread = [
          {
            run = "sc-im \"$@\"";
            block = true;
            for = "unix";
          }
          {
            run = "code \"%*\"";
            orphan = true;
            for = "windows";
          }
        ];
        open = [
          {
            run = "xdg-open \"$@\" &";
            desc = "Open";
            for = "linux";
          }
          {
            run = "open \"$@\"";
            desc = "Open";
            for = "macos";
          }
          {
            run = "start \"\" \"%1\"";
            orphan = true;
            desc = "Open";
            for = "windows";
          }
        ];
        reveal = [
          {
            run = "open -R \"$1\"";
            desc = "Reveal";
            for = "macos";
          }
          {
            run = "explorer /select, \"%1\"";
            orphan = true;
            desc = "Reveal";
            for = "windows";
          }
          {
            run = ''exiv2 "$1"; echo "Press enter to exit"; read'';
            block = true;
            desc = "Show EXIF";
            for = "unix";
          }
        ];
        extract = [
          {
            run = "unar \"$1\"";
            desc = "Extract here";
            for = "unix";
          }
          {
            run = "unar \"%1\"";
            desc = "Extract here";
            for = "windows";
          }
        ];
        play = [
          {
            run = "mpv \"$@\"";
            orphan = true;
            for = "unix";
          }
          {
            run = "mpv \"%1\"";
            orphan = true;
            for = "windows";
          }
          {
            run = ''mediainfo "$1"; echo "Press enter to exit"; read'';
            block = true;
            desc = "Show media info";
            for = "unix";
          }
        ];
      };
      open = {
        rules = [
          {
            name = "*/";
            use = ["edit" "open" "reveal"];
          }
          {
            mime = "text/*";
            use = ["edit" "reveal"];
          }
          {
            mime = "image/*";
            use = ["open" "reveal"];
          }
          {
            mime = "video/*";
            use = ["play" "reveal"];
          }
          {
            mime = "audio/*";
            use = ["play" "reveal"];
          }
          {
            mime = "inode/empty";
            use = ["edit" "reveal"];
          }
          {
            mime = "application/json";
            use = ["edit" "reveal"];
          }
          {
            mime = "*/javascript";
            use = ["edit" "reveal"];
          }
          {
            mime = "application/zip";
            use = ["extract" "reveal"];
          }
          {
            mime = "application/gzip";
            use = ["extract" "reveal"];
          }
          {
            mime = "application/tar";
            use = ["extract" "reveal"];
          }
          {
            mime = "application/bzip";
            use = ["extract" "reveal"];
          }
          {
            mime = "application/bzip2";
            use = ["extract" "reveal"];
          }
          {
            mime = "application/7z-compressed";
            use = ["extract" "reveal"];
          }
          {
            mime = "application/rar";
            use = ["extract" "reveal"];
          }
          {
            mime = "application/xz";
            use = ["extract" "reveal"];
          }
          {
            mime = "application/sc";
            use = ["spread" "reveal"];
          }
          {
            mime = "*";
            use = ["open" "reveal"];
          }
        ];
      };
      tasks = {
        micro_workers = 10;
        macro_workers = 25;
        bizarre_retry = 5;
        image_alloc = 536870912; # 512MB
        image_bound = [0 0];
        suppress_preload = false;
      };
      plugin = {
        preloaders = [
          {
            mime = "image/vnd.djvu";
            run = "noop";
          }
          {
            mime = "image/*";
            run = "image";
          }
          {
            mime = "video/*";
            run = "video";
          }
          {
            mime = "application/pdf";
            run = "pdf";
          }
        ];
        previewers = [
          {
            mime = "text/csv";
            run = "miller";
          }
          {
            name = "*.md";
            run = "glow";
          }
          {
            name = "*.org";
            run = "glow";
          }
          {
            name = "*/";
            run = "folder";
            sync = true;
          }
          {
            mime = "text/*";
            run = "code";
          }
          {
            mime = "*/xml";
            run = "code";
          }
          {
            mime = "*/javascript";
            run = "code";
          }
          {
            mime = "*/wine-extension-ini";
            run = "code";
          }
          {
            mime = "application/sc";
            run = "code";
          }
          {
            mime = "application/json";
            run = "json";
          }
          {
            mime = "image/vnd.djvu";
            run = "noop";
          }
          {
            mime = "image/*";
            run = "image";
          }
          {
            mime = "video/*";
            run = "video";
          }
          {
            mime = "application/pdf";
            run = "pdf";
          }
          {
            mime = "application/zip";
            run = "archive";
          }
          {
            mime = "application/gzip";
            run = "archive";
          }
          {
            mime = "application/tar";
            run = "archive";
          }
          {
            mime = "application/bzip";
            run = "archive";
          }
          {
            mime = "application/bzip2";
            run = "archive";
          }
          {
            mime = "application/7z-compressed";
            run = "archive";
          }
          {
            mime = "application/rar";
            run = "archive";
          }
          {
            mime = "application/xz";
            run = "archive";
          }
          {
            name = "*";
            run = "hexyl";
          }
        ];
      };
      select = {
        open_title = "Open with:";
        open_origin = "hovered";
        open_offset = [0 1 50 7];
      };
      log = {
        enabled = false;
      };
    };
  };
  # Add this section to link your custom keymap file
  home.file.".config/yazi/keymap.toml".source = ./keymap.toml;
}
