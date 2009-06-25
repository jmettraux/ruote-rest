
# runs all the tests

dirpath = File.dirname(__FILE__)

ts = Dir.new(dirpath).entries.select { |e| e.match(/^t\_.*\.rb$/) }.sort
  # small tests

fts = Dir.new(dirpath).entries.select { |e| e.match(/^ft\_.*\.rb$/) }.sort
  # functional tests

sts = Dir.new(dirpath).entries.select { |e| e.match(/^st\_.*\.rb$/) }.sort
  # resource tests (can't remember the why of the 's')

(ts + fts + sts).each { |e| load(File.join(dirpath, e)) }

