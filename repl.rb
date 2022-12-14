# From https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop:
# A minimal definition is:

# (define (REPL env)
#   (print (eval env (read)))
#   (REPL env) )

# Similar in Ruby:
def read
  $stdin.gets
end

def repl
  print("=> #{eval(read).inspect}\n")
  repl
end

repl