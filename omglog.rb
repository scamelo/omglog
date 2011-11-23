# coding: utf-8

require 'rb-fsevent'

class Object; def tapp; tap { puts inspect } end end

CLEAR = "\e[2J"
YELLOW, BLUE, GREY = 33, 34, 37
SHORTEST_MESSAGE = 12
LOG_CMD = %{git log --all --graph --color --pretty="format:\2 %h\3\2%d\3\2 %an, %ar\3\2 %s\3"}
LOG_REGEX = /(.*)\u0002(.*)\u0003\u0002(.*)\u0003\u0002(.*)\u0003\u0002(.*)\u0003/

# example `git log` output
# "*   \e[33m7c3240d\e[34m (HEAD, origin/master, origin/HEAD, master)\e[m Merge branch 'versions' \e[37m Ben Hoskings, 11 minutes ago\e[m"
# "*   7c3240d  (HEAD, origin/master, origin/HEAD, master) 'Merge branch 'versions'' 'Ben Hoskings' '16 minutes ago'"

def omglog
  `#{LOG_CMD} -$(tput lines)`.tap {|log|
    cols = `tput cols`.chomp.to_i
    puts log.split("\n").map {|l|
      commit = l.scan(LOG_REGEX).flatten.map(&:to_s)
      commit.any? ? render_commit(commit, cols) : l
    }.join("\n")
  }
end

def render_commit commit, cols
  size_commit(commit, cols)
end

def size_commit commit, cols
  lengths = commit.map(&:length)
  length = lengths.inject(&:+)
  message_length = [cols - lengths[0..-2].inject(&:+), SHORTEST_MESSAGE].max
  commit.tap {|commit|
    commit[-1] = if commit[-1].length > message_length
      commit[-1][0...(message_length - 1)] + '…'
    else
      commit[-1]
    end
  }
end

omglog